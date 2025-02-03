import { RpcProvider, Contract, cairo, num, Account, RawArgs } from 'starknet';
import { ArgentTMA } from '@argent/tma-wallet';
import dotenv from 'dotenv';

dotenv.config();


const actionsContract = process.env.VITE_ACTIONS_CONTRACT_ADDRESS ?? '';
const tableManagerContract = process.env.VITE_TABLE_MANAGER_CONTRACT_ADDRESS ?? '';
const cashierContract = process.env.VITE_CASHIER_CONTRACT_ADDRESS ?? '';

const provider = new RpcProvider({
    nodeUrl: process.env.VITE_RPC_URL
});

export async function initArgentTMA() {
    const argentTMA = ArgentTMA.init({
        environment: "sepolia",
        appName: "Dominion Sepolia",
        appTelegramUrl: "https://t.me/dominion_bot/dominion",
        sessionParams: {
          allowedMethods: [
            {
              contract: actionsContract,
              selector: "bet",
            },
            {
              contract: actionsContract,
              selector: "reveal_hand",
            },
            {
              contract: actionsContract,
              selector: "set_ready",
            },
            {
              contract: actionsContract,
              selector: "join_table",
            },
            {
              contract: actionsContract,
              selector: "fold",
            },
            {
              contract: actionsContract,
              selector: "post_auth_hash",
            },
            {
              contract: actionsContract,
              selector: "post_commit_hash",
            },
            {
              contract: actionsContract,
              selector: "leave_table",
            },
            {
              contract: actionsContract,
              selector: "top_up_table_chips",
            },
            {
              contract: cashierContract,
              selector: "deposit_erc20",
            },
            {
              contract: cashierContract,
              selector: "cashout_erc20",
            },
            {
              contract: cashierContract,
              selector: "transfer_chips",
            },
          ],
          validityDays: 90
        },
    });
    return argentTMA;
}

/**
 * Initialize contract instance
 * @param {string} contractAddress - Address of the contract
 * @returns {Contract} Contract instance
 */
async function initializeContract(contractAddress: string) {
    const { abi } = await provider.getClassAt(contractAddress);
    if (!abi) throw new Error(`No ABI found for contract at ${contractAddress}`);
    return new Contract(abi, contractAddress, provider);
}

/**
 * Generic execute function with fee estimation
 * @param {Account} account - StarkNet account instance
 * @param {Contract} contract - Contract instance
 * @param {string} entrypoint - Contract function name
 * @param {Array} calldata - Function arguments
 */
async function executeWithFeeEstimation(account: Account, contract: Contract, entrypoint: string, calldata: RawArgs) {
    // Estimate fee
    const { resourceBounds } = await account.estimateInvokeFee({
        contractAddress: contract.address,
        entrypoint,
        calldata
    });

    // Add safety margins
    const adjustedL1Gas = {
        max_amount: ((num.toBigInt(resourceBounds.l1_gas.max_amount) * 15n) / 10n).toString(), // 50% margin
        max_price_per_unit: ((num.toBigInt(resourceBounds.l1_gas.max_price_per_unit) * 12n) / 10n).toString() // 20% margin
    };

    // Execute transaction
    const tx = await account.execute(
        contract.populate(entrypoint, calldata),
        {
            resourceBounds: {
                l1_gas: adjustedL1Gas,
                l2_gas: { max_amount: '0x0', max_price_per_unit: '0x0' }
            }
        }
    );

    const txReceipt = await provider.waitForTransaction(tx.transaction_hash);
    if (!txReceipt.isSuccess()) {
        throw new Error(`Transaction failed: ${tx.transaction_hash}`);
    }

    return { tx, txReceipt };
}

/////
/// GAME ACTIONS FUNCTIONS
/////

/**
 * Place a bet
 * @param {Account} account - StarkNet account instance
 * @param {number} tableId - The table ID
 * @param {number} amount - Bet amount
 */
