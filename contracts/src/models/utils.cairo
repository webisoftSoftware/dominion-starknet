use starknet::ContractAddress;
use dominion::models::structs::StructCard;
use dominion::models::enums::{EnumCardValue, EnumHandRank};
use dominion::models::traits::{
    EnumCardValueInto, EnumCardValueSnapshotInto, EnumCardSuitInto, EnumHandRankSnapshotInto,
    StructCardDisplay, ICard
};

/// Utility function to count occurrences of each card value.
///
/// @param cards - The array of cards to count.
/// @returns A dictionary with the count of each card value.
/// Can panic?: No
fn _count_values(cards: @Array<StructCard>) -> Felt252Dict<u8> {
    let mut value_counts: Felt252Dict<u8> = Default::default();

    for card in cards
        .span() {
            if let Option::Some(value) = card.get_value() {
                let value: u32 = (@value).into();
                let current_count = value_counts.get(value.into());
                value_counts.insert(value.into(), current_count + 1);
            }
        };

    return value_counts;
}

/// Utility function to count occurrences of each suit.
///
/// @param cards - The array of cards to count.
/// @returns A dictionary with the count of each suit.
/// Can panic?: No
fn _count_suits(cards: @Array<StructCard>) -> Felt252Dict<u8> {
    let mut suit_counts: Felt252Dict<u8> = Default::default();

    for card in cards
        .span() {
            if let Option::Some(suit) = card.get_suit() {
                let value: u32 = suit.into();
                let current_count = suit_counts.get(value.into());
                suit_counts.insert(value.into(), current_count + 1);
            }
        };

    return suit_counts;
}

/// Utility function to get the highest card value.
///
/// @param cards - The array of cards to get the highest value from.
/// @returns The highest card value.
/// Can panic?: No
fn _get_highest_card_value(cards: @Array<StructCard>) -> u32 {
    let mut highest_value: u32 = 0;

    for i in 0
        ..cards
            .len() {
                if let Option::Some(card_value) = cards[i].get_value() {
                    let current_value: u32 = (@card_value).into();
                    if current_value > highest_value {
                        highest_value = current_value;
                    }
                }
            };
    return highest_value;
}

/// Utility function to evaluate the value of a hand.
///
/// @param cards - The array of cards to evaluate.
/// @returns The value of the hand.
/// Can panic?: No
fn _evaluate_value(cards: @Array<StructCard>) -> u32 {
    let mut total_value: u32 = 0;

    for i in 0
        ..cards
            .len() {
                if let Option::Some(card_value) = cards[i].get_value() {
                    let current_value: u32 = (@card_value).into();
                    total_value += current_value;
                }
            };
    return total_value;
}

/// Utility function to break ties between two hands.
///
/// @param first_hand - The first hand to compare.
/// @param second_hand - The second hand to compare.
/// @returns The result of the comparison.
/// Can panic?: No
fn tie_breaker(first_hand: @EnumHandRank, second_hand: @EnumHandRank) -> i32 {
    // Get numerical rank for each hand (higher is better)
    let first_rank = get_hand_rank(first_hand);
    let second_rank = get_hand_rank(second_hand);

    // If ranks are different, we can immediately return the comparison
    if first_rank != second_rank {
        return if first_rank > second_rank {
            1
        } else {
            -1
        };
    }

    // If ranks are equal, we need to compare the specific cards
    match (first_hand, second_hand) {
        // Special case for straight with Ace-5
        (
            EnumHandRank::Straight(h1), EnumHandRank::Straight(h2)
        ) => {
            if h1 == @EnumCardValue::Five.into() && h2 != @EnumCardValue::Five.into() {
                return -1;
            }
            if h2 == @EnumCardValue::Five.into() && h1 != @EnumCardValue::Five.into() {
                return 1;
            }
            compare_cards(h1, h2)
        },
        // Compare primary cards for hands with one important card
        (EnumHandRank::FourOfAKind(v1), EnumHandRank::FourOfAKind(v2)) |
        (EnumHandRank::ThreeOfAKind(v1), EnumHandRank::ThreeOfAKind(v2)) |
        (EnumHandRank::Pair(v1), EnumHandRank::Pair(v2)) => compare_cards(v1, v2),
        (
            EnumHandRank::Flush(cards1), EnumHandRank::Flush(cards2)
        ) => {
            let mut compare_result: i32 = 0;
            for i in 0
                ..cards1
                    .len() {
                        compare_result = compare_cards(cards1[i], cards2[i]);
                        if compare_result != 0 {
                            break;
                        }
                    };
            return compare_result;
        },
        // Compare two cards for full house and two pair
        (
            EnumHandRank::FullHouse((v1, v2)), EnumHandRank::FullHouse((w1, w2))
        ) => {
            let main_compare = compare_cards(v1, w1);
            if main_compare != 0 {
                return main_compare;
            }
            return compare_cards(v2, w2);
        },
        (
            EnumHandRank::TwoPair((v1, v2)), EnumHandRank::TwoPair((w1, w2))
        ) => {
            let main_compare = compare_cards(v1, w1);
            if main_compare != 0 {
                return main_compare;
            }
            return compare_cards(v2, w2);
        },
        // Compare arrays of cards for high card
        (
            EnumHandRank::HighCard(cards1), EnumHandRank::HighCard(cards2)
        ) => {
            let mut i = 0;
            let mut compare_result: i32 = 0;
            while i < cards1.len() {
                compare_result = compare_cards(cards1[i], cards2[i]);
                if compare_result != 0 {
                    break;
                }
                i += 1;
            };
            compare_result
        },
        // Equal hands that don't need further comparison
        (EnumHandRank::RoyalFlush, EnumHandRank::RoyalFlush) => 0,
        (EnumHandRank::StraightFlush, EnumHandRank::StraightFlush) => 0,
        // We should never reach this case.
        (_, _) => 0,
    }
}

