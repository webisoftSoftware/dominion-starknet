use starknet::ContractAddress;
use core::traits::Into;
use core::dict::Felt252Dict;
use dominion::models::structs::StructCard;
use dominion::models::enums::EnumGameState;
use dominion::models::components::{ComponentSidepot, ComponentPlayer};

#[starknet::interface]
trait ITableManagement<TContractState> {
    // Backend entrypoints.
    fn post_encrypt_deck(
        ref self: TContractState, table_id: u32, encrypted_deck: Array<StructCard>
    );
    fn post_decrypted_community_cards(
        ref self: TContractState, table_id: u32, cards: Array<StructCard>
    );
    
    // Admin Functions.
    fn skip_turn(ref self: TContractState, table_id: u32, player: ContractAddress);
    fn kick_player(ref self: TContractState, table_id: u32, player: ContractAddress);
    fn create_table(
        ref self: TContractState, small_blind: u32, big_blind: u32, min_buy_in: u32,
         max_buy_in: u32, rake_fee: u32
    );
    fn shutdown_table(ref self: TContractState, table_id: u32);
    fn change_table_manager(ref self: TContractState, new_table_manager: ContractAddress);

    // Getters.
    fn get_table_manager(self: @TContractState) -> ContractAddress;
    fn get_table_length(self: @TContractState) -> u32;
    fn get_game_state(self: @TContractState, table_id: u32) -> EnumGameState;
    fn get_table_players(self: @TContractState, table_id: u32) -> Array<ContractAddress>;
    fn get_current_turn(self: @TContractState, table_id: u32) -> Option<ContractAddress>;
    fn get_current_sidepots(self: @TContractState, table_id: u32) -> Array<ComponentSidepot>;
    fn get_table_community_cards(self: @TContractState, table_id: u32) -> Array<StructCard>;
    fn is_deck_encrypted(self: @TContractState, table_id: u32) -> bool;
    fn get_table_last_played_ts(self: @TContractState, table_id: u32) -> u64;
    fn get_table_min_buy_in(self: @TContractState, table_id: u32) -> u32;
    fn get_table_max_buy_in(self: @TContractState, table_id: u32) -> u32;
    fn get_table_rake_fee(self: @TContractState, table_id: u32) -> u32;
    fn get_table_last_raiser(self: @TContractState, table_id: u32) -> Option<ContractAddress>;
}

#[dojo::contract]
mod table_management_system {
    use starknet::{ContractAddress, get_caller_address, TxInfo, get_tx_info};
    use dojo::{model::ModelStorage, world::IWorldDispatcher};
    use dominion::models::components::{ComponentTable, ComponentPlayer, ComponentHand, ComponentSidepot, ComponentRake};
    use dominion::models::enums::{EnumGameState, EnumPlayerState, EnumPosition, EnumHandRank, EnumRankMask};
    use dominion::models::traits::{ITable, IPlayer, IHand, EnumHandRankPartialOrd, ISidepot, ComponentPlayerDisplay,
         EnumRankMaskPartialOrd, IEnumRankMask, EnumHandRankSnapshotInto, EnumHandRankSnapshotIntoMask,
        ComponentHandDisplay, StructCardEq};
    use dominion::models::utils;
    use dominion::models::structs::StructCard;
    use dojo::event::{EventStorage};
    use origami_random::deck::{Deck, DeckTrait};
    use dominion::systems::actions::actions_system;

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
    struct EventEncryptDeckRequested {
        #[key]
        m_table_id: u32,
        m_deck: Span<StructCard>,
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
            max_buy_in: u32,
            rake_fee: u32
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

            assert!(rake_fee > 0, "Rake fee cannot be less than 0");
            assert!(rake_fee < 10, "Rake fee cannot be greater than 10");

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
            new_table.m_rake_fee = rake_fee;
            new_table.m_rake_address = get_caller_address();

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
            assert!(table.m_state != EnumGameState::Shutdown, "Table is already shutdown");
            table.m_state = EnumGameState::Shutdown;
            world.write_model(@table);

