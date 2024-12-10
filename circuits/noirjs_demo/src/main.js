import circuit from '../../encryption/target/encryption.json' assert { type: "json" };
import { BarretenbergBackend, BarretenbergVerifier as Verifier } from '@noir-lang/backend_barretenberg';
import { Noir } from '@noir-lang/noir_js';

function display(container, msg) {
    const c = document.getElementById(container);
    const p = document.createElement('p');
    p.textContent = msg;
    c.appendChild(p);
}

document.getElementById('submit').addEventListener('click', async () => {
    try {
        display('logs', 'Starting initialization...');
        const backend = new BarretenbergBackend(circuit);
        const noir = new Noir(circuit);
        
        // Create exactly 52 cards as regular integers
        const deck = Array.from({ length: 16 }, (_, i) => i + 1);
        const key = 123; // Using a simple integer key for testing
        
        const input = { 
            key,    // First parameter in circuit
            deck    // Second parameter in circuit, marked as pub
        };
        
        display('logs', 'Input being sent to circuit:');
        display('logs', JSON.stringify({
            key: key,
            deckLength: deck.length,
            firstCard: deck[0],
            lastCard: deck[15]
        }));
        
        display('logs', 'Attempting to execute noir.execute()...');
        const witnessResult = await noir.execute(input);
        display('logs', 'Witness generated successfully');
        
        const proof = await backend.generateProof(witnessResult);
        display('logs', 'Proof generated successfully');
        
        // The circuit returns 52 encrypted cards
        display('results', 'First encrypted card: ' + proof.publicInputs[0]);
        display('results', 'Last encrypted card: ' + proof.publicInputs[15]);
        
        const verified = await backend.verifyProof(proof);
        display('logs', verified ? 'Proof verified ✅' : 'Proof verification failed ❌');
        
    } catch (err) {
        console.error('Top level error:', err);
        display('logs', 'Error: ' + err.toString());
    }
});