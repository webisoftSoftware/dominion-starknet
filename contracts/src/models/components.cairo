use starknet::ContractAddress;
use dominion::models::structs::StructCard;
use dominion::models::enums::{
    EnumPosition, EnumTableState, EnumStreetState, EnumPlayerState, EnumHandRank
};


/// Component that represents two cards that the player holds in their hand during a game.
///
/// 1 (2 cards) per player.
#[derive(Drop, Clone, Serde, Debug)]
#[dojo::model]
pub struct ComponentHand {
    #[key]
    /// Which table we are referring to.
    pub m_table_id: u32,
    #[key]
    /// The contract address of the player.
    pub m_owner: ContractAddress,
    /// The cards the player has in their hand (2).
    pub m_cards: Array<StructCard>,
    /// The commitment hash of the hand.
    pub m_commitment_hash: Array<u32>,
}

/// Component that represents the bank for each player to deposit, withdraw from to use
/// when bying in at tables.
///
/// 1 (2 cards) per player.
#[derive(Drop, Clone, Serde, Debug)]
#[dojo::model]
pub struct ComponentBank {
    #[key]
    /// The contract address of the player.
    pub m_owner: ContractAddress,
    /// Total chips the player has in their bank (total chips owned by the account).
    pub m_balance: u32,
}

/// Component that represents a single player at a table.
/// A player can only join ONE table at a time.
///
/// Max 6 per table.
#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct ComponentPlayer {
    #[key]
    /// The current table we are in.
    pub m_table_id: u32,
    #[key]
    /// The contract address of the player.
    pub m_owner: ContractAddress,
    /// Chips the player has at the table.
    pub m_table_chips: u32,
    /// Player's position in regards to the dealer (Dealer, Small Blind, Big Blind).
    pub m_position: EnumPosition,
    /// Indicates what the player is doing (Waiting, Ready, Active, Folded, AllIn, Left).
    pub m_state: EnumPlayerState,
    /// Current bet the player has made.
    pub m_current_bet: u32,
    /// Indicates if the player has been created in the dojo world already (Need this to prevent re-creating the player).
    pub m_is_created: bool,
    /// Player's authentication hash sent each round to prove authenticity of caller to BE.
    pub m_auth_hash: ByteArray,
    /// Keep track of who's dealer, since you can be dealer and big blind when there's only 2 players.
    pub m_is_dealer: bool,
}

/// Component that represents a single table where the games will be played on.
///
/// A handful per world.
#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct ComponentTable {
    #[key]
    /// The current table we are in.
    pub m_table_id: u32,
    /// The whole deck of cards on the table.
    pub m_deck: Array<StructCard>,
    /// Public cards in the middle of the Table
    pub m_community_cards: Array<StructCard>,
    /// Used to keep track of players at the table.
    pub m_players: Array<ContractAddress>,
    /// Total amount of chips in the pot.
    pub m_pot: u32,
    /// Number of sidepots in the table. // TODO: TBR after initial review in the block explorer
    pub m_num_sidepots: u8,
    /// The round number that we are currently in.
    pub m_current_round: u8
}

/// Component that represents a table's info before entering the table.
///
/// One per table.
#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct ComponentTableInfo {
    #[key]
    /// The current table we are in.
    pub m_table_id: u32,
    /// Small blind amount.
    pub m_small_blind: u32,
    /// Big blind amount.
    pub m_big_blind: u32,
    /// Minimum buy-in amount.
    pub m_min_buy_in: u32,
    /// Maximum buy-in amount.
    pub m_max_buy_in: u32,
    /// State of the game.
    pub m_state: EnumTableState
}

/// Component that represents a round's info at a particular table.
///
/// One or multiple per table.
#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct ComponentOriginalDeck {
    #[key]
    pub m_table_id: u32,
    pub m_deck: Array<StructCard>
}

/// Component that represents a round's info at a particular table.
///
/// One or multiple per table.
#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct ComponentRound {
    #[key]
    /// The current table we are in.
    pub m_table_id: u32,
    #[key]
    /// The current round we are in.
    pub m_round_id: u32,
    /// Index of the last raiser
    pub m_last_raiser: u8,
    /// Address of the last player who raised.
    pub m_last_raiser_addr: ContractAddress,
    /// Highest raise amount.
    pub m_highest_raise: u32,
    /// Timestamp of the last played action.
    pub m_last_played_ts: u64,
    /// Current player's turn
    pub m_current_turn: ContractAddress,
    /// Index of the current dealer
    pub m_current_dealer: u8,
}

/// Component that represents a the current street's info at a particular round and table.
///
/// One or multiple per round/per table.
#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct ComponentStreet {
    #[key]
    /// The current table we are in.
    pub m_table_id: u32,
    #[key]
    /// The current round we are in.
    pub m_round_id: u32,
    /// Indicates the current street (PreFlop, Flop, Turn, River, Showdown).
    pub m_state: EnumStreetState,
    /// Check if we finished the street before advancing to the next one.
    pub m_finished_street: bool,
}

/// Component that represents a sidepot for a table.
///
/// One or multiple per round/per table.
#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct ComponentSidepot {
    #[key]
    /// The table ID.
    pub m_table_id: u32,
    #[key]
    /// The sidepot ID.
    pub m_sidepot_id: u8,
    /// The minimum bet required to be part of this sidepot.
    pub m_min_bet: u32,
    /// The amount in this sidepot.
    pub m_amount: u32,
    /// The eligible players in this sidepot.
    pub m_eligible_players: Array<ContractAddress>,
}

/// Component that represents a sidepot for a table.
///
/// One or multiple per round/per table.
#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct ComponentRake {
    #[key]
    /// The current table we are in.
    pub m_table_id: u32,
    /// The deployer address.
    pub m_rake_address: ContractAddress,
    /// The percentage collected in fees.
    pub m_rake_fee: u32,
    /// The amount of chips collected in fees.
    pub m_chip_amount: u32
}

/// Component that represents the shuffle and deck encryption proofs of cards at the beginning of
/// each round.
///
/// Once per round/per table.
#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct ComponentProof {
    #[key]
    /// The current table we are in.
    pub m_table_id: u32,
    /// The deployer address.
    pub m_shuffle_proof: ByteArray,
    /// The amount of chips collected in fees.
    pub m_deck_proof: ByteArray,
    /// If the encrypted_deck has been posted.
    pub m_encrypted_deck_posted: bool
}

/// Component that represents winners from each round at a given table.
///
/// Once per round/per table.
#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct ComponentWinners {
    #[key]
    pub m_table_id: u32,
    #[key]
    pub m_round_id: u8,
    pub m_winners: Array<ContractAddress>,
    pub m_hands: Array<EnumHandRank>,
    pub m_amounts: Array<u32>
}