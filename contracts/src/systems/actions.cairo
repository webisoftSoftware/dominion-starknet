use dominion::models::structs::StructCard;
use starknet::ContractAddress;

#[starknet::interface]
pub trait IActions<TContractState> {
    fn bet(ref self: TContractState, table_id: u32, amount: u32);
    fn fold(ref self: TContractState, table_id: u32);
    fn post_auth_hash(ref self: TContractState, table_id: u32, auth_hash: ByteArray);
    fn post_commit_hash(ref self: TContractState, table_id: u32, commitment_hash: Array<u32>);
    fn top_up_table_chips(ref self: TContractState, table_id: u32, chips_amount: u32);
    fn skip_turn(ref self: TContractState, table_id: u32, player: ContractAddress);
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
    fn get_player_state(self: @TContractState, table_id: u32, player: ContractAddress) -> ByteArray;
    fn get_player_bet(self: @TContractState, table_id: u32, player: ContractAddress) -> u32;
    fn get_player_position(self: @TContractState, table_id: u32, player: ContractAddress) -> ByteArray;
    fn get_player_table_chips(self: @TContractState, table_id: u32, player: ContractAddress) -> u32;
    fn get_player_hand(self: @TContractState, table_id: u32, player: ContractAddress) -> Array<StructCard>;
    fn is_player_dealer(self: @TContractState, table_id: u32, player: ContractAddress) -> bool;
    fn get_player_commitment_hash(self: @TContractState, table_id: u32, player: ContractAddress) -> Array<u32>;
    fn has_player_revealed(self: @TContractState, table_id: u32, player: ContractAddress) -> bool;
    fn get_winners(self: @TContractState, table_id: u32, round: u32) -> Array<ByteArray>;
}

#[dojo::contract]
pub(crate) mod actions_system {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use dojo::{model::ModelStorage};
    use dojo::event::{EventStorage};
    use dominion::models::components::{
        ComponentTable, ComponentPlayer, ComponentHand,
        ComponentBank, ComponentTableInfo, ComponentStreet, ComponentRound, ComponentProof
    };
    use dominion::models::enums::{
        EnumPlayerState, EnumTableState, EnumStreetState, EnumPosition
    };
    use dominion::models::traits::{
        IPlayer, ITable, ComponentTableDisplay, EnumTableStateDisplay,
        ComponentPlayerDisplay, EnumHandRankSnapshotInto, EnumHandRankSnapshotIntoMask,
        EnumPlayerStateDisplay, IRound, IProof, EnumPositionInto, EnumPlayerStateInto,
        EnumHandRankDisplay, ComponentHandDisplay
    };
    use dominion::models::structs::StructCard;
    use core::sha256::compute_sha256_byte_array;

    use dominion::systems::table_manager::table_management_system;

