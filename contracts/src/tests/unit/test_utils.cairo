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

use dominion::models::structs::StructCard;
use dominion::models::enums::{EnumCardValue, EnumCardSuit};
use dominion::models::traits::{StructCardEq, StructCardDisplay};
use dominion::models::utils::{sort, merge_sort};

#[test]
fn test_sort() {
    // Check identical arrays.
    let input_arr = array![
        StructCard { m_value: EnumCardValue::Two, m_suit: EnumCardSuit::Spades },
        StructCard { m_value: EnumCardValue::Three, m_suit: EnumCardSuit::Hearts },
        StructCard { m_value: EnumCardValue::Four, m_suit: EnumCardSuit::Diamonds },
        StructCard { m_value: EnumCardValue::Five, m_suit: EnumCardSuit::Clubs },
        StructCard { m_value: EnumCardValue::Six, m_suit: EnumCardSuit::Hearts }
    ];
    let sorted_arr = sort(@input_arr);
    assert_eq!(sorted_arr, input_arr);

    // Check ascending order.
    let input_arr = array![
        StructCard { m_value: EnumCardValue::Five, m_suit: EnumCardSuit::Spades },
        StructCard { m_value: EnumCardValue::Four, m_suit: EnumCardSuit::Hearts },
        StructCard { m_value: EnumCardValue::Three, m_suit: EnumCardSuit::Diamonds },
        StructCard { m_value: EnumCardValue::Two, m_suit: EnumCardSuit::Clubs },
        StructCard { m_value: EnumCardValue::Ace, m_suit: EnumCardSuit::Hearts }
    ];
    let expected_arr = array![
        StructCard { m_value: EnumCardValue::Two, m_suit: EnumCardSuit::Clubs },
        StructCard { m_value: EnumCardValue::Three, m_suit: EnumCardSuit::Diamonds },
        StructCard { m_value: EnumCardValue::Four, m_suit: EnumCardSuit::Hearts },
        StructCard { m_value: EnumCardValue::Five, m_suit: EnumCardSuit::Spades },
        StructCard { m_value: EnumCardValue::Ace, m_suit: EnumCardSuit::Hearts }
    ];
    let sorted_arr = sort(@input_arr);
    assert_eq!(sorted_arr, expected_arr);

    // Check mixed order.
    let input_arr = array![
        StructCard { m_value: EnumCardValue::Five, m_suit: EnumCardSuit::Spades },
        StructCard { m_value: EnumCardValue::Four, m_suit: EnumCardSuit::Hearts },
        StructCard { m_value: EnumCardValue::Three, m_suit: EnumCardSuit::Diamonds },
        StructCard { m_value: EnumCardValue::Two, m_suit: EnumCardSuit::Clubs },
        StructCard { m_value: EnumCardValue::Ace, m_suit: EnumCardSuit::Hearts }
    ];
    let expected_arr = array![
        StructCard { m_value: EnumCardValue::Two, m_suit: EnumCardSuit::Clubs },
        StructCard { m_value: EnumCardValue::Three, m_suit: EnumCardSuit::Diamonds },
        StructCard { m_value: EnumCardValue::Four, m_suit: EnumCardSuit::Hearts },
        StructCard { m_value: EnumCardValue::Five, m_suit: EnumCardSuit::Spades },
        StructCard { m_value: EnumCardValue::Ace, m_suit: EnumCardSuit::Hearts }
    ];
    let sorted_arr = sort(@input_arr);
    assert_eq!(sorted_arr, expected_arr);
}

#[test]
fn test_merge_sort() {
    assert_eq!(1, 1);
}
