import Web3 from "web3";
import dotenv from 'dotenv';
import { LIDO_ABI } from "../ABI/Lido";
dotenv.config({ path: '../.env.local' });

const LIDO_ADDRESS = "0x3F1c547b21f65e10480dE3ad8E19fAAC46C95034"
async function getsharestETH() {
    try {
        const web3 = new Web3(process.env.NEXT_PUBLIC_RPC_holesky_URL as string);
        console.log(process.env.NEXT_PUBLIC_RPC_holesky_URL);

        const formattedPrivateKey = `0x${process.env.PRIVATE_KEY as string}`;
        console.log(formattedPrivateKey);
        const account = web3.eth.accounts.privateKeyToAccount(formattedPrivateKey);
        web3.eth.accounts.wallet.add(account);
        web3.eth.defaultAccount = account.address;

        const lidoContract = new web3.eth.Contract(LIDO_ABI, LIDO_ADDRESS);
        const stETHBalance = await lidoContract.methods.balanceOf(account.address).call();

        console.log(stETHBalance);
        console.log(typeof stETHBalance);
        if (stETHBalance && typeof stETHBalance === 'bigint') {
            console.log('stETH Balance:', web3.utils.fromWei(stETHBalance, 'ether'));
        } else {
            console.error('Failed to retrieve stETH balance');
        }

        const stETHshareBalance = await lidoContract.methods.sharesOf(account.address).call();
        if (stETHshareBalance && typeof stETHshareBalance === 'bigint') {
            console.log('stETH share Balance:', web3.utils.fromWei(stETHshareBalance, 'ether'));
        } else {
            console.error('Failed to retrieve stETH balance');
        }

    } catch (error) {
        console.error('トランザクションに失敗しました:', error);
    }
}

// スクリプトを実行
getsharestETH();