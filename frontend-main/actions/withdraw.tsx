import {
    LidoSDK,
    SDKError,
} from '@lidofinance/lido-ethereum-sdk';
import { AccountValue, LidoSDKCore, TransactionCallback, TransactionCallbackStage } from "@lidofinance/lido-ethereum-sdk/core";

export const callback: TransactionCallback = ({ stage, payload }) => {
    switch (stage) {
        case TransactionCallbackStage.PERMIT:
            console.log('wait for permit');
            break;
        case TransactionCallbackStage.GAS_LIMIT:
            console.log('wait for gas limit');
            break;
        case TransactionCallbackStage.SIGN:
            console.log('wait for sign');
            break;
        case TransactionCallbackStage.RECEIPT:
            console.log('wait for receipt');
            console.log(payload, 'transaction hash');
            break;
        case TransactionCallbackStage.CONFIRMATION:
            console.log('wait for confirmation');
            console.log(payload, 'transaction receipt');
            break;
        case TransactionCallbackStage.DONE:
            console.log('done');
            console.log(payload, 'transaction confirmations');
            break;
        case TransactionCallbackStage.MULTISIG_DONE:
            console.log('multisig_done');
            console.log(payload, 'transaction confirmations');
            break;
        case TransactionCallbackStage.ERROR:
            console.log('error');
            console.log(payload, 'error object with code and message');
            break;
        default:
    }
};

export const withdrawfunction = async (
    account: AccountValue,
    amount: string,
    token: 'stETH' | 'wstETH',
    callback: TransactionCallback,
    setWithdrawHash: (hash: string) => void
) => {
    if (!window.ethereum) {
        alert("MetaMaskがインストールされていません！");
        return;
    }

    try {
        const lidoSDK = new LidoSDK({
            chainId: 17000,
            rpcUrls: [process.env.REACT_APP_INFURA_URL as string],
            web3Provider: LidoSDKCore.createWeb3Provider(17000, window.ethereum),
        });

        const requestTx = await lidoSDK.withdraw.request.requestWithdrawalWithPermit({
            account,
            amount,
            token, // 'stETH' | 'wstETH'
            callback,
        });

        setWithdrawHash(requestTx.hash);
        alert("トランザクション送信成功！");

        console.log(
            'transaction hash, transaction receipt, confirmations',
            requestTx,
            'transcation hash',
            requestTx.hash,
        );
    } catch (error) {
        console.log((error as SDKError).errorMessage, (error as SDKError).code);
    }
};
