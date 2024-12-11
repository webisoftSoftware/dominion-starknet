import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
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
        // TODO: Get the deck from Torii
        // deck =
        
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

        // Broadcast only the success and proof to all clients
        io.emit('encryptionComplete', {
            success: true,
            proof
        });

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