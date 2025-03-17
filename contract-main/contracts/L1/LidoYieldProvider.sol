// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

// --- minimal IERC20 インターフェース ---
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

// --- IYieldManager の簡易インターフェース ---
interface IYieldManager {
    function availableBalance() external view returns (uint256);
    function insurance() external view returns (address);
    function recordNegativeYield(uint256 negativeYield) external;
}

// --- ILido インターフェース ---
interface ILido is IERC20 {
    function submit(address referral) external payable returns (uint256);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function isStakingPaused() external view returns (bool);
    function getPooledEthByShares(uint256 shares) external view returns (uint256);
}

// --- IWithdrawalQueue インターフェース ---
interface IWithdrawalQueue {
    function getLastCheckpointIndex() external view returns (uint256);
    function findCheckpointHints(
        uint256[] calldata _requestIds,
        uint256 _firstIndex,
        uint256 _lastIndex
    ) external view returns (uint256[] memory hintIds);
    function requestWithdrawals(uint256[] calldata _amounts, address _owner) external returns (uint256[] memory requestIds);
    function claimWithdrawals(uint256[] calldata _requestIds, uint256[] calldata _hints) external;
    function getWithdrawalStatus(uint256[] calldata _requestIds)
        external
        view
        returns (WithdrawalRequestStatus[] memory statuses);
}

// --- IInsurance インターフェース ---
interface IInsurance {
    function coverLoss(address token, uint256 amount) external;
}

/// @notice Lido の WithdrawalQueueBase から引用された withdrawal status 用構造体
struct WithdrawalRequestStatus {
    uint256 amountOfStETH;
    uint256 amountOfShares;
    address owner;
    uint256 timestamp;
    bool isFinalized;
    bool isClaimed;
}

// --- エラー定義 ---
error InsufficientStakableFunds();
error CallerIsNotYieldManager();
error ContextIsNotYieldManager();
error NotSupported();

