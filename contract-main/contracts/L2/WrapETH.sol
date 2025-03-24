// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AbstractMyToken} from "./AbERC20.sol";

contract WETH is AbstractMyToken {
    // トークンの基本情報
    string public name;
    string public symbol;
    uint8 public decimals = 18; // 一般的なERC20の小数点以下桁数

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

    // コンストラクタ：トークン名、シンボルの設定と初期供給量のmint
    constructor() {
        name = "Wrapped Ether";
        symbol = "WETH";
    }

    function wrap(address[] calldata to, uint256[] calldata amount) external {
        for (uint256 i = 0; i < to.length; i++) {
            if (balanceOf(to[i]) > 0) {
                uint256 increaseamount = amount[i] - balanceOf(to[i]);
                if (increaseamount > 0) {
                    _mint(to[i], increaseamount);
                    emit TokenValueAdjusted(to[i], increaseamount);
                }
            } else {
                _mint(to[i], amount[i]);
                emit TokenValueAdjusted(to[i], amount[i]);
            }
        }
    }

    function withdraw(address from, uint256 amount) external {
        _burn(from, amount);
        emit TokenValueAdjusted(from, balanceOf(from));
    }

    // 必要に応じて transfer 関数をオーバーライドして独自ロジックを追加可能
    function transferFromTokens(
        address from,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        // 例として、独自のログ出力や追加チェックを実施可能
        return transferFrom(from, recipient, amount);
    }

    function approveTokensfortransfer(
        address owner,
        address spender,
        uint256 amount
    ) external returns (uint256) {
        _approveTokens(owner, spender, amount);
        return allowance(owner, spender);
    }
}
