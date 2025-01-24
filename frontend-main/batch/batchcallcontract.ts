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

    /**
     * Estimated gas: 23581n
        トランザクションに失敗しました: TransactionRevertInstructionError: Transaction has been reverted by the EVM
        at <anonymous> (E:\github\nextapp\frontend-main\node_modules\web3-eth\src\utils\get_transaction_error.ts:62:11)
        at Generator.next (<anonymous>)
        at <anonymous> (E:\github\nextapp\frontend-main\node_modules\web3-eth\src\utils\get_transaction_error.ts:16:3)
        at new Promise (<anonymous>)
        at __awaiter (E:\github\nextapp\frontend-main\node_modules\web3-eth\src\utils\get_transaction_error.ts:16:3)
        at getTransactionError (E:\github\nextapp\frontend-main\node_modules\web3-eth\src\utils\get_transaction_error.ts:41:67)
        at SendTxHelper.<anonymous> (E:\github\nextapp\frontend-main\node_modules\web3-eth\src\utils\send_tx_helper.ts:140:36)
        at Generator.next (<anonymous>)
        at fulfilled (E:\github\nextapp\frontend-main\node_modules\web3-eth\lib\commonjs\utils\send_tx_helper.js:5:58)
        at process.processTicksAndRejections (node:internal/process/task_queues:95:5) {
        cause: undefined,
        reason: 'out of gas',
        signature: undefined,
        receipt: undefined,
        data: undefined,
        code: 402
        }
     * 
     * 
     */
    // const data = testContract.methods.depositETH(depositAmount).encodeABI();

    // const estimatedGas = await web3.eth.estimateGas({
    //     to: testcontract,
    //     from: account.address,
    //     value: depositAmount,
    //     data: data
    // });

    // console.log('Estimated gas:', estimatedGas);
    // const gasLimit = Math.ceil(Number(estimatedGas) * 1.5);

    // // トランザクションのパラメータを設定
    // const tx = await web3.eth.sendTransaction({
    //     to: testcontract,
    //     from: account.address,
    //     value: depositAmount,
    //     data: data,
    //     gas: gasLimit,
    //     maxFeePerGas: 2500000000
    // });

    // try {
    //     // トランザクションに署名して送信
    //     const receipt = await web3.eth.sendTransaction(tx);
    //     console.log('トランザクションが成功しました:', receipt);
    // } catch (error) {
    //     console.error('トランザクションに失敗しました:', error);
    // }
}

// スクリプトを実行
stakeWithLido();