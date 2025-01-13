use dominion::models::structs::StructCard;
use starknet::ContractAddress;
use dominion::models::enums::{EnumPlayerState, EnumPosition};

#[starknet::interface]
trait IActions<TContractState> {
    fn bet(ref self: TContractState, table_id: u32, amount: u32);
    fn fold(ref self: TContractState, table_id: u32);
    fn post_auth_hash(ref self: TContractState, table_id: u32, auth_hash: ByteArray);
    fn post_commit_hash(ref self: TContractState, table_id: u32, commitment_hash: Array<u32>);
    fn top_up_table_chips(ref self: TContractState, table_id: u32, chips_amount: u32);
    fn set_ready(ref self: TContractState, table_id: u32);
    fn join_table(ref self: TContractState, table_id: u32, chips_amount: u32);
    fn leave_table(ref self: TContractState, table_id: u32);
    fn reveal_hand_to_all(
        ref self: TContractState,
        table_id: u32,
        decrypted_hand: Array<StructCard>,
        request: ByteArray
    );

    // Getters.
    fn get_player_state(self: @TContractState, table_id: u32, player: ContractAddress) -> EnumPlayerState;
    fn get_player_bet(self: @TContractState, table_id: u32, player: ContractAddress) -> u32;
    fn get_player_position(self: @TContractState, table_id: u32, player: ContractAddress) -> EnumPosition;
    fn get_player_total_chips(self: @TContractState, table_id: u32, player: ContractAddress) -> u32;
    fn get_player_table_chips(self: @TContractState, table_id: u32, player: ContractAddress) -> u32;
    fn has_player_revealed(self: @TContractState, table_id: u32, player: ContractAddress) -> bool;
}

