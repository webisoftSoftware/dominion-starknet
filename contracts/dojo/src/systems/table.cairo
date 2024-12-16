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

    fn top_up_table_chips(ref self: TContractState, table_id: u32, chips_amount: u32);
    fn shutdown_table(ref self: TContractState, table_id: u32);
}

#[dojo::contract]
mod table_system {
    use dominion::models::components::{ComponentTable, ComponentPlayer};
    use dominion::models::enums::{EnumGameState, EnumPlayerState, EnumPosition};
    use dominion::models::traits::{ITable, IPlayer};
    use dominion::systems::table_manager::{
        ITableManagementDispatcher, ITableManagementDispatcherTrait
    };
    use starknet::{ContractAddress, get_caller_address, TxInfo, get_tx_info, get_block_timestamp};
    use dojo::{model::ModelStorage, world::IWorldDispatcher};
    use dojo::event::{EventStorage};
    use core::sha256;

    // Contract specific storage.
    #[storage]
    struct Storage {
        table_manager: ContractAddress, // Address of the table manager who can create tables.
        counter: u32, // Counter for generating unique table IDs.
    }

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    struct EventTableCreated {
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

        // Initialize the counter for table IDs
        self.counter.write(1);
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
            assert!(
                self.table_manager.read() == get_caller_address(),
                "Only the table manager can create tables"
            );

            assert!(small_blind > 0, "Small blind cannot be less than 0");
            assert!(big_blind > small_blind, "Big blind cannot be less than small blind");

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

            world
                .emit_event(
                    @EventTableCreated { m_table_id: table_id, m_timestamp: get_block_timestamp() }
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

        fn shutdown_table(ref self: ContractState, table_id: u32) {
            assert!(
                self.table_manager.read() == get_caller_address(),
                "Only the table manager can shutdown the table"
            );

            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            table.m_state = EnumGameState::Shutdown;
            world.write_model(@table);
        }
    }
}
