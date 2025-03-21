// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICrossDomainMessenger {
    function xDomainMessageSender() external view returns (address);

    function sendMessage(
        address target,
        bytes calldata message,
        uint32 gasLimit
    ) external;
}

// DataStorage コントラクトが提供するインターフェース
interface IETHYieldManager {
    // balances はアドレス毎の uint256 を返す
    function getReceivedAmount(address) external view returns (uint256);

    // balanceKeys は index を指定してアドレスを返す（自動生成 getter）
    function getBalanceKey(uint256 index) external view returns (address);

    // 別途、キー配列の長さを取得する関数を実装しておく必要があります
    function getBalanceKeysLength() external view returns (uint256);
}

contract L1StandardBridge {
    // ETH Sepolia crossDomainManager - L1 0x58Cc85b8D04EA49cC6DBd3CbFFd00B4B8D6cb3ef
    // OP Sepolia crossDomainManager - L2 0x4200000000000000000000000000000000000007

    // 既存のストレージ変数
    address public immutable CrossDomainManager;
    address public targetL2Contract;

    mapping(address => string) public greetings;

    IETHYieldManager public ETHYieldManager;

    constructor(address _crossDomainManager, address _ETHYieldManager) {
        CrossDomainManager = _crossDomainManager;
        ETHYieldManager = IETHYieldManager(_ETHYieldManager);
    }

    function set_targetL2Contract(address _targetL2Contract) external {
        targetL2Contract = _targetL2Contract;
    }

    function set(address sender, string calldata greeting) external {
        require(msg.sender == CrossDomainManager, "Not messenger");
        require(
            ICrossDomainMessenger(CrossDomainManager).xDomainMessageSender() ==
                targetL2Contract,
            "Not authorized"
        );
        greetings[sender] = greeting;
    }

    // Stake情報送信
    function senddata() external {
        // require(msg.sender == address(ETHYieldManager), "Not ETHYieldManager");
        uint256 len = ETHYieldManager.getBalanceKeysLength();
        require(len > 0, "No balance keys found");

        address keys;
        uint256 values;
        // address[] memory keys = new address[](len);
        // uint256[] memory values = new uint256[](len);

        for (uint256 i = 0; i < len; i++) {
            address key = ETHYieldManager.getBalanceKey(i);
            // keys[i] = key    ;
            // values[i] = ETHYieldManager.getReceivedAmount(key);
            keys = key;
            values = ETHYieldManager.getReceivedAmount(key);
        }
        emit SendDetails(
            CrossDomainManager,
            targetL2Contract,
            msg.sender,
            keys,
            values
        );

        // キーと値の配列を ABI エンコードして message にする
        bytes memory message = abi.encodeWithSignature(
            // "mintTokens(address[],uint256[])",
            "mintTokens(address,uint256)",
            keys,
            values
        );

        // gasLimit は実際の環境に合わせて調整してください
        ICrossDomainMessenger(CrossDomainManager).sendMessage(
            targetL2Contract,
            message,
            1000000
        );
    }

    // L2 から送信情報を受け取る
    function get_greeting(
        address sender
    ) external view returns (string memory) {
        return greetings[sender];
    }

    // L1 から情報送信確認
    function sendMessage(string calldata greeting) external {
        ICrossDomainMessenger(CrossDomainManager).sendMessage({
            target: targetL2Contract,
            message: abi.encodeCall(this.set, (msg.sender, greeting)),
            gasLimit: 200000
        });
    }

    // ログ出力用
    event SendDetails(
        address messengerAddress,
        address receiverAddress,
        address sender,
        address keys,
        uint256 values
    );
}