    // Constants
    const ETH_TO_CHIPS_RATIO: u256 =
        1_000_000_000_000; // 1,000,000 chips per ETH

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    pub(crate) struct EventRequestBet {
        #[key]
        m_table_id: u32,
        m_timestamp: u64,
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    pub(crate) struct EventShowdownRequested {
        #[key]
        m_table_id: u32,
        m_timestamp: u64
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    pub(crate) struct EventRevealShowdownRequested {
        #[key]
        m_table_id: u32,
        #[key]
        m_player: ContractAddress,
        m_hand: Span<StructCard>,
        m_timestamp: u64
    }

    #[derive(Clone, Drop, Serde, Debug)]
    #[dojo::event]
    pub(crate) struct EventHandRevealed {
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
    pub(crate) struct EventPlayerJoined {
        #[key]
        m_table_id: u32,
        #[key]
        m_player: ContractAddress,
        m_timestamp: u64,
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    pub(crate) struct EventAllPlayersReady {
        #[key]
        m_table_id: u32,
        m_players: Array<ContractAddress>,
        m_timestamp: u64,
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    pub(crate) struct EventStreetAdvanced {
        #[key]
        m_table_id: u32,
        m_timestamp: u64,
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    pub(crate) struct EventAuthHashRequested {
        #[key]
        m_table_id: u32,
        #[key]
        m_player: ContractAddress,
        m_auth_hash: ByteArray,
        m_timestamp: u64
    }

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    pub(crate) struct EventPlayerLeft {
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
            let mut player_bank: ComponentBank = world.read_model(caller);
            let mut player: ComponentPlayer = world.read_model((table_id, caller));
            
            // Create new player if first time joining
            if !player.m_is_created {
                player = IPlayer::new(table_id, caller);
            }
            
            // Validate table capacity and chip amounts.
            let mut table: ComponentTable = world.read_model(table_id);
            let table_info: ComponentTableInfo = world.read_model(table_id);
            assert!(table_info.m_state != EnumTableState::Shutdown, "Table is not created or shutdown");
            assert!(table.m_players.len() < 6, "Table is full");
            assert!(!table.contains_player(@caller), "Player is already at the table");
            assert!(player_bank.m_balance >= chips_amount, "Insufficient chips");

            assert!(table_info.m_min_buy_in <= chips_amount, "Amount is less than min buy in");
            assert!(table_info.m_max_buy_in >= chips_amount, "Amount is more than max buy in");

            // Update player state for joining table.
            player_bank.m_balance -= chips_amount;
            player.m_table_chips += chips_amount;
            player.m_state = EnumPlayerState::Waiting;

            // Reset player's current bet if they previously joined the table.
            player.m_current_bet = 0;

            // Update world state
            world.write_model(@player_bank);
            world.write_model(@player);
            table.m_players.append(caller);

            world.write_model(@table);
            world
                .emit_event(
                    @EventPlayerJoined {
                        m_table_id: table_id,
                        m_player: caller,
                        m_timestamp: starknet::get_block_timestamp()
                    }
                );
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
            let table_info: ComponentTableInfo = world.read_model(table_id);
            assert!(table_info.m_state == EnumTableState::WaitingForPlayers, "Table is not waiting for players");

            let mut player: ComponentPlayer = world.read_model((table_id, caller));
            assert!(player.m_state == EnumPlayerState::Waiting, "Cannot ready up player: Invalid state");

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
            let mut table_info: ComponentTableInfo = world.read_model(table_id);
            assert!(table_info.m_state != EnumTableState::Shutdown, "Table is not created or shutdown");

            let mut player: ComponentPlayer = world.read_model((table_id, caller));
            assert!(table.contains_player(@caller), "Player is not at the table");

            let mut player_bank: ComponentBank = world.read_model(caller);
            let mut hand: ComponentHand = world.read_model((table_id, caller));

            // Reset player's table state and return chips
            table.m_pot += player.m_current_bet;
            player_bank.m_balance += player.m_table_chips;

            hand.m_cards = array![];
            hand.m_commitment_hash = array![];
            player.m_table_chips = 0;
            player.m_state = EnumPlayerState::Left;

            world.write_model(@player_bank);
            world.write_model(@player);
            world.write_model(@hand);

            // Remove player from table.
            let mut new_table_players: Array<ContractAddress> = array![];
            for player in table.m_players.span() {
                if *player != caller {
                    new_table_players.append(*player);
                }
            };
            table.m_players = new_table_players;

            // If there's only one player left, reset the round and give the table pot to the remaining player.
            if table.m_players.len() == 1 {
                let mut player: ComponentPlayer = world.read_model((table.m_table_id, *table.m_players[0]));
                player.m_state = EnumPlayerState::Waiting;
                player.m_table_chips += table.m_pot;
                world.write_model(@player);

                table.reset_table();
                table_info.m_state = EnumTableState::WaitingForPlayers;

                let mut proofs: ComponentProof = world.read_model(table.m_table_id);
                proofs.reset();
                world.write_model(@proofs);
            }

            // Update table roles if player was dealer/big blind/small blind.
            if player.m_is_dealer || player.m_position == EnumPosition::BigBlind ||
                player.m_position == EnumPosition::SmallBlind {
                table_management_system::InternalImpl::_update_roles(ref world, ref table);
            }

            world.write_model(@table_info);
            world.write_model(@table);
            world.emit_event(
                @EventPlayerLeft {
                    m_table_id: table_id,
                    m_player: caller,
                    m_timestamp: starknet::get_block_timestamp()
                }
            );
        }

        fn skip_turn(ref self: ContractState, table_id: u32, player: ContractAddress) {
            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            let table_info: ComponentTableInfo = world.read_model(table_id);
            assert!(table_info.m_state == EnumTableState::InProgress, "Game has not started");

            let mut round: ComponentRound = world.read_model((table_id, table.m_current_round));
            assert!(round.check_turn(@player), "Cannot skip player's turn: Not player's turn");
            let last_played_ts: u64 = round.m_last_played_ts;

            // Avoid sub overflow.
            if starknet::get_block_timestamp() >= 60 {
                assert!(
                    last_played_ts < starknet::get_block_timestamp() - 60,
                    "Player has not been inactive for at least 60 seconds"
                );
            }

            // Skip turn.
            let mut player_component: ComponentPlayer = world.read_model((table_id, player));
            player_component.fold();
            table_management_system::InternalImpl::_skip_folded_players(ref world, ref table);

            world.write_model(@table);
            world.write_model(@player_component);
        }

        // Allows a player to add more chips to their stack at the table
        fn top_up_table_chips(ref self: ContractState, table_id: u32, chips_amount: u32) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            let table: ComponentTable = world.read_model(table_id);
            let table_info: ComponentTableInfo = world.read_model(table_id);
            assert!(table_info.m_state != EnumTableState::Shutdown, "Table is not created or shutdown");

            let mut player: ComponentPlayer = world.read_model((table_id, caller));

            // Validate player state and chip amount
            assert!(player.m_state != EnumPlayerState::NotCreated, "Player does not exist");
            assert!(table.contains_player(@player.m_owner), "Player is not at this table");

            let mut player_bank: ComponentBank = world.read_model(caller);
            assert!(player_bank.m_balance >= chips_amount, "Insufficient chips");

            // Transfer chips from total to table stack
            player_bank.m_balance -= chips_amount;
            player.m_table_chips += chips_amount;

            world.write_model(@player_bank);
            world.write_model(@player);
        }

        fn bet(ref self: ContractState, table_id: u32, amount: u32) {
            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            let table_info: ComponentTableInfo = world.read_model(table_id);
            assert!(table_info.m_state == EnumTableState::InProgress, "Game has not started");

            let proofs: ComponentProof = world.read_model(table_id);
            assert!(proofs.m_deck_proof != "", "Deck is not encrypted");

            let mut street: ComponentStreet = world.read_model((table_id, table.m_current_round));
            assert!(!street.m_finished_street, "Street is already finished");

            let current_round: ComponentRound = world.read_model((table_id, table.m_current_round));
            assert!(current_round.check_turn(@get_caller_address()), "It is not your turn");

            let player_component: ComponentPlayer = world.read_model((table_id, get_caller_address()));
            match player_component.m_state {
                EnumPlayerState::NotCreated | EnumPlayerState::Waiting | EnumPlayerState::Revealed |
                EnumPlayerState::Folded | EnumPlayerState::Left => {
                    panic!("Player is not active");
                },
                _ => {}
            }

            match amount {
                0 => InternalImpl::_check(ref world, ref table, amount),
                _ => InternalImpl::_place_bet(ref world, ref table, amount),
            };

            let mut current_round: ComponentRound = world.read_model((table_id, table.m_current_round));

            // Automatically skip folded player's turns and advance turn.
            table_management_system::InternalImpl::_skip_folded_players(ref world, ref table);

            if InternalImpl::_is_street_finished(current_round.m_highest_raise, @world, @table) {
                street.m_finished_street = true;
                world.write_model(@street);
                table_management_system::InternalImpl::_advance_street(ref world, ref table);
            }

            world.write_model(@table);
        }

        fn fold(ref self: ContractState, table_id: u32) {
            let mut world = self.world(@"dominion");

            let mut table: ComponentTable = world.read_model(table_id);
            let table_info: ComponentTableInfo = world.read_model(table_id);
            assert!(table_info.m_state == EnumTableState::InProgress, "Game has not started");

            let proofs: ComponentProof = world.read_model(table_id);
            assert!(proofs.m_deck_proof != "", "Deck is not encrypted");

            let mut street: ComponentStreet = world.read_model((table_id, table.m_current_round));
            assert!(!street.m_finished_street, "Street is already finished");

            let current_round: ComponentRound = world.read_model((table_id, table.m_current_round));
            assert!(current_round.check_turn(@get_caller_address()), "It is not your turn");

            let player_component: ComponentPlayer = world.read_model((table_id, get_caller_address()));
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

            InternalImpl::_fold(ref world, ref table);

            // Advance round turn.
            let mut current_round: ComponentRound = world.read_model((table_id, table.m_current_round));

            // Automatically skip folded player's turns and advance turn.
            table_management_system::InternalImpl::_skip_folded_players(ref world, ref table);

            if  InternalImpl::_is_street_finished(current_round.m_highest_raise, @world, @table) {
                street.m_finished_street = true;
                world.write_model(@street);
                table_management_system::InternalImpl::_advance_street(ref world, ref table);
            }

            world.write_model(@table);
        }

        fn post_auth_hash(ref self: ContractState, table_id: u32, auth_hash: ByteArray) {
            let mut world = self.world(@"dominion");

            let table_info: ComponentTableInfo = world.read_model(table_id);
            assert!(table_info.m_state == EnumTableState::InProgress, "Game has not started");

            let player_component: ComponentPlayer = world.read_model((table_id, get_caller_address()));
            match player_component.m_state {
                EnumPlayerState::NotCreated | EnumPlayerState::Waiting |
                EnumPlayerState::Folded | EnumPlayerState::Left => {
                    panic!("Player is not active");
                },
                _ => {}
            };

            //player_component.m_auth_hash = auth_hash.clone();
            //world.write_model(@player_component);
            world.emit_event(@EventAuthHashRequested {
                m_table_id: table_id,
                m_player: player_component.m_owner,
                m_auth_hash: auth_hash,
                m_timestamp: starknet::get_block_timestamp()
            });
        }

        fn post_commit_hash(ref self: ContractState, table_id: u32, commitment_hash: Array<u32>) {
            let mut world = self.world(@"dominion");

            let table_info: ComponentTableInfo = world.read_model(table_id);
            assert!(table_info.m_state == EnumTableState::InProgress, "Game has not started");

            let player_component: ComponentPlayer = world.read_model((table_id, get_caller_address()));
            match player_component.m_state {
                EnumPlayerState::NotCreated | EnumPlayerState::Waiting |
                EnumPlayerState::Folded | EnumPlayerState::Left => {
                    panic!("Player is not active");
                },
                _ => {}
            };
            assert!(commitment_hash.len() == 8, "Commitment hash is not 8 bytes");

            let mut hand: ComponentHand = world.read_model((table_id, get_caller_address()));
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
            let table_info: ComponentTableInfo = world.read_model(table_id);
            assert!(table_info.m_state == EnumTableState::InProgress, "Game has not started");

            let street: ComponentStreet = world.read_model((table_id, table.m_current_round));
            assert!(street.m_state == EnumStreetState::Showdown, "Round is not at showdown phase");

            let mut player: ComponentPlayer = world.read_model((table_id, caller));
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

            let mut hand: ComponentHand = world.read_model((table_id, caller));
            assert!(hand.m_commitment_hash.len() == 8, "Commitment hash is not 8 bytes");
            assert!(request != "", "Request is not valid");

            //Recompute the commitment hash of the hand to verify.
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
                world.emit_event(
                    @EventShowdownRequested {
                        m_table_id: table.m_table_id, m_timestamp: starknet::get_block_timestamp()
                    }
                );
                table_management_system::InternalImpl::_showdown(ref world, ref table);
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

        fn get_player_position(self: @ContractState, table_id: u32, player: ContractAddress) -> ByteArray {
            let world = self.world(@"dominion");
            let player_component: ComponentPlayer = world.read_model((table_id, player));
            player_component.m_position.into()
        }

        fn get_player_state(self: @ContractState, table_id: u32, player: ContractAddress) -> ByteArray {
            let world = self.world(@"dominion");
            let player_component: ComponentPlayer = world.read_model((table_id, player));
            player_component.m_state.into()
        }

        fn get_player_table_chips(self: @ContractState, table_id: u32, player: ContractAddress) -> u32 {
            let world = self.world(@"dominion");
            let player_component: ComponentPlayer = world.read_model((table_id, player));
            player_component.m_table_chips
        }

        fn get_player_hand(self: @ContractState, table_id: u32, player: ContractAddress) -> Array<StructCard> {
            let world = self.world(@"dominion");
            let hand: ComponentHand = world.read_model((table_id, player));
            hand.m_cards
        }

        fn get_player_commitment_hash(self: @ContractState, table_id: u32, player: ContractAddress) -> Array<u32> {
            let world = self.world(@"dominion");
            let hand: ComponentHand = world.read_model((table_id, player));
            hand.m_commitment_hash
        }

        fn has_player_revealed(self: @ContractState, table_id: u32, player: ContractAddress) -> bool {
            let world = self.world(@"dominion");
            let player_component: ComponentPlayer = world.read_model((table_id, player));
            player_component.m_state == EnumPlayerState::Revealed
        }

        fn is_player_dealer(self: @ContractState, table_id: u32, player: ContractAddress) -> bool {
            let world = self.world(@"dominion");
            let player_component: ComponentPlayer = world.read_model((table_id, player));
            player_component.m_is_dealer
        }

        fn get_winners(self: @ContractState, table_id: u32, round: u32) -> Array<ByteArray> {
            //let world = self.world(@"dominion");
            let mut result: Array<ByteArray> = array![];

            //let winners: ComponentWinners = world.read_model((table_id, round));
            //for index in 0..winners.m_winners.len() {
            //    let hand: ComponentHand = world.read_model((table_id, *winners.m_winners[index]));
            //    result.append(format!("Player {:?} has won {1} with {2}{3}",
            //    *winners.m_winners[index], *winners.m_amounts[index], winners.m_hands[index].clone(),
            //    hand));
            //};
            return result;
        }
    }

    #[generate_trait]
    pub(crate) impl InternalImpl of InternalTrait {
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

        fn _check(ref world: dojo::world::WorldStorage, ref table: ComponentTable, current_bet: u32) {
            assert!(current_bet == 0, "Amount must be 0 to check");

            // Determine the player's state based on the current bet
            let mut player_component: ComponentPlayer = world.read_model((table.m_table_id, get_caller_address()));
            let mut current_round: ComponentRound = world.read_model((table.m_table_id, table.m_current_round));

            if player_component.m_state != EnumPlayerState::AllIn {
                assert!(player_component.m_current_bet + current_bet == current_round.m_highest_raise, "Cannot check with an inferior amount");
                player_component.m_state = EnumPlayerState::Checked;
            }
            world.write_model(@player_component);
        }

        fn _place_bet(ref world: dojo::world::WorldStorage, ref table: ComponentTable, current_bet: u32) {
            assert!(current_bet > 0, "Amount must be greater than 0 to place a bet");

            // Determine the player's state based on the current bet.
            let mut player_component: ComponentPlayer = world.read_model((table.m_table_id, get_caller_address()));
            let mut current_round: ComponentRound = world.read_model((table.m_table_id, table.m_current_round));

            if player_component.m_current_bet + current_bet >= current_round.m_highest_raise {
                if player_component.m_current_bet + current_bet == current_round.m_highest_raise {
                    // If our last bet combined with the current one matches the last raiser's bet, we call.
                    player_component.m_state = EnumPlayerState::Called;
                } else {
                    // If we are not at the beginning of the round and not small or big blind, we raise.
                    player_component.m_state = EnumPlayerState::Raised(current_bet);
                    current_round.m_last_raiser_addr = player_component.m_owner;
                    current_round.m_last_raiser = table.find_player(@player_component.m_owner).expect('Cannot find last raiser').try_into().unwrap();
                    current_round.m_highest_raise = player_component.m_current_bet + current_bet;
                    // Update last raiser.
                    world.write_model(@current_round);
                }
            }

            table.m_pot += player_component.place_bet(current_bet);
            world.write_model(@player_component);

            if player_component.m_state == EnumPlayerState::AllIn {
                table_management_system::InternalImpl::_assign_player_to_sidepot(
                    ref world,
                    ref table,
                    player_component.m_owner,
                    player_component.m_current_bet);
            }
        }

        fn _fold(ref world: dojo::world::WorldStorage, ref table: ComponentTable) {
            let mut player_component: ComponentPlayer = world.read_model((table.m_table_id, get_caller_address()));
            table.m_pot += player_component.fold();
            // If the player was all-in, remove them from all sidepots.
            if player_component.m_state == EnumPlayerState::AllIn {
                table_management_system::InternalImpl::_remove_player_from_sidepots(
                    ref world,
                    ref table,
                    player_component.m_owner);
            }
            world.write_model(@player_component);
        }

        /// Checks if the street is finished.
        ///
        /// @param players The players at the table.
        /// @returns True if the street is finished, false otherwise.
        /// Can Panic? No.
        fn _is_street_finished(highest_raise: u32, world: @dojo::world::WorldStorage, table: @ComponentTable) -> bool {
            let mut active_players: Array<ComponentPlayer> = array![];
            let mut players_played: u32 = 0;

            for player in table.m_players.span() {
                let component: ComponentPlayer = world.read_model((*table.m_table_id, *player));
                if component.m_state != EnumPlayerState::Folded {
                    active_players.append(component);
                }
            };

            // If everyone else folded, street is finished.
            if active_players.len() == 1 {
                return true;
            }

            // Verify all active players have either:
            // 1. Matched the highest bet.
            // 2. Are all-in with a lower amount.
            let mut matched_bet: bool = true;
            for index in 0..active_players.len() {
                let current_turn: u32 = index % active_players.len();
                let player: @ComponentPlayer = active_players[current_turn];
                if *player.m_state == EnumPlayerState::Folded {
                    players_played += 1;
                    continue;
                }
                
                match player.m_state {
                    EnumPlayerState::AllIn => {
                        players_played += 1;
                        continue;
                    },
                    EnumPlayerState::Raised(_) | EnumPlayerState::Called |
                    EnumPlayerState::Checked => {
                        players_played += 1;
                        if *player.m_current_bet != highest_raise {
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

            return players_played == active_players.len() && matched_bet;
        }
    }
}
