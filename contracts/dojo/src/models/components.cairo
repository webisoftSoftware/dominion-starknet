use starknet::ContractAddress;
use dominion::models::structs::StructCard;
use dominion::models::enums::{EnumPosition, EnumGameState, EnumPlayerState};


/// Component that represents two cards that the player holds in their hand during a game.
///
/// 1 (2 cards) per player.
#[derive(Drop, Serde, Debug, Introspect)]
#[dojo::model]
struct ComponentHand {
    /// The contract address of the player.
    #[key]
    m_owner: ContractAddress,
    /// The cards the player has in their hand (2).
    m_cards: Array<StructCard>,
    /// The commitment hash of the hand.
    m_commitment_hash: Array<u32>,
}

/// Component that represents a single player at a table.
/// A player can only join ONE table at a time.
///
/// Max 6 per table.
#[derive(Drop, Serde, Debug, Introspect)]
#[dojo::model]
struct ComponentPlayer {
    /// Which table the player is at.
    #[key]
    m_table_id: u32,
    /// The contract address of the player.
    #[key]
    m_owner: ContractAddress,
    /// Chips the player has at the table.
    m_table_chips: u32,
    /// Total chips the player has in their bank (total chips owned by the account).
    m_total_chips: u32,
    /// Player's position in regards to the dealer (Dealer, Small Blind, Big Blind).
    m_position: EnumPosition,
    /// Indicates what the player is doing (Waiting, Ready, Active, Folded, AllIn, Left).
    m_state: EnumPlayerState,
    /// Current bet the player has made.
    m_current_bet: u32,
    /// Indicates if the player has been created in the dojo world already (Need this to prevent
    /// re-creating the player).
    m_is_created: bool,
    /// Keep track of who's dealer, since you can be dealer and big blind when there's only 2 players.
    m_is_dealer: bool,
}

/// Component that represents a single table where the games will be played on.
///
/// A handful per world.
#[derive(Drop, Serde, Debug, Introspect)]
#[dojo::model]
struct ComponentTable {
    /// Which table the player is at.
    #[key]
    m_table_id: u32,
    /// The whole deck of cards on the table.
    m_deck: Array<StructCard>,
    /// Public cards in the middle of the Table
    m_community_cards: Array<StructCard>,
    /// Used to keep track of players at the table.
    m_players: Array<ContractAddress>,
    /// Index of the current player turn
    m_current_turn: u8,
    /// Index of the current dealer
    m_current_dealer: u8,
    /// Total amount of chips in the pot.
    m_pot: u32,
    /// Small blind amount.
    m_small_blind: u32,
    /// Big blind amount.
    m_big_blind: u32,
    /// Minimum buy-in amount.
    m_min_buy_in: u32,
    /// Maximum buy-in amount.
    m_max_buy_in: u32,
    /// Indicates the game's round state (Shutdown, WaitingForPlayers, PreFlop, Flop, Turn, River,
    /// Showdown).
    m_state: EnumGameState,
    /// Timestamp of the last played action.
    m_last_played_ts: u64,
    /// Number of sidepots in the table.
    m_num_sidepots: u8,
    /// Check if we finished the street before advancing to the next one.
    m_finished_street: bool,
}


/// Component that represents a sidepot for a table.
///
/// One or multiple per round/per table.
#[derive(Drop, Serde, Debug, Introspect)]
#[dojo::model]
struct ComponentSidepot {
    // The table ID
    #[key]
    m_table_id: u32,
    // The player address
    #[key]
    m_player: ContractAddress,
    // The sidepot ID (can be an incrementing counter per table)
    #[key]
    m_sidepot_id: u8,
    // The amount in this sidepot
    m_amount: u32,
    // The minimum bet required to be part of this sidepot
    m_min_bet: u32,
}
