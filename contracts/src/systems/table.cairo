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

#[starknet::interface]
trait ITableSystem<TContractState> {
    fn create_table(ref self: TContractState, table_id: u32, small_blind: u256, big_blind: u256);
    fn join_table(ref self: TContractState, table_id: u32);
    fn leave_table(ref self: TContractState, table_id: u32);
    fn initialize_deck(ref self: TContractState, table_id: u32);
    fn deal_cards(ref self: TContractState, table_id: u32);
    fn encode_cards(ref self: TContractState, table_id: u32);
    fn shuffle_deck(ref self: TContractState, table_id: u32);
}

#[dojo::contract]
mod table_system {
    use starknet::{ContractAddress, get_caller_address};

    #[abi(embed_v0)]
    impl TableSystem of super::ITableSystem<ContractState> {
        fn create_table(
            ref self: ContractState, table_id: u32, small_blind: u256, big_blind: u256
        ) { // Implement create table logic
        }

        fn join_table(ref self: ContractState, table_id: u32) { // Implement join table logic
        }

        fn leave_table(ref self: ContractState, table_id: u32) { // Implement leave table logic
        }

        fn initialize_deck(
            ref self: ContractState, table_id: u32
        ) { // Implement initialize deck logic
        }

        fn deal_cards(ref self: ContractState, table_id: u32) { // Implement deal cards logic
        }

        fn encode_cards(ref self: ContractState, table_id: u32) { // Implement encode cards logic
        }

        fn shuffle_deck(ref self: ContractState, table_id: u32) { // Implement shuffle deck logic
        }
    }
}
