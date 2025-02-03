import express from 'express';
import cors from 'cors';
import { dojoConfig } from '../dojo/dojoConfig.mjs';
import { WebSocket } from 'ws';
import { createClient } from 'graphql-transport-ws';
import { spawn } from 'child_process';
import path from 'path';
import { fileURLToPath } from 'url';
import chokidar, { FSWatcher } from 'chokidar';
// import { createHash } from 'crypto';
// import { executeCircuit, readSecrets } from './utils.mjs';
// import { init, ParsedEntity, QueryBuilder, SchemaType, SDK } from '@dojoengine/sdk';
// import { EnumGameState, schema } from '../dojo/models.mjs';

// Create Express server
const app = express();
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 60000,
}));

// Create WebSocket client for GraphQL subscriptions
const wsClient = createClient({
  url: `ws://${dojoConfig.toriiUrl}/graphql`,
  webSocketImpl: WebSocket,
  retryAttempts: 5,
});

// Example subscription function
async function subscribeToEntityUpdates(callback: (data: any) => void) {
  return wsClient.subscribe(
    {
      query: `
       subscription {
          eventMessageUpdated {
          models {
              __typename
              ... on dominion_EventPlayerLeft {
                m_table_id
                m_player
                m_timestamp
              }
              __typename
              ... on dominion_EventPlayerJoined {
                m_table_id
                m_player
                m_timestamp
              }
              __typename
              ... on dominion_EventTableCreated {
                m_table_id
                m_timestamp
              }
              __typename
              ... on dominion_EventTableShutdown {
                m_table_id
                m_timestamp
              }
              __typename
              ... on dominion_EventDecryptCCRequested {
                m_table_id
                m_timestamp
                m_cards {
                  m_num_representation
                }
              }
              __typename
              ... on dominion_EventEncryptDeckRequested {
                m_table_id
                m_timestamp
                m_deck {
                  m_num_representation
                }
              }
              __typename
              ... on dominion_EventAuthHashRequested {
                m_table_id
                m_player
                m_auth_hash
                m_timestamp
              }
              __typename
              ... on dominion_EventAuthHashVerified {
                m_table_id
                m_timestamp
              }
              __typename
              ... on dominion_EventDecryptHandRequested {
                m_table_id
                m_player
                m_hand {
                  m_num_representation
                }
                m_timestamp
              }
              __typename
              ... on dominion_EventShowdownRequested {
                m_table_id
                m_timestamp
              }
              __typename
              ... on dominion_EventRevealShowdownRequested {
                m_table_id
                m_player
                m_hand {
                  m_num_representation
                }
                m_timestamp
              }
            }
          }
        }
      `,
    },
    {
      next: (data) => callback(data),
      error: (error) => console.error('Subscription error:', error),
      complete: () => console.log('Subscription complete'),
    },
  );
}


// Example query function
async function queryEntities() {
  const response = await fetch(`http://${dojoConfig.toriiUrl}/graphql`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      query: `
        query {
            models {
                edges {
                    node {
                        id
                        name
                        classHash
                        contractAddress
                    }
                }
                totalCount
            }
        }
      `,
    }),
  });

  return response.json();
}

// REST endpoints
app.get('/entities', async (req, res) => {
  try {
    const data = await queryEntities();
    console.log(JSON.stringify(data));
    res.json(data);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error });
  }
});

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

