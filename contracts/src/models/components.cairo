use starknet::ContractAddress;
use dominion::models::structs::StructCard;
use dominion::models::enums::{EnumPosition, EnumGameState, EnumPlayerState};


/// Component that represents two cards that the player holds in their hand during a game.
///
/// 1 (2 cards) per player.
#[derive(Drop, Serde, Debug, Introspect)]
#[dojo::model]
struct ComponentHand {
    #[key]
    m_owner: ContractAddress, /// The contract address of the player.
    m_cards: Array<StructCard>, /// The cards the player has in their hand (2).
    m_commitment_hash: Array<u32>, /// The commitment hash of the hand.
}

/// Component that represents a single player at a table.
/// A player can only join ONE table at a time.
///
/// Max 6 per table.
#[derive(Drop, Serde, Debug, Introspect)]
#[dojo::model]
struct ComponentPlayer {
    #[key]
    m_table_id: u32, /// The table ID the player is at.
    #[key]
    m_owner: ContractAddress, /// The contract address of the player.
    m_table_chips: u32, /// Chips the player has at the table.
    m_total_chips: u32, /// Total chips the player has in their bank (total chips owned by the account).
    m_position: EnumPosition, /// Player's position in regards to the dealer (Dealer, Small Blind, Big Blind).
    m_state: EnumPlayerState, /// Indicates what the player is doing (Waiting, Ready, Active, Folded, AllIn, Left).
    m_current_bet: u32, /// Current bet the player has made.
    m_is_created: bool, /// Indicates if the player has been created in the dojo world already (Need this to prevent re-creating the player).
    m_is_dealer: bool, /// Keep track of who's dealer, since you can be dealer and big blind when there's only 2 players.
}

/// Component that represents a single table where the games will be played on.
///
/// A handful per world.
#[derive(Drop, Serde, Debug, Introspect)]
#[dojo::model]
struct ComponentTable {
    #[key]
    m_table_id: u32, /// The table ID.
    m_deck: Array<StructCard>, /// The whole deck of cards on the table.
    m_community_cards: Array<StructCard>, /// Public cards in the middle of the Table
    m_players: Array<ContractAddress>, /// Used to keep track of players at the table.
    m_current_turn: u8, /// Index of the current player turn
    m_current_dealer: u8, /// Index of the current dealer
    m_pot: u32, /// Total amount of chips in the pot.
    m_small_blind: u32, /// Small blind amount.
    m_big_blind: u32, /// Big blind amount.
    m_min_buy_in: u32, /// Minimum buy-in amount.
    m_max_buy_in: u32, /// Maximum buy-in amount.
    m_state: EnumGameState, /// Indicates the game's round state (Shutdown, WaitingForPlayers, PreFlop, Flop, Turn, River, Showdown).
    m_last_played_ts: u64, /// Timestamp of the last played action.
    m_num_sidepots: u8, /// Number of sidepots in the table.
    m_finished_street: bool, /// Check if we finished the street before advancing to the next one.
}


/// Component that represents a sidepot for a table.
///
/// One or multiple per round/per table.
#[derive(Drop, Serde, Debug, Introspect)]
#[dojo::model]
struct ComponentSidepot {
    #[key]
    m_table_id: u32, /// The table ID
    #[key]
    m_player: ContractAddress, /// The player address
    #[key]
    m_sidepot_id: u8, /// The sidepot ID (can be an incrementing counter per table)
    m_amount: u32, /// The amount in this sidepot
    m_min_bet: u32, /// The minimum bet required to be part of this sidepot
}
