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

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumGameState {
    WaitingForPlayers,
    PreFlop,
    Flop,
    Turn,
    River,
    Showdown,
}

#[derive(Drop, Serde, Copy, Debug, Introspect)]
pub enum EnumPlayerState {
    Waiting,
    Active,
    Folded,
    AllIn,
}

#[derive(Drop, Serde, Copy, Debug, Introspect)]
pub enum EnumPosition {
    SmallBlind,
    BigBlind,
    Dealer,
    None,
}

#[derive(Drop, Serde, Copy, Debug, Introspect)]
pub enum EnumHandRank {
    HighCard,
    Pair,
    TwoPair,
    ThreeOfAKind,
    Straight,
    Flush,
    FullHouse,
    FourOfAKind,
    StraightFlush,
    RoyalFlush,
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

#[derive(Drop, Serde, Copy, Debug, Introspect)]
pub enum EnumCardSuit {
    Spades,
    Hearts,
    Diamonds,
    Clubs,
}
