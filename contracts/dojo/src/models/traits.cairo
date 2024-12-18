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
//  ██████████████  ░░██████
//  █████░███
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
use core::traits::{BitOr, BitAnd};
use core::fmt::{Display, Formatter, Error};
use alexandria_data_structures::array_ext::ArrayTraitExt;
use origami_random::deck::{Deck, DeckTrait};
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
            EnumGameState::Shutdown => {
                let str: ByteArray = format!("Shutdown");
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
            EnumPlayerState::NotCreated => f.buffer.append(@"NotCreated"),
            EnumPlayerState::Waiting => f.buffer.append(@"Waiting"),
            EnumPlayerState::Ready => f.buffer.append(@"Ready"),
            EnumPlayerState::Active => f.buffer.append(@"Active"),
            EnumPlayerState::Folded => f.buffer.append(@"Folded"),
            EnumPlayerState::AllIn => f.buffer.append(@"AllIn"),
            EnumPlayerState::Left => f.buffer.append(@"Left"),
            EnumPlayerState::Revealed => f.buffer.append(@"Revealed"),
        };
        Result::Ok(())
    }
}

impl EnumPositionDisplay of Display<EnumPosition> {
    fn fmt(self: @EnumPosition, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumPosition::SmallBlind => f.buffer.append(@"SmallBlind"),
            EnumPosition::BigBlind => f.buffer.append(@"BigBlind"),
            EnumPosition::Dealer => f.buffer.append(@"Dealer"),
            EnumPosition::None => f.buffer.append(@"None"),
        };
        Result::Ok(())
    }
}

impl EnumHandRankDisplay of Display<EnumHandRank> {
    fn fmt(self: @EnumHandRank, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumHandRank::HighCard => f.buffer.append(@"HighCard"),
            EnumHandRank::Pair => f.buffer.append(@"Pair"),
            EnumHandRank::TwoPair => f.buffer.append(@"TwoPair"),
            EnumHandRank::ThreeOfAKind => f.buffer.append(@"ThreeOfAKind"),
            EnumHandRank::Straight => f.buffer.append(@"Straight"),
            EnumHandRank::Flush => f.buffer.append(@"Flush"),
            EnumHandRank::FullHouse => f.buffer.append(@"FullHouse"),
            EnumHandRank::FourOfAKind => f.buffer.append(@"FourOfAKind"),
            EnumHandRank::StraightFlush => f.buffer.append(@"StraightFlush"),
            EnumHandRank::RoyalFlush => f.buffer.append(@"RoyalFlush"),
        };
        Result::Ok(())
    }
}

impl EnumCardValueDisplay of Display<EnumCardValue> {
    fn fmt(self: @EnumCardValue, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumCardValue::Two => f.buffer.append(@"2"),
            EnumCardValue::Three => f.buffer.append(@"3"),
            EnumCardValue::Four => f.buffer.append(@"4"),
            EnumCardValue::Five => f.buffer.append(@"5"),
            EnumCardValue::Six => f.buffer.append(@"6"),
            EnumCardValue::Seven => f.buffer.append(@"7"),
            EnumCardValue::Eight => f.buffer.append(@"8"),
            EnumCardValue::Nine => f.buffer.append(@"9"),
            EnumCardValue::Ten => f.buffer.append(@"10"),
            EnumCardValue::Jack => f.buffer.append(@"J"),
            EnumCardValue::Queen => f.buffer.append(@"Q"),
            EnumCardValue::King => f.buffer.append(@"K"),
            EnumCardValue::Ace => f.buffer.append(@"A"),
        };
        Result::Ok(())
    }
}

impl EnumCardSuitDisplay of Display<EnumCardSuit> {
    fn fmt(self: @EnumCardSuit, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumCardSuit::Spades => f.buffer.append(@"S"),
            EnumCardSuit::Hearts => f.buffer.append(@"H"),
            EnumCardSuit::Diamonds => f.buffer.append(@"D"),
            EnumCardSuit::Clubs => f.buffer.append(@"C"),
        };
        Result::Ok(())
    }
}

