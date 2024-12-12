import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';

import { UltraHonkBackend } from '@noir-lang/backend_barretenberg';
import { Noir } from '@noir-lang/noir_js';
import encryptionCircuit from '../../encryption/target/encryption.json' assert { type: "json" };
import decryption1CardCircuit from '../../decryption/1card_decryption/target/1card_decryption.json' assert { type: "json" };
import decryption2CardsCircuit from '../../decryption/2cards_decryption/target/2cards_decryption.json' assert { type: "json" };
import decryption3CardsCircuit from '../../decryption/3cards_decryption/target/3cards_decryption.json' assert { type: "json" };
import shuffleCircuit from '../../shuffle/target/shuffle.json' assert { type: "json" };

import { randomInt, createHash } from 'crypto';
import dotenv from 'dotenv';
import fs from 'fs';

// Create Express server
const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: "*", // Configure according to your security requirements
    methods: ["GET", "POST"]
  }
});

// Handle WebSocket connections
io.on('connection', (socket) => {
    console.log('Client connected');
    
    socket.on('disconnect', () => {
      console.log('Client disconnected');
    });
});

app.use(express.json());

/**
 * Function to generate random values for key, IV, and shuffle
 */
async function generateRandomValues() {
    // Generate arrays of 4 random numbers for key and IV
    const key = Array.from({length: 4}, () => randomInt(1, 281474976710655));
    const iv = Array.from({length: 4}, () => randomInt(1, 281474976710655));
    const shuffle = randomInt(1, 281474976710655);
    
    // Create the .env content with arrays
    const envContent = `ENCRYPTION_KEY=${key.join(',')}\nENCRYPTION_IV=${iv.join(',')}\nSHUFFLE_VALUE=${shuffle}\n`;
    
    // Write to .env file
    fs.writeFileSync('.env', envContent);
}

/**
 * Function to encrypt a deck of cards using Noir circuit
 * 
 * 
 * Card values should be:
 * - Hearts: 001-013
 * - Diamonds: 101-113
 * - Clubs: 201-213
 * - Spades: 301-313
 */
