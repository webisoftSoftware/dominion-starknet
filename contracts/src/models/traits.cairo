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
use core::fmt::{Display, Formatter, Error};
use dominion::models::structs::StructCard;
use dominion::models::enums::{
    EnumCardSuit, EnumCardValue, EnumGameState, EnumPlayerState, EnumPosition, EnumHandRank,
    EnumError
};
use dominion::models::components::{ComponentTable, ComponentPlayer, ComponentHand};

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////// DISPLAY /////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

impl ComponentHandDisplay of Display<ComponentHand> {
    fn fmt(self: @ComponentHand, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Hand {}:\n\tCards:", starknet::contract_address_to_felt252(*self.m_owner)
        );
        f.buffer.append(@str);

        for card in self
            .m_cards
            .span() {
                let str: ByteArray = format!("\n\t\t{}", *card);
                f.buffer.append(@str);
            };

        Result::Ok(())
    }
}

impl ComponentPlayerDisplay of Display<ComponentPlayer> {
    fn fmt(self: @ComponentPlayer, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Player: {0}", starknet::contract_address_to_felt252(*self.m_owner)
        );
        f.buffer.append(@str);

        let str: ByteArray = format!("\n\tChips: {0}", *self.m_chips);
        f.buffer.append(@str);

        let str: ByteArray = format!("\n\tPosition: {0}", *self.m_position);
        f.buffer.append(@str);

        let str: ByteArray = format!("\n\tState: {0}", *self.m_state);
        f.buffer.append(@str);

        let str: ByteArray = format!("\n\tCurrent Bet: {0}", *self.m_current_bet);
        f.buffer.append(@str);

        Result::Ok(())
    }
}

impl ComponentTableDisplay of Display<ComponentTable> {
    fn fmt(self: @ComponentTable, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("Table {0}:\n\tPlayers:", *self.m_table_id);
        f.buffer.append(@str);

        for player in self
            .m_players
            .span() {
                let str: ByteArray = format!(
                    "\n\t\t{}", starknet::contract_address_to_felt252(*player)
                );
                f.buffer.append(@str);
            };

        let str: ByteArray = format!("\n\tCurrent Turn Index: {}", *self.m_current_turn);
        f.buffer.append(@str);

        let str: ByteArray = format!("\n\tSmall Blind: {}", *self.m_small_blind);
        f.buffer.append(@str);

        let str: ByteArray = format!("\n\tBig Blind: {}", *self.m_big_blind);
        f.buffer.append(@str);

        let str: ByteArray = format!("\n\tPot: {}", *self.m_pot);
        f.buffer.append(@str);

        let str: ByteArray = format!("\n\tState: {}", *self.m_state);
        f.buffer.append(@str);

        let str: ByteArray = format!("\n\tLast Played: {}", *self.m_last_played_ts);
        f.buffer.append(@str);

        Result::Ok(())
    }
}

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

impl StructCardDisplay of Display<StructCard> {
    fn fmt(self: @StructCard, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("Card: {}\n\tSuit: {}", *self.m_value, *self.m_suit);
        f.buffer.append(@str);
        Result::Ok(())
    }
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////// INTO ////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

impl EnumCardValueInto of Into<EnumCardValue, u32> {
    fn into(self: EnumCardValue) -> u32 {
        match self {
            EnumCardValue::Two => 2,
            EnumCardValue::Three => 3,
            EnumCardValue::Four => 4,
            EnumCardValue::Five => 5,
            EnumCardValue::Six => 6,
            EnumCardValue::Seven => 7,
            EnumCardValue::Eight => 8,
            EnumCardValue::Nine => 9,
            EnumCardValue::Ten => 10,
            EnumCardValue::Jack => 11,
            EnumCardValue::Queen => 12,
            EnumCardValue::King => 13,
            EnumCardValue::Ace => 14,
        }
    }
}

impl EnumHandRankInto of Into<EnumHandRank, u32> {
    fn into(self: EnumHandRank) -> u32 {
        match self {
            EnumHandRank::HighCard => 1,
            EnumHandRank::Pair => 2,
            EnumHandRank::TwoPair => 3,
            EnumHandRank::ThreeOfAKind => 4,
            EnumHandRank::Straight => 5,
            EnumHandRank::Flush => 6,
            EnumHandRank::FullHouse => 7,
            EnumHandRank::FourOfAKind => 8,
            EnumHandRank::StraightFlush => 9,
            EnumHandRank::RoyalFlush => 10,
        }
    }
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////// PARTIALEQ ///////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

impl ComponentPlayerEq of PartialEq<ComponentPlayer> {
    fn eq(lhs: @ComponentPlayer, rhs: @ComponentPlayer) -> bool {
        *lhs.m_owner == *rhs.m_owner
    }
}

impl ComponentTableEq of PartialEq<ComponentTable> {
    fn eq(lhs: @ComponentTable, rhs: @ComponentTable) -> bool {
        *lhs.m_table_id == *rhs.m_table_id
    }
}

impl StructCardEq of PartialEq<StructCard> {
    fn eq(lhs: @StructCard, rhs: @StructCard) -> bool {
        *lhs.m_value == *rhs.m_value && *lhs.m_suit == *rhs.m_suit
    }
}

impl ComponentHandEq of PartialEq<ComponentHand> {
    fn eq(lhs: @ComponentHand, rhs: @ComponentHand) -> bool {
        let mut equal: bool = lhs.m_table_id == rhs.m_table_id;

        if !equal {
            return false;
        }

        for i in 0
            ..lhs.m_cards.len() {
                if lhs.m_cards[i] != rhs.m_cards[i] {
                    equal = false;
                    break;
                }
            };
        equal
    }
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////// TRAITS //////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

#[generate_trait]
impl CardImpl of ICard {
    fn new(value: EnumCardValue, suit: EnumCardSuit) -> StructCard {
        StructCard { m_value: value, m_suit: suit }
    }
}

#[generate_trait]
impl HandImpl of IHand {
    fn new(table_id: u32, address: ContractAddress) -> ComponentHand {
        ComponentHand { m_table_id: table_id, m_owner: address, m_cards: array![] }
    }

