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
//  ████████████  ░░██████  █████░███
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
use alexandria_data_structures::array_ext::ArrayTraitExt;
use dominion::models::utils;
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
                let str: ByteArray = format!("\n\t\t{}", card);
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

        let str: ByteArray = format!("\n\tTotal Chips: {0}", *self.m_total_chips);
        f.buffer.append(@str);

        let str: ByteArray = format!("\n\tTable Chips: {0}", *self.m_table_chips);
        f.buffer.append(@str);

        let str: ByteArray = format!("\n\tPosition: {0}", *self.m_position);
        f.buffer.append(@str);

        let str: ByteArray = format!("\n\tState: {0}", *self.m_state);
        f.buffer.append(@str);

        let str: ByteArray = format!("\n\tCurrent Bet: {0}", *self.m_current_bet);
        f.buffer.append(@str);

        let str: ByteArray = format!("\n\tIs Created: {0}", *self.m_is_created);
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

        let str: ByteArray = format!("\n\tMin Buy In: {}", *self.m_min_buy_in);
        f.buffer.append(@str);

        let str: ByteArray = format!("\n\tMax Buy In: {}", *self.m_max_buy_in);
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
            EnumGameState::NotCreated => {
                let str: ByteArray = format!("NotCreated");
                f.buffer.append(@str);
            },
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
            EnumPlayerState::Ready => {
                let str: ByteArray = format!("Ready");
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
            EnumPlayerState::Left => {
                let str: ByteArray = format!("Left");
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
        assert!(self.m_string_representation.len() == 2, "Invalid card string representation");
        let str: ByteArray = format!("{}", self.m_string_representation);
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

impl EnumCardSuitInto of Into<EnumCardSuit, u32> {
    fn into(self: EnumCardSuit) -> u32 {
        match self {
            EnumCardSuit::Spades => 1,
            EnumCardSuit::Hearts => 2,
            EnumCardSuit::Diamonds => 3,
            EnumCardSuit::Clubs => 4,
        }
    }
}

impl EnumHandRankInto of Into<EnumHandRank, u32> {
    fn into(self: EnumHandRank) -> u32 {
        match self {
            EnumHandRank::HighCard(values) | EnumHandRank::Flush(values) => {
                let mut sum: u32 = 0;
                for value in values.span() {
                    sum += (*value).into();
                };
                sum
            },
            EnumHandRank::Pair(value) => value.into(),
            EnumHandRank::TwoPair((value1, value2)) => value1.into() + value2.into(),
            EnumHandRank::ThreeOfAKind(value) => value.into(),
            EnumHandRank::Straight(value) => value.into(),
            EnumHandRank::FullHouse((value1, value2)) => value1.into() + value2.into(),
            EnumHandRank::FourOfAKind(value) => value.into(),
            EnumHandRank::StraightFlush => 9,
            EnumHandRank::RoyalFlush => 10,
        }
    }
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
///////////////////////////// PARTIALORD ////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

impl EnumHandRankPartialOrd of PartialOrd<EnumHandRank> {
    fn le(lhs: EnumHandRank, rhs: EnumHandRank) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value <= right_value
    }

    fn lt(lhs: EnumHandRank, rhs: EnumHandRank) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value < right_value
    }

    fn ge(lhs: EnumHandRank, rhs: EnumHandRank) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value >= right_value
    }

    fn gt(lhs: EnumHandRank, rhs: EnumHandRank) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value > right_value
    }
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////// PARTIALEQ ///////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

impl ComponentPlayerEq of PartialEq<ComponentPlayer> {
    fn eq(lhs: @ComponentPlayer, rhs: @ComponentPlayer) -> bool {
        *lhs.m_owner == *rhs.m_owner && *lhs.m_is_created == *rhs.m_is_created
    }
}

impl ComponentTableEq of PartialEq<ComponentTable> {
    fn eq(lhs: @ComponentTable, rhs: @ComponentTable) -> bool {
        *lhs.m_table_id == *rhs.m_table_id
    }
}

impl StructCardEq of PartialEq<StructCard> {
    fn eq(lhs: @StructCard, rhs: @StructCard) -> bool {
        lhs.m_string_representation == rhs.m_string_representation
    }
}

impl ComponentHandEq of PartialEq<ComponentHand> {
    fn eq(lhs: @ComponentHand, rhs: @ComponentHand) -> bool {
        let mut equal: bool = lhs.m_owner == rhs.m_owner;

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
        let str: ByteArray = format!("{}{}", value, suit);
        StructCard { m_string_representation: str }
    }

