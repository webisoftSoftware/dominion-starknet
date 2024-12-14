////////////////////////////////////////////////////////////////////////////////////////////////////
// ██████████                             ███              ███
// ░░███░░░░███                           ░░░              ░░░
//  ░███   ░░███  ██████  █████████████
//  ████  ████████   ████   ██████
//  ████████
//  ░███    ░███
//  ███░░███░░███░░███░░███ ░░███
//  ░░███░░███ ░░███
//  ███░░███░░███░░███
//  ░███    ░███░███ ░███ ░███ ░███ ░███
//  ░███  ░███ ░███  ░███ ░███ ░███ ░███
//  ░███
//  ░███    ███ ░███ ░███ ░███ ░███ ░███
//  ░███  ░███ ░███  ░███ ░███ ░███ ░███
//  ░███
//  ██████████  ░░██████  █████░███
//  █████ █████ ████ █████
//  █████░░██████  ████ █████
// ░░░░░░░░░░    ░░░░░░  ░░░░░ ░░░ ░░░░░
// ░░░░░ ░░░░ ░░░░░ ░░░░░  ░░░░░░  ░░░░
// ░░░░░
//
// Copyright (c) 2024 Dominion
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software
// is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////////////////////////

use dominion::models::structs::StructCard;
#[starknet::interface]
trait IActions<TContractState> {
    fn bet(ref self: TContractState, table_id: u32, amount: u32);
    fn fold(ref self: TContractState, table_id: u32);
    fn set_ready(ref self: TContractState, table_id: u32);
    fn join_table(ref self: TContractState, table_id: u32, chips_amount: u32);
    fn leave_table(ref self: TContractState, table_id: u32);
    fn reveal_hand(ref self: TContractState, table_id: u32, player_hand: Array<StructCard>, commit_hash: ByteArray);
}

#[dojo::contract]
mod actions_system {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use dojo::{model::ModelStorage, world::IWorldDispatcher};
    use dojo::event::{EventStorage};
    use dominion::models::components::{ComponentTable, ComponentPlayer, ComponentHand};
    use dominion::models::enums::{EnumPlayerState, EnumGameState};
    use dominion::models::traits::{IPlayer, ITable};
    use dominion::models::structs::StructCard;
    use alexandria_data_structures::array_ext::ArrayTraitExt;
    use core::sha256::compute_sha256_byte_array;
    use dominion::systems::table_manager::{ITableManagementDispatcher, ITableManagementDispatcherTrait};

    #[storage]
    struct Storage {
        table_manager: ContractAddress,
    }

    #[derive(Clone, Drop, Serde, Debug)]
    #[dojo::event]
    struct EventHandRevealed {
        #[key]
        m_table_id: u32,
        #[key]
        m_player: ContractAddress,
        #[key]
        m_commitment_hash: ByteArray,
        m_player_hand: Array<StructCard>,
        m_timestamp: u64,
    }

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    struct EventPlayerJoined {
        #[key]
        m_table_id: u32,
        #[key]
        m_player: ContractAddress,
        m_timestamp: u64,
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    struct EventAllPlayersReady {
        #[key]
        m_table_id: u32,
        m_players: Array<ContractAddress>,
        m_timestamp: u64,
    }

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    struct EventPlayerLeft {
        #[key]
        m_table_id: u32,
        #[key]
        m_player: ContractAddress,
        m_timestamp: u64,
    }

    #[constructor]
    fn constructor(ref self: ContractState, table_manager: ContractAddress) {
        self.table_manager.write(table_manager);
    }

    #[abi(embed_v0)]
    impl ActionsImpl of super::IActions<ContractState> {
        // Allows a player to join a table with specified chips amount
        fn join_table(ref self: ContractState, table_id: u32, chips_amount: u32) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            // Get table and player components
            let mut player: ComponentPlayer = world.read_model(caller);

            // Create new player if first time joining
            if !player.m_is_created {
                player = IPlayer::new(table_id, caller);
            }

            // Validate table capacity and chip amounts
            let mut table: ComponentTable = world.read_model(table_id);
            assert!(table.m_players.len() < 6, "Table is full");
            assert!(player.m_total_chips >= chips_amount, "Insufficient chips");
            assert!(table.m_min_buy_in < chips_amount, "Amount is less than min buy in");
            assert!(table.m_max_buy_in > chips_amount, "Amount is more than max buy in");

            // Update player state for joining table
            player.m_table_id = table_id;
            player.m_total_chips -= chips_amount;
            player.m_table_chips += chips_amount;

            // Set player state based on game state
            if table.m_state == EnumGameState::WaitingForPlayers {
                player.m_state = EnumPlayerState::Active;
            } else {
                player.m_state = EnumPlayerState::Waiting;
            }

            // Reset player's current bet
            player.m_current_bet = 0;

            // Update world state
            world.write_model(@player);
            table.m_players.append(caller);

            world.emit_event(@EventPlayerJoined {
                m_table_id: table_id,
                m_player: caller,
                m_timestamp: get_block_timestamp()
            });
            world.write_model(@table);
        }

        fn set_ready(ref self: ContractState, table_id: u32) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            let mut player: ComponentPlayer = world.read_model(caller);
            assert!(player.m_table_id == table_id, "Player is not at this table");
            assert!(player.m_state != EnumPlayerState::Active, "Player is active");

            player.m_state = EnumPlayerState::Ready;
            world.write_model(@player);

            let table: ComponentTable = world.read_model(table_id);
            let mut player_statuses: Array<bool> = array![];

            // Check if all players are ready.
            for i in 0..table.m_players.len() {
                if *table.m_players[i] == caller {
                    continue;
                }

                let player: ComponentPlayer = world.read_model(*table.m_players[i]);
                if player.m_state != EnumPlayerState::Ready {
                    break;
                }
                player_statuses.append(true);
            };

            // All players are ready.
            if player_statuses.len() == table.m_players.len() {
                world.emit_event(@EventAllPlayersReady {
                    m_table_id: table_id,
                    m_players: table.m_players,
                    m_timestamp: get_block_timestamp()
                });

                let mut table_manager: ITableManagementDispatcher = ITableManagementDispatcher { contract_address: self.table_manager.read() };
                table_manager.start_round(table_id);

            }
        }