export async function bet(account: Account, tableId: number, amount: number) {
    try {
        const contract = await initializeContract(actionsContract);
        contract.connect(account);
        
        const { tx, txReceipt } = await executeWithFeeEstimation(
            account,
            contract,
            'bet',
            [tableId, amount]
        );

        return { result: tx, txReceipt };
    } catch (error) {
        console.error('Error placing bet:', error);
        throw error;
    }
}

/**
 * Fold current hand
 * @param {Account} account - StarkNet account instance
 * @param {number} tableId - The table ID
 */
export async function fold(account: Account, tableId: number) {
    try {
        const contract = await initializeContract(actionsContract);
        contract.connect(account);
        
        const { tx, txReceipt } = await executeWithFeeEstimation(
            account,
            contract,
            'fold',
            [tableId]
        );

        return { result: tx, txReceipt };
    } catch (error) {
        console.error('Error folding:', error);
        throw error;
    }
}

/**
 * Post commitment hash
 * @param {Account} account - StarkNet account instance
 * @param {number} tableId - The table ID
 * @param {string} authHash - Authentication hash
 */
export async function postAuthHash(account: Account, tableId: number, authHash: string) {
    try {
        const contract = await initializeContract(actionsContract);
        contract.connect(account);
        
        const { tx, txReceipt } = await executeWithFeeEstimation(
            account,
            contract,
            'post_auth_hash',
            [tableId, authHash]
        );

        return { result: tx, txReceipt };
    } catch (error) {
        console.error('Error posting commitment hash:', error);
        throw error;
    }
}

/**
 * Post commitment hash
 * @param {Account} account - StarkNet account instance
 * @param {number} tableId - The table ID
 * @param {Array<number>} commitmentHash - Array of commitment hash values
 */
export async function postCommitHash(account: Account, tableId: number, commitmentHash: Uint32Array) {
    try {
        const contract = await initializeContract(actionsContract);
        contract.connect(account);
        
        const { tx, txReceipt } = await executeWithFeeEstimation(
            account,
            contract,
            'post_commit_hash',
            [tableId, commitmentHash]
        );

        return { result: tx, txReceipt };
    } catch (error) {
        console.error('Error posting commitment hash:', error);
        throw error;
    }
}

/**
 * Set ready status
 * @param {Account} account - StarkNet account instance
 * @param {number} tableId - The table ID
 */
export async function setReady(account: Account, tableId: number) {
    try {
        const contract = await initializeContract(actionsContract);
        contract.connect(account);
        
        const { tx, txReceipt } = await executeWithFeeEstimation(
            account,
            contract,
            'set_ready',
            [tableId, tableManagerContract]
        );

        return { result: tx, txReceipt };
    } catch (error) {
        console.error('Error setting ready status:', error);
        throw error;
    }
}

/**
 * Join a table
 * @param {Account} account - StarkNet account instance
 * @param {number} tableId - The table ID
 * @param {number} chipsAmount - Amount of chips to bring
 */
export async function joinTable(account: Account, tableId: number, chipsAmount: number) {
    try {
        const contract = await initializeContract(actionsContract);
        contract.connect(account);
        
        const { tx, txReceipt } = await executeWithFeeEstimation(
            account,
            contract,
            'join_table',
            [tableId, chipsAmount]
        );

        return { result: tx, txReceipt };
    } catch (error) {
        console.error('Error joining table:', error);
        throw error;
    }
}

/**
 * Leave a table
 * @param {Account} account - StarkNet account instance
 * @param {number} tableId - The table ID
 */
export async function leaveTable(account: Account, tableId: number) {
    try {
        const contract = await initializeContract(actionsContract);
        contract.connect(account);
        
        const { tx, txReceipt } = await executeWithFeeEstimation(
            account,
            contract,
            'leave_table',
            [tableId]
        );

        return { result: tx, txReceipt };
    } catch (error) {
        console.error('Error leaving table:', error);
        throw error;
    }
}

/**
 * Reveal hand
 * @param {Account} account - StarkNet account instance
 * @param {number} tableId - The table ID
 * @param {Array<Object>} decryptedHand - Array of decrypted card objects
 * @param {string} request - Request data
 */
