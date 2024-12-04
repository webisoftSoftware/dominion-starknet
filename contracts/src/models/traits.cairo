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

        let str: ByteArray = format!("\n\tTable Chips: {0}", *self.m_table_chips);
        f.buffer.append(@str);

        let str: ByteArray = format!("\n\tTotal Chips: {0}", *self.m_total_chips);
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

    fn evaluate_hand(self: @ComponentHand, board: @Array<StructCard>) -> (EnumHandRank, u32) {
        // First analyze the hand
        let rank_result: Result<EnumHandRank, EnumError> = self._evaluate_rank(board);
        assert!(rank_result.is_ok(), "Invalid hand");

        let value: u32 = self._evaluate_value();

        // Return the appropriate score and rank in case of a tie.
        match rank_result.unwrap() {
            EnumHandRank::RoyalFlush => (
                EnumHandRank::RoyalFlush, EnumHandRank::RoyalFlush.into() + value
            ),
            EnumHandRank::StraightFlush => (
                EnumHandRank::StraightFlush, EnumHandRank::StraightFlush.into() + value
            ),
            EnumHandRank::FourOfAKind => (
                EnumHandRank::FourOfAKind, EnumHandRank::FourOfAKind.into() + value
            ),
            EnumHandRank::FullHouse => (
                EnumHandRank::FullHouse, EnumHandRank::FullHouse.into() + value
            ),
            EnumHandRank::Flush => (EnumHandRank::Flush, EnumHandRank::Flush.into() + value),
            EnumHandRank::Straight => (
                EnumHandRank::Straight, EnumHandRank::Straight.into() + value
            ),
            EnumHandRank::ThreeOfAKind => (
                EnumHandRank::ThreeOfAKind, EnumHandRank::ThreeOfAKind.into() + value
            ),
            EnumHandRank::TwoPair => (EnumHandRank::TwoPair, EnumHandRank::TwoPair.into() + value),
            EnumHandRank::Pair => (EnumHandRank::Pair, EnumHandRank::Pair.into() + value),
            EnumHandRank::HighCard => (
                EnumHandRank::HighCard, EnumHandRank::HighCard.into() + value
            ),
        }
    }

    fn _has_royal_flush(self: @ComponentHand, board: @Array<StructCard>) -> bool {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):

        if self.m_cards.len() + board.len() < 5 {
            return false;
        }

        // Combine hand and board cards
        let mut all_cards: Array<StructCard> = self.m_cards.concat(board);
        let mut royal_flush: bool = false;

        // Check each suit
        let suits = array![
            EnumCardSuit::Hearts, EnumCardSuit::Diamonds, EnumCardSuit::Clubs, EnumCardSuit::Spades
        ];

        for suit in suits
            .span() {
                let mut contains_ten: bool = false;
                let mut contains_jack: bool = false;
                let mut contains_queen: bool = false;
                let mut contains_king: bool = false;
                let mut contains_ace: bool = false;

                // Check all cards for royal flush in current suit
                for card in all_cards
                    .span() {
                        if *card.m_suit != *suit {
                            continue;
                        }

                        match card.m_value {
                            EnumCardValue::Ten => contains_ten = true,
                            EnumCardValue::Jack => contains_jack = true,
                            EnumCardValue::Queen => contains_queen = true,
                            EnumCardValue::King => contains_king = true,
                            EnumCardValue::Ace => contains_ace = true,
                            _ => {},
                        };
                    };

                // If we found all required cards in the same suit
                if contains_ten
                    && contains_jack
                    && contains_queen
                    && contains_king
                    && contains_ace {
                    royal_flush = true;
                    break;
                }
            };

        return royal_flush;
    }

    fn _has_straight_flush(self: @ComponentHand, board: @Array<StructCard>) -> bool {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):
        if self.m_cards.len() + board.len() < 5 {
            return false;
        }

        // Combine hand and board cards
        let mut all_cards: Array<StructCard> = self.m_cards.concat(board);
        let mut straight_flush: bool = false;

        // Check each suit
        let suits = array![
            EnumCardSuit::Hearts, EnumCardSuit::Diamonds, EnumCardSuit::Clubs, EnumCardSuit::Spades
        ];

        for suit in suits
            .span() {
                // Get all cards of current suit and sort them
                let mut suit_cards: Array<StructCard> = array![];

                for card in all_cards
                    .span() {
                        if *card.m_suit == *suit {
                            suit_cards.append(*card);
                        }
                    };

                // Need at least 5 cards of the same suit for a straight flush
                if suit_cards.len() < 5 {
                    continue;
                }

                let sorted_cards = utils::sort(@suit_cards);

                // Check for Ace-low straight flush (A-2-3-4-5)
                if sorted_cards.len() >= 5 {
                    let last_idx = sorted_cards.len() - 1;
                    if *sorted_cards[last_idx].m_value == EnumCardValue::Ace {
                        let mut has_two = false;
                        let mut has_three = false;
                        let mut has_four = false;
                        let mut has_five = false;

                        for card in sorted_cards
                            .span() {
                                match card.m_value {
                                    EnumCardValue::Two => has_two = true,
                                    EnumCardValue::Three => has_three = true,
                                    EnumCardValue::Four => has_four = true,
                                    EnumCardValue::Five => has_five = true,
                                    _ => {},
                                };
                            };

                        if has_two && has_three && has_four && has_five {
                            straight_flush = true;
                            break;
                        }
                    }
                }

                // Check for regular straight flush
                let mut consecutive_count: u32 = 1;
                let mut prev_value: u32 = (*sorted_cards[0].m_value).into();

                for i in 1
                    ..sorted_cards
                        .len() {
                            let current_value: u32 = (*sorted_cards[i].m_value).into();

                            if current_value == prev_value {
                                continue; // Skip duplicate values
                            }

                            if current_value == prev_value + 1 {
                                consecutive_count += 1;
                                if consecutive_count >= 5 {
                                    straight_flush = true;
                                    break;
                                }
                            } else {
                                consecutive_count = 1;
                            }
                            prev_value = current_value;
                        }
            };

        return straight_flush;
    }

    fn _has_four_of_a_kind(self: @ComponentHand, board: @Array<StructCard>) -> bool {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):
        if self.m_cards.len() + board.len() < 4 {
            return false;
        }

        // Check if hand is a pair and board has matching value
        if *self.m_cards[0].m_value == *self.m_cards[1].m_value {
            let mut dup_count: u8 = 2;
            for card in board
                .span() {
                    if *card.m_value == *self.m_cards[0].m_value {
                        dup_count += 1;
                        if dup_count >= 4 {
                            break;
                        }
                    }
                };

            if dup_count >= 4 {
                return true;
            }
        }

        // Comibne cards and sort.
        let sorted_board: Array<StructCard> = utils::sort(board);
        let all_cards: Array<StructCard> = self.m_cards.concat(@sorted_board);

        // Check if there are 3 cards with the same value.
        let mut same_kind_count: u8 = 1;
        let mut prev_value: @EnumCardValue = all_cards[0].m_value;

        for card in all_cards
            .span() {
                if card.m_value == prev_value {
                    same_kind_count += 1;

                    if same_kind_count >= 4 {
                        break;
                    }
                    continue;
                }

                same_kind_count = 1;
                prev_value = card.m_value;
            };

        return same_kind_count >= 4;
    }

    fn _has_full_house(self: @ComponentHand, board: @Array<StructCard>) -> bool {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):
        if self.m_cards.len() + board.len() < 5 {
            return false;
        }

        let sorted_board: Array<StructCard> = utils::sort(board);
        let all_cards: Array<StructCard> = self.m_cards.concat(@sorted_board);

        let mut first_value: Option<@EnumCardValue> = Option::None;
        let mut first_count: u8 = 0;
        let mut second_value: Option<@EnumCardValue> = Option::None;
        let mut second_count: u8 = 0;
        let mut current_value: @EnumCardValue = all_cards[0].m_value;
        let mut current_count: u8 = 1;

        for i in 1
            ..all_cards
                .len() {
                    if all_cards[i].m_value == current_value {
                        current_count += 1;
                        continue;
                    }

                    // Update counts when we find a different value.
                    if first_value.is_none() || first_value == Option::Some(current_value) {
                        first_value = Option::Some(current_value);
                        first_count = current_count;
                    } else if second_value.is_none()
                        || second_value == Option::Some(current_value) {
                        second_value = Option::Some(current_value);
                        second_count = current_count;
                    } else if current_count > first_count {
                        second_value = first_value;
                        second_count = first_count;
                        first_value = Option::Some(current_value);
                        first_count = current_count;
                    } else if current_count > second_count {
                        second_value = Option::Some(current_value);
                        second_count = current_count;
                    }
                    current_value = all_cards[i].m_value;
                    current_count = 1;
                };

        // Handle the last group of cards
        if first_value.is_none() || first_value == Option::Some(current_value) {
            first_count = current_count;
        } else if second_value.is_none() || second_value == Option::Some(current_value) {
            second_count = current_count;
        } else if current_count > first_count {
            second_count = first_count;
            first_count = current_count;
        } else if current_count > second_count {
            second_count = current_count;
        }

        // Check if we have a three of a kind and a pair
        return (first_count == 3 && second_count == 2) || (first_count == 2 && second_count == 3);
    }

    fn _has_flush(self: @ComponentHand, board: @Array<StructCard>) -> bool {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH:
        // Check if there's 5 cards with the same suit.
        if self.m_cards.len() + board.len() < 5 {
            return false;
        }

        let all_cards: Array<StructCard> = self.m_cards.concat(board);

        // Check each suit
        let suits = array![
            EnumCardSuit::Hearts, EnumCardSuit::Diamonds, EnumCardSuit::Clubs, EnumCardSuit::Spades
        ];
        let mut is_flush: bool = false;

        for suit in suits
            .span() {
                let mut matches: u8 = 0;

                for i in 0
                    ..all_cards
                        .len() {
                            let current_suit: @EnumCardSuit = all_cards[i].m_suit;

                            if *current_suit == *suit {
                                matches += 1;
                            }

                            if matches >= 5 {
                                is_flush = true;
                                break;
                            }
                        };
            };
        return is_flush;
    }

    fn _has_straight(self: @ComponentHand, board: @Array<StructCard>) -> bool {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):

        if self.m_cards.len() + board.len() < 5 {
            return false;
        }

        let sorted_board: Array<StructCard> = utils::sort(board);

        // Combine hand and board cards into a single array
        let all_cards: Array<StructCard> = self.m_cards.concat(@sorted_board);

        // Special case: Ace can be used as 1 for A-2-3-4-5 straight.
        // Check for Ace-low straight (A-2-3-4-5)
        if all_cards.len() >= 5 {
            let last_idx = all_cards.len() - 1;
            if *all_cards[last_idx].m_value == EnumCardValue::Ace {
                let mut has_two = false;
                let mut has_three = false;
                let mut has_four = false;
                let mut has_five = false;

                for card in all_cards
                    .span() {
                        match card.m_value {
                            EnumCardValue::Two => has_two = true,
                            EnumCardValue::Three => has_three = true,
                            EnumCardValue::Four => has_four = true,
                            EnumCardValue::Five => has_five = true,
                            _ => {},
                        };
                    };

                if has_two && has_three && has_four && has_five {
                    return true;
                }
            }
        }

        // Check for regular straight.
        let mut is_straight: bool = false;
        let mut consecutive_count: u32 = 1;
        let mut prev_value: u32 = (*all_cards[0].m_value).into();

        // Check for consecutive values.
        for i in 1
            ..all_cards
                .len() {
                    let current_value: u32 = (*all_cards[i].m_value).into();

                    if current_value == prev_value {
                        continue; // Skip duplicate values.
                    }

                    if current_value == prev_value + 1 {
                        consecutive_count += 1;
                        prev_value = current_value;

                        if consecutive_count >= 5 {
                            is_straight = true;
                            break;
                        }
                        continue;
                    }

                    prev_value = current_value;
                    consecutive_count = 1;
                };

        return is_straight;
    }

    fn _has_three_of_a_kind(self: @ComponentHand, board: @Array<StructCard>) -> bool {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):
        if self.m_cards.len() + board.len() < 3 {
            return false;
        }

        let mut three_of_a_kind: bool = false;

        // Check if hand is a pair and board has matching value
        if *self.m_cards[0].m_value == *self.m_cards[1].m_value {
            for card in board
                .span() {
                    if *card.m_value == *self.m_cards[0].m_value {
                        three_of_a_kind = true;
                        break;
                    }
                };
            if three_of_a_kind {
                return true;
            }
        }

        // Comibne cards and sort.
        let sorted_board: Array<StructCard> = utils::sort(board);
        let all_cards: Array<StructCard> = self.m_cards.concat(@sorted_board);

        // Check if there are 3 cards with the same value.
        let mut same_kind_count: u8 = 1;
        let mut prev_value: @EnumCardValue = all_cards[0].m_value;

        for card in all_cards
            .span() {
                if card.m_value == prev_value {
                    same_kind_count += 1;

                    if same_kind_count >= 3 {
                        break;
                    }
                    continue;
                }

                prev_value = card.m_value;
                same_kind_count = 1;
            };

        return same_kind_count >= 3;
    }

    fn _has_two_pair(self: @ComponentHand, board: @Array<StructCard>) -> bool {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):
        if self.m_cards.len() + board.len() < 4 {
            return false;
        }

        let mut num_pairs: u8 = 0;
        let sorted_board: Array<StructCard> = utils::sort(board);
        let all_cards: Array<StructCard> = self.m_cards.concat(@sorted_board);
        let mut consecutive_count: u8 = 1;
        let mut prev_value: @EnumCardValue = all_cards[0].m_value;
        let mut first_pair_value: Option<@EnumCardValue> = Option::None;

        for i in 0
            ..all_cards
                .len() {
                    if all_cards[i].m_value == prev_value {
                        consecutive_count += 1;
                        if consecutive_count == 2 {
                            if first_pair_value != Option::Some(prev_value) {
                                num_pairs += 1;
                                if num_pairs == 1 {
                                    first_pair_value = Option::Some(prev_value);
                                }
                            }
                        } else {
                            consecutive_count = 1;
                            prev_value = all_cards[i].m_value;
                        }
                    }

                    if num_pairs >= 2 {
                        break;
                    }
                };

        return num_pairs >= 2;
    }

    fn _has_pair(self: @ComponentHand, board: @Array<StructCard>) -> bool {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):

        // Check if the hand itself is a pair.
        if *self.m_cards[0].m_value == *self.m_cards[1].m_value {
            return true;
        }

        if self.m_cards.len() + board.len() < 2 {
            return false;
        }

        // Sort board cards, since cards in hand are sorted.
        let sorted_board: Array<StructCard> = utils::sort(board);
        let mut pair_found: bool = false;

        for i in 0
            ..sorted_board
                .len() {
                    if *sorted_board[i].m_value == *self.m_cards[0].m_value
                        || *sorted_board[i].m_value == *self.m_cards[1].m_value {
                        pair_found = true;
                        break;
                    }
                };

        return pair_found;
    }

    fn _get_highest_card_value(self: @ComponentHand) -> u32 {
        let mut highest_value: u32 = 0;

        for i in 0
            ..self
                .m_cards
                .len() {
                    let current_value: u32 = (*self.m_cards[i].m_value).into();
                    if current_value > highest_value {
                        highest_value = current_value;
                    }
                };
        return highest_value;
    }

    fn _evaluate_value(self: @ComponentHand) -> u32 {
        let mut total_value: u32 = 0;

        for i in 0
            ..self
                .m_cards
                .len() {
                    let current_value: u32 = (*self.m_cards[i].m_value).into();
                    total_value += current_value;
                };
        return total_value;
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

        if self._has_flush(board) && self._has_straight(board) {
            return Result::Ok(EnumHandRank::StraightFlush);
        }

        if self._has_straight_flush(board) && self._has_flush(board) {
            return Result::Ok(EnumHandRank::RoyalFlush);
        }

        if self._has_flush(board) {
            return Result::Ok(EnumHandRank::Flush);
        }

        if self._has_straight(board) {
            return Result::Ok(EnumHandRank::Straight);
        }

        if self._has_four_of_a_kind(board) {
            return Result::Ok(EnumHandRank::FourOfAKind);
        }

        if self._has_three_of_a_kind(board) {
            return Result::Ok(EnumHandRank::ThreeOfAKind);
        }

        if self._has_two_pair(board) {
            return Result::Ok(EnumHandRank::TwoPair);
        }

        if self._has_pair(board) {
            return Result::Ok(EnumHandRank::Pair);
        }

        Result::Ok(EnumHandRank::HighCard)
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
            m_table_id: 0, m_owner: starknet::contract_address_const::<0x0>(), m_cards: array![],
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