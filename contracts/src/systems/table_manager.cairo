use starknet::ContractAddress;
use core::traits::Into;
use core::dict::Felt252Dict;
use dominion::models::structs::StructCard;

#[starknet::interface]
trait ITableManagement<TContractState> {
    // Table Manager Functions
    fn start_round(ref self: TContractState, table_id: u32);
    fn skip_turn(ref self: TContractState, table_id: u32, player: ContractAddress);
    fn advance_street(ref self: TContractState, table_id: u32);
    fn post_auth_hash(ref self: TContractState, table_id: u32, auth_hash: ByteArray);
    fn post_encrypt_deck(
        ref self: TContractState, table_id: u32, encrypted_deck: Array<StructCard>
    );
    fn post_decrypted_community_cards(
        ref self: TContractState, table_id: u32, cards: Array<StructCard>
    );
    fn showdown(ref self: TContractState, table_id: u32);
    // Timeout Functions
    fn kick_player(ref self: TContractState, table_id: u32, player: ContractAddress);

    fn create_table(
        ref self: TContractState, small_blind: u32, big_blind: u32, min_buy_in: u32, max_buy_in: u32
    );

    fn shutdown_table(ref self: TContractState, table_id: u32);
    // Admin Functions
    fn change_table_manager(ref self: TContractState, new_table_manager: ContractAddress);
    fn get_table_manager(self: @TContractState) -> ContractAddress;
}

#[dojo::contract]
mod table_management_system {
    use starknet::{ContractAddress, get_caller_address, TxInfo, get_tx_info};
    use dojo::{model::ModelStorage, world::IWorldDispatcher};
    use dominion::models::components::{ComponentTable, ComponentPlayer, ComponentHand, ComponentSidepot};
    use dominion::models::enums::{EnumGameState, EnumPlayerState, EnumPosition, EnumHandRank, EnumRankMask};
    use dominion::models::traits::{ITable, IPlayer, IHand, EnumHandRankPartialOrd, ISidepot, ComponentPlayerDisplay,
         EnumRankMaskPartialOrd, IEnumRankMask};
    use dominion::models::utils;
    use dominion::models::structs::StructCard;
    use dojo::event::{EventStorage};
    use origami_random::deck::{Deck, DeckTrait};

    use alexandria_data_structures::array_ext::ArrayTraitExt;

    const MIN_PLAYERS: u32 = 2;

