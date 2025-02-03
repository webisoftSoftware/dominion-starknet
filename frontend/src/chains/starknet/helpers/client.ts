import { Account } from 'starknet';
import axios from 'axios';
import { generateAuthenticationHash, generateCommitmentHash } from './cryptoUtils';
import { cleanupLocalStorage } from './utils';
import { postCommitHash, postAuthHash, revealHand } from './blockchainUtils';

function buf2hex(buffer: ArrayBufferLike) {
  // buffer is an ArrayBuffer
  return [...new Uint8Array(buffer)].map((x) => x.toString(16).padStart(2, '0')).join('');
}

/**
 * Generates and stores a decryption secret when encryption is requested
 * @param {number} tableId - The table ID
 */
export function handleDeckEncryptionRequest(tableId: number) {
  // Generate a random secret (64 bytes = 512 bits)
  const arr = new Uint8Array(64);
  const secret = buf2hex(crypto.getRandomValues(arr).buffer);
  // Store in localStorage with table ID to handle multiple tables
  localStorage.setItem(`decryption_secret_${tableId}`, secret);
  return secret;
}

/**
 * Request hand decryption from backend
 * @param {string} playerAddress - Player's wallet address
 * @param {string} secret - Decryption secret
 * @returns {Promise} Backend response with decrypted hand and proof
 */
async function requestHandDecryption(playerAddress: string, secret: string) {
  try {
    const response = await axios.post('/decrypt-hand', {
      address: playerAddress,
      secret: secret,
    });
    return response.data;
  } catch (error) {
    console.error('Error requesting hand decryption:', error);
    throw error;
  }
}

/**
 * Handle the complete hand decryption process
 * @param {Account} account - StarkNet account instance
 * @param {number} tableId - Table ID
 * @param {string} playerAddress - Player's wallet address
 * @param {Array} encryptedHand - Player's encrypted hand
 */
export async function handleHandDecryption(
  account: Account,
  tableId: number,
  playerAddress: string,
  encryptedHand: string[],
) {
  try {
    // Get secret from localStorage
    const secret = localStorage.getItem(`decryption_secret_${tableId}`);
    if (!secret) throw new Error('Decryption secret not found');

    // Generate authentication hash
    const authHash = generateAuthenticationHash(playerAddress, secret);

    // Submit auth hash onchain
    await postAuthHash(account, tableId, authHash);

    // Request hand decryption from backend
    const { decryptedHand, proof } = await requestHandDecryption(playerAddress, secret);

    // Generate commitment hash
    const commitmentHash = generateCommitmentHash(decryptedHand, encryptedHand, secret);

    // Store commitment hash onchain
    await postCommitHash(account, tableId, commitmentHash);

    // Store values for showdown
    localStorage.setItem(`decrypted_hand_${tableId}`, JSON.stringify(decryptedHand));

    return {};
  } catch (error) {
    console.error('Error in hand decryption process:', error);
    throw error;
  }
}

/**
 * Handle hand reveal during showdown
 * @param {Account} account - StarkNet account instance
 * @param {number} tableId - Table ID
 */
export async function handleShowdown(account: Account, tableId: number) {
  try {
    // Get all necessary values from localStorage
    const secret = localStorage.getItem(`decryption_secret_${tableId}`);
    const decryptedHand = JSON.parse(localStorage.getItem(`decrypted_hand_${tableId}`) ?? '');

    // TODO: Get encrypted_hand from Torii
    const encryptedHand: string[] = [];

    if (!secret || !decryptedHand || !encryptedHand) {
      throw new Error('Missing required showdown data');
    }

    // Concatenate encryptedHand + encryptedHand + secret in 1 string
    const concatenatedValues = decryptedHand.join('') + encryptedHand.join('') + secret;

    // Call reveal_hand with all necessary parameters
    await revealHand(account, tableId, decryptedHand, concatenatedValues);

    // Clean up localStorage after successful reveal
    cleanupLocalStorage(tableId.toString());
  } catch (error) {
    console.error('Error revealing hand:', error);
    throw error;
  }
}
