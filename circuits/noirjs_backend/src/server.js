import express from 'express';
import { UltraHonkBackend } from '@noir-lang/backend_barretenberg';
import { Noir } from '@noir-lang/noir_js';
import circuit from '../../encryption/target/encryption.json' assert { type: "json" };
import decryptionCircuit from '../../decryption/target/decryption.json' assert { type: "json" };
import dotenv from 'dotenv';

// Load environment variables from .env file
dotenv.config();

// Parse encryption key and IV from environment variables
const key = process.env.ENCRYPTION_KEY?.split(',').map(Number);
const iv = process.env.ENCRYPTION_IV?.split(',').map(Number);

const app = express();
app.use(express.json());

/**
 * Endpoint to encrypt a deck of cards using Noir circuit
 * 
 * Expected request body:
 * {
 *   "deck": [001, 002, 003, ...] // Array of 52 integers representing cards
 * }
 * 
 * Card values should be:
 * - Hearts: 001-013
 * - Diamonds: 101-113
 * - Clubs: 201-213
 * - Spades: 301-313
 * 
 * Returns:
 * {
 *   "success": true,
 *   "encryptedDeck": [...], // Array of encrypted card values
 *   "proof": {...} // Zero-knowledge proof
 * }
 */
app.post('/encrypt', async (req, res) => { // TODO: Should be executed when the encrypt_card_request is received from Torii
    try {
        // Extract deck from request body
        //TODO : The Deck should be received from Torii
        const { deck } = req.body;

        // Validate input
        if (!deck || !Array.isArray(deck) || deck.length !== 52) {
            throw new Error('Invalid deck input. Expected array of integers.');
        }
        if (!key || !iv) {
            throw new Error('Missing required parameters in environment variables');
        }

        // Initialize Noir circuit components
        const backend = new UltraHonkBackend(circuit);
        const noir = new Noir(circuit);

        // Prepare input for the encryption circuit
        const encryptionInput = {
            key,
            iv,
            deck
        };

        // Execute the circuit to generate the witness
        const witnessResult = await noir.execute(encryptionInput);
        // Generate zero-knowledge proof
        const proof = await backend.generateProof(witnessResult.witness);

        // Return encrypted deck and proof
        res.json({
            success: true,
            encryptedDeck: witnessResult.returnValue,
            proof
        });

    } catch (err) {
        console.error('Encryption error:', err);
        res.status(500).json({
            success: false,
            error: err.message
        });
    }
});

/**
 * Endpoint to decrypt hand 
 * 
 * Expected request body:
 * {
 *   "encryptedDeck": [...], // Encrypted deck of 52 cards
 *   "hand": ["0x45454546235656565", "0x32232323232323232"] // The player's encrypted hand
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
app.post('/decrypt', async (req, res) => { // TODO: Requests should only contain the client's secret & on-chain address
    try {
        // Extract parameters from request body
        const { encryptedDeck, hand } = req.body; // TODO: The encryptedDeck  & hand should be received from Torii

        // Validate input
        if (!encryptedDeck || !hand) {
            throw new Error('Missing required parameters');
        }
        if (!key || !iv) {
            throw new Error('Missing required parameters in environment variables');
        }
        // TODO: Reconstruct the hash from secret & on-chain address

        // TODO: Verify the hash with the player's hash sent from Torii

        // TODO: Get the player's encrypted hand from Torii
        
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