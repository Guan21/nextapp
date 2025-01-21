import { LidoSDK } from "@lidofinance/lido-ethereum-sdk";
import { LidoSDKCore } from "@lidofinance/lido-ethereum-sdk/core";

export const transfor = async (
    recipient: string,
    amount: string,
    setTransforresult: (arg0: string) => void,
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

        const balanceETH = await lidoSDK.steth.transfer({
            amount: amount,
            to: stakeaddress,
        });

        setTransforresult("送信成功");
    } catch (error) {
        console.error("トランザクションエラー:", error);
    }
};