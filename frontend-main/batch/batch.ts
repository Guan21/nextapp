import Web3 from "web3";
import dotenv from 'dotenv';
import { LIDO_ABI } from "../ABI/Lido";
dotenv.config({ path: '../.env.local' });

const LIDO_ADDRESS = "0x3F1c547b21f65e10480dE3ad8E19fAAC46C95034"

async function stakeWithLido() {
    // Infuraのエンドポイントを設定
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
    const lidoContract = new web3.eth.Contract(LIDO_ABI, LIDO_ADDRESS);

    // トランザクションデータを作成
    const data = lidoContract.methods.submit(process.env.WALLET_ADDRESS as string).encodeABI();

    // トランザクションのパラメータを設定
    const tx = {
        from: account.address,
        to: LIDO_ADDRESS,
        value: web3.utils.toWei('0.1', 'ether'), // ステークするETHの量
        gas: 200000, // 適切なガスリミットを設定
        data: data
    };

    try {
        // トランザクションに署名して送信
        const receipt = await web3.eth.sendTransaction(tx);
        console.log('トランザクションが成功しました:', receipt);
    } catch (error) {
        console.error('トランザクションに失敗しました:', error);
    }
}

// スクリプトを実行
stakeWithLido();