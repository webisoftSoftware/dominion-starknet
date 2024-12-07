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

use crate::models::structs::StructCard;

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumGameState {
    NotCreated,
    WaitingForPlayers,
    PreFlop,
    Flop,
    Turn,
    River,
    Showdown,
}

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumPlayerState {
    Waiting,
    Ready,
    Active,
    Folded,
    AllIn,
    Left,
}

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumPosition {
    None,
    SmallBlind,
    BigBlind,
    Dealer,
}

#[derive(Drop, Serde, Debug, PartialEq, Introspect)]
pub enum EnumHandRank {
    HighCard: EnumCardValue,                                // Card value.
    Pair: EnumCardValue,                                    // First card value only needed, since it is duplicated.
    TwoPair: (EnumCardValue, EnumCardValue),                // First card value and second card value.
    ThreeOfAKind: (EnumCardValue, Array<EnumCardValue>),    // First card value only needed, since it is duplicated.
    Straight: EnumCardValue,                                // Highest card of the straight to determine highcard.
    Flush: EnumCardValue,                                   // Sum of value of all cards falling into the flush.
    FullHouse: (EnumCardValue, EnumCardValue),              // Three of a kind card value and pair card value.
    FourOfAKind: (EnumCardValue, Array<EnumCardValue>),     // First card value only needed, since it is duplicated + kicker.
    StraightFlush: EnumCardValue,                           // Only one player can have this, no need to encode anything + kicker.
    RoyalFlush: (),                                         // Only one player can have this, no need to encode anything.
}

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumCardValue {
    Two,
    Three,
    Four,
    Five,
    Six,
    Seven,
    Eight,
    Nine,
    Ten,
    Jack,
    Queen,
    King,
    Ace
}

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumCardSuit {
    Spades,
    Hearts,
    Diamonds,
    Clubs,
}

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumError {
    InvalidCard,
    InvalidHand,
    InvalidBoard,
}
