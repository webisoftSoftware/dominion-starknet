use dominion::models::structs::StructCard;
use dominion::models::enums::{EnumCardValue, EnumCardSuit};
use dominion::models::traits::{StructCardEq, StructCardDisplay, ICard};
use dominion::models::utils::{sort, merge_sort, _merge_sort_players};

#[test]
fn test_sort_cards() {
    // Check identical arrays.
    let input_arr = array![
        ICard::new(EnumCardValue::Two, EnumCardSuit::Spades),
        ICard::new(EnumCardValue::Three, EnumCardSuit::Hearts),
        ICard::new(EnumCardValue::Four, EnumCardSuit::Diamonds),
        ICard::new(EnumCardValue::Five, EnumCardSuit::Clubs),
        ICard::new(EnumCardValue::Six, EnumCardSuit::Hearts)
    ];
    let sorted_arr = sort(@input_arr);
    assert_eq!(sorted_arr, input_arr);

    // Check ascending order.
    let input_arr = array![
        ICard::new(EnumCardValue::Five, EnumCardSuit::Spades),
        ICard::new(EnumCardValue::Four, EnumCardSuit::Hearts),
        ICard::new(EnumCardValue::Three, EnumCardSuit::Diamonds),
        ICard::new(EnumCardValue::Two, EnumCardSuit::Clubs),
        ICard::new(EnumCardValue::Ace, EnumCardSuit::Hearts)
    ];
    let expected_arr = array![
        ICard::new(EnumCardValue::Two, EnumCardSuit::Clubs),
        ICard::new(EnumCardValue::Three, EnumCardSuit::Diamonds),
        ICard::new(EnumCardValue::Four, EnumCardSuit::Hearts),
        ICard::new(EnumCardValue::Five, EnumCardSuit::Spades),
        ICard::new(EnumCardValue::Ace, EnumCardSuit::Hearts)
    ];
    let sorted_arr = sort(@input_arr);
    assert_eq!(sorted_arr, expected_arr);

    // Check mixed order.
    let input_arr = array![
        ICard::new(EnumCardValue::Five, EnumCardSuit::Spades),
        ICard::new(EnumCardValue::Four, EnumCardSuit::Hearts),
        ICard::new(EnumCardValue::Three, EnumCardSuit::Diamonds),
        ICard::new(EnumCardValue::Two, EnumCardSuit::Clubs),
        ICard::new(EnumCardValue::Ace, EnumCardSuit::Hearts)
    ];
    let expected_arr = array![
        ICard::new(EnumCardValue::Two, EnumCardSuit::Clubs),
        ICard::new(EnumCardValue::Three, EnumCardSuit::Diamonds),
        ICard::new(EnumCardValue::Four, EnumCardSuit::Hearts),
        ICard::new(EnumCardValue::Five, EnumCardSuit::Spades),
        ICard::new(EnumCardValue::Ace, EnumCardSuit::Hearts)
    ];
    let sorted_arr = sort(@input_arr);
    assert_eq!(sorted_arr, expected_arr);
}

#[test]
fn test_sort_bets() {
    let players = array![
        (starknet::contract_address_const::<1>(), 300),
        (starknet::contract_address_const::<2>(), 100),
        (starknet::contract_address_const::<3>(), 200)
    ];
    let expected_array = array![
        (starknet::contract_address_const::<2>(), 100),
        (starknet::contract_address_const::<3>(), 200),
        (starknet::contract_address_const::<1>(), 300)
    ];

    let new_array = _merge_sort_players(@players);
    assert_eq!(new_array, expected_array);
}
