use crate::models::enums::{EnumCardSuit, EnumCardValue};
use crate::models::traits::{ICard, EnumCardValueInto, EnumCardSuitInto};

#[test]
fn test_encrypt() {
    let card = ICard::new(EnumCardValue::Queen, EnumCardSuit::Hearts);
    let expected_card_value: u32 = EnumCardValue::Queen.into();
    let expected_card_suit: u32 = EnumCardSuit::Hearts.into();
    let expected_num_representation: u256 = u256 {
        low: expected_card_suit.into(), high: expected_card_value.into(),
    };

    assert!(card.m_num_representation == expected_num_representation);
}


#[test]
fn test_decrypt() {
    let card = ICard::new(EnumCardValue::Ace, EnumCardSuit::Spades);

    assert!(card.get_value().unwrap() == EnumCardValue::Ace);
    assert!(card.get_suit().unwrap() == EnumCardSuit::Spades);
}
