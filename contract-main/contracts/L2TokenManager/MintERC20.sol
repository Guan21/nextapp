// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CustomToken is ERC20, Ownable {
    address public manager; // コントラクトB

    event ManagerChanged(address indexed newManager);

    // onlyDelegateCall
    modifier onlyManager() {
        require(address(this) == manager, "Not the manager");
        _;
    }

    constructor(
        address initialOwner
    ) ERC20("CustomToken", "DDD") Ownable(initialOwner) {
        manager = initialOwner; // 初期管理者はコントラクトBに設定
    }

    // コントラクトBを管理者に設定
    function setManager(address _manager) external onlyOwner {
        require(_manager != address(0), "Invalid manager address");
        manager = _manager;
        emit ManagerChanged(_manager);
    }

    // 指定EOAにトークンを発行（コントラクトBのみ実行可能）
    function mint(address account, uint256 amount) external onlyManager {
        _mint(account, amount);
    }

    // 指定EOAのトークンを削減（コントラクトBのみ実行可能）
    function burn(address account, uint256 amount) external onlyManager {
        _burn(account, amount);
    }

    // EOAが直接トークンを送金できないようにtransfer/transferFromをオーバーライド
    // function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
    //     require(from == address(0) || msg.sender == manager, "Transfers not allowed");
    //     super._beforeTokenTransfer(from, to, amount);
    // }
    // function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
    //     require(from == address(0) || msg.sender == manager, "Transfers not allowed");
    // }

    // function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
    //     require(from == address(0) || msg.sender == manager, "Transfers not allowed");
    //     super._beforeTokenTransfer(from, to, amount);
    // }
}