    fn add_card(ref self: ComponentHand, card: StructCard) {
        self.m_cards.append(card);
    }

    fn clear(ref self: ComponentHand) {
        self.m_cards = array![];
    }

    fn _is_flush(self: @ComponentHand, cards: @Array<StructCard>, board: @Array<StructCard>) -> bool {
        // TODO: Implement the non-naive approach.
        
        // NAIVE APPROACH:
        // Check if there's 5 cards with the same suit.
        let mut is_flush: bool = false;
        for i in 0..cards.len() {
            let current_suit: @EnumCardSuit = cards[i].m_suit;
            let mut matches: u8 = 0;

            for i in 0..board.len() {
                if board[i].m_suit == current_suit {
                    matches += 1;
                }
            };

            if matches >= 5 {
                is_flush = true;
                break;
            }
        };
        is_flush
    }

    fn _is_royal_straight(self: @ComponentHand, cards: @Array<StructCard>, board: @Array<StructCard>) -> bool {
        // TODO: Implement this
        false
    }

    fn _is_straight(self: @ComponentHand, cards: @Array<StructCard>, board: @Array<StructCard>) -> bool {
        // TODO: Implement this
        false
    }

    fn is_four_of_a_kind(self: @ComponentHand, cards: @Array<StructCard>, board: @Array<StructCard>) -> bool {
        // TODO: Implement this
        false
    }

    fn is_three_of_a_kind(self: @ComponentHand, cards: @Array<StructCard>, board: @Array<StructCard>) -> bool {
        // TODO: Implement this
        false
    }

    fn is_two_pair(self: @ComponentHand, cards: @Array<StructCard>, board: @Array<StructCard>) -> bool {
        // TODO: Implement this
        false
    }

    fn is_pair(self: @ComponentHand, cards: @Array<StructCard>, board: @Array<StructCard>) -> bool {
        // TODO: Implement this
        false
    }

    fn _get_highest_card_value(self: @ComponentHand) -> u32 {
        // TODO: Implement this
        0
    }

    fn _get_value_from_cards(self: @ComponentHand, cards: @Array<StructCard>) -> u32 {
        // TODO: Implement this
        0
    }

    fn _analyze_cards(self: @ComponentHand, hand: @Array<StructCard>, board: @Array<StructCard>) -> Result<(EnumHandRank, u32), EnumError> {
        if hand.len() != 2 {
            return Result::Err(EnumError::InvalidHand);
        }

        if board.len() > 5 {
            return Result::Err(EnumError::InvalidBoard);
        }

        let value: u32 = self._get_value_from_cards(hand);

        if self._is_flush(hand, board) && self._is_straight(hand, board) {
            return Result::Ok((EnumHandRank::StraightFlush, value));
        }

        if self._is_royal_straight(hand, board) && self._is_flush(hand, board) {
            return Result::Ok((EnumHandRank::RoyalFlush, value));
        }

        if self._is_flush(hand, board) {
            return Result::Ok((EnumHandRank::Flush, value));
        }

        if self._is_straight(hand, board) {
            return Result::Ok((EnumHandRank::Straight, value));
        }

        if self.is_four_of_a_kind(hand, board) {
            return Result::Ok((EnumHandRank::FourOfAKind, value));
        }

        if self.is_three_of_a_kind(hand, board) {
            return Result::Ok((EnumHandRank::ThreeOfAKind, value));
        }

        if self.is_two_pair(hand, board) {
            return Result::Ok((EnumHandRank::TwoPair, value));
        }

        if self.is_pair(hand, board) {
            return Result::Ok((EnumHandRank::Pair, value));
        }

        Result::Ok((EnumHandRank::HighCard, value))
    }

