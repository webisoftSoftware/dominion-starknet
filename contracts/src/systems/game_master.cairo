use starknet::ContractAddress;

#[starknet::interface]
trait IGameMaster<TContractState> {
    // Game Master Functions
    fn start_round(ref self: TContractState, table_id: u32);
    fn end_round(ref self: TContractState, table_id: u32);
    fn skip_turn(ref self: TContractState, table_id: u32);
    fn determine_winner(ref self: TContractState, table_id: u32);

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
    use dominion::models::components::ComponentTable;
    use dominion::models::enums::EnumGameState;
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
            // let mut world = self.world(@"dominion");

            // // Implement start round logic
            // assert!(
            //     self.game_master.read() == get_caller_address(),
            //     "Only the game master can start the round"
            // );

            // // Fetch the table
            // let table: ComponentTable = world.read_model(table_id);

            // // Validate minimum number of players
            // assert!(table.m_players.len() >= MIN_PLAYERS, "Not enough players to start the round");

            // assert!(table.m_game_state == EnumGameState::WaitingForPlayers, "Game is not in the waiting for players state");

            

        }

        fn end_round(ref self: ContractState, table_id: u32) { // Implement end round logic
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can end the round"
            );
        }

        fn skip_turn(ref self: ContractState, table_id: u32) { // Implement skip turn logic
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can skip the turn"
            );
        }

        fn determine_winner(ref self: ContractState, table_id: u32) { // Implement determine winner logic
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can determine the winner"
            );
        }

        fn kick_player(ref self: ContractState, table_id: u32, player: ContractAddress) {
            assert!(
                self.game_master.read() == get_caller_address(),
                "Only the game master can kick players"
            );
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
