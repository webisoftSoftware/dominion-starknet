use crate::models::structs::StructCard;

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumGameState {
    WaitingForPlayers,
    PreFlop,
    Flop,
    Turn,
    River,
    Showdown,
}

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumPlayerState {
    Waiting,
    Ready,
    Active,
    Folded,
    AllIn,
    Left,
}

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumPosition {
    SmallBlind,
    BigBlind,
    Dealer,
    None,
}

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumHandRank {
    HighCard,
    Pair,
    TwoPair,
    ThreeOfAKind,
    Straight,
    Flush,
    FullHouse,
    FourOfAKind,
    StraightFlush,
    RoyalFlush,
}

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumCardValue {
    Two,
    Three,
    Four,
    Five,
    Six,
    Seven,
    Eight,
    Nine,
    Ten,
    Jack,
    Queen,
    King,
    Ace
}

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumCardSuit {
    Spades,
    Hearts,
    Diamonds,
    Clubs,
}

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumError {
    InvalidCard,
    InvalidHand,
    InvalidBoard,
}
