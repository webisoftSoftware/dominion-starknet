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
//  █���████████  ░░██████  █████░███
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
}
