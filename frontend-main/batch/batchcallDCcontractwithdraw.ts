import Web3 from "web3";
import dotenv from 'dotenv';
import { DCcontract_ABI } from "../ABI/DCstakecontract";
import { DCcontractwithdraw_ABI } from "../ABI/DCstakecontractwithdraw";
dotenv.config({ path: '../.env.local' });

const DCcontract = "0xdcB31bf51b0BffAEa0BefB0bE741f3dd3B6B1CE8"
// 0xdcB31bf51b0BffAEa0BefB0bE741f3dd3B6B1CE8 withdraw and claim機能追加
// 0x473A17F2Ef4DC726cc591C76f283238016c80629 withdraw機能追加
// 0xCb11cF8d73FA40c3b768c8E5bdCF9984D3049a88 ログ機能追加

// 0x18Defb7Da0420AD7815F1d7279272aE4E2F81957 誰でも送金できる

// 0xbad2D24ca51a3196C6492de9aB26f89AC5D508D9
// 送金transaction: 0xbd8403e1ccf90123c0ca43adc54f36e3a4622fc8831d5958c94c6ba0610116e4

async function stakeWithLido() {
    // Infuraのエンドポイントを設定
    const web3 = new Web3(process.env.NEXT_PUBLIC_RPC_holesky_URL as string);

    // アカウントをプライベートキーから作成
    const formattedPrivateKey = `0x${process.env.PRIVATE_KEY as string}`;

    const account = web3.eth.accounts.privateKeyToAccount(formattedPrivateKey);
    web3.eth.accounts.wallet.add(account);
    web3.eth.defaultAccount = account.address;

    // Lidoコントラクトのインスタンスを作成
    const testContract = new web3.eth.Contract(DCcontractwithdraw_ABI, DCcontract);

    const depositAmount = Web3.utils.toWei('0.001', 'ether');

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
