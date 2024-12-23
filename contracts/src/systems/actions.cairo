use dominion::models::structs::StructCard;
use starknet::ContractAddress;

#[starknet::interface]
trait IActions<TContractState> {
    fn bet(ref self: TContractState, table_id: u32, amount: u32, table_manager: ContractAddress);
    fn fold(ref self: TContractState, table_id: u32, table_manager: ContractAddress);
    fn post_commit_hash(ref self: TContractState, table_id: u32, commitment_hash: Array<u32>);
    fn top_up_table_chips(ref self: TContractState, table_id: u32, chips_amount: u32);
    fn set_ready(ref self: TContractState, table_id: u32, table_manager: ContractAddress);
    fn join_table(ref self: TContractState, table_id: u32, chips_amount: u32);
    fn leave_table(ref self: TContractState, table_id: u32);
    fn reveal_hand(
        ref self: TContractState,
        table_id: u32,
        decrypted_hand: Array<StructCard>,
        request: ByteArray,
        table_manager: ContractAddress
    );
}

#[dojo::contract]
mod actions_system {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp, TxInfo, get_tx_info};
    use dojo::{model::ModelStorage, world::IWorldDispatcher};
    use dojo::event::{EventStorage};
    use dominion::models::components::{ComponentTable, ComponentPlayer, ComponentHand};
    use dominion::models::enums::{EnumPlayerState, EnumGameState};
    use dominion::models::traits::{IPlayer, ITable};
    use dominion::models::structs::StructCard;
    use alexandria_data_structures::array_ext::ArrayTraitExt;
    use core::sha256::compute_sha256_byte_array;
    use dominion::systems::table_manager::{
        ITableManagementDispatcher, ITableManagementDispatcherTrait
    };

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
        // Allows a player to join a table with specified chips amount
        fn join_table(ref self: ContractState, table_id: u32, chips_amount: u32) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            // Get table and player components
            let mut player: ComponentPlayer = world.read_model((table_id, caller));

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

        fn set_ready(ref self: ContractState, table_id: u32, table_manager: ContractAddress) {
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
            for i in 0
                ..table
                    .m_players
                    .len() {
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
            if (player_statuses.len() == table.m_players.len() && table.m_players.len() > 1) {
                world
                    .emit_event(
                        @EventAllPlayersReady {
                            m_table_id: table_id,
                            m_players: table.m_players,
                            m_timestamp: get_block_timestamp()
                        }
                    );
                let mut table_manager: ITableManagementDispatcher = ITableManagementDispatcher {
                    contract_address: table_manager
                };
                table_manager.start_round(table_id);
            }
        }

        // Allows a player to leave a table and collect their chips
        fn leave_table(ref self: ContractState, table_id: u32) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            let mut player: ComponentPlayer = world.read_model(caller);
            let mut table: ComponentTable = world.read_model(player.m_table_id);

            // Reset player's table state and return chips
            player.m_table_id = 0;
            table.m_pot += player.m_current_bet;
            player.m_total_chips += player.m_table_chips;
            player.m_table_chips = 0;
            player.m_state = EnumPlayerState::Left;

            world.write_model(@player);
            world.write_model(@table);

            world
                .emit_event(
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

        fn bet(
            ref self: ContractState, table_id: u32, amount: u32, table_manager: ContractAddress
        ) {
            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            assert!(
                table.m_state != EnumGameState::Shutdown
                    && table.m_state != EnumGameState::WaitingForPlayers,
                "Game is not in a betting phase"
            );
            if amount == 0 {
                // Player has checked.
                table.advance_turn();
                if table.m_current_turn == 0 {
                    // If we were the last player doing our turn, advance the street.
                    table.m_finished_street = true;
                    world.write_model(@table);
                    table.advance_street();
                    return;
                }
                world.write_model(@table);
                return;
            }

            let mut player_component: ComponentPlayer = world.read_model(get_caller_address());
            assert!(player_component.m_state == EnumPlayerState::Active, "Player is not active");
            assert!(table.check_turn(@get_caller_address()), "It is not your turn");

            table.m_pot += player_component.place_bet(amount);
            world.write_model(@player_component);
            table.advance_turn();
            if table.m_current_turn == 0 {
                // If we were the last player doing our turn, advance the street.
                table.m_finished_street = true;
                world.write_model(@table);
                table.advance_street();
                return;
            }
            world.write_model(@table);
        }

        fn fold(ref self: ContractState, table_id: u32, table_manager: ContractAddress) {
            let mut world = self.world(@"dominion");

            let mut table: ComponentTable = world.read_model(table_id);
            assert!(
                table.m_state != EnumGameState::Shutdown
                    && table.m_state != EnumGameState::WaitingForPlayers,
                "Game is not in a betting phase"
            );

            let mut player_component: ComponentPlayer = world.read_model(get_caller_address());
            assert!(player_component.m_state == EnumPlayerState::Active, "Player is not active");
            assert!(table.check_turn(@get_caller_address()), "It is not your turn");

            if player_component.m_table_chips > 0 {
                table.m_pot += player_component.fold();
            }
            world.write_model(@player_component);
            table.advance_turn();
            if table.m_current_turn == 0 {
                // If we were the last player doing our turn, advance the street.
                table.m_finished_street = true;
                world.write_model(@table);
                table.advance_street();
                return;
            }
            world.write_model(@table);
        }

        fn post_commit_hash(ref self: ContractState, table_id: u32, commitment_hash: Array<u32>) {
            let mut world = self.world(@"dominion");

            let mut hand: ComponentHand = world.read_model(get_caller_address());
            hand.m_commitment_hash = commitment_hash;
            world.write_model(@hand);
        }

        fn reveal_hand(
            ref self: ContractState,
            table_id: u32,
            decrypted_hand: Array<StructCard>,
            request: ByteArray,
            table_manager: ContractAddress
        ) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            let mut table: ComponentTable = world.read_model(table_id);
            let mut player: ComponentPlayer = world.read_model(caller);
            assert!(table.m_state == EnumGameState::Showdown, "Table is not at showdown phase");
            assert!(player.m_table_id == table_id, "Player is not at this table");

            assert!(player.m_state == EnumPlayerState::Active, "Player is not active");

            let mut hand: ComponentHand = world.read_model(caller);

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
            world
                .emit_event(
                    @EventHandRevealed {
                        m_table_id: table_id,
                        m_player: caller,
                        m_request: request,
                        m_player_hand: decrypted_hand,
                        m_timestamp: get_block_timestamp(),
                    }
                );

            if InternalImpl::_all_players_revealed(@world, table_id) {
                let mut table_manager: ITableManagementDispatcher = ITableManagementDispatcher {
                    contract_address: table_manager
                };
                table_manager.advance_street(table_id);
            }
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _all_players_revealed(world: @dojo::world::WorldStorage, table_id: u32) -> bool {
            let mut all_revealed: bool = true;
            let table: ComponentTable = world.read_model(table_id);
            for player in table
                .m_players
                .span() {
                    let player_component: ComponentPlayer = world.read_model(*player);
                    if player_component.m_state != EnumPlayerState::Revealed {
                        all_revealed = false;
                        break;
                    }
                };
            return all_revealed;
        }
    }
}
