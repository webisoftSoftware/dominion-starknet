import { BinaryLike, createHash } from 'crypto';

/**
 * Generate SHA-256 hash from input values
 * @param {string} concatenatedValues - Values to hash
 * @param {boolean} [asByteArray=false] - Whether to return the hash as a byte array of 8 elements of u32
 * @returns {string|Array} SHA-256 hash as hex string or byte array of 8 elements of u32
 */

function generateSHA256Hash(concatenatedValues: BinaryLike, asByteArray: true): Uint32Array;
function generateSHA256Hash(concatenatedValues: BinaryLike, asByteArray?: false): string;
function generateSHA256Hash(concatenatedValues: BinaryLike, asByteArray?: boolean) {
  const hash = createHash('sha256').update(concatenatedValues).digest();

  if (asByteArray) {
    const byteArray = [];
    for (let i = 0; i < hash.length; i += 4) {
      byteArray.push(hash.readUInt32BE(i));
    }
    return new Uint32Array(byteArray);
  } else {
    return hash.toString('hex');
  }
}

/**
 * Generates authentication hash for hand decryption
 * @param {string} playerAddress - Player's wallet address
 * @param {string} secret - Decryption secret from localStorage
 * @returns {string} Authentication hash
 */
export function generateAuthenticationHash(playerAddress: string, secret: string) {
  const concatenatedValues = playerAddress + secret;
  return generateSHA256Hash(concatenatedValues);
}

/**
 * Generates commitment hash for hand reveal
 * @param {Array} decryptedHand - Decrypted card values
 * @param {Array} encryptedHand - Encrypted card values
 * @param {string} secret - Player's secret
 * @returns {Array[u32;8]} Commitment hash
 */
export function generateCommitmentHash(decryptedHand: string[], encryptedHand: string[], secret: string): Uint32Array {
  const concatenatedValues = decryptedHand.join('') + encryptedHand.join('') + secret;
  return generateSHA256Hash(concatenatedValues, true);
}