// app.post('/decrypt-hand', async (req, res) => {
//   try {
//     // Extract parameters from request body
//     const { tableID, playerOnChainAddress, playerSecret } = req.body;
//
//     // Validate input
//     if (!playerOnChainAddress || !playerSecret) {
//       console.error('Missing required parameters');
//       res.status(400).send('Missing required parameters');
//     }
//
//     const table = await torii?.getEntities({
//       query: new QueryBuilder()
//         .namespace('dominion', (n) => n.entity('ComponentHand', (e) => e.eq('m_table_id', Number(tableID))))
//         .build(),
//       callback: (resp: { error: any; data: ParsedEntity<SchemaType>[] }) => {
//         if (resp.error) {
//           console.error("Error fetching player's info:", resp.error);
//           res.status(500).send(resp.error);
//         }
//         return resp.data as ParsedEntity<SchemaType>[];
//       },
//     });
//
//     const state: EnumGameState = table?.at(0)?.models?.dominion?.["ComponentTable"]?.m_state;
//
//     if (state === EnumGameState.Shutdown) {
//       console.error("Cannot decrypt hand of a shutdown table");
//       res.status(500).send("Cannot decrypt hand of a shutdown table");
//     }
//
//     const hand = await torii?.getEntities({
//       query: new QueryBuilder()
//         .namespace("dominion", n =>
//         n.entity("ComponentHand", e =>
//         e.eq("m_owner", playerOnChainAddress.toString())))
//         .build(),
//       callback: (resp) => {
//         if (resp.error) {
//           console.error('Error fetching player\'s hand:', resp.error);
//           res.status(500).send(resp.error);
//         }
//       }
//     });
//
//     const { key, iv } = readSecrets(Number(tableID));
//     if (!key || !iv) {
//       console.error('Missing required parameters in environment variables');
//       res.status(500).send('Missing required parameters in environment variables');
//     }
//
//     // Recreate the hash from on-chain address & secret
//     const reconstructedHash = createHash('sha256')
//       .update(playerOnChainAddress + playerSecret)
//       .digest('hex');
//
//     const onChainHash  = [...hand?.at(0)?.models?.dominion?.["ComponentHand"]?.m_commitment_hash].toString();
//
//     // Verify the hash with the player's hash sent from Torii for this player address
//     if (reconstructedHash !== onChainHash) {
//       console.error('Invalid player address or secret');
//       res.status(401).send('Invalid player address or secret');
//     }
//
//     // TODO: Get the encrypted deck from Torii
//     const encryptedDeck = [
//       0x0000000000, 0x1111111111, 0x2222222222, 0x3333333333, 0x4444444444, 0x5555555555, 0x6666666666, 0x7777777777,
//       0x8888888888, 0x9999999999, 0xAAAAAAAAAA, 0xBBBBBBBBBB, 0xCCCCCCCCCC, 0xDDDDDDDDDD, 0xEEEEEEEEEE, 0xFFFFFFFF,
//       0x1111111111, 0x2222222222, 0x3333333333, 0x4444444444, 0x5555555555, 0x6666666666, 0x7777777777, 0x8888888888,
//       0x9999999999, 0xAAAAAAAAAA, 0xBBBBBBBBBB, 0xCCCCCCCCCC, 0xDDDDDDDDDD, 0xEEEEEEEEEE, 0xFFFFFFFF, 0x0000000001,
//       0x1111111112, 0x2222222223, 0x3333333334, 0x4444444445, 0x5555555556, 0x6666666667, 0x7777777778, 0x8888888889,
//       0x999999999A, 0xAAAAAAAAAB, 0xBBBBBBBBBC, 0xCCCCCCCCCD, 0xDDDDDDDDDE, 0xEEEEEEEEEF, 0xFFFFFFFFF0, 0x1111111113,
//       0x2222222224, 0x3333333335, 0x4444444446, 0x5545654836,
//     ];
//
//     // Execute decryption circuit
//     // const { witnessResult: decryptWitnessResult, proof: decryptProof } =
//     //   await executeCircuit(decryption2CardsCircuit, {
//     //     key,
//     //     iv,
//     //     deck: encryptedDeck,
//     //     hand,
//     //   });
//
//     // Return decrypted cards and proof
//     // res.json({
//     //   success: true,
//     //   decryptedHand: decryptWitnessResult.returnValue,
//     //   decryptProof,
//     // });
//
//   } catch (err) {
//     console.error('Decryption error:', err);
//     res.status(500).json({
//       success: false,
//       error: err,
//     });
//   }
// });

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Add top-level signal handlers
['SIGINT', 'SIGTERM', 'SIGQUIT'].forEach(signal => {
  process.on(signal, () => {
    console.log(`[INFO]: \tReceived ${signal}, terminating...`);
    process.exit();
  });
});

// Watch the src directory for changes
const watcher: FSWatcher = chokidar.watch(path.join(__dirname, '..', '../src/'), {
  ignored: /(^|[\/\\])\../, // ignore dotfiles
  persistent: true,
});
// @ts-ignore
watcher.on('change', (path: string) => {
  if (path.endsWith('.ts') || path.endsWith('.mts')) {
    console.log(`[INFO]: \tFile ${path} changed, recompiling...`);

    const tsc = spawn('tsc', [], {
      stdio: 'inherit',
      shell: true
    });

    // Handle potential tsc process errors
    tsc.on('error', (err) => {
      console.error('[ERROR]: \tFailed to start TypeScript compilation:', err);
      tsc.kill();
    });

    tsc.on('close', (code) => {
      if (code !== 0) {
        console.error('[ERROR]: \tTypeScript compilation failed');
        return;
      }

      // Clean exit and restart
      watcher.close().then(() => {
        spawn(process.argv[0], ["--no-warnings", process.argv[1]], {
          cwd: process.cwd(),
          stdio: 'inherit'
        });

        // Add top-level signal handlers
        ['SIGINT', 'SIGTERM', 'SIGQUIT'].forEach(signal => {
          process.on(signal, () => {
            console.log(`[INFO]: \tReceived ${signal}, terminating...`);
            process.exit();
          });
        });

        process.exit(0);
      });
    });
  }
});

app.listen(3000, async () => {
  console.log('[INFO]: \tListening on port 3000...');

  // Start subscription in background
  setImmediate(() => {
    console.log("[INFO]: \tSubscribing to events...");
    subscribeToEntityUpdates((data) => {
      console.log('[INFO]: \tReceived dominion event:', JSON.stringify(data));
    }).catch(error => {
      console.error('[ERROR]: \tSubscription error:', error);
    });
  });
});
