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
trait IGameMaster<TContractState> {
    fn change_turn(ref self: TContractState);
    fn skip_turn(ref self: TContractState);
    fn set_admin(ref self: TContractState, admin: ContractAddress);
    fn start_round(ref self: TContractState);
    fn end_round(ref self: TContractState);
    fn distribute_pot(ref self: TContractState);
    fn evaluate_hands(ref self: TContractState);
    fn determine_winner(ref self: TContractState);
}

#[dojo::contract]
mod game_master_system {
    use starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
        game_master: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        let tx_info: TxInfo = get_tx_info().unbox();

        // Access the account_contract_address field
        let sender: ContractAddress = tx_info.account_contract_address;

        // Set the game master to the sender
        self.game_master = sender;
    }

    #[abi(embed_v0)]
    impl GameMasterImpl of super::IGameMaster<ContractState> {
        fn change_turn(ref self: ContractState) { // Implement change turn logic
            assert!(self.game_master == get_caller_address(), "Only the game master can change the turn");
        }

        fn skip_turn(ref self: ContractState) { // Implement skip turn logic
            assert!(self.game_master == get_caller_address(), "Only the game master can skip the turn");
        }

        fn set_admin(ref self: ContractState, admin: ContractAddress) { // Implement set admin logic
            assert!(self.game_master == get_caller_address(), "Only the game master can set the admin");
        }

        fn start_round(ref self: ContractState) { // Implement start round logic
            assert!(self.game_master == get_caller_address(), "Only the game master can start the round");
        }

        fn end_round(ref self: ContractState) { // Implement end round logic
            assert!(self.game_master == get_caller_address(), "Only the game master can end the round");
        }

        fn distribute_pot(ref self: ContractState) { // Implement distribute pot logic
            assert!(self.game_master == get_caller_address(), "Only the game master can distribute the pot");
        }

        fn evaluate_hands(ref self: ContractState) { // Implement evaluate hands logic
            assert!(self.game_master == get_caller_address(), "Only the game master can evaluate the hands");
        }

        fn determine_winner(ref self: ContractState) { // Implement determine winner logic
            assert!(self.game_master == get_caller_address(), "Only the game master can determine the winner");
        }
    }
}
