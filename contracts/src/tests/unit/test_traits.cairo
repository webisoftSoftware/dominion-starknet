use crate::models::enums::{
    EnumCardSuit, EnumCardValue, EnumHandRank
};
use crate::models::traits::{
    EnumCardValueDisplay, EnumCardSuitDisplay, EnumHandRankDisplay, EnumPlayerStateDisplay,
    EnumTableStateDisplay, EnumHandRankSnapshotInto, ComponentPlayerEq, ComponentTableEq,
    ComponentPlayerDisplay, EnumCardValueInto, ComponentTableDisplay, ComponentHandDisplay,
    StructCardDisplay, ComponentHandEq, StructCardEq, HandDefaultImpl, TableDefaultImpl,
    PlayerDefaultImpl, ICard
};
use crate::models::structs::{StructCard};
use crate::models::components::{ComponentHand, ComponentTable, ComponentPlayer};

#[test]
fn test_eq() {
    let card1: StructCard = ICard::new(EnumCardValue::Two, EnumCardSuit::Clubs);
    let card2: StructCard = ICard::new(EnumCardValue::Two, EnumCardSuit::Clubs);
    assert_eq!(card1, card2);

    let mut player1: ComponentPlayer = Default::default();
    let mut player2: ComponentPlayer = Default::default();
    player1.m_table_chips = 100;
    player2.m_table_chips = 100;
    assert_eq!(player1, player2);

    let table1: ComponentTable = Default::default();
    let table2: ComponentTable = Default::default();
    assert_eq!(table1, table2);

    let hand1: ComponentHand = Default::default();
    let hand2: ComponentHand = Default::default();
    assert_eq!(hand1, hand2);
}

#[test]
fn test_into() {
    let high_card: u32 = (@EnumHandRank::HighCard(EnumCardValue::Ace)).into();
    let two: u32 = EnumCardValue::Two.into();

    assert_eq!(high_card, 1);
    assert_eq!(two, 2);
}
