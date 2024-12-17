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
        //     let mut world = self.world(@"dominion");
        //     let caller = get_caller_address();

        //     // Fetch the player and table
        //     let player: ComponentPlayer = world.read_model(caller);
        //     let table: ComponentTable = world.read_model(game_id);

        //     // Validate player is in the table and game is in the pre-flop state
        //     assert!(player.m_table_id == game_id, "Player is not in the specified table");
        //     assert!(table.m_game_state == EnumGameState::WaitingForPlayers, "Game is not in the waiting for players state");

           // Set player state to ready
           // player.m_player_state = EnumPlayerState::Ready;
        }
    }
}
