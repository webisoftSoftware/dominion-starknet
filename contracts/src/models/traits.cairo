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
//  ░███ ░███
//  ░███    ███ ░███ ░███ ░███ ░███ ░███
//  ░███  ░███ ░███  ░███ ░███ ░███ ░███
//  ░███ ░███
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
use core::fmt::{Display, Formatter, Error};
use dominion::models::structs::{Card, Blinds};
use dominion::models::enums::{
    EnumCardSuit, EnumCardValue, EnumGameState, EnumPlayerState, EnumPosition, EnumHandRank
};
use dominion::models::components::{ComponentTable, ComponentPlayer, ComponentHand};

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////// DISPLAY /////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

impl EnumGameStateDisplay of Display<EnumGameState> {
    fn fmt(self: @EnumGameState, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumGameState::WaitingForPlayers => {
                let str: ByteArray = format!("WaitingForPlayers");
                f.buffer.append(@str);
            },
            EnumGameState::PreFlop => {
                let str: ByteArray = format!("PreFlop");
                f.buffer.append(@str);
            },
            EnumGameState::Flop => {
                let str: ByteArray = format!("Flop");
                f.buffer.append(@str);
            },
            EnumGameState::Turn => {
                let str: ByteArray = format!("Turn");
                f.buffer.append(@str);
            },
            EnumGameState::River => {
                let str: ByteArray = format!("River");
                f.buffer.append(@str);
            },
            EnumGameState::Showdown => {
                let str: ByteArray = format!("Showdown");
                f.buffer.append(@str);
            },
        };
        Result::Ok(())
    }
}

impl EnumPlayerStateDisplay of Display<EnumPlayerState> {
    fn fmt(self: @EnumPlayerState, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumPlayerState::Waiting => {
                let str: ByteArray = format!("Waiting");
                f.buffer.append(@str);
            },
            EnumPlayerState::Active => {
                let str: ByteArray = format!("Active");
                f.buffer.append(@str);
            },
            EnumPlayerState::Folded => {
                let str: ByteArray = format!("Folded");
                f.buffer.append(@str);
            },
            EnumPlayerState::AllIn => {
                let str: ByteArray = format!("AllIn");
                f.buffer.append(@str);
            },
        };
        Result::Ok(())
    }
}

impl EnumPositionDisplay of Display<EnumPosition> {
    fn fmt(self: @EnumPosition, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumPosition::SmallBlind => {
                let str: ByteArray = format!("SmallBlind");
                f.buffer.append(@str);
            },
            EnumPosition::BigBlind => {
                let str: ByteArray = format!("BigBlind");
                f.buffer.append(@str);
            },
            EnumPosition::Dealer => {
                let str: ByteArray = format!("Dealer");
                f.buffer.append(@str);
            },
            EnumPosition::None => {
                let str: ByteArray = format!("None");
                f.buffer.append(@str);
            },
        };
        Result::Ok(())
    }
}

impl EnumHandRankDisplay of Display<EnumHandRank> {
    fn fmt(self: @EnumHandRank, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumHandRank::HighCard => {
                let str: ByteArray = format!("HighCard");
                f.buffer.append(@str);
            },
            EnumHandRank::Pair => {
                let str: ByteArray = format!("Pair");
                f.buffer.append(@str);
            },
            EnumHandRank::TwoPair => {
                let str: ByteArray = format!("TwoPair");
                f.buffer.append(@str);
            },
            EnumHandRank::ThreeOfAKind => {
                let str: ByteArray = format!("ThreeOfAKind");
                f.buffer.append(@str);
            },
            EnumHandRank::Straight => {
                let str: ByteArray = format!("Straight");
                f.buffer.append(@str);
            },
            EnumHandRank::Flush => {
                let str: ByteArray = format!("Flush");
                f.buffer.append(@str);
            },
            EnumHandRank::FullHouse => {
                let str: ByteArray = format!("FullHouse");
                f.buffer.append(@str);
            },
            EnumHandRank::FourOfAKind => {
                let str: ByteArray = format!("FourOfAKind");
                f.buffer.append(@str);
            },
            EnumHandRank::StraightFlush => {
                let str: ByteArray = format!("StraightFlush");
                f.buffer.append(@str);
            },
            EnumHandRank::RoyalFlush => {
                let str: ByteArray = format!("RoyalFlush");
                f.buffer.append(@str);
            },
        };
        Result::Ok(())
    }
}

