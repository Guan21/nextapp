// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

abstract contract AbstractMyToken is IERC20 {
    // 状態変数
    uint256 internal _totalSupply;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    // IERC20インターフェースの実装
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    // transfer, transferFrom, approveは下記のように実装
    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        require(
            _allowances[sender][sender] >= amount,
            "AbstractMyToken: transfer amount exceeds allowance"
        );
        _allowances[sender][sender] -= amount;
        _transfer(sender, recipient, amount);
        return true;
    }

    function _approveTokens(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // 内部関数 _transfer に共通カスタムロジックを定義
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(
            _balances[sender] >= amount,
            "AbstractMyToken: insufficient balance"
        );
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    // 内部関数 _mint と _burn の実装
    function _mint(address account, uint256 amount) internal virtual {
        require(
            account != address(0),
            "AbstractMyToken: mint to the zero address"
        );
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(
            account != address(0),
            "AbstractMyToken: burn from the zero address"
        );
        require(
            _balances[account] >= amount,
            "AbstractMyToken: burn amount exceeds balance"
        );
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
}
