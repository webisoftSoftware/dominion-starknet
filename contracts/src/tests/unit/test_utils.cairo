use dominion::models::enums::{EnumCardValue, EnumCardSuit};
use dominion::models::traits::{StructCardEq, StructCardDisplay, ICard};
use dominion::models::utils::{sort};

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
