use dominion::models::enums::{EnumCardSuit, EnumCardValue};

#[derive(Drop, Serde, Copy, Debug, Introspect)]
struct StructCard {
    m_value: EnumCardValue,
    m_suit: EnumCardSuit,
}
