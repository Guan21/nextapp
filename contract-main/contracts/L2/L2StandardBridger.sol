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

contract L2StandardBridge is ERC20 {
    address public l1DepositContractAddress; // L1のDepositContractのアドレス 
    address public l2CrossDomainMessengerAddress; // L2のCrossDomainMessengerのアドレス 0x4200000000000000000000000000000000000007

    constructor(
        address _l1DepositContractAddress,
        address _l2CrossDomainMessengerAddress
    ) ERC20("Bridge Test Token", "DCETH") {
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

    function mintTokenslist(
        address[] calldata to,
        uint256[] memory amount
    ) external {
        require(
            msg.sender == l2CrossDomainMessengerAddress,
            "Only the L2 CrossDomainMessenger can trigger minting" // L2のCrossDomainMessengerからのみ呼び出し可能
        );

        require(
            IL2CorssDomainMessenger(l2CrossDomainMessengerAddress)
                .xDomainMessageSender() == l1DepositContractAddress,
            "Only the L1 deposit contract can trigger minting" // L1のDepositContractからのみ呼び出し可能
        );

        for (uint256 i = 0; i < to.length; i++) {
            _mint(to[i], amount[i]);
        }
    }
}
