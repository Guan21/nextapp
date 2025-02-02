import Web3 from "web3";
import dotenv from 'dotenv';
import { WITHDRAWAL_QUEUE_ABI } from "../ABI/Withdrawalqueue";
dotenv.config({ path: '../.env.local' });

const WITHDRAWAL_QUEUE_ADDRESS = "0xc7cc160b58F8Bb0baC94b80847E2CF2800565C50"

interface Withdrawalresult {
    amountOfStETH: bigint;
    amountOfShares: bigint;
    owner: string;
    timestamp: bigint;
    isFinalized: boolean;
    isClaimed: boolean;
}

const checkIfBothTrue = (data: Withdrawalresult): boolean => {
    return data.isFinalized && data.isClaimed;
};


async function requestWithdrawalRequstID() {
    try {
        const web3 = new Web3(process.env.NEXT_PUBLIC_RPC_holesky_URL as string);
        console.log(process.env.NEXT_PUBLIC_RPC_holesky_URL);

        const formattedPrivateKey = `0x${process.env.PRIVATE_KEY as string}`;
        console.log(formattedPrivateKey);
        const account = web3.eth.accounts.privateKeyToAccount(formattedPrivateKey);
        web3.eth.accounts.wallet.add(account);
        web3.eth.defaultAccount = account.address;

        const withdrawalContract = new web3.eth.Contract(WITHDRAWAL_QUEUE_ABI, WITHDRAWAL_QUEUE_ADDRESS);

        const getWithdrawalRequestsIDs: unknown[] = await withdrawalContract.methods.getWithdrawalRequests(process.env.WALLET_ADDRESS).call();
        console.log('Withdrawal Requests:', getWithdrawalRequestsIDs);

        if (Array.isArray(getWithdrawalRequestsIDs) && getWithdrawalRequestsIDs.length > 0) {
            await withdrawalContract.methods.getWithdrawalStatus(getWithdrawalRequestsIDs).call().then((result: any) => {
                console.log('Withdrawal Status:', result);
            });
        }
        const requestId = 12472; // 必ず数値型
        const requestIdBigInt = BigInt(requestId);
        // claim withdrawl ETH
        // await withdrawalContract.methods.claimWithdrawal(requestIdBigInt).send({ from: account.address });
        // requestId状態確認
        const WithdrawalStatusResult = await withdrawalContract.methods.getWithdrawalStatus([requestIdBigInt]).call().then((result: any) => {
            console.log('Withdrawal Status:', result);
            return result;
        });

        const result = WithdrawalStatusResult.map((data: Withdrawalresult) => ({
            owner: data.owner,
            bothTrue: checkIfBothTrue(data)
        }));
        console.log(result);

    } catch (error) {
        console.error('トランザクションに失敗しました:', error);
    }
}

requestWithdrawalRequstID();