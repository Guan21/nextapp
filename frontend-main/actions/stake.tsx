"use client";


import { LidoSDK } from "@lidofinance/lido-ethereum-sdk";
import { LidoSDKCore, TransactionCallback, TransactionCallbackStage } from "@lidofinance/lido-ethereum-sdk/core";
import { MetaMaskInpageProvider } from "@metamask/providers";

// Declare the ethereum property on the window object
declare global {
    interface Window {
        ethereum?: MetaMaskInpageProvider;
    }
}

export const connectWallet = async (setAccount: (account: string | null) => void) => {
    if (!window.ethereum) {
        alert("MetaMaskがインストールされていません！");
        return;
    }

    try {
        const accounts = await window.ethereum.request({
            method: "eth_requestAccounts",
        }) as string[];
        if (accounts && accounts.length > 0) {
            setAccount(accounts[0]);
        } else {
            setAccount(null);
        }
    } catch (error) {
        console.error("ウォレット接続エラー:", error);
    }
};

export const sendTransaction = async (
    recipient: string,
    amount: string,
    callback: TransactionCallback,
    setTransactionHash: (hash: string) => void
) => {
    if (!window.ethereum) {
        alert("MetaMaskがインストールされていません！");
        return;
    }

    try {
        let stakeaddress = recipient as `0x${string}`;
        if (!stakeaddress.startsWith("0x")) {
            stakeaddress = `0x${stakeaddress}`;
        }

        const lidoSDK = new LidoSDK({
            chainId: 17000,
            rpcUrls: [process.env.REACT_APP_INFURA_URL as string],
            web3Provider: LidoSDKCore.createWeb3Provider(17000, window.ethereum),
        });

        const stakeTx = await lidoSDK.stake.stakeEth({
            value: amount,
            callback,
            referralAddress: stakeaddress,
        });

        setTransactionHash(stakeTx.hash);
        alert("トランザクション送信成功！");
    } catch (error) {
        console.error("トランザクションエラー:", error);
    }
};

export const transactionCallback: TransactionCallback = ({ stage, payload }) => {
    switch (stage) {
        case TransactionCallbackStage.SIGN:
            console.log("wait for sign");
            break;
        case TransactionCallbackStage.RECEIPT:
            console.log("wait for receipt");
            console.log(payload, "transaction hash");
            break;
        case TransactionCallbackStage.CONFIRMATION:
            console.log("wait for confirmation");
            console.log(payload, "transaction receipt");
            break;
        case TransactionCallbackStage.DONE:
            console.log("done");
            console.log(payload, "transaction confirmations");
            break;
        case TransactionCallbackStage.ERROR:
            console.log("error");
            console.log(payload, "error object with code and message");
            break;
        default:
    }
};
