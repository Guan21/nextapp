import Web3 from "web3";
import dotenv from 'dotenv';
import { LIDO_ABI } from "../ABI/Lido";
import { WITHDRAWAL_QUEUE_ABI } from "../ABI/Withdrawalqueue";
dotenv.config({ path: '../.env.local' });

const LIDO_ADDRESS = "0x3F1c547b21f65e10480dE3ad8E19fAAC46C95034"
const WITHDRAWAL_QUEUE_ADDRESS = "0xc7cc160b58F8Bb0baC94b80847E2CF2800565C50"

// https://eips.ethereum.org/EIPS/eip-2612 permit action is nessessary
// then call requestWithdrawalsWithPermit
// 参照動きログ
// https://holesky.etherscan.io/tx/0x7c058efc3032108c41586ac2330067ab136905d4ff9239d97f3486c74111a2fe#eventlog

async function requestWithdrawal() {
    const amount = '0.03';
    // Infuraのエンドポイントを設定
    try {
        const web3 = new Web3(process.env.NEXT_PUBLIC_RPC_holesky_URL as string);
        console.log(process.env.NEXT_PUBLIC_RPC_holesky_URL);
        console.log(process.env.PRIVATE_KEY);

        // アカウントをプライベートキーから作成
        const formattedPrivateKey = `0x${process.env.PRIVATE_KEY as string}`;
        console.log(formattedPrivateKey);
        const account = web3.eth.accounts.privateKeyToAccount(formattedPrivateKey);
        web3.eth.accounts.wallet.add(account);
        web3.eth.defaultAccount = account.address;

        // Lidoコントラクトのインスタンスを作成
        const withdrawalContract = new web3.eth.Contract(WITHDRAWAL_QUEUE_ABI, WITHDRAWAL_QUEUE_ADDRESS);
        const stETHContract = new web3.eth.Contract(LIDO_ABI, LIDO_ADDRESS);

        // 1. Approve transaction
        const approveTx = await stETHContract.methods.approve(
            WITHDRAWAL_QUEUE_ADDRESS,
            web3.utils.toWei(amount, 'ether')
        ).send({ from: account.address });

        // 2. Wait for approval confirmation
        console.log('Approval transaction hash:', approveTx.transactionHash);
        await web3.eth.getTransactionReceipt(approveTx.transactionHash);

        const allowance = web3.utils.fromWei(await stETHContract.methods.allowance(
            account.address,
            WITHDRAWAL_QUEUE_ADDRESS
        ).call(), 'ether');
        // console.log('Current allowance:', web3.utils.fromWei(allowance, 'ether'));

        // 4. Request withdrawal after approval
        if (parseFloat(allowance) > 0) {
            const tx = await withdrawalContract.methods.requestWithdrawals(
                [web3.utils.toWei(amount, 'ether')],
                account.address
            ).send({ from: account.address });
            console.log('Withdrawal transaction hash:', tx.transactionHash);
        }

    } catch (error) {
        console.error('トランザクションに失敗しました:', error);
    }
}

// スクリプトを実行
requestWithdrawal();