use starknet::ContractAddress;

#[starknet::interface]
trait ITableSystem<TContractState> {
    fn create_table(
        ref self: TContractState, small_blind: u32, big_blind: u32, min_buy_in: u32, max_buy_in: u32
    );
    fn join_table(ref self: TContractState, table_id: u32, chips_amount: u32);
    fn leave_table(ref self: TContractState, table_id: u32);
    fn top_up_table_chips(ref self: TContractState, table_id: u32, chips_amount: u32);
}

#[dojo::contract]
mod table_system {
    use dominion::models::components::{ComponentTable, ComponentPlayer, ComponentHand};
    use dominion::models::enums::{EnumPosition, EnumGameState, EnumPlayerState, EnumCardSuit, EnumCardValue};
    use dominion::models::structs::StructCard;
    use dominion::models::traits::{ITable, IPlayer};
    use starknet::{ContractAddress, get_caller_address, TxInfo, get_tx_info};
    use dojo::{model::ModelStorage, world::IWorldDispatcher};

    // Constant for table player limits
    const MAX_PLAYERS: u32 = 6;

    // Contract storage variables
    #[storage]
    struct Storage {
        // Address of the game master who can create tables
        game_master: ContractAddress,
        // Counter for generating unique table IDs
        counter: u32,
    }

    // Initialize contract state with game master and counter
    fn dojo_init(ref self: ContractState) {
        let tx_info: TxInfo = get_tx_info().unbox();
        let sender: ContractAddress = tx_info.account_contract_address;

        // Set initial game master and start counter at 1
        self.game_master.write(sender);
        self.counter.write(1); // Start at 1 because 0 is reserved for the "not in any table" state
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
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            // Only game master can create tables
            assert!(self.game_master.read() == caller, "Only game master can create table");

            let table_id = self.counter.read();

            // Initialize new table with provided parameters
            let table: ComponentTable = ITable::new(
                table_id, small_blind, big_blind, min_buy_in, max_buy_in, array![]
            );

            // Save table to world state and increment counter
            world.write_model(@table);
            self.counter.write(table_id + 1);
        }

        // Allows a player to join a table with specified chips amount
        fn join_table(ref self: ContractState, table_id: u32, chips_amount: u32) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            // Get table and player components
            let mut table: ComponentTable = world.read_model(table_id);
            let mut player: ComponentPlayer = world.read_model(caller);

            // Create new player if first time joining
            if !player.m_is_created {
                player = IPlayer::new(table_id, caller);
            }

            // Validate table capacity and chip amounts
            assert!(table.m_players.len() < MAX_PLAYERS, "Table is full");
            assert!(player.m_total_chips >= chips_amount, "Insufficient chips");
            assert!(table.m_min_buy_in < chips_amount, "Amount is less than min buy in");
            assert!(table.m_max_buy_in > chips_amount, "Amount is more than max buy in");

            // Update player state for joining table
            player.m_table_id = table_id;
            player.m_total_chips -= chips_amount;
            player.m_table_chips += chips_amount;
            player.m_position = EnumPosition::None;

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