    #[storage]
    struct Storage {
        table_manager: ContractAddress,
        counter: u32,
    }

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    struct EventTableCreated {
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

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    struct EventRequestBet {
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
        m_deck: Span<StructCard>,
        m_timestamp: u64
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    struct EventDecryptHandRequested {
        #[key]
        m_table_id: u32,
        #[key]
        m_player: ContractAddress,
        m_hand: Span<StructCard>,
        m_timestamp: u64
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    struct EventDecryptCCRequested {
        #[key]
        m_table_id: u32,
        m_cards: Span<StructCard>,
        m_timestamp: u64
    }

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    struct EventShowdownRequested {
        #[key]
        m_table_id: u32,
        m_timestamp: u64
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    struct EventAuthHashRequested {
        #[key]
        m_table_id: u32,
        #[key]
        m_player: ContractAddress,
        m_auth_hash: ByteArray,
        m_timestamp: u64
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    struct EventRevealShowdownRequested {
        #[key]
        m_table_id: u32,
        #[key]
        m_player: ContractAddress,
        m_hand: Span<StructCard>,
        m_timestamp: u64
    }

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    struct EventAuthHashVerified {
        #[key]
        m_table_id: u32,
        m_timestamp: u64
    }

    fn dojo_init(ref self: ContractState) {
        let tx_info: TxInfo = get_tx_info().unbox();

        // Access the account_contract_address field
        let sender: ContractAddress = tx_info.account_contract_address;

        // Set the table manager to the sender
        self.table_manager.write(sender);
        self.counter.write(1);
    }

    #[abi(embed_v0)]
    impl TableManagementImpl of super::ITableManagement<ContractState> {
        fn create_table(
            ref self: ContractState,
            small_blind: u32,
            big_blind: u32,
            min_buy_in: u32,
            max_buy_in: u32
        ) {
            assert!(
                self.table_manager.read() == get_caller_address(),
                "Only the table manager can create tables"
            );

            assert!(small_blind > 0, "Small blind cannot be less than 0");
            assert!(big_blind > small_blind, "Big blind cannot be less than small blind");

            assert!(max_buy_in > 0, "Maximum buy-in cannot be less than 0");
            assert!(
                max_buy_in > min_buy_in, "Minimum buy-in cannot be greater than maximum buy-in"
            );

            let table_id: u32 = self.counter.read();
            let mut world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            assert!(table.m_state == EnumGameState::Shutdown, "Table is already created");

            // Initialize new table with provided parameters.
            let mut new_table: ComponentTable = ITable::new(
                table_id, small_blind, big_blind, min_buy_in, max_buy_in, array![]
            );
            new_table.m_state = EnumGameState::WaitingForPlayers;
            new_table._initialize_deck();

            // Save table to world state and increment counter
            world.write_model(@new_table);
            self.counter.write(table_id + 1);

            world
                .emit_event(
                    @EventTableCreated {
                        m_table_id: table_id, m_timestamp: starknet::get_block_timestamp()
                    }
                );
        }

        fn shutdown_table(ref self: ContractState, table_id: u32) {
            assert!(
                self.table_manager.read() == get_caller_address(),
                "Only the table manager can shutdown the table"
            );

            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            table.m_state = EnumGameState::Shutdown;
            world.write_model(@table);

            world
                .emit_event(
                    @EventTableShutdown {
                        m_table_id: table_id, m_timestamp: starknet::get_block_timestamp()
                    }
                );
        }

        fn start_round(ref self: ContractState, table_id: u32) {
            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);

            assert!(
                table.m_state == EnumGameState::WaitingForPlayers
                    || table.m_state == EnumGameState::Showdown,
                "Game is not in a valid state to start a round"
            );
            assert!(table.m_players.len() >= MIN_PLAYERS, "Not enough players to start the round");

            // Reset the table (Community cards and pot are cleared out).
            table.reset_table();

            // Update order and dealer chip position (Small Blind, Big Blind, etc.).
            InternalImpl::_update_positions(ref world, ref table);

            // Remove players sitting out.
            InternalImpl::_remove_sitting_out_players(ref world, ref self, ref table);

            // let mut table: ComponentTable = world.read_model(table_id);
            table.m_state = EnumGameState::RoundStarted;
            world.write_model(@table);

            world
                .emit_event(
                    @EventEncryptDeckRequested {
                        m_table_id: table_id,
                        m_deck: table.m_deck.span(),
                        m_timestamp: starknet::get_block_timestamp()
                    }
                );
        }

        // Update deck with encrypted deck, update game state.
        fn post_encrypt_deck(
            ref self: ContractState, table_id: u32, encrypted_deck: Array<StructCard>
        ) {
            assert!(
                self.table_manager.read() == get_caller_address(),
                "Only the table manager can update the deck"
            );
            assert!(encrypted_deck.len() == 52, "Deck must contain 52 cards");

            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            assert!(
                table.m_state == EnumGameState::RoundStarted,
                "Table is not in a valid state to update the deck"
            );
            table.m_deck = encrypted_deck;

            // Shuffle the deck.
            table.shuffle_deck(starknet::get_block_timestamp().into());

            // Distribute cards to each player.
            for i in 0
                ..table
                    .m_players
                    .len() {
                        // Give card pair to each player and update table and player's hands.
                        let mut player_hand: ComponentHand = world.read_model(*table.m_players[i]);
                        assert!(player_hand.m_cards.len() < 2, "Player already has 2 cards");

                        if let Option::Some(card) = table.m_deck.pop_front() {
                            player_hand.m_cards.append(card);
                        }

                        if let Option::Some(card) = table.m_deck.pop_front() {
                            player_hand.m_cards.append(card);
                        }

                        if player_hand.m_cards.len() == 2 {
                            world.write_model(@player_hand);
                            world
                                .emit_event(
                                    @EventDecryptHandRequested {
                                        m_table_id: table_id,
                                        m_player: *table.m_players[i],
                                        m_hand: player_hand.m_cards.span(),
                                        m_timestamp: starknet::get_block_timestamp()
                                    }
                                );
                        }
                    };

            table.m_state = EnumGameState::DeckEncrypted;
            world.write_model(@table);
        }

        fn advance_street(ref self: ContractState, table_id: u32) {
            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);

            assert!(
                table.m_state != EnumGameState::WaitingForPlayers
                    && table.m_state != EnumGameState::Shutdown
                    && table.m_state != EnumGameState::RoundStarted,
                "Round has not started or deck is not encrypted"
            );
            assert!(
                table.m_finished_street || table.m_state == EnumGameState::DeckEncrypted,
                "Not all players have played their turn"
            );

            // Advance table state to the next street.
            table.advance_street();

            match table.m_state {
                // Betting round.
                EnumGameState::PreFlop => {
                    assert!(table.m_community_cards.is_empty(), "Street was not just started");
                    world
                        .emit_event(
                            @EventRequestBet {
                                m_table_id: table_id, m_timestamp: starknet::get_block_timestamp()
                            }
                        );
                },
                // Flip 3 cards.
                EnumGameState::Flop => {
                    assert!(table.m_community_cards.is_empty(), "Street was not at pre-flop");
                    for _ in 0
                        ..3_u8 {
                            let mut cards_to_reveal: Array<StructCard> = array![];
                            if let Option::Some(card_to_reveal) = table.m_deck.pop_front() {
                                cards_to_reveal.append(card_to_reveal);
                            }
                            world
                                .emit_event(
                                    @EventDecryptCCRequested {
                                        m_table_id: table_id,
                                        m_cards: cards_to_reveal.span(),
                                        m_timestamp: starknet::get_block_timestamp()
                                    }
                                );
                        };
                },
                // Flip 1 card.
                EnumGameState::Turn => {
                    assert!(table.m_community_cards.len() == 3, "Street was not at flop");
                    if let Option::Some(card_to_reveal) = table.m_deck.pop_front() {
                        world
                            .emit_event(
                                @EventDecryptCCRequested {
                                    m_table_id: table_id,
                                    m_cards: array![card_to_reveal].span(),
                                    m_timestamp: starknet::get_block_timestamp()
                                }
                            );
                    }
                },
                // Flip last card.
                EnumGameState::River => {
                    assert!(table.m_community_cards.len() == 4, "Street was not at turn");
                    if let Option::Some(card_to_reveal) = table.m_deck.pop_front() {
                        world
                            .emit_event(
                                @EventDecryptCCRequested {
                                    m_table_id: table_id,
                                    m_cards: array![card_to_reveal].span(),
                                    m_timestamp: starknet::get_block_timestamp()
                                }
                            );
                    }
                },
                // Showdown.
                EnumGameState::Showdown => {
                    assert!(table.m_community_cards.len() == 5, "Street was not at river");
                    world
                        .emit_event(
                            @EventShowdownRequested {
                                m_table_id: table_id, m_timestamp: starknet::get_block_timestamp()
                            }
                        );

                    // Request each player to reveal their hand.
                    for player in table
                        .m_players
                        .span() {
                            let player_hand: ComponentHand = world.read_model(*player);
                            world
                                .emit_event(
                                    @EventRevealShowdownRequested {
                                        m_table_id: table_id,
                                        m_player: *player,
                                        m_hand: player_hand.m_cards.span(),
                                        m_timestamp: starknet::get_block_timestamp()
                                    }
                                );
                        };
                },
                _ => {}
            }

            // Create sidepots if there are any all-in players.
            let mut player_bets: Array<u32> = array![];
            let mut has_all_in = false;

            // Collect all current bets and check for all-in players.
            for player in table
                .m_players
                .span() {
                    let player_component: ComponentPlayer = world.read_model((table_id, *player));
                    player_bets.append(player_component.m_current_bet);
                    if player_component.m_table_chips == 0
                        && player_component.m_state == EnumPlayerState::Active {
                        has_all_in = true;
                    }
                };

            // Create sidepots if there are all-in players.
            if has_all_in {
                InternalImpl::_create_sidepots(
                    ref world, table_id, table.m_players.clone(), player_bets
                );
            }

            world.write_model(@table);
            world
                .emit_event(
                    @EventStreetAdvanced {
                        m_table_id: table_id, m_timestamp: starknet::get_block_timestamp()
                    }
                );
        }

        fn post_auth_hash(ref self: ContractState, table_id: u32, auth_hash: ByteArray) {
            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            assert!(table.m_state != EnumGameState::Shutdown, "Game is shutdown");

            world
                .emit_event(
                    @EventAuthHashRequested {
                        m_table_id: table_id,
                        m_player: get_caller_address(),
                        m_auth_hash: auth_hash,
                        m_timestamp: starknet::get_block_timestamp()
                    }
                );
        }

        fn skip_turn(ref self: ContractState, table_id: u32, player: ContractAddress) {
            assert!(
                self.table_manager.read() == get_caller_address(),
                "Only the table manager can skip the turn"
            );
            let mut world = self.world(@"dominion");
            let mut player_component: ComponentPlayer = world.read_model((table_id, player));
            assert!(player_component.m_state == EnumPlayerState::Active, "Player is not active");

            let mut table: ComponentTable = world.read_model(table_id);
            assert!(table.check_turn(@player), "Player is not the current turn");
            assert!(
                table.m_last_played_ts < starknet::get_block_timestamp() - 60,
                "Player has not been inactive for at least 60 seconds"
            );

            // Skip turn.
            player_component.fold();
            table.advance_turn();
            world.write_model(@table);
            world.write_model(@player_component);
        }

        fn showdown(ref self: ContractState, table_id: u32) {
            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            assert!(table.m_state == EnumGameState::Showdown, "Round is not at showdown");
            assert!(table.m_community_cards.len() == 5, "Community cards are not set");

            // Before calculating hand, make sure all players have revealed their hands.
            for player in table.m_players.span() {
                let player_component: ComponentPlayer = world.read_model((table_id, *player));
                assert!(
                    player_component.m_state == EnumPlayerState::Revealed,
                    "All Players must have revealed their hand"
                );
            };

            // Determine winners and distribute pot.
            let (winners, ranks) = InternalImpl::_determine_winners(ref world, @table, @table.m_players);
            println!("Winners: {:?}, table pot: {}, pot_share_count: {}", winners, table.m_pot);

            InternalImpl::_distribute_sidepots(ref world, table_id, winners);
            

            // // At this point:
            // // - Winners_dict contains all winning players (winners_dict.get(player.into()) ==
            // // true).
            // // - Pot_share_count contains the number of winners to split the pot between.
            // // - Current_best_rank contains the winning hand rank.
            // for winner in winners.span() {
            //     InternalImpl::_distribute_chips(ref world, table_id, *winner, pot_share);
            // };

            // Start the next round.
            self.start_round(table_id);
        }

        fn post_decrypted_community_cards(
            ref self: ContractState, table_id: u32, mut cards: Array<StructCard>
        ) {
            assert!(
                self.table_manager.read() == get_caller_address(),
                "Only the table manager can update the community cards"
            );

            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            assert!(
                table.m_state == EnumGameState::Flop
                    || table.m_state == EnumGameState::Turn
                    || table.m_state == EnumGameState::River,
                "Game is not in a valid state to update the community cards"
            );

            table.m_community_cards.append_all(ref cards);
            world.write_model(@table);
        }

        fn kick_player(ref self: ContractState, table_id: u32, player: ContractAddress) {
            assert!(
                self.table_manager.read() == get_caller_address(),
                "Only the table manager can kick players"
            );

            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            let mut player_model: ComponentPlayer = world.read_model((table_id, player));

            // Reset player's table state and return chips
            table.m_pot += player_model.m_current_bet;
            player_model.m_table_id = 0;
            player_model.m_total_chips += player_model.m_table_chips;
            player_model.m_table_chips = 0;
            player_model.m_state = EnumPlayerState::Left;

            table.remove_player(@player);
            world.write_model(@table);
            world.write_model(@player_model);
        }

        fn change_table_manager(ref self: ContractState, new_table_manager: ContractAddress) {
            assert!(
                self.table_manager.read() == get_caller_address(),
                "Only the table manager can change the table manager"
            );
            self.table_manager.write(new_table_manager);
        }

        fn get_table_manager(self: @ContractState) -> ContractAddress {
            self.table_manager.read()
        }
    }

    const MAX_BET: u32 = 1000000000;

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _create_sidepots(
            ref world: dojo::world::WorldStorage,
            table_id: u32,
            players: Array<ContractAddress>,
            bets: Array<u32>
        ) {
            // Track the current sidepot ID for this table.
            let mut sidepot_id = 0;
            let mut remaining_players = players.clone();
            let mut remaining_bets = bets.clone();
            let mut processed_amounts: Array<u32> = array![];

            while !remaining_players.is_empty() {
                // Find smallest non-zero bet among remaining players.
                let mut min_bet: u32 = MAX_BET;
                let mut active_players: u8 = 0;

                for i in 0
                    ..remaining_bets
                        .len() {
                            if *remaining_bets[i] > 0 {
                                active_players += 1;
                                if *remaining_bets[i] < min_bet {
                                    min_bet = *remaining_bets[i];
                                }
                            }
                        };

                // Exit if no more active players or valid bets.
                if active_players < 2 || min_bet == MAX_BET {
                    break;
                }

                // Calculate pot amount for this level.
                let mut pot_amount: u32 = 0;
                let mut contribution_for_pot: u32 = min_bet;

                if !processed_amounts.is_empty() {
                    // Subtract amounts already processed in previous pots.
                    let mut total_processed: u32 = 0;
                    for amount in processed_amounts.span() {
                        total_processed += *amount;
                    };
                    contribution_for_pot = min_bet - total_processed;
                }

                // Add contribution from each eligible player.
                let mut new_remaining_bets: Array<u32> = array![];
                for i in 0
                    ..remaining_bets
                        .len() {
                            if *remaining_bets[i] >= min_bet {
                                pot_amount += contribution_for_pot;
                                // Create new bet amount with reduction
                                new_remaining_bets.append(*remaining_bets[i] - min_bet);
                            } else {
                                new_remaining_bets.append(*remaining_bets[i]);
                            }
                        };
                remaining_bets = new_remaining_bets;

                // Create eligibility entries for all players who contributed.
                for i in 0
                    ..remaining_players
                        .len() {
                            let player: ContractAddress = *remaining_players[i];
                            if *remaining_bets[i] >= min_bet {
                                world
                                    .write_model(
                                        @ISidepot::new(
                                            table_id,
                                            pot_amount,
                                            player,
                                            sidepot_id,
                                            contribution_for_pot
                                        )
                                    );
                            }
                        };

                processed_amounts.append(min_bet);
                sidepot_id += 1;
            };
        }

        fn _distribute_sidepots(
            ref world: dojo::world::WorldStorage,
            table_id: u32,
            winners: Array<(ContractAddress, u32)> // (player address, hand strength)
        ) {
            let table: ComponentTable = world.read_model(table_id);
            
            // Process each sidepot from smallest to largest.
            for pot_id in 0..table.m_num_sidepots {
                let mut pot_winners: Array<ContractAddress> = array![];
                let mut best_hand_strength: u32 = 0;
                let sidepot: ComponentSidepot = world.read_model((table_id, pot_id));
                
                // Find winners for this specific sidepot.
                for i in 0..winners.len() {
                    let (winner_address, hand_strength) = winners[i];
                    
                    // Check if player is eligible for this sidepot.
                    if sidepot.m_min_bet > 0 {
                        if hand_strength > @best_hand_strength {
                            pot_winners = array![*winner_address];
                            best_hand_strength = *hand_strength;
                        } else if hand_strength == @best_hand_strength {
                            pot_winners.append(*winner_address);
                        }
                    }
                };
                
                // Distribute this sidepot among eligible winners.
                if !pot_winners.is_empty() {
                    let pot_share = sidepot.m_amount / pot_winners.len().into();
                    for winner in pot_winners.span() {
                        Self::_distribute_chips(ref world, table_id, *winner, pot_share);
                    }
                }
                
                // Clean up sidepot entries.
                for player in table.m_players.span() {
                    world.erase_model(
                        @ISidepot::new(table_id, sidepot.m_amount, *player, pot_id, sidepot.m_min_bet)
                    );
                };
            };
        }

        fn _distribute_chips(
            ref world: dojo::world::WorldStorage, table_id: u32, player: ContractAddress, amount: u32
        ) {
            let mut player_component: ComponentPlayer = world.read_model((table_id, player));
            player_component.m_table_chips += amount;
            world.write_model(@player_component);
        }

        fn _remove_sitting_out_players(
            ref world: dojo::world::WorldStorage,
            ref contract: ContractState,
            ref table: ComponentTable
        ) {
            for i in 0
                ..table
                    .m_players
                    .len() {
                        let mut player: ComponentPlayer = world
                            .read_model((table.m_table_id, *table.m_players[i]));
                        if player.m_state == EnumPlayerState::Left {
                            contract.kick_player(table.m_table_id, *table.m_players[i]);
                        }
                    };
        }

        fn _update_positions(ref world: dojo::world::WorldStorage, ref table: ComponentTable) {
            assert!(table.m_players.len() >= 2, "Table must have at least 2 players");

            // Find out if there's a dealer.
            let mut dealer_found: Option<usize> = Option::None;
            for i in 0
                ..table
                    .m_players
                    .len() {
                        let mut player: ComponentPlayer = world
                            .read_model((table.m_table_id, *table.m_players[i]));
                        if player.m_state != EnumPlayerState::Left
                            && player.m_state != EnumPlayerState::Waiting {
                            if player.m_is_dealer {
                                dealer_found = Option::Some(i);
                                break;
                            }
                        }
                    };

            // Update dealer/small blind/big blind.
            if dealer_found.is_none() {
                // If there's no dealer, set the new dealer to this player.
                dealer_found = Option::Some(0);
                table.m_current_dealer = 0;
                table.m_current_turn = 2 % table.m_players.len().try_into().unwrap();
            } else {
                // Update next turn positions.
                table
                    .m_current_dealer = ((dealer_found.unwrap() + 1) % table.m_players.len())
                    .try_into()
                    .unwrap();
                table
                    .m_current_turn =
                        ((table.m_current_dealer + 2) % table.m_players.len().try_into().unwrap());
            }

            // Update Roles.
            let mut current_dealer: ComponentPlayer = world
                .read_model((table.m_table_id, *table.m_players[dealer_found.unwrap()]));
            current_dealer.m_is_dealer = false;
            current_dealer.m_state = EnumPlayerState::Active;

            let mut next_dealer: ComponentPlayer = world
                .read_model(
                    (table.m_table_id, *table.m_players[table.m_current_dealer.try_into().unwrap()])
                );
            next_dealer.m_is_dealer = true;
            next_dealer.m_state = EnumPlayerState::Active;

            let mut next_small_blind: ComponentPlayer = world
                .read_model(
                    (
                        table.m_table_id,
                        *table
                            .m_players[(table.m_current_dealer + 1)
                            .try_into()
                            .unwrap() % table
                            .m_players
                            .len()]
                    )
                );
            next_small_blind.m_position = EnumPosition::SmallBlind;
            next_small_blind.m_state = EnumPlayerState::Active;

            let mut next_big_blind: ComponentPlayer = world
                .read_model(
                    (table.m_table_id, *table.m_players[table.m_current_turn.try_into().unwrap()])
                );
            next_big_blind.m_is_dealer = table.m_current_turn == table.m_current_dealer;
            next_big_blind.m_position = EnumPosition::BigBlind;
            next_big_blind.m_state = EnumPlayerState::Active;

            world
                .write_models(
                    array![@current_dealer, @next_dealer, @next_small_blind, @next_big_blind].span()
                );

            // Update positions for everyone else.
            for i in 0
                ..table
                    .m_players
                    .len() {
                        // If we are not part of the three new assigned roles, set player position
                        // to none.
                        if i != ((dealer_found.unwrap() + 1) % table.m_players.len())
                            && i != table.m_current_dealer.try_into().unwrap()
                            && i != table.m_current_turn.try_into().unwrap() {
                            let mut player: ComponentPlayer = world
                                .read_model((table.m_table_id, *table.m_players[i]));

                            // Include players that are waiting, but not those who have left the
                            // table.
                            if player.m_is_created && player.m_state != EnumPlayerState::Left {
                                player.m_position = EnumPosition::None;
                                player.m_state = EnumPlayerState::Active;
                                world.write_model(@player);
                            }
                        }
                    };
        }

        fn _determine_winners(
            ref world: dojo::world::WorldStorage,
            table: @ComponentTable,
            eligible_players: @Array<ContractAddress>
        ) -> Array<(ContractAddress, u32)> {
            let mut winners: Array<ContractAddress> = array![];
            let mut current_best_rank: Option<EnumHandRank> = Option::None;

            // Collect all current bets and check for all-in players
            for player in eligible_players.span() {
                let player_component: ComponentPlayer = world.read_model((*table.m_table_id, *player));
                player_bets.append(player_component.m_current_bet);
                if player_component.m_table_chips == 0 && player_component.m_state == EnumPlayerState::Active {
                    has_all_in = true;
                }
            };

            // Create sidepots if there are all-in players
            if has_all_in {
                InternalImpl::_create_sidepots(
                    ref world, 
                    *table.m_table_id, 
                    (*eligible_players).clone(), 
                    player_bets
                );
            }

            // Find winners among eligible players.
            for player in eligible_players.span() {
                let player_component: ComponentPlayer = world.read_model((*table.m_table_id, *player));
                assert!(player_component.m_state == EnumPlayerState::Revealed, "Player is not revealed");
                let hand: ComponentHand = world.read_model(*player);
                let mut rank_mask: EnumRankMask = EnumRankMask::RoyalFlush;
                let mut hand_rank = hand
                    .evaluate_hand(table.m_community_cards, rank_mask)
                    .expect('Hand evaluation failed');

                match @current_best_rank {
                    Option::None => {
                        current_best_rank = Option::Some(hand_rank);
                    },
                    Option::Some(best_rank) => {
                        let mut comparison = utils::tie_breaker(@hand_rank, best_rank);
                        while comparison == 0 && rank_mask != EnumRankMask::None {
                            println!("Tied for best hand for player {}: {:?}",
                            starknet::contract_address_to_felt252(*player), hand_rank);
                            rank_mask.increment_depth();
                            hand_rank = hand
                                .evaluate_hand(table.m_community_cards, rank_mask)
                                .expect('Hand evaluation failed');
                            comparison = utils::tie_breaker(@hand_rank, best_rank);
                        };

                        if comparison > 0 {
                            println!("New best hand found for player {}: {:?}",
                         starknet::contract_address_to_felt252(*player), hand_rank);
                            // New best hand found- clear previous winners.
                            winners = array![*player];
                            current_best_rank = Option::Some(hand_rank);
                        } else if comparison == 0 {
                            // Tied for best hand- add to winners.
                            winners.append(*player);
                        }
                    }
                };
            };
    
            return winners;
        }
    }
}
