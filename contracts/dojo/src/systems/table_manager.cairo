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
//  █���████████  ░░██████  █████░███
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

use starknet::ContractAddress;
use core::traits::Into;
use core::dict::Felt252Dict;

#[starknet::interface]
trait ITableManagement<TContractState> {
    // Game Master Functions
    fn start_hand(ref self: TContractState, table_id: u32);
    fn advance_round(ref self: TContractState, table_id: u32);
    fn end_hand(ref self: TContractState, table_id: u32);
    fn skip_turn(ref self: TContractState, table_id: u32, player: ContractAddress);
    fn showdown(ref self: TContractState, table_id: u32);
    // Timeout Functions
    fn kick_player(ref self: TContractState, table_id: u32, player: ContractAddress);
    // Admin Functions
    fn change_game_manager(ref self: TContractState, new_game_master: ContractAddress);
    fn get_game_manager(self: @TContractState) -> ContractAddress;
}

#[dojo::contract]
mod table_management_system {
    use starknet::{ContractAddress, get_caller_address, TxInfo, get_tx_info};
    use dojo::{model::ModelStorage, world::IWorldDispatcher};
    use dominion::models::components::{ComponentTable, ComponentPlayer, ComponentHand};
    use dominion::models::enums::{EnumGameState, EnumPlayerState, EnumPosition, EnumHandRank};
    use dominion::models::traits::{ITable, IPlayer, IHand, EnumHandRankPartialOrd};
    use dominion::models::utils;

    use alexandria_data_structures::array_ext::ArrayTraitExt;

    const MIN_PLAYERS: u32 = 2;

    #[storage]
    struct Storage {
        game_master: ContractAddress,
    }

    fn dojo_init(ref self: ContractState) {
        let tx_info: TxInfo = get_tx_info().unbox();

        // Access the account_contract_address field
        let sender: ContractAddress = tx_info.account_contract_address;

        // Set the game master to the sender
        self.game_master.write(sender);
    }

    #[abi(embed_v0)]
    impl TableManagementImpl of super::ITableManagement<ContractState> {
        fn start_hand(ref self: ContractState, table_id: u32) {
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can start the round"
            );

            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);

            assert!(
                table.m_state == EnumGameState::WaitingForPlayers || table.m_state == EnumGameState::HandEnd,
                "Game is already in progress"
            );
            assert!(table.m_players.len() >= MIN_PLAYERS, "Not enough players to start the round");

