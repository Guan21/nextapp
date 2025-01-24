"use client";

import { useState } from "react";
import styles from "./styles/Layout.module.css";
import { connectWallet, sendTransaction, transactionCallback } from "../actions/stake";
import { stETH } from "../actions/stETH";
import { transfor } from "../actions/transfor";
import { withdrawfunction, callback } from "../actions/withdraw"
import { AccountValue } from "@lidofinance/lido-ethereum-sdk/core";
import { TOKEN_OPTIONS, TokenType } from "../constants/tokenOptions";

const Home = () => {
  const [account, setAccount] = useState<string | null>(null);
  const [recipient, setRecipient] = useState<string>("");
  const [amount, setAmount] = useState<string>("");
  const [transactionHash, setTransactionHash] = useState<string | null>(null);
  const [balanceETH, setBalanceETH] = useState<string | null>(null);
  const [transforresult, setTransforresult] = useState<string | null>(null);
  const [token, setToken] = useState<TokenType>('stETH');
  const [withdrawHash, setWithdrawHash] = useState<string | null>(null)

  return (
    <div className={styles.container}>
      <h1>Lido Stake インターフェース</h1>

      {/* ウォレット接続ボタン */}
      <button className={styles.walletButton} onClick={() => connectWallet(setAccount)}>
        {!account ? "ウォレット接続" : `接続済み: ${account.substring(0, 6)}...`}
      </button>

      {/* 中央に配置された送金フォーム */}
      <div className={styles.formContainer}>
        <h2 className={styles.formTitle}>ステークフォーム</h2>
        <div className={styles.inputGroup}>
          <label htmlFor="recipient">ステークアドレス:</label>
          <input
            id="recipient"
            type="text"
            placeholder="送信先アドレス"
            value={recipient}
            onChange={(e) => setRecipient(e.target.value)}
          />
        </div>
        <div className={styles.inputGroup}>
          <label htmlFor="amount">ステーク額 (ETH):</label>
          <input
            id="amount"
            type="number"
            placeholder="送金額 (ETH)"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
          />
        </div>
        <button
          className={`${styles.sendButton} ${!account && styles.disabledButton}`}
          onClick={() => sendTransaction(recipient, amount, transactionCallback, setTransactionHash)}
          disabled={!account}
        >
          staking
        </button>
      </div>

      {/* トランザクションハッシュ表示 */}
      {transactionHash && (
        <div className={styles.transactionContainer}>
          <h3>トランザクションハッシュ:</h3>
          <p>{transactionHash}</p>
        </div>
      )}

      {/* stETH残高表示 */}
      <div className={styles.formContainer}>
        <button
          className={`${styles.sendButton} ${!account && styles.disabledButton}`}
          onClick={() => stETH(account as string, setBalanceETH)}
          disabled={!account}
        >
          stETH残高確認
        </button>
        {balanceETH && (
          <div className={styles.stETHContainer}>
            <h3>stETH残高:</h3>
            <p>{balanceETH} stETH</p>
          </div>
        )}
      </div>

      {/* stETH遷移フォーム */}
      <div className={styles.formContainer}>
        <h2 className={styles.formTitle}>transfor</h2>
        <div className={styles.inputGroup}>
          <label htmlFor="recipient">送信先アドレス:</label>
          <input
            id="recipient"
            type="text"
            placeholder="送信先アドレス"
            value={recipient}
            onChange={(e) => setRecipient(e.target.value)}
          />
        </div>
        <div className={styles.inputGroup}>
          <label htmlFor="amount">ステーク額 (ETH):</label>
          <input
            id="amount"
            type="number"
            placeholder="送金額 (ETH)"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
          />
        </div>
        <button
          className={`${styles.sendButton} ${!account && styles.disabledButton}`}
          onClick={() => transfor(recipient, amount, setTransforresult)}
          disabled={!account}
        >
          transfor
        </button>
        {transforresult && (
          <div className={styles.stETHContainer}>
            <p>{transforresult}</p>
          </div>
        )}
      </div>

      {/* Withdraw ETH遷移フォーム */}
      <div className={styles.formContainer}>
        <h2 className={styles.formTitle}>Withdraw</h2>
        <div className={styles.inputGroup}>
          <label htmlFor="recipient">withdraw ETH type</label>
          <select
            id="recipient"
            value={token}
            onChange={(e) => setToken(e.target.value as TokenType)}
            className="w-full p-2 border rounded"
          >
            {TOKEN_OPTIONS.map(option => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </div>
        <div className={styles.inputGroup}>
          <label htmlFor="amount">ステーク額 (ETH):</label>
          <input
            id="amount"
            type="number"
            placeholder="送金額 (ETH)"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
          />
        </div>
        <button
          className={`${styles.sendButton} ${!account && styles.disabledButton}`}
          onClick={() => account && withdrawfunction(account as AccountValue, amount, token, callback, setWithdrawHash)}
          disabled={!account}
        >
          withdraw {token}
        </button>
        {withdrawHash && (
          <div className={styles.stETHContainer}>
            <p>{withdrawHash}</p>
          </div>
        )}
      </div>


    </div>
  );
};

export default Home;
