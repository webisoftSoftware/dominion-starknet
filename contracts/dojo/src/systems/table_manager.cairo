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
use dominion::models::structs::StructCard;

#[starknet::interface]
trait ITableManagement<TContractState> {
    // Game Master Functions
    fn start_round(ref self: TContractState, table_id: u32);
    fn end_round(ref self: TContractState, table_id: u32);
    fn skip_turn(ref self: TContractState, table_id: u32, player: ContractAddress);
    fn advance_street(ref self: TContractState, table_id: u32);
    fn post_showdown(ref self: TContractState, table_id: u32, deck: Array<StructCard>);
    fn post_encrypt_deck(ref self: TContractState, table_id: u32, encrypted_deck: Array<StructCard>);
    fn post_decrypted_community_cards(ref self: TContractState, table_id: u32, cards: Array<StructCard>);
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
    use dominion::models::structs::StructCard;
    use dojo::event::{EventStorage};
    use origami_random::deck::{Deck, DeckTrait};

    use alexandria_data_structures::array_ext::ArrayTraitExt;

    const MIN_PLAYERS: u32 = 2;

    #[storage]
    struct Storage {
        game_master: ContractAddress,
    }

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    struct EventRoundStarted {
        #[key]
        m_table_id: u32,
        m_timestamp: u64,
    }

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    struct EventStreetAdvanced {
        #[key]
        m_table_id: u32,
        m_timestamp: u64,
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    struct EventEncryptDeckRequested {
        #[key]
        m_table_id: u32,
        m_deck: Array<StructCard>,
        m_timestamp: u64
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    struct EventDecryptHandRequested {
        #[key]
        m_table_id: u32,
        m_hand: Array<StructCard>,
        m_timestamp: u64
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    struct EventDecryptCCRequested {
        #[key]
        m_table_id: u32,
        m_cards: Array<StructCard>,
        m_timestamp: u64
    }

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    struct EventShowdownRequested {
        #[key]
        m_table_id: u32,
        m_timestamp: u64
    }

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    struct EventRoundEnded {
        #[key]
        m_table_id: u32,
        m_timestamp: u64
    }

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    struct EventTableShutdown {
        #[key]
        m_table_id: u32,
        m_timestamp: u64
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
        fn start_round(ref self: ContractState, table_id: u32) {
            // TODO: Make this transaction automatic after all players are ready.
            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);

            assert!(
                table.m_state == EnumGameState::WaitingForPlayers || table.m_state == EnumGameState::RoundEnd,
                "Game is already in progress"
            );
            assert!(table.m_players.len() >= MIN_PLAYERS, "Not enough players to start the round");

            // Update order and dealer chip position (Small Blind, Big Blind, etc.).
            InternalImpl::_update_positions(ref world, table_id);

            // Remove players sitting out.
            InternalImpl::_remove_sitting_out_players(ref world, ref self, table_id);


            // Set the game state to start of hand.
            table.m_state = EnumGameState::RoundStart;
            world.write_model(@table);

            world.emit_event(@EventRoundStarted {
                m_table_id: table_id,
                m_timestamp: starknet::get_block_timestamp()
            });
        }

        fn post_encrypt_deck(ref self: ContractState, table_id: u32, encrypted_deck: Array<StructCard>) {
            // Update deck with encrypted deck, update game state.
            // Then shuffle and deal cards.

            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can update the deck"
            );

            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            table.m_deck = encrypted_deck;

            let mut dealer = origami_random::deck::DeckTrait::new(starknet::get_block_timestamp().into(), table.m_deck.len());

            // Shuffle the deck.
            for i in 0..table.m_players.len() {
                // Give card pair to each player and update table and player's hands.
                let random_index: u8 = dealer.draw();
                let card: StructCard = table.m_deck[random_index.into()].clone();
                let mut player_hand: ComponentHand = world.read_model(*table.m_players[i]);
                assert!(player_hand.m_cards.len() < 2, "Player already has 2 cards");
                player_hand.m_cards.append(card);

                let random_index: u8 = dealer.draw();
                let card: StructCard = table.m_deck[random_index.into()].clone();
                player_hand.m_cards.append(card);
                world.write_model(@player_hand);

                world.emit_event(@EventDecryptHandRequested {
                    m_table_id: table_id,
                    m_hand: player_hand.m_cards,
                    m_timestamp: starknet::get_block_timestamp()
                });
            };

            table.m_state = EnumGameState::PreFlop;
            world.write_model(@table);
        }

        fn advance_street(ref self: ContractState, table_id: u32) {
            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);

            match table.m_state {
                // TODO: At every Game state changes emit an event: <table_id, cards_to_reveal>
                // If flop 3 cards, turn 1 card, river 1 card.
                // Pop them off the deck and emit the event.
            
                EnumGameState::PreFlop => {
                    // Deal cards.
                },
                EnumGameState::Flop => {
                    // Deal cards.
                },
                EnumGameState::Turn => {
                    // Deal cards.
                },
                EnumGameState::River => {
                    // Deal cards.
                },
                EnumGameState::Showdown => {
                    // Deal cards.
                    // TODO: Implement request_showdown(table_id: u32) // Emit event so each client knows to reveal their hand.
                    // Then implement post_showdown(table_id: u32, players_hands: Array<u256>) that each player will call to reveal their hand.
                },
                EnumGameState::RoundEnd => {
                    // Deal cards.
                },
                _ => panic!("Cannot advance street in this state")
            }

            world.write_model(@table);
        }

        fn end_round(ref self: ContractState, table_id: u32) {
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can end the round"
            );

            let mut world = self.world(@"dominion");

            // Reset the table.
            let mut table: ComponentTable = world.read_model(table_id);
            table.reset_table();

            table.m_state = EnumGameState::RoundEnd;
            world.write_model(@table);

            // Start the next round.
            self.start_round(table_id);
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
            player_component.fold();
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
            assert!(table.m_community_cards.len() == 5, "Community cards are not set");
            assert!(table.m_state == EnumGameState::CommunityCardsDecrypted, "Community cards are not decrypted");

            // Before calculating hand, make sure all players have revealed their hands.
            for player in table.m_players.span() {
                let player_component: ComponentPlayer = world.read_model(*player);
                assert!(player_component.m_state == EnumPlayerState::Revealed, "All Players must have revealed their hand");
            };

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
            for player in table.m_players.span() {
                if winners_dict.get((*player).into()) {
                    InternalImpl::_distribute_chips(ref world, *player, pot_share);
                }
            };

            // Reset the table.
            table.reset_table();
            table.m_state = EnumGameState::RoundEnd;
            world.write_model(@table);
        }

        
        fn post_showdown(ref self: ContractState, table_id: u32, deck: Array<StructCard>) {
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can update the deck"
            );
        }

        fn post_decrypted_community_cards(ref self: ContractState, table_id: u32, cards: Array<StructCard>) {
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can update the community cards"
            );

            let mut world = self.world(@"dominion");
            world.emit_event(@EventDecryptCCRequested {
                m_table_id: table_id,
                m_cards: cards.clone(),
                m_timestamp: starknet::get_block_timestamp()
            });

            let mut table: ComponentTable = world.read_model(table_id);
            table.m_community_cards = cards;
            world.write_model(@table);
        }

        fn kick_player(ref self: ContractState, table_id: u32, player: ContractAddress) {
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can kick players"
            );

            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            let mut player_model: ComponentPlayer = world.read_model(player);

            // Reset player's table state and return chips
            player_model.m_table_id = 0;
            player_model.m_total_chips += player_model.m_table_chips;
            player_model.m_table_chips = 0;
            player_model.m_state = EnumPlayerState::Left;

            table.remove_player(@player);
            world.write_model(@table);
            world.write_model(@player_model);
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

            // Find out if there's a dealer.
            let mut dealer_found: bool = false;
            for i in 0..table.m_players.len() {
                let mut player: ComponentPlayer = world.read_model(*table.m_players[i]);
                if player.m_state != EnumPlayerState::Left && player.m_state != EnumPlayerState::Waiting {
                    if player.m_position == EnumPosition::Dealer {
                        dealer_found = true;
                        break;
                    }
                }
            };


            let mut new_players: Array<ContractAddress> = array![];
            for i in 0..table.m_players.len() {
                let mut player: ComponentPlayer = world.read_model(*table.m_players[i]);
                // If player is not sitting out or waiting, set their new position.
                if player.m_state != EnumPlayerState::Left
                    && player.m_state != EnumPlayerState::Waiting {
                    match player.m_position {
                        EnumPosition::Dealer => {
                            // Set the new dealer and turn.
                            table.m_current_dealer = i.try_into().expect('Index out of bounds');
                            table.m_current_turn = ((i + 2) % table.m_players.len()).try_into().expect('Index out of bounds');
                            player.m_position = EnumPosition::SmallBlind;

                        },
                        EnumPosition::SmallBlind => {
                            table.m_current_turn = ((i + 2) % table.m_players.len()).try_into().expect('Index out of bounds');
                            player.m_position = EnumPosition::BigBlind;
                        },
                        _ => {
                            if !dealer_found {
                                // If there's no dealer, set the new dealer to this player.
                                player.m_position = EnumPosition::Dealer;
                                table.m_current_dealer = i.try_into().expect('Index out of bounds');
                                table.m_current_turn = i.try_into().expect('Index out of bounds');
                                break;
                            }

                            if i + 1 < table.m_players.len() {
                                let mut next_player: ComponentPlayer = world.read_model(*table.m_players[i + 1]);
                                player.m_position = next_player.m_position;
                                world.write_model(@player);
                            } else {
                                // Wrap around to the first player.
                                let mut next_player: ComponentPlayer = world
                                    .read_model(*table.m_players[0]);
                                player.m_position = next_player.m_position;
                                world.write_model(@player);
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