            world
                .emit_event(
                    @EventTableShutdown {
                        m_table_id: table_id, m_timestamp: starknet::get_block_timestamp()
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
                table.m_state == EnumGameState::PreFlop,
                "Deck encryption is only allowed when round starts"
            );
            assert!(table.m_deck_encrypted == false, "Deck is already encrypted");

            for card in table.m_deck.span() {
                assert!(encrypted_deck.contains(card), "Deck not encrypted");
            };

            table.m_deck = encrypted_deck;

            // Shuffle the deck.
            table.shuffle_deck(starknet::get_block_timestamp().into());

            // Distribute cards to each player.
            for i in 0..table.m_players.len() {
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
                    world.emit_event(
                        @EventDecryptHandRequested {
                            m_table_id: table.m_table_id,
                            m_player: *table.m_players[i],
                            m_hand: player_hand.m_cards.span(),
                            m_timestamp: starknet::get_block_timestamp()
                        }
                    );
                }
            };

            table.m_deck_encrypted = true;
            world.write_model(@table);
        }

        fn skip_turn(ref self: ContractState, table_id: u32, player: ContractAddress) {
            assert!(
                self.table_manager.read() == get_caller_address(),
                "Only the table manager can skip the turn"
            );
            let mut world = self.world(@"dominion");
            let mut player_component: ComponentPlayer = world.read_model((table_id, player));

            let mut table: ComponentTable = world.read_model(table_id);
            assert!(table.check_turn(@player), "Cannot skip player's turn: Not player's turn");
            let last_played_ts: u64 = table.m_last_played_ts;
            // Avoid sub overflow.
            if starknet::get_block_timestamp() >= 60 {
                assert!(
                    last_played_ts < starknet::get_block_timestamp() - 60,
                    "Player has not been inactive for at least 60 seconds"
                );
            }

            // Skip turn.
            player_component.fold();
            table.advance_turn(array![]);
            world.write_model(@table);
            world.write_model(@player_component);
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

        /////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////
        //////////////////////////////// GETTERS ////////////////////////////////
        /////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////
        
        fn get_table_manager(self: @ContractState) -> ContractAddress {
            self.table_manager.read()
        }

        
        fn get_table_length(self: @ContractState) -> u32 {
            self.counter.read() - 1
        }
        
        fn get_game_state(self: @ContractState, table_id: u32) -> EnumGameState {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            table.m_state
        }
        
        fn get_table_players(self: @ContractState, table_id: u32) -> Array<ContractAddress> {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            table.m_players
        }
        
        fn get_table_last_raiser(self: @ContractState, table_id: u32) -> Option<ContractAddress> {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            if let Option::Some(player) = table.m_players.get(table.m_last_raiser.into()) {
                Option::Some(*(player.unbox()))
            } else {
                Option::None
            }
        }
        
        fn get_current_turn(self: @ContractState, table_id: u32) -> Option<ContractAddress> {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            if let Option::Some(player) = table.m_players.get(table.m_current_turn.into()) {
                Option::Some(*(player.unbox()))
            } else {
                Option::None
            }
        }

        fn get_current_sidepots(self: @ContractState, table_id: u32) -> Array<ComponentSidepot> {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            let mut sidepots: Array<ComponentSidepot> = array![];
            for i in 0..table.m_num_sidepots {
                let sidepot: ComponentSidepot = world.read_model((table_id, i));
                sidepots.append(sidepot);
            };
            sidepots
        }
        
        fn get_table_community_cards(self: @ContractState, table_id: u32) -> Array<StructCard> {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            table.m_community_cards
        }
        
        fn is_deck_encrypted(self: @ContractState, table_id: u32) -> bool {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            table.m_deck_encrypted
        }
        
        fn get_table_last_played_ts(self: @ContractState, table_id: u32) -> u64 {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            table.m_last_played_ts
        }

        fn get_table_min_buy_in(self: @ContractState, table_id: u32) -> u32 {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            table.m_min_buy_in
        }

        fn get_table_max_buy_in(self: @ContractState, table_id: u32) -> u32 {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            table.m_max_buy_in
        }

        fn get_table_rake_fee(self: @ContractState, table_id: u32) -> u32 {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            table.m_rake_fee
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _start_round(ref world: dojo::world::WorldStorage, ref table: ComponentTable) {
            assert!(
                table.m_state == EnumGameState::WaitingForPlayers
                    || table.m_state == EnumGameState::Showdown,
                "Game is not in a valid state to start a round"
            );
            assert!(table.m_players.len() >= MIN_PLAYERS, "Not enough players to start the round");

            // Reset the table (Community cards and pot are cleared out).
            table.reset_table();

            // Reset player's hands.
            for player in table.m_players.span() {
                let mut player_hand: ComponentHand = world.read_model(*player);
                player_hand.m_cards = array![];
                world.write_model(@player_hand);
            };

            // Update order and dealer chip position (Small Blind, Big Blind, etc.).
            Self::_update_roles(ref world, ref table);

            // Remove players sitting out.
            Self::_remove_sitting_out_players(ref world, ref table);

            // Make small blind and big blind bet automatically.
            let small_blind_position = (table.m_current_dealer + 1) % table.m_players.len().try_into().unwrap();
            let big_blind_position = (table.m_current_dealer + 2) % table.m_players.len().try_into().unwrap();

            if let Option::Some(small_blind_player) = table.m_players.get(small_blind_position.into()) {
                let mut small_blind_player: ComponentPlayer = world.read_model((table.m_table_id, *small_blind_player.unbox()));
                actions_system::InternalImpl::_place_bet(ref world, ref table, ref small_blind_player, table.m_small_blind, true);
                small_blind_player.m_state = EnumPlayerState::Active;
                world.write_model(@small_blind_player);
            }
            if let Option::Some(big_blind_player) = table.m_players.get(big_blind_position.into()) {
                let mut big_blind_player: ComponentPlayer = world.read_model((table.m_table_id, *big_blind_player.unbox()));
                actions_system::InternalImpl::_place_bet(ref world, ref table, ref big_blind_player, table.m_big_blind, true);
                big_blind_player.m_state = EnumPlayerState::Active;
                world.write_model(@big_blind_player);
            }

            table.m_state = EnumGameState::PreFlop;
            world.write_model(@table);
            world.emit_event(
                @EventEncryptDeckRequested {
                    m_table_id: table.m_table_id,
                    m_deck: table.m_deck.span(),
                    m_timestamp: starknet::get_block_timestamp()
                }
            );
        }

        fn _advance_street(ref world: dojo::world::WorldStorage, ref table: ComponentTable) {
            assert!(table.m_state != EnumGameState::Shutdown &&
                table.m_state != EnumGameState::WaitingForPlayers, "Round has not started");
            assert!(table.m_deck_encrypted, "Deck is not encrypted");


            // Check if all players are All-in, if they are, street is automatically finished.
            let mut all_players_all_in: bool = true;
            for player in table.m_players.span() {
                let mut player_component: ComponentPlayer = world.read_model((table.m_table_id, *player));
                if player_component.m_state != EnumPlayerState::AllIn {
                    all_players_all_in = false;
                    break;
                }
            };

            if all_players_all_in {
                table.m_finished_street = true;
            } else {
                // Reset players' states if they are not all in.
                for player in table.m_players.span() {
                    let mut player_component: ComponentPlayer = world.read_model((table.m_table_id, *player));
                    player_component.m_state = EnumPlayerState::Active;
                    world.write_model(@player_component);
                };
            }

            assert!(table.m_finished_street, "Street has not finished");

            // Advance table state to the next street.
            table.advance_street();

            match table.m_state {
                // Betting round.
                EnumGameState::PreFlop => {
                    assert!(table.m_community_cards.is_empty(), "Street was not just started");
                    world.emit_event(
                        @EventRequestBet {
                            m_table_id: table.m_table_id, m_timestamp: starknet::get_block_timestamp()
                        }
                    );
                },
                // Flip 3 cards.
                EnumGameState::Flop => {
                    assert!(table.m_community_cards.is_empty(), "Street was not at pre-flop");
                    for _ in 0..3_u8 {
                        let mut cards_to_reveal: Array<StructCard> = array![];
                        if let Option::Some(card_to_reveal) = table.m_deck.pop_front() {
                            cards_to_reveal.append(card_to_reveal);
                        }
                        world.emit_event(
                            @EventDecryptCCRequested {
                                m_table_id: table.m_table_id,
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
                        world.emit_event(
                            @EventDecryptCCRequested {
                                m_table_id: table.m_table_id,
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
                        world.emit_event(
                            @EventDecryptCCRequested {
                                m_table_id: table.m_table_id,
                                m_cards: array![card_to_reveal].span(),
                                m_timestamp: starknet::get_block_timestamp()
                            }
                        );
                    }
                },
                // Showdown.
                EnumGameState::Showdown => {
                    assert!(table.m_community_cards.len() == 5, "Street was not at river");
                    world.emit_event(
                        @EventShowdownRequested {
                            m_table_id: table.m_table_id, m_timestamp: starknet::get_block_timestamp()
                        }
                    );

                    // Request each player to reveal their hand.
                    for player in table.m_players.span() {
                        let player_hand: ComponentHand = world.read_model(*player);
                        world.emit_event(
                            @EventRevealShowdownRequested {
                                m_table_id: table.m_table_id,
                                m_player: *player,
                                m_hand: player_hand.m_cards.span(),
                                m_timestamp: starknet::get_block_timestamp()
                            }
                        );
                    };
                },
                _ => {}
            }

            world.emit_event(
                @EventStreetAdvanced {
                    m_table_id: table.m_table_id, m_timestamp: starknet::get_block_timestamp()
                }
            );
        }

        fn _showdown(ref world: dojo::world::WorldStorage, ref table: ComponentTable) {
            assert!(table.m_state == EnumGameState::Showdown, "Round is not at showdown");
            assert!(table.m_community_cards.len() == 5, "Community cards are not set");

            // Determine winners.
            let winners: Array<(ContractAddress, u32)> = Self::_determine_winners(ref world, @table, @table.m_players);
            if table.m_num_sidepots == 0 {
                // Calculate rake once per pot
                let house_rake_fee = table.m_pot * table.m_rake_fee / 100;
                let amount_after_rake = table.m_pot - house_rake_fee;
                let share_per_winner = amount_after_rake / winners.len().into();

                let mut rake: ComponentRake = world.read_model(table.m_rake_address);
                rake.m_chip_amount += house_rake_fee;
                world.write_model(@rake);

                for (addr, _) in winners.span() {
                    let mut player_component: ComponentPlayer = world.read_model((table.m_table_id, *addr));
                    // Keep house fee in mind.
                    player_component.m_table_chips += share_per_winner;
                    world.write_model(@player_component);
                };
            } else {
                Self::_distribute_sidepots(ref world, ref table, winners);
            }

            // Start the next round.
            Self::_start_round(ref world, ref table);
        }

        /// Assign a player to a sidepot. A player needs to meet the minimum bet of the sidepot to be added to it.
        /// If the player does not meet the minimum bet of any sidepot, a new sidepot is created for them.
        /// 
        /// @param world: The world storage.
        /// @param table_id: The table ID.
        /// @param player: The player to assign to a sidepot.
        /// @param amount: The amount the player has bet.
        /// @returns: Nothing.
        /// Can Panic? Yes.
        fn _assign_player_to_sidepot(
            ref world: dojo::world::WorldStorage,
            ref table: ComponentTable,
            player: ContractAddress,
            amount: u32
        ) {
            let mut remaining_amount: u32 = amount;

            // Check all sidepots to see if the player can be added to one.
            for i in 0..table.m_num_sidepots {
                let mut sidepot: ComponentSidepot = world.read_model((table.m_table_id, i));
                // If the player qualifies for this sidepot, add them to the sidepot.
                if remaining_amount >= sidepot.m_min_bet && sidepot.m_min_bet >= table.m_small_blind {
                    sidepot.m_eligible_players.append(player);
                    sidepot.m_amount += sidepot.m_min_bet;
                    world.write_model(@sidepot);
                    remaining_amount -= sidepot.m_min_bet;
                }
            };

            // If the player was not added to any sidepot, create a new sidepot for them.
            if remaining_amount >= table.m_small_blind {
                let mut sidepot: ComponentSidepot = world.read_model((table.m_table_id, table.m_num_sidepots));
                sidepot = ISidepot::new(table.m_table_id, table.m_num_sidepots, remaining_amount,
                    array![player], remaining_amount);
                world.write_model(@sidepot);
                table.m_num_sidepots += 1;
            }
        }

        /// Remove a player from all sidepots.
        /// IF there are no players left in a sidepot, remove the sidepot.
        /// 
        /// @param world: The world storage.
        /// @param table_id: The table ID.
        /// @param player: The player to remove from all sidepots.
        /// @returns: Nothing.
        /// Can Panic? Yes.
        fn _remove_player_from_sidepots(
            ref world: dojo::world::WorldStorage,
            ref table: ComponentTable,
            player: ContractAddress
        ) {
            for i in 0..table.m_num_sidepots {
                let mut sidepot: ComponentSidepot = world.read_model((table.m_table_id, i));
                if let Option::Some(index) = sidepot.m_eligible_players.position(@player) {
                    if sidepot.m_eligible_players.len() == 1 {
                        // If there's only one player left in the sidepot, remove the sidepot.
                        world.erase_model(@sidepot);
                        table.m_num_sidepots -= 1;
                    } else {
                        let mut eligible_players: Array<ContractAddress> = array![];
                        for j in 0..sidepot.m_eligible_players.len() {
                            if j != index {
                                eligible_players.append(sidepot.m_eligible_players[j].clone());
                            }
                        };
                        sidepot.m_eligible_players = eligible_players;
                        world.write_model(@sidepot);
                    }
                }
            };
        }

        fn _distribute_sidepots(
            ref world: dojo::world::WorldStorage,
            ref table: ComponentTable,
            mut winners: Array<(ContractAddress, u32)> // (player address, hand strength)
        ) {
            if table.m_num_sidepots == 0 {
                return;
            }

            // Process each sidepot from highest to lowest
            for pot_id in 0..table.m_num_sidepots {
                let mut pot_winners: Array<ContractAddress> = array![];
                let mut best_hand_strength: u32 = 0;
                let sidepot: ComponentSidepot = world.read_model((table.m_table_id, pot_id));
                
                // Find winners for this specific sidepot
                for i in 0..winners.len() {
                    let (winner_address, hand_strength) = winners[i];
                    
                    if sidepot.m_min_bet > 0 && sidepot.m_eligible_players.contains(winner_address) {
                        if hand_strength > @best_hand_strength {
                            pot_winners = array![*winner_address];
                            best_hand_strength = *hand_strength;
                        } else if hand_strength == @best_hand_strength {
                            pot_winners.append(*winner_address);
                        }
                    }
                };
                
                // Distribute this sidepot among eligible winners
                if !pot_winners.is_empty() {
                    // Calculate rake once per pot
                    let house_rake_fee = sidepot.m_amount * table.m_rake_fee / 100;
                    let amount_after_rake = sidepot.m_amount - house_rake_fee;
                    let share_per_winner = amount_after_rake / pot_winners.len().into();

                    let mut rake: ComponentRake = world.read_model(table.m_rake_address);
                    rake.m_chip_amount += house_rake_fee;
                    world.write_model(@rake);

                    // Subtract pot amount once per sidepot
                    table.m_pot -= sidepot.m_amount;

                    for winner in pot_winners.span() {
                        let mut player_component: ComponentPlayer = world.read_model((table.m_table_id, *winner));
                        player_component.m_table_chips += share_per_winner;
                        world.write_model(@player_component);
                    };
                }
            };

            // Clean up sidepot entries
            for i in 0..table.m_num_sidepots {
                let sidepot: ComponentSidepot = world.read_model((table.m_table_id, i));
                world.erase_model(@sidepot);
            };

            table.m_num_sidepots = 0;
        }

        fn _remove_sitting_out_players(
            ref world: dojo::world::WorldStorage,
            ref table: ComponentTable
        ) {
            for i in 0..table.m_players.len() {
                let mut player: ComponentPlayer = world.read_model((table.m_table_id, *table.m_players[i]));
                if player.m_state == EnumPlayerState::Left {
                    // Reset player's table state and return chips
                    table.m_pot += player.m_current_bet;
                    player.m_table_id = 0;
                    player.m_total_chips += player.m_table_chips;
                    player.m_table_chips = 0;
                    player.m_state = EnumPlayerState::Left;

                    table.remove_player(table.m_players[i]);
                    world.write_model(@table);
                    world.write_model(@player);
                }
            };
        }

        fn _update_roles(ref world: dojo::world::WorldStorage, ref table: ComponentTable) {
            assert!(table.m_players.len() >= 2, "Table must have at least 2 players");

            // Find out if there's a dealer (could have left the table).
            let mut dealer_found: Option<usize> = Option::None;
            for i in 0..table.m_players.len() {
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
            let mut dealer_position: u32 = 0;
            let mut small_blind_position: u32 = 0;
            let mut big_blind_position: u32 = 0;

            // Update dealer/small blind/big blind.
            if dealer_found.is_none() {
                // If there's no dealer, set the new dealer to this player.
                small_blind_position = 1 % table.m_players.len();
                big_blind_position = 2 % table.m_players.len();

                table.m_current_dealer = 0;
                table.m_current_turn = small_blind_position.try_into().unwrap();
            } else {
                // Update next turn positions.
                dealer_position = (dealer_found.unwrap() + 1) % table.m_players.len();
                small_blind_position = (dealer_position + 1) % table.m_players.len();
                big_blind_position = (small_blind_position + 1) % table.m_players.len();

                table.m_current_dealer = dealer_position.try_into().unwrap();
                table.m_current_turn = small_blind_position.try_into().unwrap();
            }

            table.m_last_raiser = big_blind_position.try_into().unwrap();

            // Update Roles.
            let mut dealer: ComponentPlayer = world.read_model((table.m_table_id, *table.m_players[dealer_position]));
            dealer.m_is_dealer = true;
            dealer.m_state = EnumPlayerState::Active;

            let mut small_blind: ComponentPlayer = world.read_model((table.m_table_id, *table.m_players[small_blind_position]));
            small_blind.m_position = EnumPosition::SmallBlind;
            small_blind.m_state = EnumPlayerState::Active;

            let mut big_blind: ComponentPlayer = world.read_model((table.m_table_id, *table.m_players[big_blind_position]));
            big_blind.m_position = EnumPosition::BigBlind;
            big_blind.m_state = EnumPlayerState::Active;

            world.write_models(array![@dealer, @small_blind, @big_blind].span());

            // Update positions for everyone else.
            for i in 0..table.m_players.len() {
                // If we are not part of the three new assigned roles, set player position to none.
                if i != dealer_position && i != small_blind_position && i != big_blind_position {
                    let mut player: ComponentPlayer = world
                        .read_model((table.m_table_id, *table.m_players[i]));

                    // Include only players that are waiting to fill in or are ready if the game hasn't started yet,
                    // since we might call this again mid-round and don't want to change the states of players mid-bets.
                    if player.m_is_created && (player.m_state == EnumPlayerState::Waiting ||
                        player.m_state == EnumPlayerState::Ready) {
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
            let mut winners: Array<(ContractAddress, u32)> = array![];
            let mut current_best_hand: Option<ComponentHand> = Option::None;

            // Find winners among eligible players.
            for player in eligible_players.span() {
                let player_component: ComponentPlayer = world.read_model((*table.m_table_id, *player));
                assert!(player_component.m_state == EnumPlayerState::Revealed, "Player is not revealed");
                let hand: ComponentHand = world.read_model(*player);

                let mut rank_mask: EnumRankMask = EnumRankMask::RoyalFlush;
                let mut hand_rank = hand
                    .evaluate_hand(table.m_community_cards, rank_mask)
                    .expect('Hand evaluation failed');
                rank_mask = (@hand_rank).into();
                let hand_rank_u32: u32 = (@hand_rank).into();

                match @current_best_hand {
                    Option::None => {
                        current_best_hand = Option::Some(hand.clone());
                        winners.append((*player, hand_rank_u32));
                    },
                    Option::Some(best_hand) => {
                        let mut best_rank: EnumHandRank = best_hand
                            .evaluate_hand(table.m_community_cards, rank_mask)
                            .expect('Hand evaluation failed');

                        let mut comparison = utils::tie_breaker(@hand_rank, @best_rank);
                        while comparison == 0 && rank_mask != EnumRankMask::None {
                            rank_mask.increment_depth();
                            hand_rank = hand
                                .evaluate_hand(table.m_community_cards, rank_mask)
                                .expect('Hand evaluation failed');
                            best_rank = best_hand
                                .evaluate_hand(table.m_community_cards, rank_mask)
                                .expect('Hand evaluation failed');
                            comparison = utils::tie_breaker(@hand_rank, @best_rank);
                        };
                        
                        if comparison > 0 {
                            // New best hand found- clear previous winners.
                            winners = array![(*player, hand_rank_u32)];
                            current_best_hand = Option::Some(hand.clone());
                        } else if comparison == 0 {
                            // Tied for best hand- add to winners.
                            winners.append((*player, hand_rank_u32));
                        }
                    }
                };
            };
    
            return winners;
        }
    }
}
