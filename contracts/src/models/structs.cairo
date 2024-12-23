use dominion::models::enums::{EnumCardSuit, EnumCardValue};

#[derive(Drop, Serde, Clone, Debug, Introspect)]
struct StructCard {
    m_num_representation: u256,
}
