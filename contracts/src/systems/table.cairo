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
    fn join_table(ref self: TContractState, table_id: u32);
    fn leave_table(ref self: TContractState, table_id: u32);
}

#[dojo::contract]
mod table_system {
    use dominion::models::components::{ComponentTable, ComponentPlayer, ComponentHand};
    use dominion::models::enums::{EnumPosition, EnumGameState, EnumPlayerState};
    use dominion::models::structs::StructCard;
    use dominion::models::enums::{EnumCardSuit, EnumCardValue};
    use dominion::models::traits::ITable;
    use starknet::{ContractAddress, get_caller_address, TxInfo, get_tx_info};
    use dojo::{model::ModelStorage, world::IWorldDispatcher};


    const MAX_PLAYERS: u32 = 6;
    #[storage]
    struct Storage {
        game_master: ContractAddress,
        counter: u32,
    }

    fn dojo_init(ref self: ContractState) {
        let tx_info: TxInfo = get_tx_info().unbox();

        // Access the account_contract_address field
        let sender: ContractAddress = tx_info.account_contract_address;

        // Set the game master to the sender
        self.game_master.write(sender);
        self.counter.write(1); // Start at 1 because 0 is reserved for table that is not created yet
    }

    #[abi(embed_v0)]
    impl TableSystemImpl of super::ITableSystem<ContractState> {
        fn create_table(
            ref self: ContractState,
            small_blind: u32,
            big_blind: u32,
            min_buy_in: u32,
            max_buy_in: u32
        ) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            assert!(self.game_master.read() == caller, "Only game master can create table");

            let table_id = self.counter.read();
            // Create new table
            let table: ComponentTable = ITable::new(
                table_id, small_blind, big_blind, min_buy_in, max_buy_in, array![]
            );

            // Write table to world
            world.write_model(@table);

            // Increment counter
            self.counter.write(table_id + 1);
        }

        fn join_table(ref self: ContractState, table_id: u32) {}

        fn leave_table(ref self: ContractState, table_id: u32) {}
    }
}
