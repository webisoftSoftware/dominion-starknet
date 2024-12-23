use crate::models::structs::StructCard;

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumGameState {
    Shutdown,
    WaitingForPlayers,
    RoundStarted,
    DeckEncrypted,
    PreFlop,
    Flop,
    Turn,
    River,
    Showdown,
}

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumPlayerState {
    NotCreated,
    Waiting,
    Ready,
    Active,
    Folded,
    AllIn,
    Left,
    Revealed,
}

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumPosition {
    None,
    SmallBlind,
    BigBlind,
}

#[derive(Drop, Serde, Clone, Debug, PartialEq, Introspect)]
pub enum EnumHandRank {
    HighCard: Array<EnumCardValue>, // Store all 5 cards for high card comparison.
    Pair: EnumCardValue, // Just store the pair value.
    TwoPair: (EnumCardValue, EnumCardValue), // Store both pair values.
    ThreeOfAKind: EnumCardValue, // Just store the three of a kind value.
    Straight: EnumCardValue, // Store highest card to determine the whole straight, assuming cards are sorted.
    Flush: Array<EnumCardValue>, // Get all cards to compare one by one.
    FullHouse: (EnumCardValue, EnumCardValue), // Store three of a kind and pair values.
    FourOfAKind: EnumCardValue, // Just store the four of a kind value.
    StraightFlush: (), // No additional info needed, only one player can have this.
    RoyalFlush: (), // No additional info needed, only one player can have this.
}

#[derive(Drop, Serde, Copy, Debug, PartialEq, Introspect)]
pub enum EnumRankMask {
    None,
    Pair,
    TwoPair,
    ThreeOfAKind,
    Straight,
    Flush,
    FullHouse,
    FourOfAKind,
    StraightFlush,
    RoyalFlush
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
