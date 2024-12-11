import express from 'express';
import { UltraHonkBackend } from '@noir-lang/backend_barretenberg';
import { Noir } from '@noir-lang/noir_js';
import circuit from '../../encryption/target/encryption.json' assert { type: "json" };
import decryptionCircuit from '../../decryption/target/decryption.json' assert { type: "json" };
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// Parse environment variables
const key = process.env.ENCRYPTION_KEY?.split(',').map(Number);
const iv = process.env.ENCRYPTION_IV?.split(',').map(Number);

const app = express();
app.use(express.json());

// POST endpoint for encryption
app.post('/encrypt', async (req, res) => {
    try {
        const { deck } = req.body;

        if (!deck || !Array.isArray(deck)) {
            throw new Error('Invalid deck input. Expected array of integers.');
        }
        if (!key || !iv) {
            throw new Error('Missing required parameters in environment variables');
        }

        const backend = new UltraHonkBackend(circuit);
        const noir = new Noir(circuit);

        const encryptionInput = {
            key,
            iv,
            deck
        };

        const witnessResult = await noir.execute(encryptionInput);
        const proof = await backend.generateProof(witnessResult.witness);

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

// POST endpoint for decryption
app.post('/decrypt', async (req, res) => {
    try {
        const { encryptedDeck, hand } = req.body;

        if (!encryptedDeck || !hand) {
            throw new Error('Missing required parameters');
        }
        if (!key || !iv) {
            throw new Error('Missing required parameters in environment variables');
        }

        const decryptionBackend = new UltraHonkBackend(decryptionCircuit);
        const decryptionNoir = new Noir(decryptionCircuit);
        
        const decryptInput = {
            key,
            iv,
            deck: encryptedDeck,
            hand
        };
        
        const decryptWitnessResult = await decryptionNoir.execute(decryptInput);
        const decryptProof = await decryptionBackend.generateProof(decryptWitnessResult.witness);
        
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

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
}); 