    fn get_value(self: @StructCard) -> Option<EnumCardValue> {
        assert!(self.m_string_representation.len() == 2, "Invalid card string representation");

        if self.m_string_representation[0] == '2' {
            return Option::Some(EnumCardValue::Two);
        }

        if self.m_string_representation[0] == '3' {
            return Option::Some(EnumCardValue::Three);
        }

        if self.m_string_representation[0] == '4' {
            return Option::Some(EnumCardValue::Four);
        }

        if self.m_string_representation[0] == '5' {
            return Option::Some(EnumCardValue::Five);
        }

        if self.m_string_representation[0] == '6' {
            return Option::Some(EnumCardValue::Six);
        }

        if self.m_string_representation[0] == '7' {
            return Option::Some(EnumCardValue::Seven);
        }

        if self.m_string_representation[0] == '8' {
            return Option::Some(EnumCardValue::Eight);
        }

        if self.m_string_representation[0] == '9' {
            return Option::Some(EnumCardValue::Nine);
        }

        if self.m_string_representation[0] == '1' {
            return Option::Some(EnumCardValue::Ten);
        }

        if self.m_string_representation[0] == 'J' {
            return Option::Some(EnumCardValue::Jack);
        }

        if self.m_string_representation[0] == 'Q' {
            return Option::Some(EnumCardValue::Queen);
        }

        if self.m_string_representation[0] == 'K' {
            return Option::Some(EnumCardValue::King);
        }

        if self.m_string_representation[0] == 'A' {
            return Option::Some(EnumCardValue::Ace);
        }

        return Option::None;
    }

    fn get_suit(self: @StructCard) -> Option<EnumCardSuit> {
        assert!(self.m_string_representation.len() == 2, "Invalid card string representation");

        if self.m_string_representation[1] == 'S' {
            return Option::Some(EnumCardSuit::Spades);
        }

        if self.m_string_representation[1] == 'H' {
            return Option::Some(EnumCardSuit::Hearts);
        }

        if self.m_string_representation[1] == 'D' {
            return Option::Some(EnumCardSuit::Diamonds);
        }

        if self.m_string_representation[1] == 'C' {
            return Option::Some(EnumCardSuit::Clubs);
        }

        return Option::None;
    }
}

#[generate_trait]
impl HandImpl of IHand {
    fn new(address: ContractAddress) -> ComponentHand {
        ComponentHand { m_owner: address, m_cards: array![] }
    }

    fn add_card(ref self: ComponentHand, card: StructCard) {
        self.m_cards.append(card);
    }

    fn clear(ref self: ComponentHand) {
        self.m_cards = array![];
    }

    fn evaluate_hand(self: @ComponentHand, board: @Array<StructCard>) -> Result<EnumHandRank, EnumError> {
        // First analyze the hand.
        let rank_result: Result<EnumHandRank, EnumError> = self._evaluate_rank(board);
        return rank_result;
    }

    fn _has_royal_flush(self: @ComponentHand, board: @Array<StructCard>) -> bool {
        // We can first check if we have a flush, and then check if it's royal.
        // This avoids doing two full passes through the cards.
        if let Option::Some(flush_values) = self._has_flush(board) {
            // Check if flush_values contains 10,J,Q,K,A in sequence.
            return flush_values.len() >= 5 
                && *flush_values[0] == EnumCardValue::Ten
                && *flush_values[1] == EnumCardValue::Jack
                && *flush_values[2] == EnumCardValue::Queen
                && *flush_values[3] == EnumCardValue::King
                && *flush_values[4] == EnumCardValue::Ace;
        }
        return false;
    }

    fn _has_straight_flush(self: @ComponentHand, board: @Array<StructCard>) -> bool {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):

        if self.m_cards.len() + board.len() < 5 {
            return false;
        }

        // First check if we have a flush.
        if let Option::Some(flush_values) = self._has_flush(board) {
            // Then check if those flush cards form a straight.
            if flush_values.len() >= 5 {
                let mut consecutive_count: u8 = 1;
                let mut prev_value: u32 = (*flush_values[0]).into();
                
                for i in 1..flush_values.len() {
                    let curr_value: u32 = (*flush_values[i]).into();
                    if curr_value == prev_value - 1 {
                        consecutive_count += 1;
                        if consecutive_count >= 5 {
                            break;
                        }
                    } else if curr_value != prev_value {
                        consecutive_count = 1;
                    }
                    prev_value = curr_value;
                };

                if consecutive_count >= 5 {
                    return true;
                }
            }
        }

