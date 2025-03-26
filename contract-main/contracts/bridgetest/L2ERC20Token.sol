// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IL2CorssDomainMessenger {
    function xDomainMessageSender() external view returns (address);

    function sendMessage(
        address target,
        bytes calldata message,
        uint32 gasLimit
    ) external;
}

contract L2ERC20Token is ERC20 {
    address public l1DepositContractAddress; // L1のDepositContractのアドレス
    address public l2CrossDomainMessengerAddress; // L2のCrossDomainMessengerのアドレス

    constructor(
        address _l1DepositContractAddress,
        address _l2CrossDomainMessengerAddress
    ) ERC20("Bridge Test Token", "BTT") {
        l1DepositContractAddress = _l1DepositContractAddress;
        l2CrossDomainMessengerAddress = _l2CrossDomainMessengerAddress;
    }

    function mintTokens(address to, uint256 amount) external {
        require(
            msg.sender == l2CrossDomainMessengerAddress,
            "Only the L2 CrossDomainMessenger can trigger minting" // L2のCrossDomainMessengerからのみ呼び出し可能
        );

        require(
            IL2CorssDomainMessenger(l2CrossDomainMessengerAddress)
                .xDomainMessageSender() == l1DepositContractAddress,
            "Only the L1 deposit contract can trigger minting" // L1のDepositContractからのみ呼び出し可能
        );

        _mint(to, amount);
    }

    function burnAndWithdraw(uint256 amount) external {
        require(amount > 0, "Burn amount must be greater than 0");

        _burn(msg.sender, amount);

        bytes32 requestId = keccak256(
            abi.encodePacked(msg.sender, amount, block.timestamp)
        );

        bytes memory data = abi.encodeWithSignature(
            "initiateWithdraw(bytes32,address,uint256)",
            requestId,
            msg.sender,
            amount
        );

        // L2CrossDomainMessengerProxyを経由してL1にメッセージ送信
        IL2CorssDomainMessenger(l2CrossDomainMessengerAddress).sendMessage({
            target: l1DepositContractAddress,
            message: data,
            gasLimit: 5000000 // L1のガスリミット
        });

        emit BurnAndWithdrawInitiated(requestId, msg.sender, amount);
    }

    event BurnAndWithdrawInitiated(
        bytes32 indexed requestId,
        address indexed requester,
        uint256 amount
    );
}
