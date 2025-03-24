// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
}

// --- IYieldManager の簡易インターフェース ---
interface IYieldManager {
    function availableBalance() external view returns (uint256);

    function insurance() external view returns (address);

    function recordNegativeYield(uint256 negativeYield) external;
}

interface ILido is IERC20 {
    function submit(address referral) external payable returns (uint256);

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) external returns (bool);

    function isStakingPaused() external view returns (bool);

    function getPooledEthByShares(
        uint256 shares
    ) external view returns (uint256);
}

// --- IInsurance インターフェース ---
interface IInsurance {
    function coverLoss(address token, uint256 amount) external;
}

// --- IWithdrawalQueue インターフェース ---
interface IWithdrawalQueue {
    function getLastCheckpointIndex() external view returns (uint256);

    function findCheckpointHints(
        uint256[] calldata _requestIds,
        uint256 _firstIndex,
        uint256 _lastIndex
    ) external view returns (uint256[] memory hintIds);

    function requestWithdrawals(
        uint256[] calldata _amounts,
        address _owner
    ) external returns (uint256[] memory requestIds);

    function claimWithdrawals(
        uint256[] calldata _requestIds,
        uint256[] calldata _hints
    ) external;

    function getWithdrawalStatus(
        uint256[] calldata _requestIds
    ) external view returns (WithdrawalRequestStatus[] memory statuses);
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

contract LidoYieldProvider {
    // 任意の初期設定値
    address public StakeAddress;
    uint256 public StakeBalance;
    uint256 public StakedBalance;

    // ETHYieldManager を表すインターフェース（delegatecall 時は ETHYieldManager の文脈で実行される）
    // B の実装アドレス
    IYieldManager public ETHYieldManager;
    // // YieldProvider 由来の会計用変数
    uint256 public stakedPrincipal;
    // uint256 public pendingBalance;

    // // 自身のデプロイ先アドレス（delegatecall 時は yieldManager の文脈となるため）
    // address public immutable self;
    // uint256 public constant claimBatchSize = 10;

    // // アンステークリクエストの記録（先頭はダミーとして 0 を配置し、インデックスを 1 から開始）
    // uint256[] public unstakeRequests;
    // uint256 public lastClaimedIndex;

    // 定数アドレス（Sepolia 用例）
    ILido public constant LIDO =
        ILido(0x3e3FE7dBc6B4C189E7128855dD526361c49b40Af);
    IWithdrawalQueue public constant WITHDRAWAL_QUEUE =
        IWithdrawalQueue(0x1583C7b3f4C3B008720E6BcE5726336b0aB25fdd);

    // onlyDelegateCall モディファイア:
    // 直接 B を呼び出した場合は、address(this) != ETHYieldManagerアドレス となるためリバートさせます。
    modifier onlyETHYieldManagerDelegateCall() {
        require(
            address(this) == address(ETHYieldManager),
            "guest call not allowed"
        );
        _;
    }

    constructor(address _ETHYieldManager) {
        ETHYieldManager = IYieldManager(_ETHYieldManager);
    }

    // 初期設定なし
    function initialize() external {}

    /// @notice プロバイダー名称
    function name() public pure returns (string memory) {
        return "LidoYieldProvider";
    }

    /// @notice プロバイダー識別子（名称の keccak256 ハッシュ）
    function id() public pure returns (bytes32) {
        return keccak256(abi.encodePacked(name()));
    }

    /// @notice ETHYieldManager 側におけるステーク済み残高（Lido の stETH 残高）
    function stakedBalance() public view returns (uint256) {
        return LIDO.balanceOf(address(ETHYieldManager));
    }

    /// @notice 前回コミット時との yield 差分（int256 に変換して計算）
    function yield() public view returns (int256) {
        // SafeCast の代わりに直接 int256 へ変換（値が int256 の範囲内である前提）
        return int256(stakedBalance()) - int256(stakedPrincipal);
    }

    /// @notice yield 保険の支払いをサポートするか
    function supportsInsurancePayment() public view returns (bool) {
        return ETHYieldManager.insurance() != address(0);
    }

    // stake関数
    function stake(uint256 amount) public onlyETHYieldManagerDelegateCall {
        StakeBalance = amount;
        LIDO.submit{value: amount}(address(0));
    }

    /*** HELPER FUNCTIONS ***/
    function getStETHBalance() public onlyETHYieldManagerDelegateCall {
        StakeAddress = address(this);
        StakedBalance = LIDO.balanceOf(address(this));
    }

    // /*** WITHDRAWAL FUNCTIONS ***/
    // /**
    //  * @notice ユーザーが stETH を引き出す (WithdrawalQueue にリクエストを作成)
    //  * @param amount 引き出したい stETH の数量(wei単位)
    //  */
    // function withdrawStakedETH(uint256 amount) external {
    //     // deposit のみで制御しているが、コントラクトが本当に stETH を持っているか要注意
    //     require(deposits[msg.sender] >= amount, "Insufficient stake");

    //     // WithdrawalQueue に stETH を引き出してもらうため、まず approve が必要
    //     bool approved = stETH.approve(address(withdrawalQueue), amount);
    //     require(approved, "Approval failed");

    //     uint256[] memory amounts = new uint256[](1);
    //     amounts[0] = amount;

    //     // Lido側へのwithdrawリクエストを送る
    //     uint256[] memory requestIds = withdrawalQueue.requestWithdrawals(
    //         amounts,
    //         msg.sender // リクエストが完了した際、ETH受取アドレスはユーザー
    //     );

    //     // ユーザー毎にリクエストIDを追跡
    //     withdrawalRequests[msg.sender] = requestIds;

    //     // Deposit記録を減算（厳密には、コントラクト残高内のstETHをUserごとに割り当てしている想定）
    //     deposits[msg.sender] -= amount;
    // }

    // /**
    //  * @notice ユーザーがfinalized(完了)したWithdrawalを受け取る
    //  *         （WithdrawalQueueのclaimWithdrawalsを呼ぶ）
    //  */
    // function claimWithdrawnETH() external {
    //     uint256[] memory requestIds = withdrawalRequests[msg.sender];
    //     require(requestIds.length > 0, "No pending withdrawals");

    //     bool[] memory readyStatus = checkWithdrawalStatus(requestIds);

    //     // 引き出し可能なリクエストの個数をカウント
    //     uint256 readyCount = 0;
    //     for (uint i = 0; i < readyStatus.length; i++) {
    //         if (readyStatus[i]) readyCount++;
    //     }
    //     require(readyCount > 0, "No requests ready for claim");

    //     // finalizedなリクエストのみを抽出
    //     uint256[] memory finalizedRequestIds = new uint256[](readyCount);
    //     uint256 currentIndex = 0;
    //     for (uint i = 0; i < requestIds.length; i++) {
    //         if (readyStatus[i]) {
    //             finalizedRequestIds[currentIndex] = requestIds[i];
    //             currentIndex++;
    //         }
    //     }

    //     // コントラクトではなくユーザー自身のアドレスにETHが送られる
    //     withdrawalQueue.claimWithdrawals(finalizedRequestIds);

    //     // 未完了リクエストだけを再保存
    //     uint256[] memory remainingRequests = new uint256[](
    //         requestIds.length - readyCount
    //     );
    //     currentIndex = 0;
    //     for (uint i = 0; i < requestIds.length; i++) {
    //         if (!readyStatus[i]) {
    //             remainingRequests[currentIndex] = requestIds[i];
    //             currentIndex++;
    //         }
    //     }

    //     // リクエストが全て残っていない場合は初期化
    //     if (remainingRequests.length > 0) {
    //         withdrawalRequests[msg.sender] = remainingRequests;
    //     } else {
    //         delete withdrawalRequests[msg.sender];
    //     }

    //     emit WithdrawalsClaimed(msg.sender, finalizedRequestIds);
    // }
}