        return false;
    }

    fn _has_four_of_a_kind(self: @ComponentHand, board: @Array<StructCard>) -> Option<EnumCardValue> {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):
        if self.m_cards.len() + board.len() < 4 {
            return Option::None;
        }

        let all_cards: Array<StructCard> = self.m_cards.concat(board);
        let mut value_counts: Felt252Dict<u8> = Default::default();
        
        // Single pass to count values.
        for card in all_cards.span() {
            if let Option::Some(value) = card.get_value() {
                let value_count: u32 = value.into();
                value_counts.insert(value_count.into(), value_counts.get(value_count.into()) + 1);
                // Early return if we find four of a kind.
                if value_counts.get(value_count.into()) == 4 {
                    break;
                }
            }
        };

        let card_value: EnumCardValue = all_cards[0].get_value().unwrap();
        let value_count: u32 = card_value.into();
        if value_counts.get(value_count.into()) == 4 {
            return Option::Some(card_value);
        }

        return Option::None;
    }

    fn _has_full_house(self: @ComponentHand, board: @Array<StructCard>) -> Option<(EnumCardValue, EnumCardValue)> {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):
        if self.m_cards.len() + board.len() < 5 {
            return Option::None;
        }

        let all_cards = self.m_cards.concat(board);
        let mut value_counts: Felt252Dict<u8> = utils::_count_values(@all_cards);
        
        let mut three_of_kind: Option<EnumCardValue> = Option::None;
        let mut pair: Option<EnumCardValue> = Option::None;
        
        // First find three of a kind.
        for card in all_cards.span() {
            if let Option::Some(value) = card.get_value() {
                let value_count: u32 = value.into();
                let count = value_counts.get(value_count.into());
                if count == 3 && three_of_kind.is_none() {
                    three_of_kind = Option::Some(value);
                } else if count >= 2 && pair.is_none() && 
                    (three_of_kind.is_none() || three_of_kind.unwrap() != value) {
                    pair = Option::Some(value);
                }
            }
        };
        
        if three_of_kind.is_some() && pair.is_some() {
            return Option::Some((three_of_kind.unwrap(), pair.unwrap()));
        }
        
        return Option::None;
    }

    fn _has_flush(self: @ComponentHand, board: @Array<StructCard>) -> Option<Array<EnumCardValue>> {
        if self.m_cards.len() + board.len() < 5 {
            return Option::None;
        }

        let all_cards: Array<StructCard> = self.m_cards.concat(board);

        // Count cards of each suit and store their values
        let mut spades_values: Array<EnumCardValue> = array![];
        let mut hearts_values: Array<EnumCardValue> = array![];
        let mut diamonds_values: Array<EnumCardValue> = array![];
        let mut clubs_values: Array<EnumCardValue> = array![];

        // Group cards by suit
        for card in all_cards.span() {
            if let Option::Some(suit) = card.get_suit() {
                if let Option::Some(value) = card.get_value() {
                    match suit {
                        EnumCardSuit::Spades => spades_values.append(value),
                        EnumCardSuit::Hearts => hearts_values.append(value),
                        EnumCardSuit::Diamonds => diamonds_values.append(value),
                        EnumCardSuit::Clubs => clubs_values.append(value),
                    };
                }
            }
        };

        // Check which suit has 5 or more cards and return its top 5 values
        if spades_values.len() >= 5 {
            let sorted = utils::sort_values(@spades_values);
            return Option::Some(utils::get_top_n_values(@sorted, 5));
        }
        if hearts_values.len() >= 5 {
            let sorted = utils::sort_values(@hearts_values);
            return Option::Some(utils::get_top_n_values(@sorted, 5));
        }
        if diamonds_values.len() >= 5 {
            let sorted = utils::sort_values(@diamonds_values);
            return Option::Some(utils::get_top_n_values(@sorted, 5));
        }
        if clubs_values.len() >= 5 {
            let sorted = utils::sort_values(@clubs_values);
            return Option::Some(utils::get_top_n_values(@sorted, 5));
        }

        return Option::None;
    }

    fn _has_straight(self: @ComponentHand, board: @Array<StructCard>) -> Option<EnumCardValue> {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):
        if self.m_cards.len() + board.len() < 5 {
            return Option::None;
        }

        let all_cards: Array<StructCard> = self.m_cards.concat(board);
        let mut unique_values: Array<EnumCardValue> = array![];
        
        // First get unique values
        for card in all_cards.span() {
            if let Option::Some(value) = card.get_value() {
                if !unique_values.contains(@value) {
                    unique_values.append(value);
                }
            }
        };
        
        let sorted_unique_values: Array<EnumCardValue> = utils::sort_values(@unique_values);
        
        // Check for regular straight.
        let mut consecutive_count: u8 = 1;
        let mut prev_value: u32 = (*sorted_unique_values[0]).into();
        let mut highest_value: EnumCardValue = *sorted_unique_values[0];
        
        for i in 1..sorted_unique_values.len() {
            let curr_value: u32 = (*sorted_unique_values[i]).into();
            if curr_value == prev_value - 1 {
                consecutive_count += 1;
                if consecutive_count >= 5 {
                    break;
                }
            } else {
                consecutive_count = 1;
                highest_value = *sorted_unique_values[i];
            }
            prev_value = curr_value;
        };
        
        if consecutive_count >= 5 {
            return Option::Some(highest_value);
        }
        
        // Check for Ace-low straight.
        if sorted_unique_values.contains(@EnumCardValue::Ace) 
            && sorted_unique_values.contains(@EnumCardValue::Two)
            && sorted_unique_values.contains(@EnumCardValue::Three)
            && sorted_unique_values.contains(@EnumCardValue::Four)
            && sorted_unique_values.contains(@EnumCardValue::Five) {
            return Option::Some(EnumCardValue::Five);
        }
        
        return Option::None;
    }

    fn _has_three_of_a_kind(self: @ComponentHand, board: @Array<StructCard>) -> Option<EnumCardValue> {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):
        if self.m_cards.len() + board.len() < 3 {
            return Option::None;
        }

        let mut three_of_a_kind: Option<EnumCardValue> = Option::None;
        let mut first_value: EnumCardValue = self.m_cards[0].get_value().unwrap();
        
        // Check if hand is a pair and board has matching value
        if first_value == self.m_cards[1].get_value().unwrap() {

            for card in board.span() {
                if let Option::Some(card_value) = card.get_value() {
                    if card_value == first_value {
                        three_of_a_kind = Option::Some(card_value);
                        break;
                    }
                }
            };

            if three_of_a_kind.is_some() {
                return Option::Some(three_of_a_kind.unwrap());
            }
        }

        // Comibne cards and sort.
        let sorted_board: Array<StructCard> = utils::sort(board);
        let all_cards: Array<StructCard> = self.m_cards.concat(@sorted_board);
        let mut same_kind_count: u8 = 1;
        let mut prev_value: EnumCardValue = all_cards[0].get_value().unwrap();

        for card in all_cards.span() {
            if let Option::Some(card_value) = card.get_value() {
                if card_value == prev_value {
                    same_kind_count += 1;
                }

                if same_kind_count >= 3 {
                    three_of_a_kind = Option::Some(prev_value);
                    break;
                }

                prev_value = card_value;
                same_kind_count = 1;
            }
        };

        return three_of_a_kind;
    }

    fn _has_two_pair(self: @ComponentHand, board: @Array<StructCard>) -> Option<(EnumCardValue, EnumCardValue)> {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):
        if self.m_cards.len() + board.len() < 4 {
            return Option::None;
        }

        let sorted_board: Array<StructCard> = utils::sort(board);
        let all_cards: Array<StructCard> = self.m_cards.concat(@sorted_board);
        let mut prev_value: EnumCardValue = all_cards[0].get_value().unwrap();
        let mut first_pair_value: Option<EnumCardValue> = Option::None;
        let mut second_pair_value: Option<EnumCardValue> = Option::None;

        for i in 0..all_cards.len() {
            if let Option::Some(card_value) = all_cards[i].get_value() {
                if card_value == prev_value {
                    if first_pair_value.is_none() {
                        first_pair_value = Option::Some(prev_value);
                        continue;
                    }
                    if second_pair_value.is_none() && first_pair_value.unwrap() != prev_value {
                        second_pair_value = Option::Some(prev_value);
                        continue;
                    }
                }

                prev_value = card_value;
                if first_pair_value.is_some() && second_pair_value.is_some() {
                    break;
                }
            }
        };

        if first_pair_value.is_none() || second_pair_value.is_none() {
            return Option::None;
        }

        return Option::Some((first_pair_value.unwrap(), second_pair_value.unwrap()));
    }

    fn _has_pair(self: @ComponentHand, board: @Array<StructCard>) -> Option<EnumCardValue> {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):

        // Check if the hand itself is a pair.
        if self.m_cards.len() + board.len() < 2 {
            return Option::None;
        }

        let all_cards = self.m_cards.concat(board);
        let mut value_counts: Felt252Dict<u8> = utils::_count_values(@all_cards);
        
        let mut pairs: Array<EnumCardValue> = array![];
        
        for card in all_cards.span() {
            if let Option::Some(value) = card.get_value() {
                let value_count: u32 = value.into();
                if value_counts.get(value_count.into()) == 2 && !pairs.contains(@value) {
                    pairs.append(value);
                }
            }
        };
        
        if pairs.len() >= 2 {
            let sorted_pairs = utils::sort_values(@pairs);
            return Option::Some(sorted_pairs[0].clone());
        }
        
        return Option::None;
    }

    fn _evaluate_rank(
        self: @ComponentHand, board: @Array<StructCard>
    ) -> Result<EnumHandRank, EnumError> {
        if self.m_cards.len() != 2 {
            return Result::Err(EnumError::InvalidHand);
        }

        if board.len() > 5 {
            return Result::Err(EnumError::InvalidBoard);
        }

        if self._has_royal_flush(board) {
            return Result::Ok(EnumHandRank::RoyalFlush);
        }

        if self._has_straight_flush(board) {
            return Result::Ok(EnumHandRank::StraightFlush);
        }

        if let Option::Some(four_of_a_kind_value) = self._has_four_of_a_kind(board) {
            return Result::Ok(EnumHandRank::FourOfAKind(four_of_a_kind_value));
        }

        if let Option::Some(full_house_values) = self._has_full_house(board) {
            return Result::Ok(EnumHandRank::FullHouse(full_house_values));
        }

        if let Option::Some(flush_values) = self._has_flush(board) {
            return Result::Ok(EnumHandRank::Flush(flush_values));
        }

        if let Option::Some(straight_value) = self._has_straight(board) {
            return Result::Ok(EnumHandRank::Straight(straight_value));
        }

        if let Option::Some(three_of_a_kind_value) = self._has_three_of_a_kind(board) {
            return Result::Ok(EnumHandRank::ThreeOfAKind(three_of_a_kind_value));
        }

        if let Option::Some((first_pair_value, second_pair_value)) = self._has_two_pair(board) {
            return Result::Ok(EnumHandRank::TwoPair((first_pair_value, second_pair_value)));
        }

        if let Option::Some(pair_value) = self._has_pair(board) {
            return Result::Ok(EnumHandRank::Pair(pair_value));
        }

        let all_cards = self.m_cards.concat(board);
        let mut all_values: Array<EnumCardValue> = array![];
        for i in 0..all_cards.len() {
            if let Option::Some(card_value) = all_cards[i].get_value() {
                all_values.append(card_value);
            }
        };
        return Result::Ok(EnumHandRank::HighCard(all_values));
    }
}

