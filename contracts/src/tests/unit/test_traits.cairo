use crate::models::enums::{
    EnumCardSuit, EnumCardValue, EnumHandRank, EnumPlayerState, EnumGameState, EnumPosition
};
use crate::models::traits::{
    EnumCardValueDisplay, EnumCardSuitDisplay, EnumHandRankDisplay, EnumPlayerStateDisplay,
    EnumGameStateDisplay, EnumHandRankInto, ComponentPlayerEq, ComponentTableEq,
    ComponentPlayerDisplay, EnumCardValueInto, ComponentTableDisplay, ComponentHandDisplay,
    StructCardDisplay, ComponentHandEq, StructCardEq, HandDefaultImpl, TableDefaultImpl,
    PlayerDefaultImpl
};
use crate::models::structs::{StructCard};
use crate::models::components::{ComponentHand, ComponentTable, ComponentPlayer};

#[test]
fn test_eq() {
    let card1: StructCard = StructCard { m_value: EnumCardValue::Two, m_suit: EnumCardSuit::Clubs };
    let card2: StructCard = StructCard { m_value: EnumCardValue::Two, m_suit: EnumCardSuit::Clubs };
    assert_eq!(card1, card2);

    let mut player1: ComponentPlayer = Default::default();
    let mut player2: ComponentPlayer = Default::default();
    player1.m_total_chips = 100;
    player2.m_total_chips = 100;
    assert_eq!(player1, player2);

    let table1: ComponentTable = Default::default();
    let table2: ComponentTable = Default::default();
    assert_eq!(table1, table2);

    let hand1: ComponentHand = Default::default();
    let hand2: ComponentHand = Default::default();
    assert_eq!(hand1, hand2);
}

#[test]
fn test_display() {
    assert_eq!(
        format!(
            "{}",
            ComponentPlayer {
                m_table_id: 0,
                m_owner: starknet::contract_address_const::<0x0>(),
                m_total_chips: 100,
                m_table_chips: 0,
                m_position: EnumPosition::None,
                m_state: EnumPlayerState::Active,
                m_current_bet: 0,
                m_is_created: false
            }
        ),
        "Player: 0\n\tTotal Chips: 100\n\tTable Chips: 0\n\tPosition: None\n\tState: Active\n\tCurrent Bet: 0\n\tIs Created: false"
    );
    assert_eq!(
        format!("{}", TableDefaultImpl::default()),
        "Table 0:\n\tPlayers:\n\tCurrent Turn Index: 0\n\tSmall Blind: 0\n\tBig Blind: 0\n\tMin Buy In: 0\n\tMax Buy In: 0\n\tPot: 0\n\tState: WaitingForPlayers\n\tLast Played: 0"
    );
    assert_eq!(format!("{}", HandDefaultImpl::default()), "Hand 0:\n\tCards:");
    assert_eq!(
        format!("{}", StructCard { m_value: EnumCardValue::Two, m_suit: EnumCardSuit::Clubs }),
        "Card: 2\n\tSuit: C"
    );
    assert_eq!(format!("{}", EnumHandRank::HighCard), "HighCard");
    assert_eq!(format!("{}", EnumCardSuit::Clubs), "C");
    assert_eq!(format!("{}", EnumCardValue::Two), "2");
    assert_eq!(format!("{}", EnumPlayerState::Active), "Active");
}

#[test]
fn test_into() {
    let high_card: u32 = EnumHandRank::HighCard.into();
    let two: u32 = EnumCardValue::Two.into();

    assert_eq!(high_card, 1);
    assert_eq!(two, 2);
}