    fn evaluate_hand(
        self: @ComponentHand, hand: @Array<StructCard>, board: @Array<StructCard>
    ) -> (EnumHandRank, u32) {
        // First analyze the hand
        let result: Result<(EnumHandRank, u32), EnumError> = self._analyze_cards(hand, board);
        assert!(result.is_ok(), "Invalid hand");

        let (rank, value): (EnumHandRank, u32) = result.unwrap();

        // Then match on the result to return the appropriate rank and score
        match rank {
            EnumHandRank::RoyalFlush => (EnumHandRank::RoyalFlush, EnumHandRank::RoyalFlush.into() + value),
            EnumHandRank::StraightFlush => (EnumHandRank::StraightFlush, EnumHandRank::StraightFlush.into() + value),
            EnumHandRank::FourOfAKind => (EnumHandRank::FourOfAKind, EnumHandRank::FourOfAKind.into() + value),
            EnumHandRank::FullHouse => (EnumHandRank::FullHouse, EnumHandRank::FullHouse.into() + value),
            EnumHandRank::Flush => (EnumHandRank::Flush, EnumHandRank::Flush.into() + value),
            EnumHandRank::Straight => (EnumHandRank::Straight, EnumHandRank::Straight.into() + value),
            EnumHandRank::ThreeOfAKind => (EnumHandRank::ThreeOfAKind, EnumHandRank::ThreeOfAKind.into() + value),
            EnumHandRank::TwoPair => (EnumHandRank::TwoPair, EnumHandRank::TwoPair.into() + value),
            EnumHandRank::Pair => (EnumHandRank::Pair, EnumHandRank::Pair.into() + value),
            EnumHandRank::HighCard => (EnumHandRank::HighCard, EnumHandRank::HighCard.into() + value),
        }
    }
}

#[generate_trait]
impl PlayerImpl of IPlayer {
    fn new(table_id: u32, address: ContractAddress, initial_chips: u32) -> ComponentPlayer {
        ComponentPlayer {
            m_table_id: table_id,
            m_owner: address,
            m_chips: initial_chips,
            m_position: EnumPosition::None,
            m_state: EnumPlayerState::Waiting,
            m_current_bet: 0,
        }
    }

    fn set_position(ref self: ComponentPlayer, position: EnumPosition) {
        self.m_position = position;
    }

    fn place_bet(ref self: ComponentPlayer, amount: u32) {
        assert(self.m_chips >= amount, 'Insufficient chips');
        self.m_chips -= amount;
        self.m_current_bet += amount;
    }

    fn fold(ref self: ComponentPlayer) {
        self.m_state = EnumPlayerState::Folded;
    }

    fn all_in(ref self: ComponentPlayer) {
        self.m_current_bet += self.m_chips;
        self.m_chips = 0;
        self.m_state = EnumPlayerState::AllIn;
    }
}

#[generate_trait]
impl TableImpl of ITable {
    fn new(id: u32, small_blind: u32, big_blind: u32) -> ComponentTable {
        ComponentTable {
            m_table_id: id,
            m_deck: array![],
            m_community_cards: array![],
            m_players: array![],
            m_current_turn: 0,
            m_pot: 0,
            m_small_blind: small_blind,
            m_big_blind: big_blind,
            m_state: EnumGameState::WaitingForPlayers,
            m_last_played_ts: 0,
        }
    }

    fn find_card(self: @ComponentTable, card: @StructCard) -> Option<u32> {
        let mut found = Option::None;

        for i in 0
            ..self.m_deck.len() {
                if self.m_deck[i] == card {
                    found = Option::Some(i);
                    break;
                }
            };
        return found;
    }

    fn find_player(self: @ComponentTable, player: @ContractAddress) -> Option<u32> {
        let mut found = Option::None;

        for i in 0
            ..self
                .m_players
                .len() {
                    if self.m_players[i] == player {
                        found = Option::Some(i);
                        break;
                    }
                };
        return found;
    }

    fn add_player(ref self: ComponentTable, player: ContractAddress) {
        if self.m_state == EnumGameState::WaitingForPlayers {
            self.m_players.append(player);
        }
    }

    fn remove_player(ref self: ComponentTable, player: @ContractAddress) {
        let mut new_players: Array<ContractAddress> = array![];

        for p in self.m_players.span() {
            if *p != *player {
                new_players.append(p.clone());
            }
        };
        self.m_players = new_players;
    }

    fn add_to_pot(ref self: ComponentTable, amount: u32) {
        self.m_pot += amount;
    }

    fn increase_blinds(ref self: ComponentTable, multiplier: u32) {
        self.m_small_blind *= multiplier;
        self.m_big_blind *= multiplier;
    }

    fn get_blind_amount(self: @ComponentTable, position: @EnumPosition) -> u32 {
        match position {
            EnumPosition::SmallBlind => *self.m_small_blind,
            EnumPosition::BigBlind => *self.m_big_blind,
            _ => 0,
        }
    }
}
