use starknet::ContractAddress;
use dominion::models::structs::StructCard;
use dominion::models::enums::{EnumPosition, EnumGameState, EnumPlayerState};

#[derive(Drop, Serde, Debug, Introspect)]
#[dojo::model]
struct ComponentHand {
    #[key]
    m_table_id: u32, // Table ID
    #[key]
    m_owner: ContractAddress,
    m_cards: Array<StructCard>,
}

#[derive(Drop, Serde, Debug, Introspect)]
#[dojo::model]
struct ComponentPlayer {
    m_table_id: u32, // Table ID
    #[key]
    m_owner: ContractAddress,
    m_table_chips: u32,
    m_total_chips: u32,
    m_position: EnumPosition, // Set at start of game
    m_state: EnumPlayerState,
    m_current_bet: u32,
    m_is_created: bool,
}

#[derive(Drop, Serde, Debug, Introspect)]
#[dojo::model]
struct ComponentTable {
    #[key]
    m_table_id: u32, // Table ID
    m_deck: Array<StructCard>,
    m_community_cards: Array<StructCard>, // Public cards in the middle of the Table
    m_players: Array<
        ContractAddress
    >, // This array is used to keep track of the order of the players turns
    m_current_turn: u8, // Index of the current player turn SET AT START OF GAME
    m_current_dealer: u8, // Index of the current dealer SET AT START OF GAME
    m_pot: u32,
    // pub side_pots: Array<u256>, // Consider adding this later
    m_small_blind: u32,
    m_big_blind: u32,
    m_min_buy_in: u32,
    m_max_buy_in: u32,
    m_state: EnumGameState, // UPDATE AT START OF GAME
    m_last_played_ts: u64
}
