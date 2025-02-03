import { RpcProvider, Contract, Account, cairo, BigNumberish } from 'starknet';

/**
 * Initialize StarkNet provider, account and contract
 * @returns {Object} Object containing provider, account, and contract instances
 */
export async function initializeStarkNet(): Promise<{ provider: RpcProvider, contract: Contract }> {
  try {
    // Initialize provider
    const provider = new RpcProvider({
      nodeUrl: process.env.RPC_URL,
    });

    // Initialize account
    const account = new Account(
      provider,
      process.env.BACKEND_WALLET_ADDRESS ?? '',
      process.env.BACKEND_WALLET_PRIVATE_KEY ?? '',
    );

    // Get contract ABI and initialize contract
    const { abi: tableManagerAbi } = await provider.getClassAt(process.env.TABLE_MANAGER_CONTRACT_ADDRESS ?? '');
    if (!tableManagerAbi) throw new Error('No ABI found for TableManager contract');

    // Initialize contract with account connection
    const tableManagerContract = new Contract(
      tableManagerAbi,
      process.env.TABLE_MANAGER_CONTRACT_ADDRESS ?? '',
      provider,
    );
    tableManagerContract.connect(account);

    console.log('StarkNet initialization successful');
    return { provider: provider, contract: tableManagerContract };
  } catch (error) {
    console.error('Error initializing StarkNet:', error);
    throw error;
  }
}

/**
 * Send encrypted deck to contract
 * @param {number} tableId - The table ID
 * @param {Array} encryptedDeck - Array of encrypted cards
 */
export async function postEncryptedDeck(tableId: number, encryptedDeck: BigNumberish[]) {
    try {
        // Initialize StarkNet first
        const { provider, contract } = await initializeStarkNet();

        // Format the encrypted deck for contract
        // Each card should be a StructCard with m_num_representation as u256
        const formattedDeck = encryptedDeck.map(card => ({
            m_num_representation: cairo.uint256(card)  // Convert to BigInt for u256 compatibility
        }));

        // Call contract method using populate
        const myCall = contract.populate('post_encrypt_deck', [
            tableId,
            formattedDeck
        ]);

        // Execute the call
        const result = await contract.post_encrypt_deck(myCall.calldata);

        // Wait for transaction to be confirmed
        const txReceipt = await provider.waitForTransaction(result.transaction_hash);

        // Check transaction status
        if (!txReceipt.isSuccess()) {
            throw new Error(`Transaction failed: ${result.transaction_hash}`);
        }

        console.log('Encrypted deck sent successfully:', result.transaction_hash);
        return { result, txReceipt };
    } catch (error) {
        console.error('Error sending encrypted deck:', error);
        throw error;
    }
}

/**
 * Send decrypted community cards to contract
 * @param {number} tableId - The table ID
 * @param {Array} decryptedCards - Array of decrypted cards
 */
export async function postDecryptedCommunityCards(tableId: number, decryptedCards: Array<never>) {
  try {
    // Initialize StarkNet first
    const { provider, contract } = await initializeStarkNet();

    // Format the decrypted cards for contract
    // Each card should be a StructCard with m_num_representation as u256
    const formattedCards = decryptedCards.map((card) => ({
      m_num_representation: cairo.uint256(card), // Convert to BigInt for u256 compatibility
    }));

    // Call contract method using populate
    const myCall = contract.populate('post_decrypted_community_cards', [tableId, formattedCards]);

    // Execute the call
    const result = await contract.post_decrypted_community_cards(myCall.calldata);

    // Wait for transaction to be confirmed
    const txReceipt = await provider.waitForTransaction(result.transaction_hash);

    // Check transaction status
    if (!txReceipt.isSuccess()) {
      throw new Error(`Transaction failed: ${result.transaction_hash}`);
    }

    console.log('Decrypted community cards sent successfully:', result.transaction_hash);
    return { result, txReceipt };
  } catch (error) {
    console.error('Error sending decrypted community cards:', error);
    throw error;
  }
}
