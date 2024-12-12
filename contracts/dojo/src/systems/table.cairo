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

use starknet::ContractAddress;

#[starknet::interface]
trait ITableSystem<TContractState> {
    fn create_table(
        ref self: TContractState, small_blind: u32, big_blind: u32, min_buy_in: u32, max_buy_in: u32
    );
    fn join_table(ref self: TContractState, table_id: u32, chips_amount: u32);
    fn set_ready(ref self: TContractState, table_id: u32);
    fn leave_table(ref self: TContractState, table_id: u32);
    fn top_up_table_chips(ref self: TContractState, table_id: u32, chips_amount: u32);
}

#[dojo::contract]
mod table_system {
    use dominion::models::components::{ComponentTable, ComponentPlayer};
    use dominion::models::enums::{EnumGameState, EnumPlayerState, EnumPosition};
    use dominion::models::traits::{ITable, IPlayer};
    use dominion::systems::table_manager::{ITableManagementDispatcher, ITableManagementDispatcherTrait};
    use starknet::{ContractAddress, get_caller_address, TxInfo, get_tx_info};
    use dojo::{model::ModelStorage, world::IWorldDispatcher};

    // Constant for table player limits.
    const MAX_PLAYERS: u32 = 6;
    const MAX_TABLES: u32 = 10;
    // Contract specific storage.
    #[storage]
    struct Storage {
        game_master: ContractAddress, // Address of the game master who can create tables.
        counter: u32, // Counter for generating unique table IDs.
        max_tables: u32,
    }

    #[constructor]
    fn constructor(ref self: ContractState, max_tables: u32) {
        self.game_master.write(get_caller_address());
        self.counter.write(1);
        self.max_tables.write(max_tables);
    }

    #[abi(embed_v0)]
    impl TableSystemImpl of super::ITableSystem<ContractState> {
        // Creates a new poker table with blinds and buy-in limits
        fn create_table(
            ref self: ContractState,
            small_blind: u32,
            big_blind: u32,
            min_buy_in: u32,
            max_buy_in: u32
        ) {
            assert!(self.counter.read() < self.max_tables.read(), "Max tables reached");
            assert!(max_buy_in > 0, "Maximum buy-in cannot be less than 0");
            assert!(
                min_buy_in < max_buy_in, "Minimum buy-in cannot be greater than maximum buy-in"
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
        }

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
            assert!(table.m_players.len() < MAX_PLAYERS, "Table is full");
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
    }
}
