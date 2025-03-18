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

    // 初期設定時のデフォルトETHYieldManagerアドレス（必要に応じて変更してください）
    // IYieldManager public ETHYieldManager = IYieldManager(0x6Fc280cb465D218f3D6dd12C7D6e4279495e7f67);

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
}
