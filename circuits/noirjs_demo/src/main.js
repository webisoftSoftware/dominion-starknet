import circuit from '../../encryption/target/encryption.json' assert { type: "json" };
import { UltraHonkBackend, UltraHonkVerifier as Verifier } from '@noir-lang/backend_barretenberg';
import { Noir } from '@noir-lang/noir_js';
import decryptionCircuit from '../../decryption/target/decryption.json' assert { type: "json" };

// Define card constants at the top level
const suits = ['H', 'D', 'C', 'S'];  // Hearts, Diamonds, Clubs, Spades
const values = ['A', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K'];

function display(container, msg, type = 'info') {
    const c = document.getElementById('log-content');
    const p = document.createElement('p');
    const timestamp = new Date().toLocaleTimeString();
    p.textContent = `[${timestamp}] ${msg}`;
    p.className = `log-${type}`;
    c.appendChild(p);
    c.scrollTop = c.scrollHeight;
}

// Store encrypted deck globally so we can access it in decrypt
let encryptedDeck = null;
let encryptionInput = null;

// Encrypt button handler
document.getElementById('encrypt').addEventListener('click', async () => {
    try {
        // Clear previous results
        document.getElementById('logs').innerHTML = '<h2>Process Logs</h2><div id="log-content"></div>';
        document.getElementById('deck-comparison-body').innerHTML = '';
        
        display('logs', 'Starting initialization...');
        const backend = new UltraHonkBackend(circuit);
        const noir = new Noir(circuit);
        
        // Create deck with card notation
        const cardNotations = [];
        
        // Generate card notations (HA, D5, ST, etc.)
        for (const suit of suits) {
            for (const value of values) {
                cardNotations.push(suit + value);
            }
        }
        
        // Convert card notations to meaningful integers
        const deck = cardNotations.map(card => {
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
        
        encryptionInput = { 
            key: [75465, 45678, 98765, 45678],
            iv: [1, 2, 3, 4],
            deck
        };
        
        try {
            display('logs', 'Attempting to execute noir.execute()...');
            const witnessResult = await noir.execute(encryptionInput);
            
            console.log(witnessResult);
            display('logs', 'Witness generated successfully');
            
            display('logs', 'Generating proof...');
            const proof = await backend.generateProof(witnessResult.witness);
            display('logs', 'Proof generated successfully');
            
            // Store encrypted deck for later use
            encryptedDeck = witnessResult.returnValue;
            
            // Show the decrypt section
            document.getElementById('decrypt-section').style.display = 'block';
            
            // Display the deck comparison
            updateTable(deck, witnessResult.returnValue);
            
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

// Decrypt button handler
document.getElementById('decrypt').addEventListener('click', async () => {
    try {
        const card1 = document.getElementById('card1').value;
        const card2 = document.getElementById('card2').value;
        
        if (!encryptedDeck) {
            throw new Error('Please encrypt the deck first');
        }
        
        display('logs', 'Initializing decryption circuit...');
        const decryptionBackend = new UltraHonkBackend(decryptionCircuit);
        const decryptionNoir = new Noir(decryptionCircuit);
        
        const decryptInput = {
            key: encryptionInput.key,
            iv: encryptionInput.iv,
            deck: encryptedDeck,
            hand: [card1, card2]
        };
        
        display('logs', 'Attempting to decrypt hand...');
        const decryptWitnessResult = await decryptionNoir.execute(decryptInput);
        
        display('logs', 'Hand decrypted successfully', 'success');
        const decryptedHand = decryptWitnessResult.returnValue;
        
        display('logs', 'Generating decryption proof...', 'info');
        const decryptProof = await decryptionBackend.generateProof(decryptWitnessResult.witness);
        display('logs', 'Decryption proof generated successfully', 'success');
        
        // Display decrypted results in the dedicated section
        displayDecryptedHand(decryptedHand);
        
    } catch (err) {
        console.error('Decryption error:', err);
        display('logs', 'Decryption Error: ' + err.toString(), 'error');
        if (err.stack) {
            display('logs', 'Stack: ' + err.stack, 'error');
        }
    }
});

function getCardNotation(cardValue) {
    const suit = suits[Math.floor(cardValue / 100)];
    const valueNum = cardValue % 100;
    let value = '';
    if (valueNum === 1) value = 'A';
    else if (valueNum === 10) value = 'T';
    else if (valueNum === 11) value = 'J';
    else if (valueNum === 12) value = 'Q';
    else if (valueNum === 13) value = 'K';
    else value = valueNum.toString();
    return suit + value;
}

function updateTable(deck, encryptedDeck) {
    const tbody = document.getElementById('deck-comparison-body');
    tbody.innerHTML = '';
    
    deck.forEach((card, index) => {
        const row = document.createElement('tr');
        const originalCell = document.createElement('td');
        const encryptedCell = document.createElement('td');
        
        originalCell.textContent = getCardNotation(card);  // Just show card notation (e.g., "H7")
        encryptedCell.textContent = encryptedDeck[index];
        
        row.appendChild(originalCell);
        row.appendChild(encryptedCell);
        tbody.appendChild(row);
        
        // Add slight delay for staggered animation
        row.style.animationDelay = `${index * 50}ms`;
    });
}

function displayDecryptedHand(decryptedHand) {
    const handDiv = document.getElementById('decrypted-hand');
    const card1 = document.getElementById('decrypted-card-1');
    const card2 = document.getElementById('decrypted-card-2');
    
    card1.textContent = getCardNotation(decryptedHand[0]);
    card2.textContent = getCardNotation(decryptedHand[1]);
    
    handDiv.style.display = 'block';
}