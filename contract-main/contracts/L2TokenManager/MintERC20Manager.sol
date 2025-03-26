// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICustomToken {
    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);
}

contract TokenManager {
    ICustomToken public token;
    // address public admin;

    struct TransferRecord {
        address from;
        address to;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => TransferRecord[]) private transferHistory;

    event TokenValueAdjusted(address indexed account, uint256 newBalance);
    event TokensTransferred(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 timestamp
    );

    constructor(address tokenAddress) {
        token = ICustomToken(tokenAddress);
        // admin = address(this);
    }

    // EOAのトークンを増加（価値調整）
    function increaseTokenValue(address account, uint256 amount) external {
        token.mint(account, amount);
        emit TokenValueAdjusted(account, token.balanceOf(account));
    }

    // EOAのトークンを減少（価値調整）
    function decreaseTokenValue(address account, uint256 amount) external {
        require(token.balanceOf(account) >= amount, "Insufficient balance");
        token.burn(account, amount);
        emit TokenValueAdjusted(account, token.balanceOf(account));
    }

    // EOA間のトークン送金（EOAは直接送れない）
    function transferTokens(address from, address to, uint256 amount) external {
        require(token.balanceOf(from) >= amount, "Insufficient balance");
        token.burn(from, amount);
        token.mint(to, amount);

        transferHistory[from].push(
            TransferRecord(from, to, amount, block.timestamp)
        );
        emit TokensTransferred(from, to, amount, block.timestamp);
    }

    function getTransferHistory(
        address user
    ) external view returns (TransferRecord[] memory) {
        return transferHistory[user];
    }

    // EOAの残高を取得（フロントエンドから呼び出し可能）
    function getTokenBalance(address account) external view returns (uint256) {
        return token.balanceOf(account);
    }
}
