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
        // Clear previous results
        document.getElementById('logs').innerHTML = '<h2>Process Logs</h2>';
        document.getElementById('deck-comparison-body').innerHTML = '';
        
        display('logs', 'Starting initialization...');
        const backend = new UltraHonkBackend(circuit);
        const noir = new Noir(circuit);
        
        // Create deck with card notation
        const suits = ['H', 'D', 'C', 'S'];  // Hearts, Diamonds, Clubs, Spades
        const values = ['A', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K'];
        const cardNotations = [];
        
        // Generate card notations (HA, D5, ST, etc.)
        for (const suit of suits) {
            for (const value of values) {
                cardNotations.push(suit + value);
            }
        }
        
        // Add shuffle function
        function shuffleArray(array) {
            for (let i = array.length - 1; i > 0; i--) {
                const random = Math.random();
                console.log(random);
                const j = Math.floor(random * (i + 1));
                
                [array[i], array[j]] = [array[j], array[i]];
            }
            return array;
        }
        
        // Convert card notations to meaningful integers
        let deck = cardNotations.map(card => {
            const suit = card[0];
            const value = card[1];
            
            // Calculate suit base value
            let suitValue = 0;
            switch(suit) {
                case 'H': suitValue = 0; break;
                case 'D': suitValue = 100; break;
                case 'C': suitValue = 200; break;
                case 'S': suitValue = 300; break;
            }
            
            // Calculate card value
            let cardValue = 0;
            if (value === 'A') cardValue = 1;
            else if (value === 'T') cardValue = 10;
            else if (value === 'J') cardValue = 11;
            else if (value === 'Q') cardValue = 12;
            else if (value === 'K') cardValue = 13;
            else cardValue = parseInt(value);
            
            return suitValue + cardValue;
        });
        
        // Shuffle the input deck
        deck = shuffleArray([...deck]);
        
        const key = parseInt(import.meta.env.VITE_ENCRYPTION_KEY) || 123;
        
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
            
            // Create arrays of card notations for both decks
            const originalNotations = deck.map(num => {
                const suit = suits[Math.floor(num / 100)];
                const valueNum = num % 100;
                let value = '';
                if (valueNum === 1) value = 'A';
                else if (valueNum === 10) value = 'T';
                else if (valueNum === 11) value = 'J';
                else if (valueNum === 12) value = 'Q';
                else if (valueNum === 13) value = 'K';
                else value = valueNum.toString();
                return suit + value;
            });

            // Clear previous results
            const tbody = document.getElementById('deck-comparison-body');
            tbody.innerHTML = '';

            // Create table rows showing original card and its encrypted value
            originalNotations.forEach((card, index) => {
                const row = document.createElement('tr');
                const originalCell = document.createElement('td');
                const encryptedCell = document.createElement('td');
                
                originalCell.textContent = `${card} (${deck[index]})`;
                const encryptedValue = witnessResult.returnValue[index];
                const encryptedIndex = deck.indexOf(encryptedValue);
                encryptedCell.textContent = encryptedIndex !== -1 ? 
                    `${cardNotations[encryptedIndex]} (${encryptedValue})` : 
                    encryptedValue;
                
                row.appendChild(originalCell);
                row.appendChild(encryptedCell);
                tbody.appendChild(row);
            });
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