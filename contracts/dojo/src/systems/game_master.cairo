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
    // Game Master Functions
    fn start_round(ref self: TContractState, table_id: u32);
    fn end_round(ref self: TContractState, table_id: u32);
    fn skip_turn(ref self: TContractState, table_id: u32);
    fn determine_winner(ref self: TContractState, table_id: u32);
    fn remove_sitting_out_players(ref self: TContractState, table_id: u32);
    fn update_positions(ref self: TContractState, table_id: u32);

    // Timeout Functions
    fn kick_player(ref self: TContractState, table_id: u32, player: ContractAddress);

    // Admin Functions
    fn change_game_master(ref self: TContractState, new_game_master: ContractAddress);
    fn get_game_master(self: @TContractState) -> ContractAddress;
}

#[dojo::contract]
mod game_master_system {
    use starknet::{ContractAddress, get_caller_address, TxInfo, get_tx_info};
    use dojo::{model::ModelStorage, world::IWorldDispatcher};
    use dominion::models::components::{ComponentTable, ComponentPlayer};
    use dominion::models::enums::{EnumGameState, EnumPlayerState, EnumPosition};
    use dominion::models::traits::{ITable, IPlayer};

    const MIN_PLAYERS: u32 = 2;

    #[storage]
    struct Storage {
        game_master: ContractAddress,
    }

    fn dojo_init(ref self: ContractState) {
        let tx_info: TxInfo = get_tx_info().unbox();

        // Access the account_contract_address field
        let sender: ContractAddress = tx_info.account_contract_address;

        // Set the game master to the sender
        self.game_master.write(sender);
    }

    #[abi(embed_v0)]
    impl GameMasterImpl of super::IGameMaster<ContractState> {
        fn start_round(ref self: ContractState, table_id: u32) {
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can start the round"
            );

            let mut world = self.world(@"dominion");
            // Fetch the table
            let table: ComponentTable = world.read_model(table_id);

            // Validate minimum number of players
            assert!(table.m_players.len() >= MIN_PLAYERS, "Not enough players to start the round");
            assert!(
                table.m_state == EnumGameState::WaitingForPlayers,
                "Game is not in the waiting for players state"
            );
        }

        fn end_round(ref self: ContractState, table_id: u32) { // Implement end round logic
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can end the round"
            );

            // Remove players sitting out.
            self.remove_sitting_out_players(table_id);

            // Update order and dealer chip position (Small Blind, Big Blind, etc.).
            self.update_positions(table_id);
        }

        fn skip_turn(ref self: ContractState, table_id: u32) { // Implement skip turn logic
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can skip the turn"
            );
        }

        fn determine_winner(
            ref self: ContractState, table_id: u32
        ) { // Implement determine winner logic
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can determine the winner"
            );
        }

        fn remove_sitting_out_players(ref self: ContractState, table_id: u32) {
            let mut world = self.world(@"dominion");

            let mut table: ComponentTable = world.read_model(table_id);
            for i in 0
                ..table
                    .m_players
                    .len() {
                        let mut player: ComponentPlayer = world.read_model(*table.m_players[i]);
                        if player.m_state == EnumPlayerState::Left {
                            self.kick_player(table_id, *table.m_players[i]);
                        }
                    };

            world.write_model(@table);
        }

        fn update_positions(ref self: ContractState, table_id: u32) {
            let mut world = self.world(@"dominion");

            let mut table: ComponentTable = world.read_model(table_id);

            let mut new_players: Array<ContractAddress> = array![];
            for i in 0
                ..table
                    .m_players
                    .len() {
                        let mut player: ComponentPlayer = world.read_model(*table.m_players[i]);
                        // If player is not sitting out or waiting, set their new position.
                        if player.m_state != EnumPlayerState::Left
                            && player.m_state != EnumPlayerState::Waiting {
                            match player.m_position {
                                EnumPosition::Dealer => {
                                    player.set_position(EnumPosition::SmallBlind);
                                },
                                EnumPosition::SmallBlind => {
                                    player.set_position(EnumPosition::BigBlind);
                                },
                                _ => {
                                    if i + 1 < table.m_players.len() {
                                        let mut next_player: ComponentPlayer = world
                                            .read_model(*table.m_players[i + 1]);
                                        player.set_position(next_player.m_position);
                                    } else {
                                        // Wrap around to the first player.
                                        let mut next_player: ComponentPlayer = world
                                            .read_model(*table.m_players[0]);
                                        player.set_position(next_player.m_position);
                                    }
                                }
                            };
                        }
                        new_players.append(*table.m_players[i]);
                    };

            table.m_players = new_players;
            world.write_model(@table);
        }

        fn kick_player(ref self: ContractState, table_id: u32, player: ContractAddress) {
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can kick players"
            );

            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            let player_model: ComponentPlayer = world.read_model(player);
            table.remove_player(@player);
            world.erase_model(@player_model);
            world.write_model(@table);
        }

        fn change_game_master(ref self: ContractState, new_game_master: ContractAddress) {
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can change the game master"
            );
            self.game_master.write(new_game_master);
        }

        fn get_game_master(self: @ContractState) -> ContractAddress {
            self.game_master.read()
        }
    }
}
