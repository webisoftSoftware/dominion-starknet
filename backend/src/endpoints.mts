import 'dotenv/config';

import encryptionCircuit from '../circuits/encryption/target/encryption.json' with { type: "json" };
import decryption1CardCircuit from '../circuits/decryption/1card_decryption/target/1card_decryption.json' with { type: "json" };
import decryption3CardsCircuit from '../circuits/decryption/3cards_decryption/target/3cards_decryption.json' with { type: "json" };
import shuffleCircuit from '../circuits/shuffle/target/shuffle.json' with { type: "json" };

import {
    postEncryptedDeck,
    postDecryptedCommunityCards
} from './blockchainUtils.js';

import {
    executeCircuit,
    readSecrets,
    generateRandomValues
} from './utils.mjs';
import { CompiledCircuit } from '@noir-lang/backend_barretenberg';
import { BigNumberish } from 'starknet';

/**
 * Function to encrypt a deck of cards using Noir circuit
 */
async function encryptDeck() {
    try {
        // TODO: Get the tableId from Torii
        const tableId = 1;

        // Generate new random numbers for key, iv, and shuffle
        await generateRandomValues(tableId);

        // Read secrets
        const { key, iv, shuffleKey } = readSecrets(tableId);
        if (!key || !iv || !shuffleKey) {
            throw new Error('Missing required parameters in secrets file');
        }

        // TODO: Get the deck from Torii
        const deck = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
                     101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113,
                     201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213,
                     301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313];

        // Validate input
        if (deck?.length !== 52) {
            throw new Error('Invalid deck input. Expected array of integers.');
        }

        // Execute shuffle circuit
        const { witnessResult: shuffleWitnessResult, proof: shuffleProof } =
            await executeCircuit(shuffleCircuit as CompiledCircuit, { deck, key: shuffleKey });

        const shuffledDeck = shuffleWitnessResult.returnValue;

        // Validate shuffled deck
        if (Array.isArray(shuffledDeck) && shuffledDeck.length !== 52) {
            throw new Error('Invalid deck input after shuffle. Expected array of 52 integers.');
        }

        // Execute encryption circuit
        const { witnessResult, proof: encryptionProof } =
            await executeCircuit(encryptionCircuit as CompiledCircuit, { key, iv, deck: shuffledDeck });

        // Broadcast proofs to all clients
        // io.emit('encryptionComplete', {
        //     success: true,
        //     shuffleProof,
        //     encryptionProof
        // });

        if (!Array.isArray(witnessResult.returnValue)) throw new Error('Invalid encrypted deck');

        // Send the encrypted deck on-chain with the Backend wallet
        await postEncryptedDeck(tableId, witnessResult.returnValue as BigNumberish[]);

    } catch (err) {
        console.error('Encryption error:', err);
        // io.emit('encryptionError', { success: false });
        throw err;
    }
}

/**
 * Function to decrypt community cards using Noir circuit
 *
 * This function will fetch the encrypted cards from Torii based on the number of cards to decrypt (1 or 3).
 * It then decrypts the cards using the appropriate Noir circuit and broadcasts the result.
 *
 * Returns:
 * {
 *   "success": true,
 *   "decryptedCards": [card1, card2, ...], // Original values of the requested cards
 *   "decryptProof": {...} // Zero-knowledge proof of correct decryption
 * }
 */
async function decryptCommunityCards() {
    try {
        // TODO: Get the tableId from Torii
        const tableId = 1;

        const { key, iv } = readSecrets(tableId);
        if (!key || !iv) {
            throw new Error('Missing required parameters in environment variables');
        }

        // TODO: Get the encrypted cards from Torii
        const encryptedCards: string | any[] = [];

        // Get the number of cards to decrypt from Torii
        const numCards: number = encryptedCards.length;

        // Validate the number of cards to decrypt
        if (numCards !== 1 && numCards !== 3) {
            throw new Error('Invalid number of cards to decrypt');
        }

        // TODO: Get the encrypted deck from Torii
        const encryptedDeck = [
            0x0000000000, 0x1111111111, 0x2222222222, 0x3333333333, 0x4444444444, 0x5555555555, 0x6666666666, 0x7777777777,
            0x8888888888, 0x9999999999, 0xAAAAAAAAAA, 0xBBBBBBBBBB, 0xCCCCCCCCCC, 0xDDDDDDDDDD, 0xEEEEEEEEEE, 0xFFFFFFFF,
            0x1111111111, 0x2222222222, 0x3333333333, 0x4444444444, 0x5555555555, 0x6666666666, 0x7777777777, 0x8888888888,
            0x9999999999, 0xAAAAAAAAAA, 0xBBBBBBBBBB, 0xCCCCCCCCCC, 0xDDDDDDDDDD, 0xEEEEEEEEEE, 0xFFFFFFFF, 0x0000000001,
            0x1111111112, 0x2222222223, 0x3333333334, 0x4444444445, 0x5555555556, 0x6666666667, 0x7777777778, 0x8888888889,
            0x999999999A, 0xAAAAAAAAAB, 0xBBBBBBBBBC, 0xCCCCCCCCCD, 0xDDDDDDDDDE, 0xEEEEEEEEEF, 0xFFFFFFFFF0, 0x1111111113,
            0x2222222224, 0x3333333335, 0x4444444446, 0x5545654836
        ];

        // Select the appropriate circuit based on number of cards
        const circuit = numCards === 1 ? decryption1CardCircuit : decryption3CardsCircuit;

        // Execute decryption circuit
        const { witnessResult: decryptWitnessResult, proof: decryptProof } =
            await executeCircuit(circuit as CompiledCircuit, {
                key,
                iv,
                deck: encryptedDeck,
                cards: encryptedCards
            });

        // Broadcast decryption proof to all clients
        // io.emit('decryptionComplete', {
        //     success: true,
        //     decryptedCards: decryptWitnessResult.returnValue,
        //     decryptProof
        // });

        // Send the decrypted cards on-chain with the Backend wallet
        await postDecryptedCommunityCards(tableId, decryptWitnessResult.returnValue);

    } catch (err) {
        console.error('Decryption error:', err);
        // io.emit('decryptionError', { success: false });
        throw err;
    }
}
