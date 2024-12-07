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
//  █���██████  ░░██████  █████░███
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
use dominion::models::enums::{EnumCardValue, EnumHandRank};
use dominion::models::traits::{EnumCardValueInto, StructCardDisplay, ICard};

fn tie_breaker(first_hand: @EnumHandRank, second_hand: @EnumHandRank) -> i32 {
    match (first_hand, second_hand) {
        (EnumHandRank::RoyalFlush, EnumHandRank::RoyalFlush) => 0,

        (EnumHandRank::StraightFlush(highcard), EnumHandRank::StraightFlush(other_highcard)) => { 
            return compare_cards(*highcard, *other_highcard);
        },

        (EnumHandRank::FourOfAKind((quad_value, kickers)), EnumHandRank::FourOfAKind((other_quad_value, other_kickers))) => {
            let quad_compare = compare_cards(*quad_value, *other_quad_value);
            if quad_compare != 0 {
                return quad_compare;
            }
            let mut result = 0;
            for i in 0_u32..3_u32 {
                if result == 0 {
                    result = compare_cards(*kickers[i], *other_kickers[i]);
                }
            };
            return result;
        },

        (EnumHandRank::FullHouse((three_value, pair_value)), EnumHandRank::FullHouse((other_three_value, other_pair_value))) => {
            let three_compare = compare_cards(*three_value, *other_three_value);
            if three_compare != 0 {
                return three_compare;
            }
            return compare_cards(*pair_value, *other_pair_value);
        },

        (EnumHandRank::Flush(sum), EnumHandRank::Flush(other_sum)) => {
            let sum_value: u32 = (*sum).into();
            let other_sum_value: u32 = (*other_sum).into();

            if sum_value > other_sum_value {
                return 1;
            }
            if sum_value < other_sum_value {
                return -1;
            }
            return 0;
        },

        (EnumHandRank::Straight(highcard), EnumHandRank::Straight(other_highcard)) => {
            if *highcard == EnumCardValue::Five.into() && *other_highcard != EnumCardValue::Five.into() {
                return -1;
            }
            if *other_highcard == EnumCardValue::Five.into() && *highcard != EnumCardValue::Five.into() {
                return 1;
            }
            return compare_cards(*highcard, *other_highcard);
        },

        (EnumHandRank::ThreeOfAKind((three_value, kickers)), EnumHandRank::ThreeOfAKind((other_three_value, other_kickers))) => {
            let three_compare = compare_cards(*three_value, *other_three_value);
            if three_compare != 0 {
                return three_compare;
            }
            let mut result = 0;
            for i in 0_u32..2_u32 {
                if result == 0 {
                    result = compare_cards(*kickers[i], *other_kickers[i]);
                }
            };
            return result;
        },

        _ => { return 1; }
    }
}

fn compare_cards(first_card_value: EnumCardValue, second_card_value: EnumCardValue) -> i32 {
    let first_value: u32 = first_card_value.into();
    let second_value: u32 = second_card_value.into();

    if first_value > second_value {
        return 1;
    }
    if first_value < second_value {
        return -1;
    }
    return 0;
}

fn sort(arr: @Array<StructCard>) -> Array<StructCard> {
    // If array is empty or has 1 element, it's already sorted
    if arr.len() <= 1 {
        return arr.clone();
    }

    // Perform merge sort
    return merge_sort(arr, 0, arr.len() - 1);
}

// Helper function to merge two sorted subarrays
fn merge(left_arr: @Array<StructCard>, right_arr: @Array<StructCard>) -> Array<StructCard> {
    let mut result: Array<StructCard> = array![];
    let mut i = 0;
    let mut j = 0;

    // Merge the two arrays
    while i < left_arr.len() && j < right_arr.len() {
        if left_arr[i].get_value().is_none() || right_arr[j].get_value().is_none() {
            println!("left_arr[i]: {}", left_arr[i]);
            println!("right_arr[j]: {}", right_arr[j]);
            panic!("Card value is none");
        }

        let left_value: u32 = left_arr[i].get_value().unwrap().into();
        let right_value: u32 = right_arr[j].get_value().unwrap().into();

        if left_value <= right_value {
            result.append(left_arr[i].clone());
            i += 1;
        } else {
            result.append(right_arr[j].clone());
            j += 1;
        }
    };

    // Copy remaining elements from left array
    while i < left_arr.len() {
        result.append(left_arr[i].clone());
        i += 1;
    };

    // Copy remaining elements from right array
    while j < right_arr.len() {
        result.append(right_arr[j].clone());
        j += 1;
    };

    result
}

// Recursive merge sort implementation
fn merge_sort(arr: @Array<StructCard>, left: usize, right: usize) -> Array<StructCard> {
    if left >= right {
        let mut result = array![];
        result.append(arr[left].clone());
        return result;
    }

    let mid = left + (right - left) / 2;

    // Create subarrays for left and right portions
    let mut left_arr = array![];
    let mut right_arr = array![];

    // Fill left subarray
    let mut i = left;
    while i <= mid {
        left_arr.append(arr[i].clone());
        i += 1;
    };

    // Fill right subarray
    let mut i = mid + 1;
    while i <= right {
        right_arr.append(arr[i].clone());
        i += 1;
    };

    // Sort both subarrays
    let sorted_left = merge_sort(@left_arr, 0, left_arr.len() - 1);
    let sorted_right = merge_sort(@right_arr, 0, right_arr.len() - 1);

    // Merge the sorted subarrays
    merge(@sorted_left, @sorted_right)
}