        // Allows a player to leave a table and collect their chips
        fn leave_table(ref self: ContractState, table_id: u32) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            let mut player: ComponentPlayer = world.read_model(caller);

            // Reset player's table state and return chips
            player.m_table_id = 0;
            player.m_total_chips += player.m_table_chips;
            player.m_table_chips = 0;
            player.m_state = EnumPlayerState::Left;

            world.write_model(@player);
        }

        fn bet(ref self: ContractState, table_id: u32, amount: u32) {
            
            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            assert!(table.m_state == EnumGameState::RoundStart, "Game is not in betting phase");
            
            if amount == 0 {
                // Player has checked.
                table.advance_turn();
                return;
            }

            let mut player_component: ComponentPlayer = world.read_model(get_caller_address());
            assert!(player_component.m_state == EnumPlayerState::Active, "Player is not active");

            table.m_pot += player_component.place_bet(amount);
            table.advance_turn();
            world.write_model(@player_component);
            world.write_model(@table);
        }

        fn fold(ref self: ContractState, table_id: u32) {
            let mut world = self.world(@"dominion");

            let mut table: ComponentTable = world.read_model(table_id);
            assert!(table.m_state == EnumGameState::RoundStart, "Game is not in betting phase");

            let mut player_component: ComponentPlayer = world.read_model(get_caller_address());
            assert!(player_component.m_state == EnumPlayerState::Active, "Player is not active");

            if player_component.m_table_chips > 0 {
                table.m_pot += player_component.fold();
            }
            world.write_model(@player_component);
            table.advance_turn();
            world.write_model(@table);
        }

        // fn check(ref self: ContractState, table_id: u32) {
        //     let mut world = self.world(@"dominion");
        //     let mut table: ComponentTable = world.read_model(table_id);
        //     assert!(table.m_state == EnumGameState::RoundStart, "Game is not in betting phase");

        //     let mut player_component: ComponentPlayer = world.read_model(get_caller_address());
        //     assert!(player_component.m_state == EnumPlayerState::Active, "Player is not active");
        // }

        // fn set_ready(ref self: ContractState, table_id: u32) {
        //     let mut world = self.world(@"dominion");
        //     let mut table: ComponentTable = world.read_model(table_id);
        //     assert!(table.m_state == EnumGameState::WaitingForPlayers, "Game is not in waiting for players phase");

        //     let mut player_component: ComponentPlayer = world.read_model(get_caller_address());
        //     player_component.set_ready();

        //     table.advance_turn();
        //     world.write_model(@table);
        //     world.write_model(@player_component);
        // }

        fn reveal_hand(ref self: ContractState, table_id: u32, player_hand: Array<StructCard>, commit_hash: ByteArray) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            let mut table: ComponentTable = world.read_model(table_id);
            assert!(table.m_state == EnumGameState::Showdown, "Table is not at showdown phase");
            assert!(table.m_players.contains(@caller), "Player is not at this table");

            let mut player: ComponentPlayer = world.read_model(caller);
            assert!(player.m_state == EnumPlayerState::Active, "Player is not active");

            let mut hand: ComponentHand = world.read_model(caller);

            // Recompute the commitment hash of the hand to verify.
            let computed_hash: [u32; 8] = compute_sha256_byte_array(@commit_hash);
            // assert!(computed_hash == hand.m_commitment_hash, "Commitment hash does not match");

            // Commitment has verified, overwrite the encrypted cards with unencrypted ones to display to all players.
            hand.m_cards = player_hand.clone();
            //TODO: Update player state to Revealed.
            // Before calcualting hand, make sure all players have revealed their hands.
            world.write_model(@hand);
            world.emit_event(@EventHandRevealed {
                m_table_id: table_id,
                m_player: caller,
                m_commitment_hash: commit_hash,
                m_player_hand: player_hand,
                m_timestamp: get_block_timestamp(),
            });
        }

        // }

        // fn call(ref self: ContractState, table_id: u32) { // Implement call logic
        // }

        // fn raise(ref self: ContractState, table_id: u32, amount: u256) { // Implement raise logic
        // }

        // fn all_in(ref self: ContractState, table_id: u32) { // Implement all-in logic
        // }
    }
}
