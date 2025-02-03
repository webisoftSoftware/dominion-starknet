import fs from 'fs';
import { randomInt } from 'crypto';
import { CompiledCircuit, UltraHonkBackend } from '@noir-lang/backend_barretenberg';
import { InputMap, Noir } from '@noir-lang/noir_js';

/**
 * Initialize and execute a Noir circuit with proof generation
 * @param {Object} circuit - The circuit configuration
 * @param {Object} input - The input for the circuit
 * @returns {Object} - Object containing the witness result and proof
 */
export async function executeCircuit(circuit: CompiledCircuit, input: InputMap): Promise<{witnessResult: any,
  proof: any}> {
  const backend = new UltraHonkBackend(circuit);
  const noir = new Noir(circuit);
  const witnessResult = await noir.execute(input);
  const proof = await backend.generateProof(witnessResult.witness);
  return { witnessResult, proof };
}

/**
 * Read secrets from the .secrets_{tableId} file
 * @param {number} tableId - The ID of the table
 * @returns {Object} - Object containing the parsed secrets
 */
export function readSecrets(tableId: number): { key: any, iv: any, shuffleKey: any} {
  const secretsContent = fs.readFileSync(`.secrets_${tableId}`, 'utf8');
  const secrets = Object.fromEntries(
    secretsContent
      .split('\n')
      .filter((line) => line.trim())
      .map((line) => line.split('=')),
  );

  return {
    key: secrets.ENCRYPTION_KEY?.split(',').map(Number),
    iv: secrets.ENCRYPTION_IV?.split(',').map(Number),
    shuffleKey: parseInt(secrets.SHUFFLE_VALUE),
  };
}

/**
 * Function to generate random values for key, IV, and shuffle
 * @param {number} tableId - The ID of the table
 */
export async function generateRandomValues(tableId: number) {
    // Generate arrays of 4 random numbers for key and IV
    const key = Array.from({length: 4}, () => randomInt(1, 281474976710655));
    const iv = Array.from({length: 4}, () => randomInt(1, 281474976710655));
    const shuffle = randomInt(1, 281474976710655);

    // Create the .secrets content with arrays
    const secretsContent = `ENCRYPTION_KEY=${key.join(',')}\nENCRYPTION_IV=${iv.join(',')}\nSHUFFLE_VALUE=${shuffle}\n`;

    // Write to .secrets_{tableId} file
    fs.writeFileSync(`.secrets_${tableId}`, secretsContent);
}
