import Web3 from "web3";
import dotenv from 'dotenv';
import { testcontract_ABI } from "../ABI/testcontract";
dotenv.config({ path: '../.env.local' });

const testcontract = "0x9347e99CdcE0bF42aB40BB7C39cE13AC8A267195"

async function stakeWithLido() {
    // Infuraのエンドポイントを設定
    const web3 = new Web3(process.env.NEXT_PUBLIC_RPC_holesky_URL as string);

    // アカウントをプライベートキーから作成
    const formattedPrivateKey = `0x${process.env.PRIVATE_KEY as string}`;

    const account = web3.eth.accounts.privateKeyToAccount(formattedPrivateKey);
    web3.eth.accounts.wallet.add(account);
    web3.eth.defaultAccount = account.address;

    // Lidoコントラクトのインスタンスを作成
    const testContract = new web3.eth.Contract(testcontract_ABI, testcontract);

    const depositAmount = Web3.utils.toWei('0.01', 'ether');

    try {

        // トランザクションの送信
        const tx = await testContract.methods.depositETH(depositAmount).send({
            from: account.address,
            value: depositAmount,
            gas: '200000' // ガスリミットは適宜調整
        });

        console.log('Transaction successful:', tx.transactionHash);
    } catch (error) {
        console.error('Error:', error);
    }
}

// スクリプトを実行
stakeWithLido();
