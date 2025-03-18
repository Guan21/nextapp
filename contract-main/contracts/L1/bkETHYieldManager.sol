// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//
// ===== 各種インターフェース =====
//
//0x3d01b2bc14FC3173907adCaA433D6daa82A80BFE

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface ILido is IERC20 {
    function submit(address referral) external payable returns (uint256);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function isStakingPaused() external view returns (bool);
    function getPooledEthByShares(uint256 shares) external view returns (uint256);
}

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

//
// ===== IYieldManager インターフェース =====
// ETHYieldManager 自身が実装するインターフェースです。
// LidoYieldProvider 内部では availableBalance() などとして利用されます。
//
interface IYieldManager {
    function availableBalance() external view returns (uint256);
    function insurance() external pure returns (address);
    function recordNegativeYield(uint256 negativeYield) external;
}

//
// ===== ETHYieldManager コントラクト =====
// LidoYieldProvider の各関数を delegatecall で呼び出すとともに、
// LidoYieldProvider が想定するストレージレイアウトを下記の通りに再現しています。
//
contract ETHYieldManager is IYieldManager {
    // ── LidoYieldProvider の delegatecall 用ストレージレイアウト ──
    // LidoYieldProvider 側（下記順）の変数に合わせて配置する必要があります。
    // 1. yieldManager (address) … LidoYieldProvider の onlyDelegateCall で利用される（＝呼び出し元のアドレスと一致させる）
    address public yieldManager;
    // 2. stakedPrincipal
    uint256 public stakedPrincipal;
    // 3. pendingBalance
    uint256 public pendingBalance;
    // 4. THIS … LidoYieldProvider 内部で自身のアドレスを参照するための変数
    address public THIS;
    // 5. lastClaimedIndex
    uint256 public lastClaimedIndex;
    // 6. unstakeRequests 配列（先頭はダミー値を格納し、インデックスを 1 から開始する）
    uint256[] public unstakeRequests;
    // ───────────────────────────────────────────────

    // YieldProvider の実装アドレス（LidoYieldProvider のデプロイ済みアドレス）
    address public yieldProviderImplementation;
    
    // イベント
    event NegativeYieldRecorded(uint256 negativeYield);
    event Received(address sender, uint256 amount);
    
    /**
     * @notice コンストラクタ
     * @param _yieldProviderImplementation LidoYieldProvider の実装アドレス
     * コントラクト作成時に、delegatecall 用のストレージを初期化します。
     * また、yieldManager および THIS には本コントラクトのアドレスを設定します。
     */
    constructor(address _yieldProviderImplementation) payable {
        yieldProviderImplementation = _yieldProviderImplementation;
        yieldManager = address(this);
        THIS = address(this);
        unstakeRequests.push(0); // ダミー値（インデックス開始を 1 にするため）
    }
    
    // ETH を受け取るための receive 関数
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    
    // ── IYieldManager インターフェースの実装 ──
    
    function availableBalance() external view override returns (uint256) {
        return address(this).balance;
    }
    
    // 今回は保険機能未実装のため、address(0) を返す
    function insurance() external pure override returns (address) {
        return address(0);
    }
    
    function recordNegativeYield(uint256 negativeYield) external override {
        emit NegativeYieldRecorded(negativeYield);
    }
    
    // ── LidoYieldProvider の各関数を delegatecall 経由で呼び出す関数群 ──
    
    function initializeYieldProvider(IYieldManager _yieldManager) external {
        (bool success, ) = yieldProviderImplementation.delegatecall(
            abi.encodeWithSignature("initialize(address)", address(_yieldManager))
        );
        require(success, "initialize delegatecall failed");
    }
    
    function stake(uint256 amount) external {
        (bool success, ) = yieldProviderImplementation.delegatecall(
            abi.encodeWithSignature("stake(uint256)", amount)
        );
        require(success, "stake delegatecall failed");
    }
    
    /**
     * @notice ETHYieldManager の資金をアンステークする
     * @param amount アンステークする金額
     * @return pending アンステーク遅延中の金額、claimed 直ちに出金可能な金額（本実装例では pending のみ）
     */
    function unstake(uint256 amount) external returns (uint256 pending, uint256 claimed) {
        (bool success, bytes memory result) = yieldProviderImplementation.delegatecall(
            abi.encodeWithSignature("unstake(uint256)", amount)
        );
        require(success, "unstake delegatecall failed");
        (pending, claimed) = abi.decode(result, (uint256, uint256));
    }
    
    function preCommitYieldReportDelegateCallHook() external {
        (bool success, ) = yieldProviderImplementation.delegatecall(
            abi.encodeWithSignature("preCommitYieldReportDelegateCallHook()")
        );
        require(success, "preCommitYieldReport delegatecall failed");
    }
    
    function recordClaimed(uint256 claimed, uint256 expected) external {
        (bool success, ) = yieldProviderImplementation.delegatecall(
            abi.encodeWithSignature("recordClaimed(uint256,uint256)", claimed, expected)
        );
        require(success, "recordClaimed delegatecall failed");
    }
    
    function payInsurancePremium(uint256 amount) external {
        (bool success, ) = yieldProviderImplementation.delegatecall(
            abi.encodeWithSignature("payInsurancePremium(uint256)", amount)
        );
        require(success, "payInsurancePremium delegatecall failed");
    }
    
    function withdrawFromInsurance(uint256 amount) external {
        (bool success, ) = yieldProviderImplementation.delegatecall(
            abi.encodeWithSignature("withdrawFromInsurance(uint256)", amount)
        );
        require(success, "withdrawFromInsurance delegatecall failed");
    }
    
    // ── LidoYieldProvider の view 関数（staticcall） ──
    
    function stakedBalance() external view returns (uint256) {
        (bool success, bytes memory result) = yieldProviderImplementation.staticcall(
            abi.encodeWithSignature("stakedBalance()")
        );
        require(success, "stakedBalance staticcall failed");
        return abi.decode(result, (uint256));
    }
    
    function yield() external view returns (int256) {
        (bool success, bytes memory result) = yieldProviderImplementation.staticcall(
            abi.encodeWithSignature("yield()")
        );
        require(success, "yield staticcall failed");
        return abi.decode(result, (int256));
    }
    
    function isStakingEnabled(address token) external view returns (bool) {
        (bool success, bytes memory result) = yieldProviderImplementation.staticcall(
            abi.encodeWithSignature("isStakingEnabled(address)", token)
        );
        require(success, "isStakingEnabled staticcall failed");
        return abi.decode(result, (bool));
    }
    
    function insuranceBalance() external view returns (uint256) {
        (bool success, bytes memory result) = yieldProviderImplementation.staticcall(
            abi.encodeWithSignature("insuranceBalance()")
        );
        require(success, "insuranceBalance staticcall failed");
        return abi.decode(result, (uint256));
    }
}
