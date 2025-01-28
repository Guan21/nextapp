// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Lido の "submit" 関数を呼び出すための簡易インターフェイス。
 * 実際には Lido のソースコードを参照し、正確なシグネチャ・返り値を確認することを推奨します。
 */
interface ILido {
    /**
     * @notice ETHを送信し、stETHを受け取る。
     * @param _referral リファラル報酬先アドレス（不要であれば address(0)）
     * @return 発行されたstETH量など（実際のLidoコントラクト実装次第）
     */
    function submit(address _referral) external payable returns (uint256);
}

/**
 * @dev Lidov2のwithdrawal関数を呼び出すためのインターフェイス。
 */
interface ILidoWithdrawal {
    function requestWithdrawals(
        uint256[] calldata _amounts,
        address _owner
    ) external returns (uint256[] memory requestIds);

    function claimWithdrawals(uint256[] calldata _requestIds) external;

    function getWithdrawalStatus(
        uint256[] calldata _requestIds
    )
        external
        view
        returns (
            uint256[] memory amountOfStETH,
            uint256[] memory amountOfShares,
            bool[] memory isFinalized
        );
}

/**
 * @dev stETH(ERC20)トークンのインターフェイス。
 * transfer以外にも必要に応じて、balanceOf/approve/transferFrom 等を追加してください。
 */
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

/**
 * @title MyStakingContract
 * @notice
 *  1. 他のウォレットがこのコントラクトに ETH を送金 (depositETH)
 *      - depositETH 呼び出し時に、depositAmount をパラメータとして渡す
 *  2. コントラクトがまとめて Lido にステーク (stakeAllInLido)
 *      - コントラクト残高 (ETH) をすべて Lido に送金し、stETH をコントラクト自身が受け取る
 *  3. 受け取った stETH はこのコントラクトに保管される
 *  4. transferStETH でコントラクト内の stETH を任意アドレスへ送金可能
 */