impl EnumCardValueDisplay of Display<EnumCardValue> {
    fn fmt(self: @EnumCardValue, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumCardValue::Two => {
                let str: ByteArray = format!("2");
                f.buffer.append(@str);
            },
            EnumCardValue::Three => {
                let str: ByteArray = format!("3");
                f.buffer.append(@str);
            },
            EnumCardValue::Four => {
                let str: ByteArray = format!("4");
                f.buffer.append(@str);
            },
            EnumCardValue::Five => {
                let str: ByteArray = format!("5");
                f.buffer.append(@str);
            },
            EnumCardValue::Six => {
                let str: ByteArray = format!("6");
                f.buffer.append(@str);
            },
            EnumCardValue::Seven => {
                let str: ByteArray = format!("7");
                f.buffer.append(@str);
            },
            EnumCardValue::Eight => {
                let str: ByteArray = format!("8");
                f.buffer.append(@str);
            },
            EnumCardValue::Nine => {
                let str: ByteArray = format!("9");
                f.buffer.append(@str);
            },
            EnumCardValue::Ten => {
                let str: ByteArray = format!("10");
                f.buffer.append(@str);
            },
            EnumCardValue::Jack => {
                let str: ByteArray = format!("J");
                f.buffer.append(@str);
            },
            EnumCardValue::Queen => {
                let str: ByteArray = format!("Q");
                f.buffer.append(@str);
            },
            EnumCardValue::King => {
                let str: ByteArray = format!("K");
                f.buffer.append(@str);
            },
            EnumCardValue::Ace => {
                let str: ByteArray = format!("A");
                f.buffer.append(@str);
            },
        };
        Result::Ok(())
    }
}

impl EnumCardSuitDisplay of Display<EnumCardSuit> {
    fn fmt(self: @EnumCardSuit, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumCardSuit::Spades => {
                let str: ByteArray = format!("S");
                f.buffer.append(@str);
            },
            EnumCardSuit::Hearts => {
                let str: ByteArray = format!("H");
                f.buffer.append(@str);
            },
            EnumCardSuit::Diamonds => {
                let str: ByteArray = format!("D");
                f.buffer.append(@str);
            },
            EnumCardSuit::Clubs => {
                let str: ByteArray = format!("C");
                f.buffer.append(@str);
            },
        };
        Result::Ok(())
    }
}

impl CardDisplay of Display<Card> {
    fn fmt(self: @Card, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("{}{}", *self.value, *self.suit);
        f.buffer.append(@str);
        Result::Ok(())
    }
}

impl ComponentTableDisplay of Display<ComponentTable> {
    fn fmt(self: @ComponentTable, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("Table {}: {} players", *self.id, self.players.len());
        f.buffer.append(@str);
        Result::Ok(())
    }
}

impl ComponentPlayerDisplay of Display<ComponentPlayer> {
    fn fmt(self: @ComponentPlayer, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Player: {}, Chips: {}",
            starknet::contract_address_to_felt252(*self.address),
            *self.chips
        );
        f.buffer.append(@str);
        Result::Ok(())
    }
}

impl ComponentHandDisplay of Display<ComponentHand> {
    fn fmt(self: @ComponentHand, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Hand {}: {} cards",
            starknet::contract_address_to_felt252(*self.address),
            self.cards.len()
        );
        f.buffer.append(@str);
        Result::Ok(())
    }
}