// 0x04d07e8759f1ef10692F18A0dad4fA57c3D1bcE3
/// @title LidoYieldProvider
/// @notice Lido (ETH) イールドソース用のプロバイダー（delegatecall 経由で YieldManager から利用）
contract LidoYieldProvider {
    // 定数アドレス（Sepolia 用例）
    ILido public constant LIDO = ILido(0x8f6254332f69557A72b0DA2D5F0Bc07d4CA991E7);
    IWithdrawalQueue public constant WITHDRAWAL_QUEUE =
        IWithdrawalQueue(0x1583C7b3f4C3B008720E6BcE5726336b0aB25fdd);
    // 定数アドレス（holesky 用例）
    // ILido public constant LIDO = ILido(0x3F1c547b21f65e10480dE3ad8E19fAAC46C95034);
    // IWithdrawalQueue public constant WITHDRAWAL_QUEUE =
    //     IWithdrawalQueue(0x3F1c547b21f65e10480dE3ad8E19fAAC46C95034);

    // YieldManager を表すインターフェース（delegatecall 時は YieldManager の文脈で実行される）
    IYieldManager public yieldManager;
    // YieldProvider 由来の会計用変数
    uint256 public stakedPrincipal;
    uint256 public pendingBalance;

    // 自身のデプロイ先アドレス（delegatecall 時は yieldManager の文脈となるため）
    address public immutable THIS;
    uint256 public constant claimBatchSize = 10;

    // アンステークリクエストの記録（先頭はダミーとして 0 を配置し、インデックスを 1 から開始）
    uint256[] public unstakeRequests;
    uint256 public lastClaimedIndex;

    // --- イベント ---
    event LidoUnstakeInitiated(uint256 indexed requestId, uint256 amount);
    event Staked(bytes32 indexed provider, uint256 amount);
    event Unstaked(bytes32 indexed provider, uint256 amount);
    event Pending(bytes32 indexed provider, uint256 amount);
    event Claimed(bytes32 indexed provider, uint256 claimedAmount, uint256 expectedAmount);
    event InsurancePremiumPaid(bytes32 indexed provider, uint256 amount);
    event InsuranceWithdrawn(bytes32 indexed provider, uint256 amount);

    // --- モディファイア ---
    modifier onlyYieldManager() {
        if (msg.sender != address(yieldManager)) {
            revert CallerIsNotYieldManager();
        }
        _;
    }

    /// @dev このモディファイアは、delegatecall により YieldManager のコンテキストで実行されることを要求する
    modifier onlyDelegateCall() {
        if (address(this) == address(yieldManager)) {
            // 本来、delegatecall 時は address(this) が yieldManager となる
            _;
        } else {
            revert ContextIsNotYieldManager();
        }
    }

    constructor() {
        THIS = address(this);
        // ダミーリクエストを追加（unstakeRequests[0] = 0）
        unstakeRequests.push(0);
    }

    /// @notice 初期化処理（delegatecall 経由で YieldManager から呼ばれる）
    function initialize(IYieldManager _yieldManager) external {
        require(address(yieldManager) == address(0), "Already initialized");
        require(address(_yieldManager) != address(this), "invalid yieldManager");
        yieldManager = _yieldManager;
        // Lido 側に対し、WithdrawalQueue および YieldManager（のアドレス）への無制限承認を実施
        LIDO.approve(address(WITHDRAWAL_QUEUE), type(uint256).max);
        LIDO.approve(address(yieldManager), type(uint256).max);
    }

    /// @notice プロバイダー名称
    function name() public pure returns (string memory) {
        return "LidoYieldProvider";
    }

    /// @notice プロバイダー識別子（名称の keccak256 ハッシュ）
    function id() public pure returns (bytes32) {
        return keccak256(abi.encodePacked(name()));
    }

    /// @notice 対象トークンがステーキング可能か（Lido の場合、LIDO トークンかつステーキング停止でないこと）
    function isStakingEnabled(address token) public view returns (bool) {
        return (token == address(LIDO)) && (!LIDO.isStakingPaused());
    }

    /// @notice YieldManager 側におけるステーク済み残高（Lido の stETH 残高）
    function stakedBalance() public view returns (uint256) {
        return LIDO.balanceOf(address(yieldManager));
    }

    /// @notice 前回コミット時との yield 差分（int256 に変換して計算）
    function yield() public view returns (int256) {
        // SafeCast の代わりに直接 int256 へ変換（値が int256 の範囲内である前提）
        return int256(stakedBalance()) - int256(stakedPrincipal);
    }

    /// @notice yield 保険の支払いをサポートするか
    function supportsInsurancePayment() public view returns (bool) {
        return yieldManager.insurance() != address(0);
    }

    /// @notice YieldManager の資金を Lido にステークする（delegatecall 経由で呼ばれる）
    function stake(uint256 amount) external onlyDelegateCall {
        if (amount > yieldManager.availableBalance()) {
            revert InsufficientStakableFunds();
        }
        // Lido.submit により ETH を送付；リファラは 0 アドレスとする
        LIDO.submit{value: amount}(address(0));
    }

    /// @notice YieldManager の資金をアンステークする（delegatecall 経由で呼ばれる）
    /// @return pending アンステーク遅延中の金額、claimed 直ちに出金可能な金額（本実装では pending のみ）
    function unstake(uint256 amount) external onlyDelegateCall returns (uint256 pending, uint256 claimed) {
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        uint256 requestId = WITHDRAWAL_QUEUE.requestWithdrawals(amounts, address(yieldManager))[0];
        // 自身のデプロイ済みコントラクトを介してリクエスト ID を記録
        LidoYieldProvider(THIS).enqueueUnstakeRequest(requestId);
        emit LidoUnstakeInitiated(requestId, amount);

        pending = amount;
        claimed = 0;
    }

    /// @notice アンステークリクエスト ID を記録（YieldManager 経由で呼ばれる）
    function enqueueUnstakeRequest(uint256 lidoRequestId) external onlyYieldManager {
        unstakeRequests.push(lidoRequestId);
    }

    /// @notice 最後にクレーム済みとしたインデックスを更新（YieldManager 経由で呼ばれる）
    function setLastClaimedIndex(uint256 index) external onlyYieldManager {
        lastClaimedIndex = index;
    }

    /// @notice 外部からクレーム結果を記録するための関数（YieldManager 経由で呼ばれる）
    function recordClaimed(uint256 claimed, uint256 expected) external onlyYieldManager {
        _recordClaimed(claimed, expected);
    }

    /// @dev 内部処理：クレーム済み金額の記録。pendingBalance を expected 分減算し、イベントを発行する。
    function _recordClaimed(uint256 claimed, uint256 expected) internal {
        require(claimed <= expected, "invalid yield provider implementation");
        pendingBalance -= expected;
        emit Claimed(id(), claimed, expected);
    }

    /// @notice YieldManager の delegatecall フック：クレーム処理を実行
    function preCommitYieldReportDelegateCallHook() external onlyDelegateCall {
        _claim();
    }

    /// @notice Lido の withdrawal request をクレーム処理する（delegatecall 経由で YieldManager から呼ばれる）
    /// @return claimed クレームにより入金された金額、expected クレーム対象の stETH 総額
    function _claim() internal onlyDelegateCall returns (uint256 claimed, uint256 expected) {
        uint256 _lastClaimedIndex = lastClaimedIndex;
        uint256 lastRequestIndex = unstakeRequests.length - 1;

        if (_lastClaimedIndex == lastRequestIndex) {
            // クレーム対象がない場合
            return (0, 0);
        }
        require(_lastClaimedIndex < lastRequestIndex, "invalid claim index");

        uint256 firstIndex = _lastClaimedIndex + 1;
        uint256 lastIndex = (lastRequestIndex - _lastClaimedIndex) > claimBatchSize
            ? firstIndex + claimBatchSize - 1
            : lastRequestIndex;

        uint256 arrayLength = lastIndex - firstIndex + 1;
        uint256[] memory requestIds = new uint256[](arrayLength);
        for (uint256 idx = firstIndex; idx <= lastIndex; idx++) {
            requestIds[idx - firstIndex] = unstakeRequests[idx];
        }

        WithdrawalRequestStatus[] memory statuses = WITHDRAWAL_QUEUE.getWithdrawalStatus(requestIds);

        uint256 claimableCount = 0;
        // ここでは "j" を利用
        for (uint256 j = 0; j < statuses.length; j++) {
            if (!(statuses[j].isFinalized && !statuses[j].isClaimed)) {
                break;
            }
            expected += statuses[j].amountOfStETH;
            claimableCount++;
        }
        uint256 lastClaimableIndex = _lastClaimedIndex + claimableCount;
        if (lastClaimableIndex == _lastClaimedIndex) {
            return (0, 0);
        }

        uint256 balanceBefore = address(yieldManager).balance;

        uint256[] memory claimableRequestIds = new uint256[](claimableCount);
        for (uint256 j = 0; j < claimableCount; j++) {
            claimableRequestIds[j] = requestIds[j];
        }

        uint256[] memory hintIds = WITHDRAWAL_QUEUE.findCheckpointHints(
            claimableRequestIds,
            1,
            WITHDRAWAL_QUEUE.getLastCheckpointIndex()
        );

        lastClaimedIndex = lastClaimableIndex;
        WITHDRAWAL_QUEUE.claimWithdrawals(claimableRequestIds, hintIds);

        claimed = address(yieldManager).balance - balanceBefore;
        _recordClaimed(claimed, expected);
        uint256 negativeYield = expected > claimed ? expected - claimed : 0;
        if (negativeYield > 0) {
            yieldManager.recordNegativeYield(negativeYield);
        }
    }


    /// @notice yield 保険料の支払い（delegatecall 経由で YieldManager から呼ばれる）
    function payInsurancePremium(uint256 amount) external onlyDelegateCall {
        if (!supportsInsurancePayment()) {
            revert NotSupported();
        }
        // 保険対象の yieldManager へ stETH を送付
        LIDO.transfer(yieldManager.insurance(), amount);
        emit InsurancePremiumPaid(id(), amount);
    }

    /// @notice yield 損失を補填するための保険資金の引出（delegatecall 経由で YieldManager から呼ばれる）
    function withdrawFromInsurance(uint256 amount) external onlyDelegateCall {
        if (!supportsInsurancePayment()) {
            revert NotSupported();
        }
        IInsurance(yieldManager.insurance()).coverLoss(address(LIDO), amount);
        emit InsuranceWithdrawn(id(), amount);
    }

    /// @notice 保険残高（yieldManager.insurance() が保有する LIDO 残高）
    function insuranceBalance() public view returns (uint256) {
        return LIDO.balanceOf(yieldManager.insurance());
    }
}
