// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IL2CorssDomainMessenger {
    function xDomainMessageSender() external view returns (address);

    function sendMessage(
        address target,
        bytes calldata message,
        uint32 gasLimit
    ) external;
}

interface IWrapETH {
    function wrap(address[] calldata to, uint256[] calldata amount) external;

    function withdraw(address from, uint256 amount) external;
}

contract L2StandardBridge {
    address public l1DepositContractAddress; // L1のDepositContractのアドレス
    address public l2CrossDomainMessengerAddress; // L2のCrossDomainMessengerのアドレス 0x4200000000000000000000000000000000000007
    address public WrapETHAddress;

    constructor(
        address _l1DepositContractAddress,
        address _l2CrossDomainMessengerAddress
    ) {
        l1DepositContractAddress = _l1DepositContractAddress;
        l2CrossDomainMessengerAddress = _l2CrossDomainMessengerAddress;
    }

    function set_WrapETHContract(address _WrapETHAddress) external {
        WrapETHAddress = _WrapETHAddress;
    }

    function mintTokens(
        address[] calldata to,
        uint256[] calldata amount
    ) external {
        // require(
        //     msg.sender == l2CrossDomainMessengerAddress,
        //     "Only the L2 CrossDomainMessenger can trigger minting" // L2のCrossDomainMessengerからのみ呼び出し可能
        // );

        require(
            IL2CorssDomainMessenger(l2CrossDomainMessengerAddress)
                .xDomainMessageSender() == l1DepositContractAddress,
            "Only the L1 deposit contract can trigger minting" // L1のDepositContractからのみ呼び出し可能
        );

        IWrapETH(WrapETHAddress).wrap(to, amount); // WrapETHのwrap関数を呼び出し
        emit ReceiveStakelist(IL2CorssDomainMessenger(l2CrossDomainMessengerAddress).xDomainMessageSender(),WrapETHAddress, "wrap", to, amount);
    }

    function burnTokens(address from, uint256 amount) external {
        // require(
        //     msg.sender == l2CrossDomainMessengerAddress,
        //     "Only the L2 CrossDomainMessenger can trigger burning" // L2のCrossDomainMessengerからのみ呼び出し可能
        // );

        require(
            IL2CorssDomainMessenger(l2CrossDomainMessengerAddress)
                .xDomainMessageSender() == l1DepositContractAddress,
            "Only the L1 deposit contract can trigger burning" // L1のDepositContractからのみ呼び出し可能
        );

        IWrapETH(WrapETHAddress).withdraw(from, amount); // WrapETHのwithdraw関数を呼び出し
        emit ReceiveBurnMessage(IL2CorssDomainMessenger(l2CrossDomainMessengerAddress).xDomainMessageSender(), WrapETHAddress, "withdraw", from, amount);
    }

    event ReceiveStakelist(
        address messengersenderaddress,
        address sendtargetaddress,
        string functionname,
        address[] keys,
        uint256[] values
    );

    event ReceiveBurnMessage(
        address messengersenderaddress,
        address sendtargetaddress,
        string functionname,
        address key,
        uint256 value
    );
}
