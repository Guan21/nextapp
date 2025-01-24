export const WITHDRAWAL_QUEUE_ABI =[
    {
        "inputs": [],
        "name": "AdminZeroAddress",
        "type": "error"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_firstArrayLength",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "_secondArrayLength",
                "type": "uint256"
            }
        ],
        "name": "ArraysLengthMismatch",
        "type": "error"
    },
    {
        "inputs": [],
        "name": "BatchesAreNotSorted",
        "type": "error"
    },
    {
        "inputs": [],
        "name": "CantSendValueRecipientMayHaveReverted",
        "type": "error"
    },
    {
        "inputs": [],
        "name": "EmptyBatches",
        "type": "error"
    },
    {
        "inputs": [],
        "name": "InvalidContractVersionIncrement",
        "type": "error"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_hint",
                "type": "uint256"
            }
        ],
        "name": "InvalidHint",
        "type": "error"
    },
    {
        "inputs": [],
        "name": "InvalidReportTimestamp",
        "type": "error"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_requestId",
                "type": "uint256"
            }
        ],
        "name": "InvalidRequestId",
        "type": "error"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "startId",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "endId",
                "type": "uint256"
            }
        ],
        "name": "InvalidRequestIdRange",
        "type": "error"
    },
    {
        "inputs": [],
        "name": "InvalidState",
        "type": "error"
    },
    {
        "inputs": [],
        "name": "NonZeroContractVersionOnInit",
        "type": "error"
    },
    {
        "inputs": [],
        "name": "NotEnoughEther",
        "type": "error"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_sender",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "_owner",
                "type": "address"
            }
        ],
        "name": "NotOwner",
        "type": "error"
    },
    {
        "inputs": [],
        "name": "PauseUntilMustBeInFuture",
        "type": "error"
    },
    {
        "inputs": [],
        "name": "PausedExpected",
        "type": "error"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_requestId",
                "type": "uint256"
            }
        ],
        "name": "RequestAlreadyClaimed",
        "type": "error"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_amountOfStETH",
                "type": "uint256"
            }
        ],
        "name": "RequestAmountTooLarge",
        "type": "error"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_amountOfStETH",
                "type": "uint256"
            }
        ],
        "name": "RequestAmountTooSmall",
        "type": "error"
    },
    {
        "inputs": [],
        "name": "RequestIdsNotSorted",
        "type": "error"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_requestId",
                "type": "uint256"
            }
        ],
        "name": "RequestNotFoundOrNotFinalized",
        "type": "error"
    },
    {
        "inputs": [],
        "name": "ResumedExpected",
        "type": "error"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "sent",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "maxExpected",
                "type": "uint256"
            }
        ],
        "name": "TooMuchEtherToFinalize",
        "type": "error"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "expected",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "received",
                "type": "uint256"
            }
        ],
        "name": "UnexpectedContractVersion",
        "type": "error"
    },
    {
        "inputs": [],
        "name": "ZeroAmountOfETH",
        "type": "error"
    },
    {
        "inputs": [],
        "name": "ZeroPauseDuration",
        "type": "error"
    },
    {
        "inputs": [],
        "name": "ZeroRecipient",
        "type": "error"
    },
    {
        "inputs": [],
        "name": "ZeroShareRate",
        "type": "error"
    },
    {
        "inputs": [],
        "name": "ZeroTimestamp",
        "type": "error"
    },
    {
        "anonymous": false,
        "inputs": [],
        "name": "BunkerModeDisabled",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "_sinceTimestamp",
                "type": "uint256"
            }
        ],
        "name": "BunkerModeEnabled",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "version",
                "type": "uint256"
            }
        ],
        "name": "ContractVersionSet",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "address",
                "name": "_admin",
                "type": "address"
            }
        ],
        "name": "InitializedV1",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "duration",
                "type": "uint256"
            }
        ],
        "name": "Paused",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [],
        "name": "Resumed",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            },
            {
                "indexed": true,
                "internalType": "bytes32",
                "name": "previousAdminRole",
                "type": "bytes32"
            },
            {
                "indexed": true,
                "internalType": "bytes32",
                "name": "newAdminRole",
                "type": "bytes32"
            }
        ],
        "name": "RoleAdminChanged",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "account",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "sender",
                "type": "address"
            }
        ],
        "name": "RoleGranted",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "account",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "sender",
                "type": "address"
            }
        ],
        "name": "RoleRevoked",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "uint256",
                "name": "requestId",
                "type": "uint256"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "owner",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "receiver",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "amountOfETH",
                "type": "uint256"
            }
        ],
        "name": "WithdrawalClaimed",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "uint256",
                "name": "requestId",
                "type": "uint256"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "requestor",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "owner",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "amountOfStETH",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "amountOfShares",
                "type": "uint256"
            }
        ],
        "name": "WithdrawalRequested",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "uint256",
                "name": "from",
                "type": "uint256"
            },
            {
                "indexed": true,
                "internalType": "uint256",
                "name": "to",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "amountOfETHLocked",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "sharesToBurn",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "timestamp",
                "type": "uint256"
            }
        ],
        "name": "WithdrawalsFinalized",
        "type": "event"
    },
    {
        "inputs": [],
        "name": "BUNKER_MODE_DISABLED_TIMESTAMP",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "DEFAULT_ADMIN_ROLE",
        "outputs": [
            {
                "internalType": "bytes32",
                "name": "",
                "type": "bytes32"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "FINALIZE_ROLE",
        "outputs": [
            {
                "internalType": "bytes32",
                "name": "",
                "type": "bytes32"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "MAX_BATCHES_LENGTH",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "MAX_STETH_WITHDRAWAL_AMOUNT",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "MIN_STETH_WITHDRAWAL_AMOUNT",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "ORACLE_ROLE",
        "outputs": [
            {
                "internalType": "bytes32",
                "name": "",
                "type": "bytes32"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "PAUSE_INFINITELY",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "PAUSE_ROLE",
        "outputs": [
            {
                "internalType": "bytes32",
                "name": "",
                "type": "bytes32"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "RESUME_ROLE",
        "outputs": [
            {
                "internalType": "bytes32",
                "name": "",
                "type": "bytes32"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "STETH",
        "outputs": [
            {
                "internalType": "contract IStETH",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "WSTETH",
        "outputs": [
            {
                "internalType": "contract IWstETH",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "bunkerModeSinceTimestamp",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_maxShareRate",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "_maxTimestamp",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "_maxRequestsPerCall",
                "type": "uint256"
            },
            {
                "components": [
                    {
                        "internalType": "uint256",
                        "name": "remainingEthBudget",
                        "type": "uint256"
                    },
                    {
                        "internalType": "bool",
                        "name": "finished",
                        "type": "bool"
                    },
                    {
                        "internalType": "uint256[36]",
                        "name": "batches",
                        "type": "uint256[36]"
                    },
                    {
                        "internalType": "uint256",
                        "name": "batchesLength",
                        "type": "uint256"
                    }
                ],
                "internalType": "struct WithdrawalQueueBase.BatchesCalculationState",
                "name": "_state",
                "type": "tuple"
            }
        ],
        "name": "calculateFinalizationBatches",
        "outputs": [
            {
                "components": [
                    {
                        "internalType": "uint256",
                        "name": "remainingEthBudget",
                        "type": "uint256"
                    },
                    {
                        "internalType": "bool",
                        "name": "finished",
                        "type": "bool"
                    },
                    {
                        "internalType": "uint256[36]",
                        "name": "batches",
                        "type": "uint256[36]"
                    },
                    {
                        "internalType": "uint256",
                        "name": "batchesLength",
                        "type": "uint256"
                    }
                ],
                "internalType": "struct WithdrawalQueueBase.BatchesCalculationState",
                "name": "",
                "type": "tuple"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_requestId",
                "type": "uint256"
            }
        ],
        "name": "claimWithdrawal",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256[]",
                "name": "_requestIds",
                "type": "uint256[]"
            },
            {
                "internalType": "uint256[]",
                "name": "_hints",
                "type": "uint256[]"
            }
        ],
        "name": "claimWithdrawals",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256[]",
                "name": "_requestIds",
                "type": "uint256[]"
            },
            {
                "internalType": "uint256[]",
                "name": "_hints",
                "type": "uint256[]"
            },
            {
                "internalType": "address",
                "name": "_recipient",
                "type": "address"
            }
        ],
        "name": "claimWithdrawalsTo",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256[]",
                "name": "_requestIds",
                "type": "uint256[]"
            },
            {
                "internalType": "uint256",
                "name": "_firstIndex",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "_lastIndex",
                "type": "uint256"
            }
        ],
        "name": "findCheckpointHints",
        "outputs": [
            {
                "internalType": "uint256[]",
                "name": "hintIds",
                "type": "uint256[]"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256[]",
                "name": "_requestIds",
                "type": "uint256[]"
            },
            {
                "internalType": "uint256[]",
                "name": "_hints",
                "type": "uint256[]"
            }
        ],
        "name": "getClaimableEther",
        "outputs": [
            {
                "internalType": "uint256[]",
                "name": "claimableEthValues",
                "type": "uint256[]"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getContractVersion",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getLastCheckpointIndex",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getLastFinalizedRequestId",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getLastRequestId",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getLockedEtherAmount",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getResumeSinceTimestamp",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            }
        ],
        "name": "getRoleAdmin",
        "outputs": [
            {
                "internalType": "bytes32",
                "name": "",
                "type": "bytes32"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            },
            {
                "internalType": "uint256",
                "name": "index",
                "type": "uint256"
            }
        ],
        "name": "getRoleMember",
        "outputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            }
        ],
        "name": "getRoleMemberCount",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_owner",
                "type": "address"
            }
        ],
        "name": "getWithdrawalRequests",
        "outputs": [
            {
                "internalType": "uint256[]",
                "name": "requestsIds",
                "type": "uint256[]"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256[]",
                "name": "_requestIds",
                "type": "uint256[]"
            }
        ],
        "name": "getWithdrawalStatus",
        "outputs": [
            {
                "components": [
                    {
                        "internalType": "uint256",
                        "name": "amountOfStETH",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "amountOfShares",
                        "type": "uint256"
                    },
                    {
                        "internalType": "address",
                        "name": "owner",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "timestamp",
                        "type": "uint256"
                    },
                    {
                        "internalType": "bool",
                        "name": "isFinalized",
                        "type": "bool"
                    },
                    {
                        "internalType": "bool",
                        "name": "isClaimed",
                        "type": "bool"
                    }
                ],
                "internalType": "struct WithdrawalQueueBase.WithdrawalRequestStatus[]",
                "name": "statuses",
                "type": "tuple[]"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            },
            {
                "internalType": "address",
                "name": "account",
                "type": "address"
            }
        ],
        "name": "grantRole",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            },
            {
                "internalType": "address",
                "name": "account",
                "type": "address"
            }
        ],
        "name": "hasRole",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_admin",
                "type": "address"
            }
        ],
        "name": "initialize",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "isBunkerModeActive",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "isPaused",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bool",
                "name": "_isBunkerModeNow",
                "type": "bool"
            },
            {
                "internalType": "uint256",
                "name": "_bunkerStartTimestamp",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "_currentReportTimestamp",
                "type": "uint256"
            }
        ],
        "name": "onOracleReport",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_duration",
                "type": "uint256"
            }
        ],
        "name": "pauseFor",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "_pauseUntilInclusive",
                "type": "uint256"
            }
        ],
        "name": "pauseUntil",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256[]",
                "name": "_batches",
                "type": "uint256[]"
            },
            {
                "internalType": "uint256",
                "name": "_maxShareRate",
                "type": "uint256"
            }
        ],
        "name": "prefinalize",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "ethToLock",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "sharesToBurn",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            },
            {
                "internalType": "address",
                "name": "account",
                "type": "address"
            }
        ],
        "name": "renounceRole",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256[]",
                "name": "_amounts",
                "type": "uint256[]"
            },
            {
                "internalType": "address",
                "name": "_owner",
                "type": "address"
            }
        ],
        "name": "requestWithdrawals",
        "outputs": [
            {
                "internalType": "uint256[]",
                "name": "requestIds",
                "type": "uint256[]"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256[]",
                "name": "_amounts",
                "type": "uint256[]"
            },
            {
                "internalType": "address",
                "name": "_owner",
                "type": "address"
            },
            {
                "components": [
                    {
                        "internalType": "uint256",
                        "name": "value",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "deadline",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint8",
                        "name": "v",
                        "type": "uint8"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "r",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "s",
                        "type": "bytes32"
                    }
                ],
                "internalType": "struct WithdrawalQueue.PermitInput",
                "name": "_permit",
                "type": "tuple"
            }
        ],
        "name": "requestWithdrawalsWithPermit",
        "outputs": [
            {
                "internalType": "uint256[]",
                "name": "requestIds",
                "type": "uint256[]"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256[]",
                "name": "_amounts",
                "type": "uint256[]"
            },
            {
                "internalType": "address",
                "name": "_owner",
                "type": "address"
            }
        ],
        "name": "requestWithdrawalsWstETH",
        "outputs": [
            {
                "internalType": "uint256[]",
                "name": "requestIds",
                "type": "uint256[]"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256[]",
                "name": "_amounts",
                "type": "uint256[]"
            },
            {
                "internalType": "address",
                "name": "_owner",
                "type": "address"
            },
            {
                "components": [
                    {
                        "internalType": "uint256",
                        "name": "value",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "deadline",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint8",
                        "name": "v",
                        "type": "uint8"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "r",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "s",
                        "type": "bytes32"
                    }
                ],
                "internalType": "struct WithdrawalQueue.PermitInput",
                "name": "_permit",
                "type": "tuple"
            }
        ],
        "name": "requestWithdrawalsWstETHWithPermit",
        "outputs": [
            {
                "internalType": "uint256[]",
                "name": "requestIds",
                "type": "uint256[]"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "resume",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            },
            {
                "internalType": "address",
                "name": "account",
                "type": "address"
            }
        ],
        "name": "revokeRole",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes4",
                "name": "interfaceId",
                "type": "bytes4"
            }
        ],
        "name": "supportsInterface",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "unfinalizedRequestNumber",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "unfinalizedStETH",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    }
]