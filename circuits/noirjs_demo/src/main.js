import circuit from '../../encryption/target/encryption.json' assert { type: "json" };
import { UltraHonkBackend, UltraHonkVerifier as Verifier } from '@noir-lang/backend_barretenberg';
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
        const backend = new UltraHonkBackend(circuit);
        const noir = new Noir(circuit);
        
        // Create a smaller deck for testing
        const deck = Array.from({ length: 16 }, (_, i) => i + 1);  // Regular integers
        const key = 123; // Regular integer
        
        const input = { 
            key,
            deck
        };
        
        try {
            display('logs', 'Attempting to execute noir.execute()...');
            const witnessResult = await noir.execute(input);
            console.log(witnessResult);
            display('logs', 'Witness generated successfully');
            
            display('logs', 'Generating proof...');
            const proof = await backend.generateProof(witnessResult.witness);
            display('logs', 'Proof generated successfully');
            
            console.log(proof);
            display('results', 'First encrypted card: ' + proof.publicInputs[0].toString());
            display('results', 'Last encrypted card: ' + proof.publicInputs[15].toString());
            
            const verified = await backend.verifyProof(proof);
            display('logs', verified ? 'Proof verified ✅' : 'Proof verification failed ❌');
        } catch (execError) {
            console.error('Circuit execution error:', execError);
            display('logs', 'Circuit Error: ' + execError.toString());
            if (execError.stack) {
                display('logs', 'Stack: ' + execError.stack);
            }
        }
        
    } catch (err) {
        console.error('Top level error:', err);
        display('logs', 'Error: ' + err.toString());
        if (err.stack) {
            display('logs', 'Stack: ' + err.stack);
        }
    }
});