contract MyStakingContract {
    /*** STATE VARIABLES ***/
    // Core contracts
    ILido public lido;
    IERC20 public stETH;
    ILidoWithdrawal public withdrawalQueue;

    // Withdrawal requests tracking (必要があれば拡張)
    mapping(address => uint256[]) public withdrawalRequests;

    // 送金者のマッピング
    mapping(address => uint256) public deposits;

    // ==== イベントの定義 ====
    event Deposit(address indexed from, uint256 amount);
    event TransferStETH(
        address indexed sender,
        address indexed to,
        uint256 amount
    );
    event WithdrawalStatus(bool isFinalized, uint256 requestId);
    event WithdrawalsClaimed(address indexed sender, uint256[] indexedIds);

    /*** CONSTRUCTOR ***/
    /**
     * @dev コンストラクタで Lido と stETH のコントラクトアドレスを設定
     * @param _lidoAddress Lidoステークコントラクトのアドレス
     * @param _stETHAddress stETHトークンのコントラクトアドレス
     * @param _lidowithdrawalQueueAddress LidoのWithdrawalQueueコントラクトのアドレス
     */
    constructor(
        address _lidoAddress,
        address _stETHAddress,
        address _lidowithdrawalQueueAddress
    ) {
        require(_lidoAddress != address(0), "Invalid Lido address");
        require(_stETHAddress != address(0), "Invalid stETH address");
        require(
            _lidowithdrawalQueueAddress != address(0),
            "Invalid withdrawalQueue address"
        );
        require(
            _lidowithdrawalQueueAddress != _stETHAddress,
            "WithdrawalQueue and stETH must be different"
        );

        lido = ILido(_lidoAddress);
        stETH = IERC20(_stETHAddress);
        withdrawalQueue = ILidoWithdrawal(_lidowithdrawalQueueAddress);
    }

    /*** DEPOSIT FUNCTIONS ***/
    /**
     * @notice コントラクトに ETH をデポジットする関数
     * @param depositAmount ユーザーが送金したい金額 (msg.value と一致させる)
     *
     * @dev 呼び出し時に {value: depositAmount} を指定し、msg.value == depositAmount であることを確認。
     *      送金額をユーザーが明示的にコントロールできるようにする。
     */
    function depositETH(uint256 depositAmount) external payable {
        require(depositAmount > 0, "depositAmount must be > 0");
        require(
            depositAmount == msg.value,
            "Sent ETH does not match depositAmount"
        );

        // 送金者の記録を更新
        deposits[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    /*** STAKING FUNCTIONS ***/
    /**
     * @notice コントラクト内にあるすべての ETH をまとめて Lido にステークする
     * @dev ここを呼ぶと Lido に ETH を送信し、stETH が当コントラクト宛にミントされる
     */
    function stakeAllInLido() external {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH balance in contract");

        // Lido の submit() を呼び出す（referral は address(0)）
        lido.submit{value: balance}(address(0));
    }

    /*** WITHDRAWAL FUNCTIONS ***/
    /**
     * @notice ユーザーが stETH を引き出す (WithdrawalQueue にリクエストを作成)
     * @param amount 引き出したい stETH の数量(wei単位)
     */
    function withdrawStakedETH(uint256 amount) external {
        // deposit のみで制御しているが、コントラクトが本当に stETH を持っているか要注意
        require(deposits[msg.sender] >= amount, "Insufficient stake");

        // WithdrawalQueue に stETH を引き出してもらうため、まず approve が必要
        bool approved = stETH.approve(address(withdrawalQueue), amount);
        require(approved, "Approval failed");

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        // Lido側へのwithdrawリクエストを送る
        uint256[] memory requestIds = withdrawalQueue.requestWithdrawals(
            amounts,
            msg.sender // リクエストが完了した際、ETH受取アドレスはユーザー
        );

        // ユーザー毎にリクエストIDを追跡
        withdrawalRequests[msg.sender] = requestIds;

        // Deposit記録を減算（厳密には、コントラクト残高内のstETHをUserごとに割り当てしている想定）
        deposits[msg.sender] -= amount;
    }

    /**
     * @notice ユーザーがfinalized(完了)したWithdrawalを受け取る
     *         （WithdrawalQueueのclaimWithdrawalsを呼ぶ）
     */
    function claimWithdrawnETH() external {
        uint256[] memory requestIds = withdrawalRequests[msg.sender];
        require(requestIds.length > 0, "No pending withdrawals");

        bool[] memory readyStatus = checkWithdrawalStatus(requestIds);

        // 引き出し可能なリクエストの個数をカウント
        uint256 readyCount = 0;
        for (uint i = 0; i < readyStatus.length; i++) {
            if (readyStatus[i]) readyCount++;
        }
        require(readyCount > 0, "No requests ready for claim");

        // finalizedなリクエストのみを抽出
        uint256[] memory finalizedRequestIds = new uint256[](readyCount);
        uint256 currentIndex = 0;
        for (uint i = 0; i < requestIds.length; i++) {
            if (readyStatus[i]) {
                finalizedRequestIds[currentIndex] = requestIds[i];
                currentIndex++;
            }
        }

        // コントラクトではなくユーザー自身のアドレスにETHが送られる
        withdrawalQueue.claimWithdrawals(finalizedRequestIds);

        // 未完了リクエストだけを再保存
        uint256[] memory remainingRequests = new uint256[](
            requestIds.length - readyCount
        );
        currentIndex = 0;
        for (uint i = 0; i < requestIds.length; i++) {
            if (!readyStatus[i]) {
                remainingRequests[currentIndex] = requestIds[i];
                currentIndex++;
            }
        }

        // リクエストが全て残っていない場合は初期化
        if (remainingRequests.length > 0) {
            withdrawalRequests[msg.sender] = remainingRequests;
        } else {
            delete withdrawalRequests[msg.sender];
        }

        emit WithdrawalsClaimed(msg.sender, finalizedRequestIds);
    }

    /*** TRANSFER FUNCTIONS ***/
    /**
     * @notice コントラクトが保有している stETH を指定アドレスに転送する
     * @param to 受取先アドレス
     * @param amount 転送するstETH量 (最小単位: wei)
     * @return 転送が成功したかどうか
     */
    function transferStETH(address to, uint256 amount) external returns (bool) {
        // deposit記録をしているが、実際のstETH残高との整合性をどう取るか要検討
        require(deposits[msg.sender] > 0, "No deposits found");
        require(amount <= deposits[msg.sender], "Exceeds deposit amount");

        emit TransferStETH(msg.sender, to, amount);

        // コントラクトが保持しているstETHを転送する
        bool success = stETH.transfer(to, amount);
        if (success) {
            deposits[msg.sender] -= amount;
        }
        return success;
    }

    /*** HELPER FUNCTIONS ***/
    /**
     * @notice コントラクトが保有している stETH 残高を返す
     * @return stETH残高 (wei単位)
     */
    function getStETHBalance() external view returns (uint256) {
        return stETH.balanceOf(address(this));
    }

    /**
     * @dev (オプション) コントラクトが受け取った ETH を処理するための fallback/receive 関数
     */
    receive() external payable {
        // 受領するだけ (stakeAllInLido() を後から呼ぶ)
    }

    /**
     * @notice コントラクトの ETH 残高を返す
     * @return ETH 残高
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice 指定したrequestIdsが引き出し可能かどうか確認する
     * @param requestIds withdrawalリクエストID配列
     * @return bool配列（引き出し可能ならtrue）
     */
    function checkWithdrawalStatus(
        uint256[] memory requestIds
    ) public view returns (bool[] memory) {
        (, , bool[] memory isFinalized) = withdrawalQueue.getWithdrawalStatus(
            requestIds
        );
        return isFinalized;
    }
}
