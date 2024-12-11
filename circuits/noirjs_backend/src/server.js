import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';

import { UltraHonkBackend } from '@noir-lang/backend_barretenberg';
import { Noir } from '@noir-lang/noir_js';
import encryptionCircuit from '../../encryption/target/encryption.json' assert { type: "json" };
import decryptionCircuit from '../../decryption/target/decryption.json' assert { type: "json" };
import shuffleCircuit from '../../shuffle/target/shuffle.json' assert { type: "json" };

import { randomInt } from 'crypto';
import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';

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

        return {
            success: true,
            shuffleProof,
            encryptionProof
        };
        // TODO: Send the encrypted deck on-chain with the GM's wallet

    } catch (err) {
        console.error('Encryption error:', err);
        io.emit('encryptionError', { success: false });
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
app.post('/decrypt', async (req, res) => {
    try {
        // Extract parameters from request body
        const { playerOnChainAddress, playerSecret } = req.body;

        // Validate input
        if (!playerOnChainAddress || !playerSecret) {
            throw new Error('Missing required parameters');
        }
        if (!key || !iv) {
            throw new Error('Missing required parameters in environment variables');
        }
        // TODO: Reconstruct the hash from on-chain address & secret

        // TODO: Verify the hash with the player's hash sent from Torii for this player address

        // TODO: Get the player's encrypted hand from Torii for this player address
        // hand =

        // TODO: Get the encrypted deck from Torii
        // encryptedDeck =
        
        // Initialize Noir circuit components for decryption
        const decryptionBackend = new UltraHonkBackend(decryptionCircuit);
        const decryptionNoir = new Noir(decryptionCircuit);
        
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

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
}); 