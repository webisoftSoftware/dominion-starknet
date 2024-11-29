////////////////////////////////////////////////////////////////////////////////////////////////////
// ██████████                             ███              ███                     
// ░░███░░░░███                           ░░░              ░░░                      
//  ░███   ░░███  ██████  █████████████   ████  ████████   ████   ██████  ████████  
//  ░███    ░███ ███░░███░░███░░███░░███ ░░███ ░░███░░███ ░░███  ███░░███░░███░░███ 
//  ░███    ░███░███ ░███ ░███ ░███ ░███  ░███  ░███ ░███  ░███ ░███ ░███ ░███ ░███ 
//  ░███    ███ ░███ ░███ ░███ ░███ ░███  ░███  ░███ ░███  ░███ ░███ ░███ ░███ ░███ 
//  ██████████  ░░██████  █████░███ █████ █████ ████ █████ █████░░██████  ████ █████
// ░░░░░░░░░░    ░░░░░░  ░░░░░ ░░░ ░░░░░ ░░░░░ ░░░░ ░░░░░ ░░░░░  ░░░░░░  ░░░░ ░░░░░ 
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
use dominion::models::structs::{Blinds, Card};
use dominion::models::enums::{EnumHandRank, EnumPosition, EnumGameState, EnumPlayerState};

#[derive(Drop, Serde, Debug, Introspect)]
#[dojo::model]
pub struct ComponentTable {
    #[key]
    pub id: u32, // Table ID
    pub deck: Array<Card>,
    pub community_cards: Array<Card>, // Public cards in the middle of the Table
    pub players: Array<ContractAddress>, // This array is used to keep track of the order of the players turns
    pub current_turn: ContractAddress, // Address of the Player that needs to play
    pub pot: u256,
    // pub side_pots: Array<u256>, // Consider adding this later
    pub blinds: Blinds,
    pub state: EnumGameState,
}

#[derive(Drop, Serde, Debug, Introspect)]
#[dojo::model]
pub struct ComponentPlayer {
    #[key]
    pub address: ContractAddress,
    pub chips: u256,
    pub position: EnumPosition,
    pub state: EnumPlayerState, // Maybe add a new state for the player that is waiting to join the table and is not eligible for blinds
    pub current_bet: u256,
}

#[derive(Drop, Serde, Debug, Introspect)]
#[dojo::model]
pub struct ComponentHand {
    #[key]
    pub address: ContractAddress, // Address of the Player
    pub cards: Array<Card>,
    //pub hand_rank: EnumHandRank,
}