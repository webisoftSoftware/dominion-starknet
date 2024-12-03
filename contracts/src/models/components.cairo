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
use dominion::models::structs::StructCard;
use dominion::models::enums::{EnumPosition, EnumGameState, EnumPlayerState};

#[derive(Drop, Serde, Debug, Introspect)]
#[dojo::model]
struct ComponentPlayer {
    #[key]
    m_table_id: u32, // Table ID
    #[key]
    m_owner: ContractAddress,
    m_chips: u32,
    m_position: EnumPosition,
    m_state: EnumPlayerState,
    m_current_bet: u32,
}

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
struct ComponentTable {
    #[key]
    m_table_id: u32, // Table ID
    m_deck: Array<StructCard>,
    m_community_cards: Array<StructCard>, // Public cards in the middle of the Table
    m_players: Array<ContractAddress>, // This array is used to keep track of the order of the players turns
    m_current_turn: u8, // Index of the current player turn
    m_pot: u32,
    // pub side_pots: Array<u256>, // Consider adding this later
    m_small_blind: u32,
    m_big_blind: u32,
    m_state: EnumGameState,
    m_last_played_ts: u64
}
