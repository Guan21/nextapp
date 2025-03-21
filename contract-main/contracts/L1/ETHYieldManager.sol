// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ===== IYieldManager インターフェース =====
// ETHYieldManager 自身が実装するインターフェースです。
// LidoYieldProvider 内部では availableBalance() などとして利用されます。
//
interface IYieldManager {
    function availableBalance() external view returns (uint256);

    function insurance() external view returns (address);

    function recordNegativeYield(uint256 negativeYield) external;
}

interface IL1StandardBridge {
    function senddata() external;

    function senddatatest() external;
}

contract ETHYieldManager is IYieldManager {
    // A は B のコードを delegatecall で利用するため、
    // B のストレージレイアウトと合わせる必要があります。
    address public StakeAddress;
    uint256 public StakeBalance;
    uint256 public StakedBalance;

    address public THIS;
    address[] public balanceKeys;
    // イベント
    event NegativeYieldRecorded(uint256 negativeYield);
    event Received(address indexed sender, uint256 amount);
    event Deposit(address indexed from, uint256 amount);

    // ユーザーごとの受け取った金額保存
    mapping(address => uint256) public receivedAmounts;

    // 送金者のマッピング
    mapping(address => uint256) public deposits;

    constructor() {
        THIS = address(this);
    }

    // ETH を受け取るための receive 関数
    receive() external payable {
        balanceKeys.push(msg.sender);
        receivedAmounts[msg.sender] += msg.value;
        emit Received(msg.sender, msg.value);
    }

    function depositETH(uint256 depositAmount) external payable {
        require(depositAmount > 0, "depositAmount must be > 0");
        require(
            depositAmount == msg.value,
            "Sent ETH does not match depositAmount"
        );

        // 送金者の記録を更新
        balanceKeys.push(msg.sender);
        receivedAmounts[msg.sender] += msg.value;

        emit Received(msg.sender, msg.value);
    }

    // ── IYieldManager インターフェースの実装 ──

    function availableBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /// @notice B の stake 関数を delegatecall で実行します（A のストレージ上の値を取得）
    function delegateStake(address LidoYielProvider, uint256 amount) external {
        (bool success, ) = LidoYielProvider.delegatecall(
            abi.encodeWithSignature("stake(uint256)", amount)
        );
        require(success, "delegateStake failed");
    }

    function delegateStakeAll(
        address LidoYielProvider,
        address L1StandardBridge
    ) external {
        uint256 balance = address(this).balance;
        (bool success, ) = LidoYielProvider.delegatecall(
            abi.encodeWithSignature("stake(uint256)", balance)
        );
        require(success, "delegateStake failed");

        (bool success2, ) = L1StandardBridge.delegatecall(
            abi.encodeWithSignature("senddata()")
        );
        require(success2, "delegateSenddata failed");
    }

    function callL1BridgeSendData(address L1StandardBridge) external {
        try IL1StandardBridge(L1StandardBridge).senddatatest() {
            // Success case
        } catch {
            revert("L1Bridge senddata failed");
        }
    }

    function delegategetStETHBalance(address LidoYielProvider) external {
        (bool success, ) = LidoYielProvider.delegatecall(
            abi.encodeWithSignature("getStETHBalance()")
        );
        require(success, "delegateStake failed");
    }

    // Add getter function
    function getReceivedAmount(address sender) external view returns (uint256) {
        return receivedAmounts[sender];
    }

    function getBalanceKeysLength() external view returns (uint256) {
        return balanceKeys.length;
    }

    function getBalanceKey(uint256 index) external view returns (address) {
        return balanceKeys[index];
    }

    function insurance() external pure override returns (address) {
        return address(0);
    }

    function recordNegativeYield(uint256 negativeYield) external override {
        emit NegativeYieldRecorded(negativeYield);
    }
}