async function encryptDeck() { // TODO: This function should be called once the request is received from Torii
    try {
        // Generate new random numbers for key, iv, and shuffle
        await generateRandomValues();
        
        // Load environment variables from .env file
        dotenv.config();

        // Parse encryption key, IV, and shuffle key from environment variables
        const key = process.env.ENCRYPTION_KEY?.split(',').map(Number);
        const iv = process.env.ENCRYPTION_IV?.split(',').map(Number);
        const shuffleKey = parseInt(process.env.SHUFFLE_VALUE);

        // TODO: Get the deck from Torii
        const deck = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
                     101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113,
                     201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213,
                     301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313];
        
        // Validate input
        if (!deck || !Array.isArray(deck) || deck.length !== 52) {
            throw new Error('Invalid deck input. Expected array of integers.');
        }

        // Initialize Noir circuit components for shuffling
        const shuffleBackend = new UltraHonkBackend(shuffleCircuit);
        const shuffleNoir = new Noir(shuffleCircuit);

        // Prepare input for the shuffle circuit
        const shuffleInput = {
            deck: deck,
            key: shuffleKey
        };

        // Execute the shuffle circuit
        const shuffleWitnessResult = await shuffleNoir.execute(shuffleInput);
        const shuffleProof = await shuffleBackend.generateProof(shuffleWitnessResult.witness);
        
        // Get the shuffled deck from the circuit's return value
        const shuffledDeck = shuffleWitnessResult.returnValue;

        // Validate input for encryption
        if (!shuffledDeck || !Array.isArray(shuffledDeck) || shuffledDeck.length !== 52) {
            throw new Error('Invalid deck input after shuffle. Expected array of 52 integers.');
        }
        if (!key || !iv) {
            throw new Error('Missing required parameters in environment variables');
        }

        // Initialize Noir circuit components for encryption
        const encryptionBackend = new UltraHonkBackend(encryptionCircuit);
        const encryptionNoir = new Noir(encryptionCircuit);

        // Prepare input for the encryption circuit
        const encryptionInput = {
            key,
            iv,
            deck: shuffledDeck
        };

        // Execute the encryption circuit
        const witnessResult = await encryptionNoir.execute(encryptionInput);
        const encryptionProof = await encryptionBackend.generateProof(witnessResult.witness);

        // Broadcast proofs to all clients
        io.emit('encryptionComplete', {
            success: true,
            shuffleProof,
            encryptionProof
        });

        // TODO: Send the encrypted deck on-chain with the GM's wallet

    } catch (err) {
        console.error('Encryption error:', err);
        io.emit('encryptionError', { success: false });
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
async function decryptCommunityCards() { // TODO: This function should be called once the request is received from Torii
    try {
        // Load environment variables from .env file
        dotenv.config();

        // Parse encryption key, IV from environment variables
        const key = process.env.ENCRYPTION_KEY?.split(',').map(Number);
        const iv = process.env.ENCRYPTION_IV?.split(',').map(Number);
        if (!key || !iv) {
            throw new Error('Missing required parameters in environment variables');
        }

        // TODO: Get the encrypted cards from Torii
        let encryptedCards;

        // Get the number of cards to decrypt from Torii
        const numCards = encryptedCards.length;

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

        // Select the appropriate Noir circuit based on the number of cards
        let decryptionBackend, decryptionNoir;
        if (numCards === 1) {
            decryptionBackend = new UltraHonkBackend(decryption1CardCircuit);
            decryptionNoir = new Noir(decryption1CardCircuit);
        } else {
            decryptionBackend = new UltraHonkBackend(decryption3CardsCircuit); 
            decryptionNoir = new Noir(decryption3CardsCircuit);
        }

        // Prepare input for the decryption circuit
        const decryptInput = {
            key,
            iv,
            deck: encryptedDeck,
            cards: encryptedCards
        };

        // Execute the circuit to decrypt the requested cards
        const decryptWitnessResult = await decryptionNoir.execute(decryptInput);
        // Generate zero-knowledge proof of correct decryption
        const decryptProof = await decryptionBackend.generateProof(decryptWitnessResult.witness);

        // Broadcast decryption proof to all clients
        io.emit('decryptionComplete', {
            success: true,
            decryptedCards: decryptWitnessResult.returnValue,
            decryptProof
        });

        // TODO: Send the decrypted cards on-chain with the GM's wallet

    } catch (err) {
        console.error('Decryption error:', err);
        io.emit('decryptionError', { success: false });
        throw err;
    }
}

/**
 * Endpoint to decrypt hand 
 * 
 * Expected request body:
 * {
 *   "address": 0x123456789015154, // The player's on-chain address
 *   "secret": "1234567890" // The player's secret
 * }
 * 
 * Returns:
 * {
 *   "success": true,
 *   "decryptedHand": [card1, card2], // Original values of the requested cards
 *   "decryptProof": {...} // Zero-knowledge proof of correct decryption
 * }
 * 
 * Example:
 * If hand=["0x45454546235656565", "0x32232323232323232"] and the decrypted values are [0x01, 0x02],
 * this means the first two cards are Ace of Hearts and 2 of Hearts
 */

app.post('/decrypt-hand', async (req, res) => {
    try {
        // Extract parameters from request body
        const { playerOnChainAddress, playerSecret } = req.body;

        // Validate input
        if (!playerOnChainAddress || !playerSecret) {
            throw new Error('Missing required parameters');
        }

        // Load environment variables from .env file
        dotenv.config();

        // Parse encryption key, IV from environment variables
        const key = process.env.ENCRYPTION_KEY?.split(',').map(Number);
        const iv = process.env.ENCRYPTION_IV?.split(',').map(Number);
        if (!key || !iv) {
            throw new Error('Missing required parameters in environment variables');
        }

        // Recreate the hash from on-chain address & secret
        const reconstructedHash = createHash('sha256')
            .update(playerOnChainAddress + playerSecret)
            .digest('hex');

        // TODO: Get the player's hash from Torii for this player address
        const onChainHash = "a9f6054c7d2b69af6b8175ce762f4529e5d2e663596bf24c5df744989dd813d3";

        // Verify the hash with the player's hash sent from Torii for this player address
        if (reconstructedHash !== onChainHash) {
            throw new Error('Invalid player address or secret');
        }

        // TODO: Get the player's encrypted hand from Torii for this player address
        const hand = [0x0000000000, 0x1111111111]

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
        
        // Initialize Noir circuit components for decryption
        const decryptionBackend = new UltraHonkBackend(decryption2CardsCircuit);
        const decryptionNoir = new Noir(decryption2CardsCircuit);
        
        // Prepare input for the decryption circuit
        const decryptInput = {
            key,
            iv,
            deck: encryptedDeck,
            hand
        };
        
        // Execute the circuit to decrypt the requested cards
        const decryptWitnessResult = await decryptionNoir.execute(decryptInput);
        // Generate zero-knowledge proof of correct decryption
        const decryptProof = await decryptionBackend.generateProof(decryptWitnessResult.witness);
        
        // Return decrypted cards and proof
        res.json({
            success: true,
            decryptedHand: decryptWitnessResult.returnValue,
            decryptProof
        });

    } catch (err) {
        console.error('Decryption error:', err);
        res.status(500).json({
            success: false,
            error: err.message
        });
    }
});