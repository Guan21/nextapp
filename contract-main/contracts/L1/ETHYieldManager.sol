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
    function sendstakedata() external;

    function burnL2Tokens(address from, uint256 amount) external;
}

contract ETHYieldManager is IYieldManager {
    // ETHYieldManager は LidoYieldProvider のコードを delegatecall で利用するため、
    // LidoYieldProvider のストレージレイアウトと合わせる必要があります。
    address public StakeAddress;
    uint256 public StakeBalance;
    uint256 public LidoYieldStakedBalance;
    uint256 public StakedAllBalance;
    uint256 public paidStETH;

    address public THIS;
    address[] public balanceKeys;
    address[] public transactions;
    address[] public paymentkeys;
    
    // イベント
    event NegativeYieldRecorded(uint256 negativeYield);
    event Received(address indexed sender, uint256 amount);
    event Deposit(address indexed from, uint256 amount);
    event Payment(address indexed sender, uint256 amount);

    // ユーザーごとの受け取った金額保存
    mapping(address => uint256) public receivedAmounts;
    // 重複登録を防ぐためのmapping
    mapping(address => bool) private isRecorded;
    // 利子分配の受け取った金額保存
    mapping(address => uint256) public paymentAmounts;
    // 重複登録を防ぐためのmapping
    mapping(address => bool) private paymentisRecorded;

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
        require(msg.sender != THIS, "this is not ETHyield");

        // 送金者の記録を更新
        transactions.push(msg.sender);
        if (!isRecorded[msg.sender]) {
            balanceKeys.push(msg.sender);
            isRecorded[msg.sender] = true;
        }
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
        try IL1StandardBridge(L1StandardBridge).sendstakedata() {
            // Success case
        } catch {
            revert("L1Bridge senddata failed");
        }

        uint256 balance = address(this).balance;
        (bool success, ) = LidoYielProvider.delegatecall(
            abi.encodeWithSignature("stake(uint256)", balance)
        );
        require(success, "delegateStake failed");

    }

    function callL1BridgeSendPaymentData(address L1StandardBridge) external {
        try IL1StandardBridge(L1StandardBridge).sendstakedata() {
            // Success case
        } catch {
            revert("L1Bridge senddata failed");
        }
    }

    function callL1BridgeBurnTokens(
        address L1StandardBridge,
        address from,
        uint256 amount
    ) external {
        try IL1StandardBridge(L1StandardBridge).burnL2Tokens(from, amount) {
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

    function getTransactionNumber() external view returns (uint256) {
        return transactions.length;
    }

    function insurance() external pure override returns (address) {
        return address(0);
    }

    function recordNegativeYield(uint256 negativeYield) external override {
        emit NegativeYieldRecorded(negativeYield);
    }

    function getYieldStETH() external view returns (uint256) {
        return LidoYieldStakedBalance - StakedAllBalance - paidStETH;

    }

    function getPaymentAmount(address sender) external view returns (uint256) {
        return paymentAmounts[sender];
    }

    function getPaymentKeysLength() external view returns (uint256) {
        return paymentkeys.length;
    }

    function getPaymentKey(uint256 index) external view returns (address) {
        return paymentkeys[index];
    }

    function getBalanceKeysLengthPure() external view returns (uint256) {
        uint256 count = 0;
        uint256 len = this.getBalanceKeysLength();
        for (uint256 i = 0; i < len; i++) {
            if (this.getBalanceKey(i) != address(0)) {
                count++;
            }
        }
        return count;
    }

    function intersetPaymentMemory(address distibutiontarget, uint256 amount) external returns(bool) {
        uint256 payablepayment = this.getYieldStETH();
        require(payablepayment > amount, "not enough payments");
        if (!paymentisRecorded[distibutiontarget]) {
            paymentkeys.push(distibutiontarget);
            paymentisRecorded[distibutiontarget] = true;
        }
        if (!isRecorded[distibutiontarget]) {
            balanceKeys.push(distibutiontarget);
            isRecorded[distibutiontarget] = true;
        }
        paymentAmounts[distibutiontarget] += amount;
        receivedAmounts[distibutiontarget] += amount;
        paidStETH += amount;
        emit Payment(distibutiontarget, amount);
        return true;
    }
}