/// Utility function to get the numerical rank of a hand.
///
/// @param hand - The hand to get the rank from.
/// @returns The numerical rank of the hand.
/// Can panic?: No
fn get_hand_rank(hand: @EnumHandRank) -> u32 {
    return hand.into();
}

/// Utility function to compare two cards.
///
/// @param first_card_value - The first card value to compare.
/// @param second_card_value - The second card value to compare.
/// @returns The result of the comparison.
/// Can panic?: No
fn compare_cards(first_card_value: @EnumCardValue, second_card_value: @EnumCardValue) -> i32 {
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

/// Utility function to sort an array of cards.
///
/// @param arr - The array of cards to sort.
/// @returns The sorted array of cards.
/// Can panic?: No
fn sort(arr: @Array<StructCard>) -> Array<StructCard> {
    if arr.len() <= 1 {
        return arr.clone();
    }

    return merge_sort(arr, 0, arr.len() - 1);
}

/// Utility function to sort an array of card values.
///
/// @param arr - The array of card values to sort.
/// @returns The sorted array of card values.
/// Can panic?: No
fn sort_values(arr: @Array<EnumCardValue>) -> Array<EnumCardValue> {
    if arr.len() <= 1 {
        return arr.clone();
    }

    return merge_sort_values(arr, 0, arr.len() - 1);
}

/// Utility function to merge two arrays of card values.
///
/// @param left_arr - The left array of card values to merge.
/// @param right_arr - The right array of card values to merge.
/// @returns The merged array of card values.
/// Can panic?: No
fn merge_values(
    left_arr: @Array<EnumCardValue>, right_arr: @Array<EnumCardValue>
) -> Array<EnumCardValue> {
    let mut result: Array<EnumCardValue> = array![];
    let mut i = 0;
    let mut j = 0;

    while i < left_arr.len() && j < right_arr.len() {
        let left_value: u32 = left_arr[i].into();
        let right_value: u32 = right_arr[j].into();

        if left_value <= right_value {
            result.append(left_arr[i].clone());
            i += 1;
        } else {
            result.append(right_arr[j].clone());
            j += 1;
        }
    };

    // Copy remaining elements from left array.
    while i < left_arr.len() {
        result.append(left_arr[i].clone());
        i += 1;
    };

    // Copy remaining elements from right array.
    while j < right_arr.len() {
        result.append(right_arr[j].clone());
        j += 1;
    };

    return result;
}

/// Utility function to merge two arrays of cards.
///
/// @param left_arr - The left array of cards to merge.
/// @param right_arr - The right array of cards to merge.
/// @returns The merged array of cards.
/// Can panic?: No
fn merge(left_arr: @Array<StructCard>, right_arr: @Array<StructCard>) -> Array<StructCard> {
    let mut result: Array<StructCard> = array![];
    let mut i = 0;
    let mut j = 0;

    // Merge the two arrays.
    while i < left_arr.len() && j < right_arr.len() {
        if left_arr[i].get_value().is_none() || right_arr[j].get_value().is_none() {
            panic!("Card value is none");
        }

        let left_value: u32 = (@left_arr[i].get_value().unwrap()).into();
        let right_value: u32 = (@right_arr[j].get_value().unwrap()).into();

        if left_value <= right_value {
            result.append(left_arr[i].clone());
            i += 1;
        } else {
            result.append(right_arr[j].clone());
            j += 1;
        }
    };

    // Copy remaining elements from left array.
    while i < left_arr.len() {
        result.append(left_arr[i].clone());
        i += 1;
    };

    // Copy remaining elements from right array.
    while j < right_arr.len() {
        result.append(right_arr[j].clone());
        j += 1;
    };

    return result;
}

/// Utility function to merge sort an array of card values.
///
/// @param arr - The array of card values to sort.
/// @param left - The left index of the array to sort.
/// @param right - The right index of the array to sort.
/// @returns The sorted array of card values.
/// Can panic?: No
fn merge_sort_values(
    arr: @Array<EnumCardValue>, left: usize, right: usize
) -> Array<EnumCardValue> {
    if left >= right {
        let mut result = array![];
        result.append(arr[left].clone());
        return result;
    }

    let mid = left + (right - left) / 2;
    let left_arr = merge_sort_values(arr, left, mid);
    let right_arr = merge_sort_values(arr, mid + 1, right);
    return merge_values(@left_arr, @right_arr);
}

/// Utility function to merge sort an array of cards.
///
/// @param arr - The array of cards to sort.
/// @param left - The left index of the array to sort.
/// @param right - The right index of the array to sort.
/// @returns The sorted array of cards.
/// Can panic?: No
fn merge_sort(arr: @Array<StructCard>, left: usize, right: usize) -> Array<StructCard> {
    if left >= right {
        let mut result = array![];
        result.append(arr[left].clone());
        return result;
    }

    let mid = left + (right - left) / 2;

    // Create subarrays for left and right portions.
    let mut left_arr = array![];
    let mut right_arr = array![];

    // Fill left subarray.
    let mut i = left;
    while i <= mid {
        left_arr.append(arr[i].clone());
        i += 1;
    };

    // Fill right subarray.
    let mut i = mid + 1;
    while i <= right {
        right_arr.append(arr[i].clone());
        i += 1;
    };

    // Sort both subarrays.
    let sorted_left = merge_sort(@left_arr, 0, left_arr.len() - 1);
    let sorted_right = merge_sort(@right_arr, 0, right_arr.len() - 1);

    // Merge the sorted subarrays.
    return merge(@sorted_left, @sorted_right);
}

/// Utility function to get the top n values from an array of card values.
///
/// @param values - The array of card values to get the top n values from.
/// @param n - The number of values to get.
/// @returns The top n values from the array.
/// Can panic?: No
fn get_top_n_values(values: @Array<EnumCardValue>, n: usize) -> Array<EnumCardValue> {
    let mut result: Array<EnumCardValue> = array![];
    let count = if values.len() < n {
        values.len()
    } else {
        n
    };

    for i in 0..count {
        result.append(*values[i]);
    };

    return result;
}

fn _merge_sort_players(arr: @Array<(ContractAddress, u32)>) -> Array<(ContractAddress, u32)> {
    let len = arr.len();
    if len <= 1 {
        return arr.clone();
    }

    let mid = len / 2;
    let mut left: Array<(ContractAddress, u32)> = array![];
    let mut right: Array<(ContractAddress, u32)> = array![];

    // Split array into left and right halves.
    for i in 0..mid {
        left.append(*arr[i]);
    };

    for i in mid..len {
        right.append(*arr[i]);
    };

    // Recursively sort both halves.
    left = _merge_sort_players(@left);
    right = _merge_sort_players(@right);

    // Merge the sorted halves.
    return _merge_players(@left, @right);
}

fn _merge_players(
    left: @Array<(ContractAddress, u32)>, right: @Array<(ContractAddress, u32)>
) -> Array<(ContractAddress, u32)> {
    let mut result: Array<(ContractAddress, u32)> = array![];
    let mut left_idx: usize = 0;
    let mut right_idx: usize = 0;
    let left_len = left.len();
    let right_len = right.len();

    // Merge while both arrays have elements.
    while left_idx < left_len && right_idx < right_len {
        let (_, left_bet) = *left[left_idx];
        let (_, right_bet) = *right[right_idx];

        if left_bet <= right_bet {
            result.append(*left[left_idx]);
            left_idx += 1;
        } else {
            result.append(*right[right_idx]);
            right_idx += 1;
        }
    };

    // Append remaining elements from left array.
    for i in left_idx..left_len {
        result.append(*left[i]);
    };

    // Append remaining elements from right array.
    for i in right_idx..right_len {
        result.append(*right[i]);
    };

    return result;
}