impl BlindsDisplay of Display<Blinds> {
    fn fmt(self: @Blinds, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("SB: {}, BB: {}", *self.small_blind, *self.big_blind);
        f.buffer.append(@str);
        Result::Ok(())
    }
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////// TRAITS /////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

#[generate_trait]
impl CardImpl of ICard {
    fn new(value: EnumCardValue, suit: EnumCardSuit) -> Card {
        Card { value, suit }
    }

    fn compare(self: @Card, other: @Card) -> bool {
        *self.value == *other.value
    }

    fn get_value(self: @Card) -> EnumCardValue {
        *self.value
    }

    fn get_suit(self: @Card) -> EnumCardSuit {
        *self.suit
    }
}

#[generate_trait]
impl BlindsImpl of IBlinds {
    fn new(small_blind: u256, big_blind: u256) -> Blinds {
        assert(big_blind > small_blind, 'Invalid blind values');
        Blinds { small_blind, big_blind }
    }

    fn increase_blinds(ref self: Blinds, multiplier: u256) {
        self.small_blind *= multiplier;
        self.big_blind *= multiplier;
    }

    fn get_blind_amount(self: @Blinds, position: @EnumPosition) -> u256 {
        match position {
            EnumPosition::SmallBlind => *self.small_blind,
            EnumPosition::BigBlind => *self.big_blind,
            _ => 0,
        }
    }

    fn get_small_blind(self: @Blinds) -> u256 {
        *self.small_blind
    }

    fn get_big_blind(self: @Blinds) -> u256 {
        *self.big_blind
    }
}

#[generate_trait]
impl TableImpl of ITable {
    fn new(id: u32, blinds: Blinds) -> ComponentTable {
        ComponentTable {
            id,
            deck: array![],
            community_cards: array![],
            players: array![],
            current_turn: starknet::contract_address_const::<0>(),
            pot: 0,
            blinds,
            state: EnumGameState::WaitingForPlayers,
        }
    }

    fn add_player(ref self: ComponentTable, player: ContractAddress) {
        if self.state == EnumGameState::WaitingForPlayers {
            self.players.append(player);
        }
    }

    fn add_to_pot(ref self: ComponentTable, amount: u256) {
        self.pot += amount;
    }

    fn get_state(self: @ComponentTable) -> EnumGameState {
        *self.state
    }

    fn get_pot(self: @ComponentTable) -> u256 {
        *self.pot
    }

    fn get_players(self: @ComponentTable) -> Span<ContractAddress> {
        self.players.span()
    }
}

#[generate_trait]
impl PlayerImpl of IPlayer {
    fn new(
        address: ContractAddress, initial_chips: u256, position: EnumPosition
    ) -> ComponentPlayer {
        ComponentPlayer {
            address,
            chips: initial_chips,
            position,
            state: EnumPlayerState::Waiting,
            current_bet: 0,
        }
    }

    fn place_bet(ref self: ComponentPlayer, amount: u256) {
        assert(self.chips >= amount, 'Insufficient chips');
        self.chips -= amount;
        self.current_bet += amount;
    }

    fn fold(ref self: ComponentPlayer) {
        self.state = EnumPlayerState::Folded;
    }

    fn all_in(ref self: ComponentPlayer) {
        self.current_bet += self.chips;
        self.chips = 0;
        self.state = EnumPlayerState::AllIn;
    }

    fn get_state(self: @ComponentPlayer) -> EnumPlayerState {
        *self.state
    }

    fn get_chips(self: @ComponentPlayer) -> u256 {
        *self.chips
    }

    fn get_current_bet(self: @ComponentPlayer) -> u256 {
        *self.current_bet
    }
}

#[generate_trait]
impl HandImpl of IHand {
    fn new(address: ContractAddress) -> ComponentHand {
        ComponentHand { address, cards: array![] }
    }

    fn add_card(ref self: ComponentHand, card: Card) {
        self.cards.append(card);
    }

    fn get_cards(self: @ComponentHand) -> Span<Card> {
        self.cards.span()
    }
}
