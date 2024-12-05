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
trait IActions<TContractState> {
    fn bet(ref self: TContractState, game_id: u32, amount: u256);
    fn fold(ref self: TContractState, game_id: u32);
    fn check(ref self: TContractState, game_id: u32);
    fn call(ref self: TContractState, game_id: u32);
    fn raise(ref self: TContractState, game_id: u32, amount: u256);
    fn all_in(ref self: TContractState, game_id: u32);
    fn set_ready(ref self: TContractState, game_id: u32);
}

#[dojo::contract]
mod actions_system {
    use starknet::{ContractAddress, get_caller_address};
    use dojo::{model::ModelStorage, world::IWorldDispatcher};
    use dominion::models::components::{ComponentTable, ComponentPlayer};
    use dominion::models::enums::EnumPlayerState;

    #[abi(embed_v0)]
    impl ActionsImpl of super::IActions<ContractState> {
        fn bet(ref self: ContractState, game_id: u32, amount: u256) { // Implement bet logic
        }

        fn fold(ref self: ContractState, game_id: u32) { // Implement fold logic
        }

        fn check(ref self: ContractState, game_id: u32) { // Implement check logic
        }

        fn call(ref self: ContractState, game_id: u32) { // Implement call logic
        }

        fn raise(ref self: ContractState, game_id: u32, amount: u256) { // Implement raise logic
        }

        fn all_in(ref self: ContractState, game_id: u32) { // Implement all-in logic
        }

        fn set_ready(ref self: ContractState, game_id: u32) { // Implement set ready logic
        }
    }
}