#[generate_trait]
impl PlayerImpl of IPlayer {
    fn new(table_id: u32, address: ContractAddress) -> ComponentPlayer {
        ComponentPlayer {
            m_table_id: table_id,
            m_owner: address,
            m_table_chips: 0,
            m_total_chips: 0,
            m_position: EnumPosition::None,
            m_state: EnumPlayerState::Waiting,
            m_current_bet: 0,
            m_is_created: true,
        }
    }

    fn set_position(ref self: ComponentPlayer, position: EnumPosition) {
        self.m_position = position;
    }

    fn place_bet(ref self: ComponentPlayer, amount: u32) {
        assert(self.m_table_chips >= amount, 'Insufficient chips');
        self.m_table_chips -= amount;
        self.m_current_bet += amount;
    }

    fn fold(ref self: ComponentPlayer) {
        self.m_state = EnumPlayerState::Folded;
    }

    fn all_in(ref self: ComponentPlayer) {
        self.m_current_bet += self.m_table_chips;
        self.m_table_chips = 0;
        self.m_state = EnumPlayerState::AllIn;
    }

    fn _is_created(self: @ComponentPlayer) -> bool {
        return *self.m_is_created;
    }
}

#[generate_trait]
impl TableImpl of ITable {
    fn new(
        id: u32,
        small_blind: u32,
        big_blind: u32,
        min_buy_in: u32,
        max_buy_in: u32,
        m_players: Array<ContractAddress>
    ) -> ComponentTable {
        assert!(min_buy_in > max_buy_in, "Minimum buy-in cannot be greater than maximum buy-in");
        assert!(m_players.len() <= 6, "There must be at most 6 players");

        let mut table: ComponentTable = ComponentTable {
            m_table_id: id,
            m_deck: array![],
            m_community_cards: array![],
            m_players: m_players,
            m_current_turn: 0,
            m_current_dealer: 0,
            m_pot: 0,
            m_small_blind: small_blind,
            m_big_blind: big_blind,
            m_min_buy_in: min_buy_in,
            m_max_buy_in: max_buy_in,
            m_state: EnumGameState::WaitingForPlayers,
            m_last_played_ts: 0,
        };
        table._initialize_deck();
        return table;
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

    fn find_player(self: @ComponentTable, player: @ContractAddress) -> Option<usize> {
        return self.m_players.position(player);
    }

    fn add_player(ref self: ComponentTable, player: ContractAddress) {
        if self.m_state == EnumGameState::WaitingForPlayers {
            // Insert the new player right after the last player joined.
            self.m_players.append(player);
        }
    }

    fn remove_player(ref self: ComponentTable, player: @ContractAddress) {
        let player_position: Option<usize> = self.find_player(player);
        assert!(player_position.is_some(), "Cannot find player");

        let removed_player_position: usize = player_position.unwrap();
        let mut new_players: Array<ContractAddress> = array![];
        // Set the player to 0 to indicate empty seat.
        for i in 0
            ..self
                .m_players
                .len() {
                    if i != removed_player_position {
                        new_players.append(self.m_players[i].clone());
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

    fn reset_table(ref self: ComponentTable) {
        self.m_pot = 0;
        self.m_state = EnumGameState::PreFlop;
        self.m_community_cards = array![];
    }

    fn _initialize_deck(ref self: ComponentTable) {
        // Initialize a standard 52-card deck
        self.m_deck = array![];

        // Add cards for each suit and value
        let suits = array![
            EnumCardSuit::Spades, EnumCardSuit::Hearts, EnumCardSuit::Diamonds, EnumCardSuit::Clubs
        ];

        let values = array![
            EnumCardValue::Two,
            EnumCardValue::Three,
            EnumCardValue::Four,
            EnumCardValue::Five,
            EnumCardValue::Six,
            EnumCardValue::Seven,
            EnumCardValue::Eight,
            EnumCardValue::Nine,
            EnumCardValue::Ten,
            EnumCardValue::Jack,
            EnumCardValue::Queen,
            EnumCardValue::King,
            EnumCardValue::Ace
        ];

        for i in 0
            ..suits
                .len() {
                    for j in 0
                        ..values.len() {
                            self.m_deck.append(ICard::new(*values[j], *suits[i]));
                        };
                };
    }
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////// DEFAULT /////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

impl HandDefaultImpl of Default<ComponentHand> {
    fn default() -> ComponentHand {
        return ComponentHand {
            m_owner: starknet::contract_address_const::<0x0>(), m_cards: array![],
        };
    }
}

impl PlayerDefaultImpl of Default<ComponentPlayer> {
    fn default() -> ComponentPlayer {
        return ComponentPlayer {
            m_table_id: 0,
            m_owner: starknet::contract_address_const::<0x0>(),
            m_table_chips: 0,
            m_total_chips: 0,
            m_position: EnumPosition::None,
            m_state: EnumPlayerState::Waiting,
            m_current_bet: 0,
            m_is_created: false,
        };
    }
}

impl TableDefaultImpl of Default<ComponentTable> {
    fn default() -> ComponentTable {
        return ComponentTable {
            m_table_id: 0,
            m_deck: array![],
            m_community_cards: array![],
            m_players: array![],
            m_current_turn: 0,
            m_current_dealer: 0,
            m_pot: 0,
            m_small_blind: 0,
            m_big_blind: 0,
            m_max_buy_in: 0,
            m_min_buy_in: 0,
            m_state: EnumGameState::WaitingForPlayers,
            m_last_played_ts: 0,
        };
    }
}
