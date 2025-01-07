import { LidoSDK } from "@lidofinance/lido-ethereum-sdk";
import { LidoSDKCore } from "@lidofinance/lido-ethereum-sdk/core";
import { ethers } from "ethers";

const weiToEth = (wei: string | number | bigint): string => {
    return ethers.formatEther(wei);
};

export const stETH = async (
    recipient: string,
    setBalanceETH: (arg0: string) => void,
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

        const balanceETH = await lidoSDK.steth.balance(stakeaddress);

        setBalanceETH(weiToEth(balanceETH).toString());
    } catch (error) {
        console.error("お持ちstETHの確認エラー:", error);
    }
};