## 1.プロジェクト概要

#### 1. プロジェクト名

docomo L2 MVP

#### プロジェクトの目的

L2の実現可能性を検証する

## 2.主要技術
| 言語・フレームワーク | バージョン |
| ----------------- | -------- |
| Solidity          | 0.8.28   |
| Hardhat           | 2.22     |
| Node.js           | 22       |
| パッケージマネージャー| pnpm     |

## 3.コマンド一覧
| コマンド                                               　| 実行する処理                         |
| ------------------------------------------------------ | ---------------------------------- |
| npx hardhat compile                                    | コントラクトをコンパイル               |
| npx hardhat test                                       | コントラクトをテスト                  |
| npx hardhat node                                       | hardhatネットワーク起動               |
| npx hardhat ignition deploy ./ignition/modules/Lock.ts --network localhost | hardhatネットワークにデプロイ |
| npx hardhat ignition verify sepolia-deployment | コントラクトverify                            |

## 4.注意事項
- VScodeにsolidityに関する拡張機能を不要に入れない
  - 拡張機能からハッキングにあう可能性がある為
- hardhat.congif.tsにwalletの秘密鍵を書かない
  - このファイルに秘密鍵を直書きしているネット記事をよく見る
- Solidityは出来るだけ最新のバージョンとコードを使う
  - Openzeppelin等のコードを使う際にもバージョンによってバグがあるので信用しすぎない

