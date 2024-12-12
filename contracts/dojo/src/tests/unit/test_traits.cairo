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

use crate::models::enums::{
    EnumCardSuit, EnumCardValue, EnumHandRank, EnumPlayerState, EnumGameState, EnumPosition
};
use crate::models::traits::{
    EnumCardValueDisplay, EnumCardSuitDisplay, EnumHandRankDisplay, EnumPlayerStateDisplay,
    EnumGameStateDisplay, EnumHandRankInto, ComponentPlayerEq, ComponentTableEq,
    ComponentPlayerDisplay, EnumCardValueInto, ComponentTableDisplay, ComponentHandDisplay,
    StructCardDisplay, ComponentHandEq, StructCardEq, HandDefaultImpl, TableDefaultImpl,
    PlayerDefaultImpl, ICard
};
use crate::models::structs::{StructCard};
use crate::models::components::{ComponentHand, ComponentTable, ComponentPlayer};

#[test]
fn test_eq() {
    let card1: StructCard = ICard::new(@EnumCardValue::Two, @EnumCardSuit::Clubs);
    let card2: StructCard = ICard::new(@EnumCardValue::Two, @EnumCardSuit::Clubs);
    assert_eq!(card1, card2);

    let mut player1: ComponentPlayer = Default::default();
    let mut player2: ComponentPlayer = Default::default();
    player1.m_total_chips = 100;
    player2.m_total_chips = 100;
    assert_eq!(player1, player2);

    let table1: ComponentTable = Default::default();
    let table2: ComponentTable = Default::default();
    assert_eq!(table1, table2);

    let hand1: ComponentHand = Default::default();
    let hand2: ComponentHand = Default::default();
    assert_eq!(hand1, hand2);
}

#[test]
fn test_display() {
    assert_eq!(
        format!(
            "{}",
            ComponentPlayer {
                m_table_id: 0,
                m_owner: starknet::contract_address_const::<0x0>(),
                m_total_chips: 100,
                m_table_chips: 0,
                m_position: EnumPosition::None,
                m_state: EnumPlayerState::Active,
                m_current_bet: 0,
                m_is_created: false
            }
        ),
        "Player: 0\n\tTotal Chips: 100\n\tTable Chips: 0\n\tPosition: None\n\tState: Active\n\tCurrent Bet: 0\n\tIs Created: false"
    );
    assert_eq!(
        format!("{}", TableDefaultImpl::default()),
        "Table 0:\n\tPlayers:\n\tCurrent Turn Index: 0\n\tSmall Blind: 0\n\tBig Blind: 0\n\tMin Buy In: 0\n\tMax Buy In: 0\n\tPot: 0\n\tState: WaitingForPlayers\n\tLast Played: 0"
    );
    assert_eq!(format!("{}", HandDefaultImpl::default()), "Hand 0:\n\tCards:");
    assert_eq!(format!("{}", ICard::new(@EnumCardValue::Two, @EnumCardSuit::Clubs)), "2C");
    assert_eq!(format!("{}", EnumHandRank::HighCard(array![EnumCardValue::Two])), "HighCard");
    assert_eq!(format!("{}", EnumCardSuit::Clubs), "C");
    assert_eq!(format!("{}", EnumCardValue::Two), "2");
    assert_eq!(format!("{}", EnumPlayerState::Active), "Active");
}

#[test]
fn test_into() {
    let high_card: u32 = (@EnumHandRank::HighCard(array![EnumCardValue::Ace])).into();
    let two: u32 = (@EnumCardValue::Two).into();

    assert_eq!(high_card, 14);
    assert_eq!(two, 2);
}