#[dojo::contract]
mod actions_system {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp, TxInfo, get_tx_info};
    use dojo::{model::ModelStorage, world::IWorldDispatcher};
    use dojo::event::{EventStorage};
    use dominion::models::components::{ComponentTable, ComponentPlayer, ComponentHand, ComponentSidepot};
    use dominion::models::enums::{EnumPlayerState, EnumGameState, EnumPosition};
    use dominion::models::traits::{IPlayer, ITable, ComponentTableDisplay, EnumGameStateDisplay, ComponentPlayerDisplay,
        EnumPlayerStateDisplay};
    use dominion::models::structs::StructCard;
    use alexandria_data_structures::array_ext::ArrayTraitExt;
    use core::sha256::compute_sha256_byte_array;
    use dominion::systems::table_manager::{
        ITableManagementDispatcher, ITableManagementDispatcherTrait
    };
    use dominion::systems::table_manager::table_management_system;

    #[derive(Clone, Drop, Serde, Debug)]
    #[dojo::event]
    struct EventHandRevealed {
        #[key]
        m_table_id: u32,
        #[key]
        m_player: ContractAddress,
        m_request: ByteArray,
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

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    struct EventPlayerLeft {
        #[key]
        m_table_id: u32,
        #[key]
        m_player: ContractAddress,
        m_timestamp: u64,
    }

    #[abi(embed_v0)]
    impl ActionsImpl of super::IActions<ContractState> {
        /// Allows a player to join a table with specified chips amount.
        ///
        /// If the player is not at the table, a new player is created.
        /// If the player is already at the table, their chips are updated.
        /// If the player is already at the table and has not joined yet, their chips are updated.
        ///
        /// @param table_id The ID of the table to join.
        /// @param chips_amount The amount of chips to join the table with.
        /// @returns Nothing.
        /// Can Panic? Yes, if the table is not created or shutdown, or if the player is already active.
        /// Allows a player to join a table with specified chips amount.
        ///
        /// If the player is not at the table, a new player is created.
        /// If the player is already at the table, their chips are updated.
        /// If the player is already at the table and has not joined yet, their chips are updated.
        ///
        /// @param table_id The ID of the table to join.
        /// @param chips_amount The amount of chips to join the table with.
        /// @returns Nothing.
        /// Can Panic? Yes, if the table is not created or shutdown, or if the player is already active.
        fn join_table(ref self: ContractState, table_id: u32, chips_amount: u32) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            // Get total chips from cashier table (0).
            let mut player: ComponentPlayer = world.read_model((table_id, caller));
            
            // Create new player if first time joining
            if !player.m_is_created {
                player = IPlayer::new(table_id, caller);
            }
            
            // Validate table capacity and chip amounts.
            let mut table: ComponentTable = world.read_model(table_id);
            assert!(table.m_state != EnumGameState::Shutdown, "Table is not created or shutdown");
            assert!(table.m_players.len() < 6, "Table is full");
            assert!(!table.m_players.contains(@caller), "Player is already at the table");
            assert!(player.m_total_chips >= chips_amount, "Insufficient chips");
            assert!(table.m_min_buy_in <= chips_amount, "Amount is less than min buy in");
            assert!(table.m_max_buy_in >= chips_amount, "Amount is more than max buy in");

            // Update player state for joining table.
            player.m_total_chips -= chips_amount;
            player.m_table_chips += chips_amount;

            // Set player state based on game state.
            if table.m_state == EnumGameState::WaitingForPlayers {
                player.m_state = EnumPlayerState::Active;
            } else {
                player.m_state = EnumPlayerState::Waiting;
            }

            // Reset player's current bet if they previously joined the table.
            player.m_current_bet = 0;

            // Update world state
            world.write_model(@player);
            table.m_players.append(caller);

            world
                .emit_event(
                    @EventPlayerJoined {
                        m_table_id: table_id,
                        m_player: caller,
                        m_timestamp: starknet::get_block_timestamp()
                    }
                );
            world.write_model(@table);
        }

        /// Sets a player's state to ready.
        ///
        /// This is used to start a round automatically when all players are ready.
        ///
        /// @param table_id The ID of the table to set ready.
        /// @returns Nothing.
        /// Can Panic? Yes, if the table is not waiting for players, or if the player is not at the table.
        fn set_ready(ref self: ContractState, table_id: u32) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();
            let mut table: ComponentTable = world.read_model(table_id);
            assert!(table.m_state == EnumGameState::WaitingForPlayers, "Table is not waiting for players");

            let mut player: ComponentPlayer = world.read_model((table_id, caller));
            assert!(player.m_table_id == table_id, "Player is not at this table");
            assert!(player.m_state != EnumPlayerState::Ready, "Player is already ready");

            player.m_state = EnumPlayerState::Ready;
            world.write_model(@player);

            let mut player_statuses: Array<bool> = array![];

            // Check if all players are ready.
            for i in 0..table.m_players.len() {
                if *table.m_players[i] == caller {
                    player_statuses.append(true);
                    continue;
                }

                let player: ComponentPlayer = world.read_model((table_id, *table.m_players[i]));
                if player.m_state != EnumPlayerState::Ready {
                    break;
                }
                player_statuses.append(true);
            };

            // All players are ready.
            if (player_statuses.len() == table.m_players.len() && table.m_players.len() > 1) {
                world.emit_event(
                    @EventAllPlayersReady {
                        m_table_id: table.m_table_id,
                        m_players: table.m_players.clone(),
                        m_timestamp: get_block_timestamp()
                    }
                );
                table_management_system::InternalImpl::_start_round(ref world, ref table);
                world.write_model(@table);
            }
        }

        /// Allows a player to leave a table and collect their chips
        /// The player retrieves their chips and adds them to their total chips.
        /// If the player is the dealer/big blind/small blind, roles are updated.
        ///
        /// @param table_id The ID of the table to leave.
        /// @returns Nothing.
        /// Can Panic? Yes, if the player is not at the table.
        fn leave_table(ref self: ContractState, table_id: u32) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            let mut table: ComponentTable = world.read_model(table_id);
            assert!(table.m_state != EnumGameState::Shutdown, "Table is not created or shutdown");

            let mut player: ComponentPlayer = world.read_model((table_id, caller));
            assert!(table.m_players.contains(@caller), "Player is not at the table");

            // Reset player's table state and return chips
            table.m_pot += player.m_current_bet;
            player.m_total_chips += player.m_table_chips;
            player.m_table_chips = 0;
            player.m_state = EnumPlayerState::Left;

            world.write_model(@player);

            // Update table roles if player was dealer/big blind/small blind.
            if player.m_is_dealer || player.m_position == EnumPosition::BigBlind ||
                player.m_position == EnumPosition::SmallBlind {
                table_management_system::InternalImpl::_update_roles(ref world, ref table);
            }

            world.write_model(@table);
            world.emit_event(
                @EventPlayerLeft {
                    m_table_id: table_id,
                    m_player: caller,
                    m_timestamp: starknet::get_block_timestamp()
                }
            );
        }

        // Allows a player to add more chips to their stack at the table
        fn top_up_table_chips(ref self: ContractState, table_id: u32, chips_amount: u32) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            let mut player: ComponentPlayer = world.read_model(caller);

            // Validate player state and chip amount
            assert!(player.m_table_id == table_id, "Player is not at this table");
            assert!(player.m_state != EnumPlayerState::Active, "Player is active");
            assert!(player.m_total_chips >= chips_amount, "Insufficient chips");

            // Transfer chips from total to table stack
            player.m_total_chips -= chips_amount;
            player.m_table_chips += chips_amount;

            world.write_model(@player);
        }

        fn bet(ref self: ContractState, table_id: u32, amount: u32) {
            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            assert!(table.m_state != EnumGameState::Shutdown &&
                table.m_state != EnumGameState::WaitingForPlayers, "Game is not in a betting phase");
            assert!(table.m_deck_encrypted, "Deck is not encrypted");
            assert!(!table.m_finished_street, "Street is already finished");
            
            let mut player_component: ComponentPlayer = world.read_model((table_id, get_caller_address()));
            assert!(table.check_turn(@player_component.m_owner), "It is not your turn");

            match player_component.m_state {
                EnumPlayerState::NotCreated | EnumPlayerState::Waiting | EnumPlayerState::Revealed |
                EnumPlayerState::Folded | EnumPlayerState::Left => {
                    panic!("Player is not active");
                },
                _ => {}
            }

            let last_raiser: ComponentPlayer = world.read_model((table_id, *table.m_players[table.m_last_raiser.into()]));

            match amount {
                0 => InternalImpl::_check(ref world, ref table, ref player_component, amount, true),
                _ => InternalImpl::_place_bet(ref world, ref table, ref player_component, amount, true),
            };
            world.write_model(@player_component);

            let mut players: Array<ComponentPlayer> = array![];
            for player in table.m_players.span() {
                players.append(world.read_model((table_id, *player)));
            };

            if last_raiser.m_owner == get_caller_address() && InternalImpl::_is_street_finished(table.m_last_raiser, @players) {
                table.m_finished_street = true;
                table_management_system::InternalImpl::_advance_street(ref world, ref table);
            }

            world.write_model(@table);
        }

        fn fold(ref self: ContractState, table_id: u32) {
            let mut world = self.world(@"dominion");

            let mut table: ComponentTable = world.read_model(table_id);
            assert!(table.m_state != EnumGameState::Shutdown &&
                table.m_state != EnumGameState::WaitingForPlayers, "Game is not in a betting phase");
            assert!(table.m_deck_encrypted, "Deck is not encrypted");
            assert!(!table.m_finished_street, "Street is already finished");

            let mut player_component: ComponentPlayer = world.read_model((table_id, get_caller_address()));
            assert!(table.check_turn(@get_caller_address()), "It is not your turn");

            match player_component.m_state {
                EnumPlayerState::NotCreated | EnumPlayerState::Waiting | EnumPlayerState::Revealed |
                EnumPlayerState::Left => {
                    panic!("Player is not active");
                },
                EnumPlayerState::Folded => {
                    panic!("Player has already folded");
                },
                _ => {}
            };

            let last_raiser: ComponentPlayer = world.read_model((table_id, *table.m_players[table.m_last_raiser.into()]));

            InternalImpl::_fold(ref world, ref table, ref player_component, true);
            world.write_model(@player_component);

            // Check if the street is finished.
            let mut players: Array<ComponentPlayer> = array![];
            for player in table.m_players.span() {
                players.append(world.read_model((table_id, *player)));
            };

            if last_raiser.m_owner == get_caller_address() && InternalImpl::_is_street_finished(table.m_last_raiser, @players) {
                table.m_finished_street = true;
                table_management_system::InternalImpl::_advance_street(ref world, ref table);
            }

            world.write_model(@table);
        }

        fn post_auth_hash(ref self: ContractState, table_id: u32, auth_hash: ByteArray) {
            let mut world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            assert!(table.m_state != EnumGameState::Shutdown, "Game is shutdown");

            let player_component: ComponentPlayer = world.read_model((table_id, get_caller_address()));
            match player_component.m_state {
                EnumPlayerState::NotCreated | EnumPlayerState::Waiting | EnumPlayerState::Revealed |
                EnumPlayerState::Folded | EnumPlayerState::Left => {
                    panic!("Player is not active");
                },
                _ => {}
            };

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

        fn post_commit_hash(ref self: ContractState, table_id: u32, commitment_hash: Array<u32>) {
            let mut world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            assert!(table.m_state != EnumGameState::Shutdown, "Game is shutdown");

            let player_component: ComponentPlayer = world.read_model((table_id, get_caller_address()));
            match player_component.m_state {
                EnumPlayerState::NotCreated | EnumPlayerState::Waiting | EnumPlayerState::Revealed |
                EnumPlayerState::Folded | EnumPlayerState::Left => {
                    panic!("Player is not active");
                },
                _ => {}
            };
            assert!(commitment_hash.len() == 8, "Commitment hash is not 8 bytes");

            let mut hand: ComponentHand = world.read_model(get_caller_address());
            hand.m_commitment_hash = commitment_hash;
            world.write_model(@hand);
        }

        fn reveal_hand_to_all(
            ref self: ContractState,
            table_id: u32,
            decrypted_hand: Array<StructCard>,
            request: ByteArray
        ) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            let mut table: ComponentTable = world.read_model(table_id);
            let mut player: ComponentPlayer = world.read_model((table_id, caller));
            assert!(table.m_state == EnumGameState::Showdown, "Table is not at showdown phase");
            assert!(player.m_table_id == table_id, "Player is not at this table");

            match player.m_state {
                EnumPlayerState::NotCreated | EnumPlayerState::Waiting |
                EnumPlayerState::Folded | EnumPlayerState::Left => {
                    panic!("Player is not active");
                },
                EnumPlayerState::Revealed => {
                    panic!("Player has already revealed hand");
                },
                _ => {}
            };

            let mut hand: ComponentHand = world.read_model(caller);
            assert!(hand.m_commitment_hash.len() == 8, "Commitment hash is not 8 bytes");
            assert!(request != "", "Request is not valid");

            // Recompute the commitment hash of the hand to verify.
            let computed_hash: [u32; 8] = compute_sha256_byte_array(@format!("{}", request));
            let static_array: [u32; 8] = [
                *hand.m_commitment_hash[0],
                *hand.m_commitment_hash[1],
                *hand.m_commitment_hash[2],
                *hand.m_commitment_hash[3],
                *hand.m_commitment_hash[4],
                *hand.m_commitment_hash[5],
                *hand.m_commitment_hash[6],
                *hand.m_commitment_hash[7]
            ];

            assert!(computed_hash == static_array, "Commitment hash does not match");

            // Commitment has been verified, overwrite the encrypted cards with deccrypted ones to
            // display to all players.
            hand.m_cards = decrypted_hand.clone();
            player.m_state = EnumPlayerState::Revealed;

            world.write_model(@hand);
            world.write_model(@player);
            world.emit_event(@EventHandRevealed {
                    m_table_id: table_id,
                    m_player: caller,
                    m_request: request,
                    m_player_hand: decrypted_hand,
                    m_timestamp: get_block_timestamp(),
                }
            );

            // Check if all players have revealed their hands.
            let mut players: Array<ComponentPlayer> = array![];
            for player in table.m_players.span() {
                players.append(world.read_model((table_id, *player)));
            };

            if InternalImpl::_all_players_revealed(players.span()) {
                table_management_system::InternalImpl::_showdown(ref world, ref table);
                world.write_model(@table);
            }
        }

        /////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////
        //////////////////////////////// GETTERS ////////////////////////////////
        /////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////
        
        fn get_player_bet(self: @ContractState, table_id: u32, player: ContractAddress) -> u32 {
            let world = self.world(@"dominion");
            let player_component: ComponentPlayer = world.read_model((table_id, player));
            player_component.m_current_bet
        }

        fn get_player_position(self: @ContractState, table_id: u32, player: ContractAddress) -> EnumPosition {
            let world = self.world(@"dominion");
            let player_component: ComponentPlayer = world.read_model((table_id, player));
            player_component.m_position
        }

        fn get_player_state(self: @ContractState, table_id: u32, player: ContractAddress) -> EnumPlayerState {
            let world = self.world(@"dominion");
            let player_component: ComponentPlayer = world.read_model((table_id, player));
            player_component.m_state
        }

        fn get_player_total_chips(self: @ContractState, table_id: u32, player: ContractAddress) -> u32 {
            let world = self.world(@"dominion");
            let player_component: ComponentPlayer = world.read_model((table_id, player));
            player_component.m_total_chips
        }

        fn get_player_table_chips(self: @ContractState, table_id: u32, player: ContractAddress) -> u32 {
            let world = self.world(@"dominion");
            let player_component: ComponentPlayer = world.read_model((table_id, player));
            player_component.m_table_chips
        }

        fn has_player_revealed(self: @ContractState, table_id: u32, player: ContractAddress) -> bool {
            let world = self.world(@"dominion");
            let player_component: ComponentPlayer = world.read_model((table_id, player));
            player_component.m_state == EnumPlayerState::Revealed
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _all_players_revealed(players: Span<ComponentPlayer>) -> bool {
            let mut all_revealed: bool = true;
            for player in players {
                if player.m_state != @EnumPlayerState::Revealed {
                    all_revealed = false;
                    break;
                }
            };
            return all_revealed;
        }

        fn _check(ref world: dojo::world::WorldStorage, ref table: ComponentTable, ref player: ComponentPlayer,
                current_bet: u32, advance_turn: bool) {
            assert!(current_bet == 0, "Amount must be 0 to check");
            player.m_state = EnumPlayerState::Checked;

            if advance_turn {
                Self::_skip_folded_players(ref world, ref table);
            }
        }

        fn _place_bet(ref world: dojo::world::WorldStorage, ref table: ComponentTable, ref player: ComponentPlayer,
                current_bet: u32, advance_turn: bool) {
            assert!(current_bet > 0, "Amount must be greater than 0 to place a bet");

            // Determine the player's state based on the current bet.
            let last_raiser: ComponentPlayer = world.read_model((table.m_table_id, *table.m_players[table.m_last_raiser.into()]));

            if player.m_current_bet + current_bet >= last_raiser.m_current_bet {
                if player.m_current_bet + current_bet == last_raiser.m_current_bet {
                    // If our last bet combined with the current one matches the last raiser's bet, we call.
                    player.m_state = EnumPlayerState::Called;
                } else {
                    // If we are not at the beginning of the round and not small or big blind, we raise.
                    player.m_state = EnumPlayerState::Raised(current_bet);
                }
            }

            table.m_pot += player.place_bet(current_bet);
            if player.m_state == EnumPlayerState::AllIn {
                table_management_system::InternalImpl::_assign_player_to_sidepot(
                    ref world,
                    ref table,
                    player.m_owner,
                    player.m_current_bet);
            }
            
            if advance_turn {
                Self::_skip_folded_players(ref world, ref table);
            }
        }

        fn _fold(ref world: dojo::world::WorldStorage, ref table: ComponentTable, ref player: ComponentPlayer,
                advance_turn: bool) {
            table.m_pot += player.fold();
            // If the player was all-in, remove them from all sidepots.
            if player.m_state == EnumPlayerState::AllIn {
                table_management_system::InternalImpl::_remove_player_from_sidepots(
                    ref world,
                    ref table,
                    player.m_owner);
            }

            if advance_turn {
                Self::_skip_folded_players(ref world, ref table);
            }
        }

        /// Checks if the street is finished.
        ///
        /// @param players The players at the table.
        /// @returns True if the street is finished, false otherwise.
        /// Can Panic? No.
        fn _is_street_finished(mut last_raiser: u8, players: @Array<ComponentPlayer>) -> bool {
            let mut highest_bet: u32 = *players[last_raiser.into()].m_current_bet;
            let mut active_players: u32 = 0;
        
            // First pass: find highest bet and count active players.
            for index in 0..players.len() {
                let player: @ComponentPlayer = players[index];
                if *player.m_state != EnumPlayerState::Folded {
                    active_players += 1;
                    if *player.m_current_bet > highest_bet {
                        last_raiser = index.try_into().unwrap();
                        highest_bet = *player.m_current_bet;
                    }
                }
            };
        
            // If only one active player, street is finished.
            if active_players <= 1 {
                return true;
            }
        
            // Second pass: verify all active players have either:
            // 1. Matched the highest bet.
            // 2. Are all-in with a lower amount.
            let mut matched_bet: bool = true;
            for index in 0..active_players {
                let current_turn: u32 = (last_raiser.into() + index) % players.len();
                let player: @ComponentPlayer = players[current_turn];
                if *player.m_state == EnumPlayerState::Folded {
                    continue;
                }
                
                match player.m_state {
                    EnumPlayerState::AllIn => {
                        continue;
                    },
                    EnumPlayerState::Raised(_) | EnumPlayerState::Called |
                    EnumPlayerState::Checked => {
                        if *player.m_current_bet != highest_bet {
                            matched_bet = false;
                            break;
                        }
                    },
                    _ => {
                        matched_bet = false;
                        break;
                    }
                }
            };
        
            return matched_bet;
        }

        fn _skip_folded_players(ref world: dojo::world::WorldStorage, ref table: ComponentTable) {
            let players_len = table.m_players.len();
            let mut index: u32 = ((table.m_current_turn + 1) % players_len.try_into().unwrap()).into();
            let mut players_folded: Array<EnumPlayerState> = array![];
            let mut player_component: ComponentPlayer = world.read_model((table.m_table_id, *table.m_players[index % players_len.try_into().unwrap()]));
            
            while player_component.m_state == EnumPlayerState::Folded {
                players_folded.append(player_component.m_state);
                index += 1;
                player_component = world.read_model((table.m_table_id, *table.m_players[index % players_len.try_into().unwrap()]));
            };
            table.advance_turn(players_folded);
        }
    }
}