            // Set the game state to start of hand.
            table.m_state = EnumGameState::HandStart;
            world.write_model(@table);
        }

        fn advance_round(ref self: ContractState, table_id: u32) {
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can advance the hand"
            );

            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            assert!(table.m_state == EnumGameState::RoundEnd, "Game is not at round end");

            // Remove players sitting out.
            InternalImpl::_remove_sitting_out_players(ref world, ref self, table_id);

            // Update order and dealer chip position (Small Blind, Big Blind, etc.).
            InternalImpl::_update_positions(ref world, table_id);

            table.m_state = EnumGameState::RoundStart;
            table.m_pot = 0;
            table.m_community_cards = array![];
            world.write_model(@table);
        }

        fn end_hand(ref self: ContractState, table_id: u32) {
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can end the round"
            );

            self.advance_round(table_id);
            let mut world = self.world(@"dominion");

            // Reset the table.
            let mut table: ComponentTable = world.read_model(table_id);
            table.reset_table();

            table.m_state = EnumGameState::HandEnd;
            world.write_model(@table);
        }

        fn skip_turn(ref self: ContractState, table_id: u32, player: ContractAddress) {
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can skip the turn"
            );

            let mut world = self.world(@"dominion");
            let mut player_component: ComponentPlayer = world.read_model(player);
            assert!(player_component.m_state == EnumPlayerState::Active, "Player is not active");

            let mut table: ComponentTable = world.read_model(table_id);
            assert!(table.m_current_turn == table.m_players.position(@player).unwrap().try_into().unwrap(), "Player is not the current turn");

            // Skip turn.
            player_component.m_state = EnumPlayerState::Folded;
            table.advance_turn();
            world.write_model(@table);
            world.write_model(@player_component);
        }

        fn showdown(ref self: ContractState, table_id: u32) {
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can determine the winner"
            );

            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            assert!(table.m_state == EnumGameState::Showdown, "Hand is not at showdown");

            // Track winners and their hand ranks in a single pass.
            let mut winners_dict: Felt252Dict<bool> = Default::default();
            let mut current_best_rank: Option<EnumHandRank> = Option::None;
            let mut pot_share_count: u32 = 0;

            // Single pass through all players.
            for address in table.m_players.span() {
                let player_component: ComponentPlayer = world.read_model(*address);
                if player_component.m_state == EnumPlayerState::Active {
                    let hand: ComponentHand = world.read_model(*address);
                    let hand_rank = hand.evaluate_hand(@table.m_community_cards).expect('Hand evaluation failed');
                    
                    match @current_best_rank {
                        Option::None => {
                            // First active player sets the initial best rank.
                            winners_dict.insert((*address).into(), true);
                            current_best_rank = Option::Some(hand_rank);
                            pot_share_count = 1;
                        },
                        Option::Some(best_rank) => {
                            let comparison = utils::tie_breaker(@hand_rank, best_rank);
                            if comparison > 0 {
                                // New best hand found- clear previous winners.
                                winners_dict = Default::default();
                                winners_dict.insert((*address).into(), true);
                                current_best_rank = Option::Some(hand_rank);
                                pot_share_count = 1;
                            } else if comparison == 0 {
                                // Tied for best hand- add to winners.
                                winners_dict.insert((*address).into(), true);
                                pot_share_count += 1;
                            }
                            // If comparison < 0, this hand is worse, so we ignore it.
                        }
                    };
                }
            };

            // At this point:
            // - Winners_dict contains all winning players (winners_dict.get(player.into()) == true).
            // - Pot_share_count contains the number of winners to split the pot between.
            // - Current_best_rank contains the winning hand rank.

            // Distribute pot.
            let pot_share = table.m_pot / pot_share_count;
            for player in table.m_players {
                if winners_dict.get(player.into()) {
                    InternalImpl::_distribute_chips(ref world,player, pot_share);
                }
            }
        }

        fn kick_player(ref self: ContractState, table_id: u32, player: ContractAddress) {
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can kick players"
            );

            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            let player_model: ComponentPlayer = world.read_model(player);
            table.remove_player(@player);
            world.erase_model(@player_model);
            world.write_model(@table);
        }

        fn change_game_manager(ref self: ContractState, new_game_master: ContractAddress) {
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can change the game master"
            );
            self.game_master.write(new_game_master);
        }

        fn get_game_manager(self: @ContractState) -> ContractAddress {
            self.game_master.read()
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _distribute_chips(ref world: dojo::world::WorldStorage, player: ContractAddress, amount: u32) {
            let mut player_component: ComponentPlayer = world.read_model(player);
            player_component.m_table_chips += amount;
            world.write_model(@player_component);
        }

        fn _remove_sitting_out_players(ref world: dojo::world::WorldStorage, ref contract: ContractState, table_id: u32) {
            let mut table: ComponentTable = world.read_model(table_id);
            for i in 0..table.m_players.len() {
                let mut player: ComponentPlayer = world.read_model(*table.m_players[i]);
                if player.m_state == EnumPlayerState::Left {
                    contract.kick_player(table_id, *table.m_players[i]);
                }
            };

            world.write_model(@table);
        }

        fn _update_positions(ref world: dojo::world::WorldStorage, table_id: u32) {
            let mut table: ComponentTable = world.read_model(table_id);

            let mut new_players: Array<ContractAddress> = array![];
            for i in 0..table.m_players.len() {
                let mut player: ComponentPlayer = world.read_model(*table.m_players[i]);
                // If player is not sitting out or waiting, set their new position.
                if player.m_state != EnumPlayerState::Left
                    && player.m_state != EnumPlayerState::Waiting {
                    match player.m_position {
                        EnumPosition::Dealer => {
                            player.m_position = EnumPosition::SmallBlind;

                            // Set the new dealer and turn.
                            table.m_current_dealer = i.try_into().expect('Index out of bounds');
                            table.m_current_turn = i.try_into().expect('Index out of bounds');
                        },
                        EnumPosition::SmallBlind => {
                            player.m_position = EnumPosition::BigBlind;
                        },
                        _ => {
                            if i + 1 < table.m_players.len() {
                                let mut next_player: ComponentPlayer = world
                                    .read_model(*table.m_players[i + 1]);
                                player.m_position = next_player.m_position;
                            } else {
                                // Wrap around to the first player.
                                let mut next_player: ComponentPlayer = world
                                    .read_model(*table.m_players[0]);
                                player.m_position = next_player.m_position;
                            }
                        }
                    };
                }
                new_players.append(*table.m_players[i]);
            };

            table.m_players = new_players;
            world.write_model(@table);
        }
    }
}