impl StructCardDisplay of Display<StructCard> {
    fn fmt(self: @StructCard, ref f: Formatter) -> Result<(), Error> {
        let value: EnumCardValue = self.get_value().unwrap();
        let suit: EnumCardSuit = self.get_suit().unwrap();
        let str: ByteArray = format!("{}{}", value, suit);
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

impl EnumCardValueSnapshotInto of Into<@EnumCardValue, u32> {
    fn into(self: @EnumCardValue) -> u32 {
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

impl EnumCardSuitSnapshotInto of Into<@EnumCardSuit, u32> {
    fn into(self: @EnumCardSuit) -> u32 {
        match self {
            EnumCardSuit::Spades => 1,
            EnumCardSuit::Hearts => 2,
            EnumCardSuit::Diamonds => 3,
            EnumCardSuit::Clubs => 4,
        }
    }
}

impl EnumHandRankInto of Into<@EnumHandRank, u32> {
    fn into(self: @EnumHandRank) -> u32 {
        match self {
            EnumHandRank::HighCard(values) |
            EnumHandRank::Flush(values) => {
                let mut sum: u32 = 0;
                for value in values.span() {
                    sum += value.into();
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

impl EnumHandRankPartialOrd of PartialOrd<@EnumHandRank> {
    fn le(lhs: @EnumHandRank, rhs: @EnumHandRank) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value <= right_value
    }

    fn lt(lhs: @EnumHandRank, rhs: @EnumHandRank) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value < right_value
    }

    fn ge(lhs: @EnumHandRank, rhs: @EnumHandRank) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value >= right_value
    }

    fn gt(lhs: @EnumHandRank, rhs: @EnumHandRank) -> bool {
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
        lhs.m_num_representation == rhs.m_num_representation
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
        let value_as_u32: u32 = value.into();
        let suit_as_u32: u32 = suit.into();
        StructCard {
            m_num_representation: u256 { high: value_as_u32.into(), low: suit_as_u32.into() }
        }
    }

    fn get_value(self: @StructCard) -> Option<EnumCardValue> {
        // Get the 8 most significant bits.
        match *self.m_num_representation.high {
            0 => Option::None,
            1 => Option::Some(EnumCardValue::Ace),
            2 => Option::Some(EnumCardValue::Two),
            3 => Option::Some(EnumCardValue::Three),
            4 => Option::Some(EnumCardValue::Four),
            5 => Option::Some(EnumCardValue::Five),
            6 => Option::Some(EnumCardValue::Six),
            7 => Option::Some(EnumCardValue::Seven),
            8 => Option::Some(EnumCardValue::Eight),
            9 => Option::Some(EnumCardValue::Nine),
            10 => Option::Some(EnumCardValue::Ten),
            11 => Option::Some(EnumCardValue::Jack),
            12 => Option::Some(EnumCardValue::Queen),
            13 => Option::Some(EnumCardValue::King),
            14 => Option::Some(EnumCardValue::Ace),
            _ => Option::None,
        }
    }

    fn get_suit(self: @StructCard) -> Option<EnumCardSuit> {
        // Get the 8 least significant bits.
        match *self.m_num_representation.low {
            0 => Option::None,
            1 => Option::Some(EnumCardSuit::Spades),
            2 => Option::Some(EnumCardSuit::Hearts),
            3 => Option::Some(EnumCardSuit::Diamonds),
            4 => Option::Some(EnumCardSuit::Clubs),
            _ => Option::None,
        }
    }
}

#[generate_trait]
impl HandImpl of IHand {
    fn new(address: ContractAddress, commitment_hash: ByteArray) -> ComponentHand {
        let mut commitment_hash_num: Array<u32> = array![];
        for i in 0..8_u32 {
            commitment_hash_num.append(commitment_hash[i].into());
        };
        ComponentHand {
            m_owner: address, m_cards: array![], m_commitment_hash: commitment_hash_num
        }
    }

    fn add_card(ref self: ComponentHand, card: StructCard) {
        self.m_cards.append(card);
    }

    fn clear(ref self: ComponentHand) {
        self.m_cards = array![];
    }

    fn evaluate_hand(
        self: @ComponentHand, board: @Array<StructCard>
    ) -> Result<EnumHandRank, EnumError> {
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
                let mut prev_value: u32 = flush_values[0].into();

                for i in 1
                    ..flush_values
                        .len() {
                            let curr_value: u32 = flush_values[i].into();
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

    fn _has_four_of_a_kind(
        self: @ComponentHand, board: @Array<StructCard>
    ) -> Option<EnumCardValue> {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):
        if self.m_cards.len() + board.len() < 4 {
            return Option::None;
        }

        let all_cards: Array<StructCard> = self.m_cards.concat(board);
        let mut value_counts: Felt252Dict<u8> = Default::default();

        // Single pass to count values.
        for card in all_cards
            .span() {
                if let Option::Some(value) = card.get_value() {
                    let value_count: u32 = (@value).into();
                    value_counts
                        .insert(value_count.into(), value_counts.get(value_count.into()) + 1);
                    // Early return if we find four of a kind.
                    if value_counts.get(value_count.into()) == 4 {
                        break;
                    }
                }
            };

        let card_value: EnumCardValue = all_cards[0].get_value().unwrap();
        let value_count: u32 = (@card_value).into();
        if value_counts.get(value_count.into()) == 4 {
            return Option::Some(card_value);
        }

        return Option::None;
    }

    fn _has_full_house(
        self: @ComponentHand, board: @Array<StructCard>
    ) -> Option<(EnumCardValue, EnumCardValue)> {
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
        for card in all_cards
            .span() {
                if let Option::Some(value) = card.get_value() {
                    let value_count: u32 = (@value).into();
                    let count = value_counts.get(value_count.into());
                    if count == 3 && three_of_kind.is_none() {
                        three_of_kind = Option::Some(value);
                    } else if count >= 2
                        && pair.is_none()
                        && (three_of_kind.is_none() || three_of_kind.unwrap() != value) {
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
        for card in all_cards
            .span() {
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
        for card in all_cards
            .span() {
                if let Option::Some(value) = card.get_value() {
                    if !unique_values.contains(@value) {
                        unique_values.append(value);
                    }
                }
            };

        let sorted_unique_values: Array<EnumCardValue> = utils::sort_values(@unique_values);

        // Check for regular straight.
        let mut consecutive_count: u8 = 1;
        let mut prev_value: u32 = sorted_unique_values[0].into();
        let mut highest_value: EnumCardValue = *sorted_unique_values[0];

        for i in 1
            ..sorted_unique_values
                .len() {
                    let curr_value: u32 = sorted_unique_values[i].into();
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

    fn _has_three_of_a_kind(
        self: @ComponentHand, board: @Array<StructCard>
    ) -> Option<EnumCardValue> {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):
        if self.m_cards.len() + board.len() < 3 {
            return Option::None;
        }

        let mut three_of_a_kind: Option<EnumCardValue> = Option::None;
        let mut first_value: EnumCardValue = self.m_cards[0].get_value().unwrap();

        // Check if hand is a pair and board has matching value
        if first_value == self.m_cards[1].get_value().unwrap() {
            for card in board
                .span() {
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

        for card in all_cards
            .span() {
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

    fn _has_two_pair(
        self: @ComponentHand, board: @Array<StructCard>
    ) -> Option<(EnumCardValue, EnumCardValue)> {
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

        for i in 0
            ..all_cards
                .len() {
                    if let Option::Some(card_value) = all_cards[i].get_value() {
                        if card_value == prev_value {
                            if first_pair_value.is_none() {
                                first_pair_value = Option::Some(prev_value);
                                continue;
                            }
                            if second_pair_value.is_none()
                                && first_pair_value.unwrap() != prev_value {
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

        // Get all possible pairs.
        for card in all_cards
            .span() {
                if let Option::Some(value) = card.get_value() {
                    let value_count: u32 = (@value).into();
                    if value_counts.get(value_count.into()) == 2 && !pairs.contains(@value) {
                        pairs.append(value);
                    }
                }
            };

        if pairs.len() >= 2 {
            // Get highest pair.
            let sorted_pairs = utils::sort_values(@pairs);
            return Option::Some(sorted_pairs[sorted_pairs.len() - 1].clone());
        }

        return Option::None;
    }

    fn _evaluate_rank(
        self: @ComponentHand, board: @Array<StructCard>
    ) -> Result<EnumHandRank, EnumError> {
        // Combine both checks.
        if self.m_cards.len() != 2 || board.len() > 5 {
            return Result::Err(
                if self.m_cards.len() != 2 {
                    EnumError::InvalidHand
                } else {
                    EnumError::InvalidBoard
                }
            );
        }

        // Single pass to collect data to prevent having to call all check functions for i.e. a
        // simple pair.
        let all_cards = self.m_cards.concat(board);
        let mut value_counts: Felt252Dict<u8> = Default::default();
        let mut suit_counts: Felt252Dict<u8> = Default::default();
        let mut values: Array<EnumCardValue> = array![];

        // Track maximums during our single pass.
        let mut max_value_count: u8 = 0;
        let mut max_suit_count: u8 = 0;
        let mut pair_count: u8 = 0;

        for card in all_cards
            .span() {
                if let Option::Some(value) = card.get_value() {
                    let value_count: u32 = (@value).into();
                    let new_count = value_counts.get(value_count.into()) + 1;
                    value_counts.insert(value_count.into(), new_count);
                    if new_count > max_value_count {
                        max_value_count = new_count;
                    }
                    if new_count == 2 {
                        pair_count += 1;
                    }
                    values.append(value);
                }
                if let Option::Some(suit) = card.get_suit() {
                    let suit_count: u32 = (@suit).into();
                    let new_count = suit_counts.get(suit_count.into()) + 1;
                    suit_counts.insert(suit_count.into(), new_count);
                    if new_count > max_suit_count {
                        max_suit_count = new_count;
                    }
                }
            };

        // Now we can use these counts to skip impossible hands.
        if max_suit_count >= 5 {
            if self._has_royal_flush(board) {
                return Result::Ok(EnumHandRank::RoyalFlush);
            }
            if self._has_straight_flush(board) {
                return Result::Ok(EnumHandRank::StraightFlush);
            }
        }

        if max_value_count == 4 {
            if let Option::Some(value) = self._has_four_of_a_kind(board) {
                return Result::Ok(EnumHandRank::FourOfAKind(value));
            }
        }

        if max_value_count == 3 && pair_count >= 1 {
            if let Option::Some((three, pair)) = self._has_full_house(board) {
                return Result::Ok(EnumHandRank::FullHouse((three, pair)));
            }
        }

        if max_suit_count >= 5 {
            if let Option::Some(values) = self._has_flush(board) {
                return Result::Ok(EnumHandRank::Flush(values));
            }
        }

        // Check for straight (can't easily rule this out from counts alone).
        if let Option::Some(high_card) = self._has_straight(board) {
            return Result::Ok(EnumHandRank::Straight(high_card));
        }

        if max_value_count == 3 {
            if let Option::Some(value) = self._has_three_of_a_kind(board) {
                return Result::Ok(EnumHandRank::ThreeOfAKind(value));
            }
        }

        if pair_count >= 2 {
            if let Option::Some((high, low)) = self._has_two_pair(board) {
                return Result::Ok(EnumHandRank::TwoPair((high, low)));
            }
        }

        if pair_count == 1 {
            if let Option::Some(value) = self._has_pair(board) {
                return Result::Ok(EnumHandRank::Pair(value));
            }
        }

        // If no other hand is found, return high card.
        Result::Ok(EnumHandRank::HighCard(utils::sort_values(@values)))
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

    fn set_ready(ref self: ComponentPlayer) {
        assert!(self.m_state != EnumPlayerState::NotCreated, "Player is not created");
        assert!(self.m_state == EnumPlayerState::Waiting, "Player is not waiting");

        self.m_state = EnumPlayerState::Ready;
    }

    fn place_bet(ref self: ComponentPlayer, added_amount: u32) -> u32 {
        assert!(self.m_state != EnumPlayerState::NotCreated, "Player is not created");
        assert!(self.m_table_chips >= added_amount, "Insufficient chips");

        if self.m_table_chips == added_amount {
            self.m_state = EnumPlayerState::AllIn;
        }

        self.m_table_chips -= added_amount;
        self.m_current_bet += added_amount;
        return added_amount;
    }

    fn fold(ref self: ComponentPlayer) -> u32 {
        assert!(self.m_state != EnumPlayerState::NotCreated, "Player is not created");
        assert!(self.m_state == EnumPlayerState::Active, "Player is not active");

        self.m_state = EnumPlayerState::Folded;
        return self.m_current_bet;
    }

    // fn all_in(ref self: ComponentPlayer) -> u32 {
    //     assert!(self.m_state != EnumPlayerState::NotCreated, "Player is not created");
    //     assert!(self.m_state == EnumPlayerState::Active, "Player is not active");

    //     let added_amount: u32 = self.m_table_chips;
    //     self.m_current_bet += added_amount;
    //     self.m_table_chips = 0;
    //     self.m_state = EnumPlayerState::AllIn;
    //     return added_amount;
    // }

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

    fn check_turn(ref self: ComponentTable, player: @ContractAddress) -> bool {
        assert!(self.m_players.contains(player), "Player is not at this table");

        let player_position: Option<usize> = self.find_player(player);
        assert!(player_position.is_some(), "Cannot find player");

        let player_position: usize = player_position.unwrap();
        return self.m_current_turn == player_position.try_into().expect('Cannot downcast turn');
    }

    fn shuffle_deck(ref self: ComponentTable, seed: felt252) {
        let mut shuffled_deck: Array<StructCard> = array![];
        let mut deck = DeckTrait::new(seed, self.m_deck.len());

        while deck.remaining > 0 {
            // Draw a random number from 0 to 52.
            let card_index: u8 = deck.draw();

            if let Option::Some(_) = self.m_deck.get(card_index.into()) {
                shuffled_deck.append(self.m_deck[card_index.into()].clone());
            }
        };
        self.m_deck = shuffled_deck;
    }

    fn advance_street(ref self: ComponentTable) {
        self.m_state = match self.m_state {
            EnumGameState::PreFlop => EnumGameState::Flop,
            EnumGameState::Flop => EnumGameState::Turn,
            EnumGameState::Turn => EnumGameState::River,
            EnumGameState::River => EnumGameState::Showdown,
            EnumGameState::Showdown => EnumGameState::PreFlop,
            _ => self.m_state,
        };
    }

    fn advance_turn(ref self: ComponentTable) {
        self.m_current_turn += 1;
        self
            .m_current_turn = self
            .m_current_turn % self
            .m_players
            .len()
            .try_into()
            .expect('Cannot downcast turn');
        self.m_last_played_ts = starknet::get_block_timestamp();
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

        // Initialize the deck with 52 cards.
        let mut suit_index: u32 = 0;
        let mut value_index: u32 = 0;

        for _ in 0
            ..52_u32 {
                self.m_deck.append(ICard::new(*values[value_index], *suits[suit_index]));

                // Check if we've created every value for the current suit.
                value_index += 1;
                value_index = value_index % 13;
                if value_index == 0 {
                    suit_index += 1;
                }
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
            m_owner: starknet::contract_address_const::<0x0>(),
            m_cards: array![],
            m_commitment_hash: array![],
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