export async function revealHand(account: Account, tableId: number, decryptedHand: string[], request: string) {
    try {
        const contract = await initializeContract(actionsContract);
        contract.connect(account);
        
        const formattedDecryptedHand = decryptedHand.map(card => ({
            m_num_representation: cairo.uint256(card)  // Convert to BigInt for u256 compatibility
        }));

        const { tx, txReceipt } = await executeWithFeeEstimation(
            account,
            contract,
            'reveal_hand',
            [tableId, formattedDecryptedHand, request]
        );

        return { result: tx, txReceipt };
    } catch (error) {
        console.error('Error revealing hand:', error);
        throw error;
    }
}

/**
 * Top up table chips
 * @param {Account} account - StarkNet account instance
 * @param {number} tableId - The table ID
 * @param {number} chipsAmount - Amount of chips to add
 */
export async function topUpTableChips(account: Account, tableId: number, chipsAmount: number) {
    try {
        const contract = await initializeContract(actionsContract);
        contract.connect(account);
        
        const { tx, txReceipt } = await executeWithFeeEstimation(
            account,
            contract,
            'top_up_table_chips',
            [tableId, chipsAmount]
        );

        return { result: tx, txReceipt };
    } catch (error) {
        console.error('Error topping up table chips:', error);
        throw error;
    }
}

/////
/// CASHIER FUNCTIONS
/////

/**
 * Deposit ERC20 tokens
 * @param {ArgentTMA} argentTMA - Argent TMA wallet instance
 * @param {Account} account - StarkNet account instance
 * @param {bigint} amount - Amount to deposit
 */
export async function depositERC20(argentTMA: ArgentTMA, account: Account, amount: bigint) {
    try {
        const contract = await initializeContract(cashierContract);
        contract.connect(account);
        
        // First approve
        await argentTMA.requestApprovals(
            [
              {
                token: {
                  // Token address that you need approved
                  address: '0x049D36570D4e46f48e99674bd3fcc84644DdD6b96F7C741B1562B82f9e004dC7',
                  name: 'Ethereum',
                  symbol: 'ETH',
                  decimals: 18,
                },
                amount: BigInt(amount).toString(),
                spender: contract,
              },
            ],
        );

        // Then deposit
        const depositCall = contract.populate('deposit_erc20', [cairo.uint256(amount)]);
        const result = await contract.deposit_erc20(depositCall.calldata);
        const depositReceipt = await provider.waitForTransaction(result.transaction_hash);
        if (!depositReceipt.isSuccess()) {
            throw new Error(`Transaction failed: ${result.transaction_hash}`);
        }

        return { result, txReceipt: depositReceipt };
    } catch (error) {
        console.error('Error depositing ERC20:', error);
        throw error;
    }
}

/**
 * Cashout ERC20 tokens
 * @param {Account} account - StarkNet account instance
 * @param {number} chipsAmount - Amount of chips to cashout
 */
export async function cashoutERC20(account: Account, chipsAmount: number) {
    try {
        const contract = await initializeContract(cashierContract);
        contract.connect(account);
        
        const { tx, txReceipt } = await executeWithFeeEstimation(
            account,
            contract,
            'cashout_erc20',
            [chipsAmount]
        );

        return { result: tx, txReceipt };
    } catch (error) {
        console.error('Error cashing out ERC20:', error);
        throw error;
    }
}

/**
 * Transfer chips to another address
 * @param {Account} account - StarkNet account instance
 * @param {string} to - Recipient address
 * @param {number} amount - Amount of chips to transfer
 */
export async function transferChips(account: Account, to: string, amount: number) {
    try {
        const contract = await initializeContract(cashierContract);
        contract.connect(account);
        
        const { tx, txReceipt } = await executeWithFeeEstimation(
            account,
            contract,
            'transfer_chips',
            [to, amount]
        );

        return { result: tx, txReceipt };
    } catch (error) {
        console.error('Error transferring chips:', error);
        throw error;
    }
}