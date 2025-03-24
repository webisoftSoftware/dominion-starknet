pub use starknet::ContractAddress;
use core::dict::{Felt252Dict};
use core::fmt::{Display, Formatter, Error};
use origami_random::deck::{DeckTrait};
use dominion::models::utils;
use dominion::models::structs::StructCard;
use dominion::models::enums::{
    EnumCardSuit, EnumCardValue, EnumTableState, EnumPlayerState, EnumPosition, EnumHandRank,
    EnumError, EnumRankMask, EnumStreetState
};
use dominion::models::components::{
    ComponentTable, ComponentPlayer, ComponentHand, ComponentSidepot, ComponentRound, ComponentStreet,
    ComponentProof, ComponentTableInfo, ComponentBank
};

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////// DISPLAY /////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

pub impl ComponentHandDisplay of Display<ComponentHand> {
    fn fmt(self: @ComponentHand, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("({},{})", self.m_cards[0], self.m_cards[1]);
        f.buffer.append(@str);
        Result::Ok(())
    }
}

pub impl ComponentPlayerDisplay of Display<ComponentPlayer> {
    fn fmt(self: @ComponentPlayer, ref f: Formatter) -> Result<(), Error> {
        let mut str: ByteArray = format!(
            "Player: {0:?}", *self.m_owner
        );

        str += format!("\n\tTable Chips: {0}", *self.m_table_chips);
        str += format!("\n\tPosition: {0}", *self.m_position);
        str += format!("\n\tState: {0}", *self.m_state);
        str += format!("\n\tCurrent Bet: {0}", *self.m_current_bet);
        str += format!("\n\tIs Created: {0}", *self.m_is_created);
        str += format!("\n\tIs Dealer: {0}", *self.m_is_dealer);

        f.buffer.append(@str);
        Result::Ok(())
    }
}

pub impl ComponentRoundDisplay of Display<ComponentRound> {
    fn fmt(self: @ComponentRound, ref f: Formatter) -> Result<(), Error> {
        let mut str: ByteArray = format!("Round {0}:\n\t", *self.m_round_id);
        str += format!("\n\tLast Raiser Index: {}", *self.m_last_raiser);
        str += format!("\n\tLast Raiser Address: {:?}", *self.m_last_raiser_addr);
        str += format!("\n\tLast Played Timestamp: {}", *self.m_last_played_ts);
        str += format!("\n\tCurrent Turn: {:?}", *self.m_current_turn);
        str += format!("\n\tCurrent Dealer: {}", *self.m_current_dealer);

        f.buffer.append(@str);
        Result::Ok(())
    }
}

pub impl ComponentTableInfoDisplay of Display<ComponentTableInfo> {
    fn fmt(self: @ComponentTableInfo, ref f: Formatter) -> Result<(), Error> {
        let mut str: ByteArray = format!("Table {0}:\n\t: ", *self.m_table_id);
        str += format!("\n\tSmall Blind: {}", *self.m_small_blind);
        str += format!("\n\tBig Blind: {}", *self.m_big_blind);
        str += format!("\n\tMin Buy In: {}", *self.m_min_buy_in);
        str += format!("\n\tMax Buy In: {}", *self.m_max_buy_in);
        str += format!("\n\tState: {}", *self.m_state);

        f.buffer.append(@str);
        Result::Ok(())
    }
}

pub impl ComponentTableDisplay of Display<ComponentTable> {
    fn fmt(self: @ComponentTable, ref f: Formatter) -> Result<(), Error> {
        let mut str: ByteArray = format!("Table {0}:\n\tPlayers: ", *self.m_table_id);

        for player in self.m_players.span() {
            str += format!(
                "{:?}, ", *player
            );
        };

        str += format!("\n\tCommunity Cards: ");
        for card in self.m_community_cards.span() {
            str += format!("{}, ", card.clone());
        };

        str += format!("\n\tNum Sidepots: {}", *self.m_num_sidepots);

        str += format!("\n\tPot: {}", *self.m_pot);

        f.buffer.append(@str);
        Result::Ok(())
    }
}

pub impl ComponentSidepotDisplay of Display<ComponentSidepot> {
    fn fmt(self: @ComponentSidepot, ref f: Formatter) -> Result<(), Error> {
        let mut str: ByteArray = format!("Sidepot: {}, Min Bet: {}, Amount: {}, Eligible Players: ",
         *self.m_sidepot_id, *self.m_min_bet, *self.m_amount);

        for player in self.m_eligible_players.span() {
            str += format!("{:?}, ", *player);
        };

        f.buffer.append(@str);
        Result::Ok(())
    }
}

pub impl EnumErrorDisplay of Display<EnumError> {
    fn fmt(self: @EnumError, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumError::InvalidCard => f.buffer.append(@"Invalid Card"),
            EnumError::InvalidHand => f.buffer.append(@"Invalid Hand"),
            EnumError::InvalidBoard => f.buffer.append(@"Invalid Board"),
        }
        Result::Ok(())
    }
}

pub impl EnumTableStateDisplay of Display<EnumTableState> {
    fn fmt(self: @EnumTableState, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumTableState::Shutdown => {
                let str: ByteArray = format!("Shutdown");
                f.buffer.append(@str);
            },
            EnumTableState::WaitingForPlayers => {
                let str: ByteArray = format!("WaitingForPlayers");
                f.buffer.append(@str);
            },
            EnumTableState::InProgress => {
                let str: ByteArray = format!("InProgress");
                f.buffer.append(@str);
            }
        };
        Result::Ok(())
    }
}

pub impl EnumPlayerStateDisplay of Display<EnumPlayerState> {
    fn fmt(self: @EnumPlayerState, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumPlayerState::NotCreated => f.buffer.append(@"NotCreated"),
            EnumPlayerState::Waiting => f.buffer.append(@"Waiting"),
            EnumPlayerState::Ready => f.buffer.append(@"Ready"),
            EnumPlayerState::Active => f.buffer.append(@"Active"),
            EnumPlayerState::Called => f.buffer.append(@"Called"),
            EnumPlayerState::Checked => f.buffer.append(@"Checked"),
            EnumPlayerState::Raised(amount) => f.buffer.append(@format!("Raised: {}", amount)),
            EnumPlayerState::Folded => f.buffer.append(@"Folded"),
            EnumPlayerState::AllIn => f.buffer.append(@"AllIn"),
            EnumPlayerState::Left => f.buffer.append(@"Left"),
            EnumPlayerState::Revealed => f.buffer.append(@"Revealed"),
        };
        Result::Ok(())
    }
}

pub impl EnumPositionDisplay of Display<EnumPosition> {
    fn fmt(self: @EnumPosition, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumPosition::SmallBlind => f.buffer.append(@"SmallBlind"),
            EnumPosition::BigBlind => f.buffer.append(@"BigBlind"),
            EnumPosition::None => f.buffer.append(@"None"),
        };
        Result::Ok(())
    }
}

pub impl EnumHandRankDisplay of Display<EnumHandRank> {
    fn fmt(self: @EnumHandRank, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumHandRank::None => f.buffer.append(@"None"),
            EnumHandRank::HighCard => f.buffer.append(@"HighCard"),
            EnumHandRank::Pair => f.buffer.append(@"Pair"),
            EnumHandRank::TwoPair => f.buffer.append(@"TwoPair"),
            EnumHandRank::ThreeOfAKind => f.buffer.append(@"ThreeOfAKind"),
            EnumHandRank::Straight => f.buffer.append(@"Straight"),
            EnumHandRank::Flush => f.buffer.append(@"Flush"),
            EnumHandRank::FullHouse => f.buffer.append(@"FullHouse"),
            EnumHandRank::FourOfAKind => f.buffer.append(@"FourOfAKind"),
            EnumHandRank::StraightFlush => f.buffer.append(@"StraightFlush"),
            EnumHandRank::RoyalFlush => f.buffer.append(@"RoyalFlush"),
        };
        Result::Ok(())
    }
}

pub impl EnumCardValueDisplay of Display<EnumCardValue> {
    fn fmt(self: @EnumCardValue, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumCardValue::Two => f.buffer.append(@"2"),
            EnumCardValue::Three => f.buffer.append(@"3"),
            EnumCardValue::Four => f.buffer.append(@"4"),
            EnumCardValue::Five => f.buffer.append(@"5"),
            EnumCardValue::Six => f.buffer.append(@"6"),
            EnumCardValue::Seven => f.buffer.append(@"7"),
            EnumCardValue::Eight => f.buffer.append(@"8"),
            EnumCardValue::Nine => f.buffer.append(@"9"),
            EnumCardValue::Ten => f.buffer.append(@"10"),
            EnumCardValue::Jack => f.buffer.append(@"J"),
            EnumCardValue::Queen => f.buffer.append(@"Q"),
            EnumCardValue::King => f.buffer.append(@"K"),
            EnumCardValue::Ace => f.buffer.append(@"A"),
        };
        Result::Ok(())
    }
}

pub impl EnumCardSuitDisplay of Display<EnumCardSuit> {
    fn fmt(self: @EnumCardSuit, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumCardSuit::Spades => f.buffer.append(@"S"),
            EnumCardSuit::Hearts => f.buffer.append(@"H"),
            EnumCardSuit::Diamonds => f.buffer.append(@"D"),
            EnumCardSuit::Clubs => f.buffer.append(@"C"),
        };
        Result::Ok(())
    }
}

pub impl StructCardDisplay of Display<StructCard> {
    fn fmt(self: @StructCard, ref f: Formatter) -> Result<(), Error> {
        let value: EnumCardValue = self.get_value().unwrap();
        let suit: EnumCardSuit = self.get_suit().unwrap();
        let str: ByteArray = format!("{}{}", value, suit);
        f.buffer.append(@str);
        Result::Ok(())
    }
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////// INTO ////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

pub impl EnumCardValueInto of Into<EnumCardValue, u32> {
    fn into(self: EnumCardValue) -> u32 {
        match self {
            EnumCardValue::Two => 2,
            EnumCardValue::Three => 3,
            EnumCardValue::Four => 4,
            EnumCardValue::Five => 5,
            EnumCardValue::Six => 6,
            EnumCardValue::Seven => 7,
            EnumCardValue::Eight => 8,
            EnumCardValue::Nine => 9,
            EnumCardValue::Ten => 10,
            EnumCardValue::Jack => 11,
            EnumCardValue::Queen => 12,
            EnumCardValue::King => 13,
            EnumCardValue::Ace => 14,
        }
    }
}

pub impl EnumCardValueSnapshotInto of Into<@EnumCardValue, u32> {
    fn into(self: @EnumCardValue) -> u32 {
        match self {
            EnumCardValue::Two => 2,
            EnumCardValue::Three => 3,
            EnumCardValue::Four => 4,
            EnumCardValue::Five => 5,
            EnumCardValue::Six => 6,
            EnumCardValue::Seven => 7,
            EnumCardValue::Eight => 8,
            EnumCardValue::Nine => 9,
            EnumCardValue::Ten => 10,
            EnumCardValue::Jack => 11,
            EnumCardValue::Queen => 12,
            EnumCardValue::King => 13,
            EnumCardValue::Ace => 14,
        }
    }
}

pub impl EnumCardSuitInto of Into<EnumCardSuit, u32> {
    fn into(self: EnumCardSuit) -> u32 {
        match self {
            EnumCardSuit::Spades => 1,
            EnumCardSuit::Hearts => 2,
            EnumCardSuit::Diamonds => 3,
            EnumCardSuit::Clubs => 4,
        }
    }
}

pub impl EnumCardSuitSnapshotInto of Into<@EnumCardSuit, u32> {
    fn into(self: @EnumCardSuit) -> u32 {
        match self {
            EnumCardSuit::Spades => 1,
            EnumCardSuit::Hearts => 2,
            EnumCardSuit::Diamonds => 3,
            EnumCardSuit::Clubs => 4,
        }
    }
}

pub impl EnumHandRankSnapshotInto of Into<@EnumHandRank, u32> {
    fn into(self: @EnumHandRank) -> u32 {
        match self {
            EnumHandRank::None => 0,
            EnumHandRank::HighCard(_) => 1,
            EnumHandRank::Pair(_) => 2,
            EnumHandRank::TwoPair((_, _)) => 3,
            EnumHandRank::ThreeOfAKind(_) => 4,
            EnumHandRank::Straight(_) => 5,
            EnumHandRank::Flush(_) => 6,
            EnumHandRank::FullHouse((_, _)) => 7,
            EnumHandRank::FourOfAKind(_) => 8,
            EnumHandRank::StraightFlush => 9,
            EnumHandRank::RoyalFlush => 10,
        }
    }
}

pub impl EnumHandRankSnapshotIntoMask of Into<@EnumHandRank, EnumRankMask> {
    fn into(self: @EnumHandRank) -> EnumRankMask {
        match self {
            EnumHandRank::None => EnumRankMask::None,
            EnumHandRank::HighCard(_) => EnumRankMask::None,
            EnumHandRank::Pair(_) => EnumRankMask::Pair,
            EnumHandRank::TwoPair((_, _)) => EnumRankMask::TwoPair,
            EnumHandRank::ThreeOfAKind(_) => EnumRankMask::ThreeOfAKind,
            EnumHandRank::Straight(_) => EnumRankMask::Straight,
            EnumHandRank::Flush(_) => EnumRankMask::Flush,
            EnumHandRank::FullHouse((_, _)) => EnumRankMask::FullHouse,
            EnumHandRank::FourOfAKind(_) => EnumRankMask::FourOfAKind,
            EnumHandRank::StraightFlush => EnumRankMask::StraightFlush,
            EnumHandRank::RoyalFlush => EnumRankMask::RoyalFlush,
        }
    }
}

pub impl EnumHandRankInto of Into<EnumHandRank, u32> {
    fn into(self: EnumHandRank) -> u32 {
        match self {
            EnumHandRank::None => 0,
            EnumHandRank::HighCard(_) => 1,
            EnumHandRank::Pair(_) => 2,
            EnumHandRank::TwoPair((_, _)) => 3,
            EnumHandRank::ThreeOfAKind(_) => 4,
            EnumHandRank::Straight(_) => 5,
            EnumHandRank::Flush(_) => 6,
            EnumHandRank::FullHouse((_, _)) => 7,
            EnumHandRank::FourOfAKind(_) => 8,
            EnumHandRank::StraightFlush => 9,
            EnumHandRank::RoyalFlush => 10,
        }
    }
}

pub impl EnumPlayerStateInto of Into<EnumPlayerState, ByteArray> {
    fn into(self: EnumPlayerState) -> ByteArray {
        match self {
            EnumPlayerState::NotCreated => "NotCreated",
            EnumPlayerState::Waiting => "Waiting",
            EnumPlayerState::Ready => "Ready",
            EnumPlayerState::Active => "Active",
            EnumPlayerState::Checked => "Checked",
            EnumPlayerState::Called => "Called",
            EnumPlayerState::Raised(amount) => format!("Raised {amount}"),
            EnumPlayerState::Folded => "Folded",
            EnumPlayerState::AllIn => "AllIn",
            EnumPlayerState::Left => "Left",
            EnumPlayerState::Revealed => "Revealed",
        }
    }
}

pub impl EnumPositionInto of Into<EnumPosition, ByteArray> {
    fn into(self: EnumPosition) -> ByteArray {
        match self {
            EnumPosition::None => "None",
            EnumPosition::SmallBlind => "SmallBlind",
            EnumPosition::BigBlind => "BigBlind",
        }
    }
}

pub impl EnumTableStateInto of Into<EnumTableState, ByteArray> {
    fn into(self: EnumTableState) -> ByteArray {
        match self {
            EnumTableState::Shutdown => "Shutdown",
            EnumTableState::WaitingForPlayers => "WaitingForPlayers",
            EnumTableState::InProgress => "InProgress"
        }
    }
}

pub impl EnumRankMaskSnapshotInto of Into<@EnumRankMask, u32> {
    fn into(self: @EnumRankMask) -> u32 {
        match self {
            EnumRankMask::None => 0,
            EnumRankMask::Pair => 9,
            EnumRankMask::TwoPair => 8,
            EnumRankMask::ThreeOfAKind => 7,
            EnumRankMask::Straight => 6,
            EnumRankMask::Flush => 5,
            EnumRankMask::FullHouse => 4,
            EnumRankMask::FourOfAKind => 3,
            EnumRankMask::StraightFlush => 2,
            EnumRankMask::RoyalFlush => 1,
        }
    }
}

pub impl EnumRankMaskInto of Into<EnumRankMask, u32> {
    fn into(self: EnumRankMask) -> u32 {
        match self {
            EnumRankMask::None => 10,
            EnumRankMask::Pair => 9,
            EnumRankMask::TwoPair => 8,
            EnumRankMask::ThreeOfAKind => 7,
            EnumRankMask::Straight => 6,
            EnumRankMask::Flush => 5,
            EnumRankMask::FullHouse => 4,
            EnumRankMask::FourOfAKind => 3,
            EnumRankMask::StraightFlush => 2,
            EnumRankMask::RoyalFlush => 1,
        }
    }
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
///////////////////////////// PARTIALORD ////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

pub impl EnumHandRankPartialOrd of PartialOrd<@EnumHandRank> {
    fn le(lhs: @EnumHandRank, rhs: @EnumHandRank) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value <= right_value
    }

    fn lt(lhs: @EnumHandRank, rhs: @EnumHandRank) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value < right_value
    }

    fn ge(lhs: @EnumHandRank, rhs: @EnumHandRank) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value >= right_value
    }

    fn gt(lhs: @EnumHandRank, rhs: @EnumHandRank) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value > right_value
    }
}

pub impl EnumRankMaskSnapshotPartialOrd of PartialOrd<@EnumRankMask> {
    fn le(lhs: @EnumRankMask, rhs: @EnumRankMask) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value <= right_value
    }

    fn lt(lhs: @EnumRankMask, rhs: @EnumRankMask) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value < right_value
    }

    fn ge(lhs: @EnumRankMask, rhs: @EnumRankMask) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value >= right_value
    }

    fn gt(lhs: @EnumRankMask, rhs: @EnumRankMask) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value > right_value
    }
}

pub impl EnumRankMaskPartialOrd of PartialOrd<EnumRankMask> {
    fn le(lhs: EnumRankMask, rhs: EnumRankMask) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value <= right_value
    }

    fn lt(lhs: EnumRankMask, rhs: EnumRankMask) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value < right_value
    }

    fn ge(lhs: EnumRankMask, rhs: EnumRankMask) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value >= right_value
    }

    fn gt(lhs: EnumRankMask, rhs: EnumRankMask) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value > right_value
    }
}

pub impl EnumCardValuePartialOrd of PartialOrd<EnumCardValue> {
    fn le(lhs: EnumCardValue, rhs: EnumCardValue) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value <= right_value
    }

    fn lt(lhs: EnumCardValue, rhs: EnumCardValue) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value < right_value
    }

    fn ge(lhs: EnumCardValue, rhs: EnumCardValue) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value >= right_value
    }

    fn gt(lhs: EnumCardValue, rhs: EnumCardValue) -> bool {
        let left_value: u32 = lhs.into();
        let right_value: u32 = rhs.into();
        left_value > right_value
    }
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////// PARTIALEQ ///////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

pub impl ComponentPlayerEq of PartialEq<ComponentPlayer> {
    fn eq(lhs: @ComponentPlayer, rhs: @ComponentPlayer) -> bool {
        *lhs.m_owner == *rhs.m_owner && *lhs.m_is_created == *rhs.m_is_created
    }
}

pub impl ComponentTableEq of PartialEq<ComponentTable> {
    fn eq(lhs: @ComponentTable, rhs: @ComponentTable) -> bool {
        *lhs.m_table_id == *rhs.m_table_id
    }
}

pub impl StructCardEq of PartialEq<StructCard> {
    fn eq(lhs: @StructCard, rhs: @StructCard) -> bool {
        lhs.m_num_representation == rhs.m_num_representation
    }
}

pub impl ComponentHandEq of PartialEq<ComponentHand> {
    fn eq(lhs: @ComponentHand, rhs: @ComponentHand) -> bool {
        let mut equal: bool = lhs.m_owner == rhs.m_owner;

        if !equal {
            return false;
        }

        for i in 0
            ..lhs.m_cards.len() {
                if lhs.m_cards[i] != rhs.m_cards[i] {
                    equal = false;
                    break;
                }
            };
        equal
    }
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////// TRAITS //////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

#[generate_trait]
pub impl CardImpl of ICard {
    fn new(value: EnumCardValue, suit: EnumCardSuit) -> StructCard {
        let value_as_u32: u32 = value.into();
        let suit_as_u32: u32 = suit.into();
        StructCard {
            m_num_representation: u256 { high: value_as_u32.into(), low: suit_as_u32.into() }
        }
    }

    fn get_value(self: @StructCard) -> Option<EnumCardValue> {
        // Get the 8 most significant bits.
        match *self.m_num_representation.high {
            0 => Option::None,
            1 => Option::Some(EnumCardValue::Ace),
            2 => Option::Some(EnumCardValue::Two),
            3 => Option::Some(EnumCardValue::Three),
            4 => Option::Some(EnumCardValue::Four),
            5 => Option::Some(EnumCardValue::Five),
            6 => Option::Some(EnumCardValue::Six),
            7 => Option::Some(EnumCardValue::Seven),
            8 => Option::Some(EnumCardValue::Eight),
            9 => Option::Some(EnumCardValue::Nine),
            10 => Option::Some(EnumCardValue::Ten),
            11 => Option::Some(EnumCardValue::Jack),
            12 => Option::Some(EnumCardValue::Queen),
            13 => Option::Some(EnumCardValue::King),
            14 => Option::Some(EnumCardValue::Ace),
            _ => Option::None,
        }
    }

    fn get_suit(self: @StructCard) -> Option<EnumCardSuit> {
        // Get the 8 least significant bits.
        match *self.m_num_representation.low {
            0 => Option::None,
            1 => Option::Some(EnumCardSuit::Spades),
            2 => Option::Some(EnumCardSuit::Hearts),
            3 => Option::Some(EnumCardSuit::Diamonds),
            4 => Option::Some(EnumCardSuit::Clubs),
            _ => Option::None,
        }
    }
}

#[generate_trait]
pub impl EnumRankMaskImpl of IEnumRankMask {
    fn increment_depth(ref self: EnumRankMask) {
        match @self {
            EnumRankMask::RoyalFlush => self = EnumRankMask::StraightFlush,
            EnumRankMask::StraightFlush => self = EnumRankMask::FourOfAKind,
            EnumRankMask::FourOfAKind => self = EnumRankMask::FullHouse,
            EnumRankMask::FullHouse => self = EnumRankMask::Flush,
            EnumRankMask::Flush => self = EnumRankMask::Straight,
            EnumRankMask::Straight => self = EnumRankMask::ThreeOfAKind,
            EnumRankMask::ThreeOfAKind => self = EnumRankMask::TwoPair,
            EnumRankMask::TwoPair => self = EnumRankMask::Pair,
            EnumRankMask::Pair => self = EnumRankMask::None,
            _ => self = EnumRankMask::None,
        }
    }
}

#[generate_trait]
pub impl HandImpl of IHand {
    fn new(id: u32, address: ContractAddress, commitment_hash: ByteArray) -> ComponentHand {
        let mut commitment_hash_num: Array<u32> = array![];
        for i in 0..8_u32 {
            commitment_hash_num.append(commitment_hash[i].into());
        };
        ComponentHand {
            m_table_id: id,
            m_owner: address,
            m_cards: array![],
            m_commitment_hash: commitment_hash_num
        }
    }

    fn add_card(ref self: ComponentHand, card: StructCard) {
        self.m_cards.append(card);
    }

    fn clear(ref self: ComponentHand) {
        self.m_cards = array![];
    }

    fn evaluate_hand(
        self: @ComponentHand, board: @Array<StructCard>, from_depth: EnumRankMask
    ) -> Result<EnumHandRank, EnumError> {
        // Combine both checks.
        if self.m_cards.len() != 2 || board.len() > 5 {
            return Result::Err(
                if self.m_cards.len() != 2 {
                    EnumError::InvalidHand
                } else {
                    EnumError::InvalidBoard
                }
            );
        }

        // Single pass to collect data to prevent having to call all check functions for i.e. a
        // simple pair.
        let all_cards = utils::concat_cards(self.m_cards, board);
        let mut value_counts: Felt252Dict<u8> = Default::default();
        let mut suit_counts: Felt252Dict<u8> = Default::default();
        let mut values: Array<EnumCardValue> = array![];

        // Track maximums during our single pass.
        let mut max_value_count: u8 = 0;
        let mut max_suit_count: u8 = 0;
        let mut pair_count: u8 = 0;

        for card in all_cards.span() {
            if let Option::Some(value) = card.get_value() {
                let value_count: u32 = (@value).into();
                let new_count = value_counts.get(value_count.into()) + 1;
                value_counts.insert(value_count.into(), new_count);
                if new_count > max_value_count {
                    max_value_count = new_count;
                }
                if new_count == 2 {
                    pair_count += 1;
                }
                values.append(value);
            }
            if let Option::Some(suit) = card.get_suit() {
                let suit_count: u32 = (@suit).into();
                let new_count = suit_counts.get(suit_count.into()) + 1;
                suit_counts.insert(suit_count.into(), new_count);
                if new_count > max_suit_count {
                    max_suit_count = new_count;
                }
            }
        };

        // Now we can use these counts to skip impossible hands.
        if max_suit_count >= 5 {
            if from_depth == EnumRankMask::RoyalFlush && self._has_royal_flush(board) {
                return Result::Ok(EnumHandRank::RoyalFlush);
            }
            if (from_depth <= EnumRankMask::StraightFlush)
                && self._has_straight_flush(board) {
                return Result::Ok(EnumHandRank::StraightFlush);
                }
        }

        if max_value_count == 4 && (from_depth <= EnumRankMask::FourOfAKind) {
            if let Option::Some(value) = self._has_four_of_a_kind(board) {
                return Result::Ok(EnumHandRank::FourOfAKind(value));
            }
        }

        if max_value_count == 3 && pair_count >= 1 && (from_depth <= EnumRankMask::FullHouse) {
            if let Option::Some((three, pair)) = self._has_full_house(board) {
                return Result::Ok(EnumHandRank::FullHouse((three, pair)));
            }
        }

        if max_suit_count >= 5 && (from_depth <= EnumRankMask::Flush) {
            if let Option::Some(values) = self._has_flush(board) {
                return Result::Ok(EnumHandRank::Flush(values));
            }
        }

        // Check for straight (can't easily rule this out from counts alone).
        if (from_depth <= EnumRankMask::Straight) {
            if let Option::Some(high_card) = self._has_straight(board) {
                return Result::Ok(EnumHandRank::Straight(high_card));
            }
        }

        if max_value_count >= 3 && (from_depth <= EnumRankMask::ThreeOfAKind) {
            if let Option::Some(value) = self._has_three_of_a_kind(board) {
                return Result::Ok(EnumHandRank::ThreeOfAKind(value));
            }
        }

        if pair_count >= 2 && (from_depth <= EnumRankMask::TwoPair) {
            if let Option::Some((high, low)) = self._has_two_pair(board) {
                return Result::Ok(EnumHandRank::TwoPair((high, low)));
            }
        }

        if pair_count >= 1 && from_depth <= EnumRankMask::Pair {
            if let Option::Some(value) = self._has_pair(board) {
                return Result::Ok(EnumHandRank::Pair(value));
            }
        }

        // If no other combination is found, check for high card.
        if let Option::Some(value) = self._has_high_card(board) {
            return Result::Ok(EnumHandRank::HighCard(value));
        }

        // We should never reach this point.
        return Result::Err(EnumError::InvalidHand);
    }

    fn _has_royal_flush(self: @ComponentHand, board: @Array<StructCard>) -> bool {
        // We can first check if we have a flush, and then check if it's royal.
        if let Option::Some(flush_values) = self._has_flush(board) {
            // Check if flush_values contains A,K,Q,J,10 in any order
            let mut has_ace = false;
            let mut has_king = false;
            let mut has_queen = false;
            let mut has_jack = false;
            let mut has_ten = false;

            for value in flush_values.span() {
                match value {
                    EnumCardValue::Ace => has_ace = true,
                    EnumCardValue::King => has_king = true,
                    EnumCardValue::Queen => has_queen = true,
                    EnumCardValue::Jack => has_jack = true,
                    EnumCardValue::Ten => has_ten = true,
                    _ => {}
                };
            };

            return has_ace && has_king && has_queen && has_jack && has_ten;
        }
        return false;
    }

    fn _has_straight_flush(self: @ComponentHand, board: @Array<StructCard>) -> bool {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):

        if self.m_cards.len() + board.len() < 5 {
            return false;
        }

        // First check if we have a flush.
        if let Option::Some(flush_values) = self._has_flush(board) {
            // Then check if those flush cards form a straight.
            if flush_values.len() >= 5 {
                let mut consecutive_count: u8 = 1;
                let mut prev_value: u32 = flush_values[0].into();

                for i in 1
                    ..flush_values
                        .len() {
                            let curr_value: u32 = flush_values[i].into();
                            if curr_value == prev_value + 1 {
                                consecutive_count += 1;
                                if consecutive_count >= 5 {
                                    break;
                                }
                            } else if curr_value != prev_value {
                                consecutive_count = 1;
                            }
                            prev_value = curr_value;
                        };

                if consecutive_count >= 5 {
                    return true;
                }
            }
        }

        return false;
    }

    fn _has_four_of_a_kind(
        self: @ComponentHand, board: @Array<StructCard>
    ) -> Option<EnumCardValue> {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):
        if self.m_cards.len() + board.len() < 4 {
            return Option::None;
        }

        // Concatenate all cards together.
        let all_cards: Array<StructCard> = utils::concat_cards(self.m_cards, board);
        let mut value_counts: Felt252Dict<u8> = Default::default();

        // Single pass to count values.
        for card in all_cards
            .span() {
                if let Option::Some(value) = card.get_value() {
                    let value_count: u32 = (@value).into();
                    value_counts
                        .insert(value_count.into(), value_counts.get(value_count.into()) + 1);
                    // Early return if we find four of a kind.
                    if value_counts.get(value_count.into()) == 4 {
                        break;
                    }
                }
            };

        let card_value: EnumCardValue = all_cards[0].get_value().expect('Cannot get first card');
        let value_count: u32 = (@card_value).into();
        if value_counts.get(value_count.into()) == 4 {
            return Option::Some(card_value);
        }

        return Option::None;
    }

    fn _has_full_house(
        self: @ComponentHand, board: @Array<StructCard>
    ) -> Option<(EnumCardValue, EnumCardValue)> {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):
        if self.m_cards.len() + board.len() < 5 {
            return Option::None;
        }

        let all_cards = utils::concat_cards(self.m_cards, board);
        let mut value_counts: Felt252Dict<u8> = utils::_count_values(@all_cards);
        
        // First find the highest three of a kind
        let mut three_of_a_kind: Option<EnumCardValue> = Option::None;
        let mut pair: Option<EnumCardValue> = Option::None;
        
        // First pass: find highest three of a kind
        for card in all_cards.span() {
            if let Option::Some(value) = card.get_value() {
                let value_count: u32 = (@value).into();
                if value_counts.get(value_count.into()) >= 3 {
                    match three_of_a_kind {
                        Option::Some(current_high) => {
                            if utils::compare_cards(@value, @current_high) == 2 {
                                three_of_a_kind = Option::Some(value);
                            }
                        },
                        Option::None => {
                            three_of_a_kind = Option::Some(value);
                        }
                    }
                }
            }
        };

        // If we found a three of a kind, look for the highest pair that's not the same value
        if let Option::Some(three_value) = three_of_a_kind {
            for card in all_cards.span() {
                if let Option::Some(value) = card.get_value() {
                    if value != three_value {  // Don't use the same cards
                        let value_count: u32 = (@value).into();
                        if value_counts.get(value_count.into()) >= 2 {
                            match pair {
                                Option::Some(current_pair) => {
                                    if utils::compare_cards(@value, @current_pair) == 2 {
                                        pair = Option::Some(value);
                                    }
                                },
                                Option::None => {
                                    pair = Option::Some(value);
                                }
                            }
                        }
                    }
                }
            };
        }

        // Return full house only if we found both three of a kind and a pair
        match (three_of_a_kind, pair) {
            (Option::Some(three), Option::Some(two)) => Option::Some((three, two)),
            (_, _) => Option::None,
        }
    }

    fn _has_flush(self: @ComponentHand, board: @Array<StructCard>) -> Option<Array<EnumCardValue>> {
        if self.m_cards.len() + board.len() < 5 {
            return Option::None;
        }

        let all_cards: Array<StructCard> = utils::concat_cards(self.m_cards, board);

        // Count cards of each suit and store their values
        let mut spades_values: Array<EnumCardValue> = array![];
        let mut hearts_values: Array<EnumCardValue> = array![];
        let mut diamonds_values: Array<EnumCardValue> = array![];
        let mut clubs_values: Array<EnumCardValue> = array![];

        // Group cards by suit
        for card in all_cards.span() {
            if let Option::Some(suit) = card.get_suit() {
                if let Option::Some(value) = card.get_value() {
                    match suit {
                        EnumCardSuit::Spades => spades_values.append(value),
                        EnumCardSuit::Hearts => hearts_values.append(value),
                        EnumCardSuit::Diamonds => diamonds_values.append(value),
                        EnumCardSuit::Clubs => clubs_values.append(value),
                    };
                }
            }
        };

        // Check which suit has 5 or more cards and return its top 5 values
        if spades_values.len() >= 5 {
            let sorted = utils::sort_values(@spades_values);
            return Option::Some(utils::get_top_n_values(@sorted, 5));
        }
        if hearts_values.len() >= 5 {
            let sorted = utils::sort_values(@hearts_values);
            return Option::Some(utils::get_top_n_values(@sorted, 5));
        }
        if diamonds_values.len() >= 5 {
            let sorted = utils::sort_values(@diamonds_values);
            return Option::Some(utils::get_top_n_values(@sorted, 5));
        }
        if clubs_values.len() >= 5 {
            let sorted = utils::sort_values(@clubs_values);
            return Option::Some(utils::get_top_n_values(@sorted, 5));
        }

        return Option::None;
    }

    fn _has_straight(self: @ComponentHand, board: @Array<StructCard>) -> Option<EnumCardValue> {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):
        if self.m_cards.len() + board.len() < 5 {
            return Option::None;
        }

        let all_cards: Array<StructCard> = utils::concat_cards(self.m_cards, board);
        let mut unique_values: Array<EnumCardValue> = array![];

        // First get unique values
        for card in all_cards.span() {
            if let Option::Some(value) = card.get_value() {
                if !utils::contains_value(@unique_values, @value) {
                    unique_values.append(value);
                }
            }
        };

        let sorted_unique_values: Array<EnumCardValue> = utils::sort_values(@unique_values);

        // Check for regular straight.
        let mut consecutive_count: u8 = 1;
        let mut prev_value: u32 = sorted_unique_values[0].into();
        let mut highest_value: EnumCardValue = *sorted_unique_values[0];

        for i in 1..sorted_unique_values.len() {
            let curr_value: u32 = sorted_unique_values[i].into();
            if curr_value == prev_value + 1 {
                consecutive_count += 1;
                if consecutive_count >= 5 {
                    highest_value = *sorted_unique_values[i];
                    break;
                }
            } else {
                consecutive_count = 1;
                highest_value = *sorted_unique_values[i];
            }
            prev_value = curr_value;
        };

        if consecutive_count >= 5 {
            return Option::Some(highest_value);
        }

        // Check for Ace-low straight.
        if utils::contains_value(@sorted_unique_values, @EnumCardValue::Ace)
            && utils::contains_value(@sorted_unique_values, @EnumCardValue::Two)
            && utils::contains_value(@sorted_unique_values, @EnumCardValue::Three)
            && utils::contains_value(@sorted_unique_values, @EnumCardValue::Four)
            && utils::contains_value(@sorted_unique_values, @EnumCardValue::Five) {
            return Option::Some(EnumCardValue::Five);
        }

        return Option::None;
    }

    fn _has_three_of_a_kind(
        self: @ComponentHand, board: @Array<StructCard>
    ) -> Option<EnumCardValue> {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):
        if self.m_cards.len() + board.len() < 3 {
            return Option::None;
        }

        let mut three_of_a_kind: Option<EnumCardValue> = Option::None;
        let mut first_value: EnumCardValue = self.m_cards[0].get_value().expect('Cannot get first card');

        // Check if hand is a pair and board has matching value
        if first_value == self.m_cards[1].get_value().expect('Cannot get second card') {
            for card in board
                .span() {
                    if let Option::Some(card_value) = card.get_value() {
                        if card_value == first_value {
                            three_of_a_kind = Option::Some(card_value);
                            break;
                        }
                    }
                };

            if three_of_a_kind.is_some() {
                return Option::Some(three_of_a_kind.unwrap());
            }
        }

        // Combine cards and sort
        let all_cards: Array<StructCard> = utils::concat_cards(self.m_cards, board);
        let sorted_cards: Array<StructCard> = utils::sort(@all_cards);
        let mut same_kind_count: u8 = 1;
        let mut prev_value: EnumCardValue = sorted_cards[0].get_value().expect('Cannot get first card');

        for card in 1..sorted_cards.len() {
            if let Option::Some(card_value) = sorted_cards[card].get_value() {
                if card_value == prev_value {
                    same_kind_count += 1;
                    if same_kind_count >= 3 {
                        three_of_a_kind = Option::Some(prev_value);
                        break;
                    }
                } else {
                    same_kind_count = 1;
                    prev_value = card_value;
                }
            }
        };

        return three_of_a_kind;
    }

    fn _has_two_pair(
        self: @ComponentHand, board: @Array<StructCard>
    ) -> Option<(EnumCardValue, EnumCardValue)> {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):
        if self.m_cards.len() + board.len() < 4 {
            return Option::None;
        }

        let all_cards: Array<StructCard> = utils::concat_cards(self.m_cards, board);
        let sorted_cards: Array<StructCard> = utils::sort(@all_cards);
        let mut prev_value: EnumCardValue = sorted_cards[0].get_value().expect('Cannot get first card');
        let mut first_pair_value: Option<EnumCardValue> = Option::None;
        let mut second_pair_value: Option<EnumCardValue> = Option::None;

        for i in 1..sorted_cards.len() {
            if let Option::Some(card_value) = sorted_cards[i].get_value() {
                if card_value == prev_value {
                    if first_pair_value.is_none() {
                        first_pair_value = Option::Some(prev_value);
                        continue;
                    }
                    if second_pair_value.is_none()
                        && first_pair_value.unwrap() != prev_value {
                        second_pair_value = Option::Some(prev_value);
                        continue;
                    }
                }

                prev_value = card_value;
                if first_pair_value.is_some() && second_pair_value.is_some() {
                    break;
                }
            }
        };

        if first_pair_value.is_none() || second_pair_value.is_none() {
            return Option::None;
        }

        return Option::Some((first_pair_value.unwrap(), second_pair_value.unwrap()));
    }

    fn _has_pair(self: @ComponentHand, board: @Array<StructCard>) -> Option<EnumCardValue> {
        // TODO: Implement the non-naive approach.

        // NAIVE APPROACH (ASSUMING THAT THE CARDS IN HAND ARE SORTED):

        // Check if the hand itself is a pair.
        if self.m_cards.len() + board.len() < 2 {
            return Option::None;
        }

        let all_cards = utils::concat_cards(self.m_cards, board);
        let mut value_counts: Felt252Dict<u8> = utils::_count_values(@all_cards);
        let mut pairs: Array<EnumCardValue> = array![];

        // Get all possible pairs.
        for card in all_cards.span() {
            if let Option::Some(value) = card.get_value() {
                let value_count: u32 = (@value).into();
                if value_counts.get(value_count.into()) == 2 && !utils::contains_value(@pairs, @value) {
                    pairs.append(value);
                }
            }
        };

        if pairs.len() >= 2 {
            // Get highest pair.
            let sorted_pairs = utils::sort_values(@pairs);
            return Option::Some(sorted_pairs[sorted_pairs.len() - 1].clone());
        } else if pairs.len() == 1 {
            return Option::Some(pairs[0].clone());
        }

        return Option::None;
    }

    fn _has_high_card(self: @ComponentHand, board: @Array<StructCard>) -> Option<EnumCardValue> {
        let hand_sorted = utils::sort(self.m_cards);

        let mut copy_found: bool = false;
        let mut highest_unique_card: Option<EnumCardValue> = Option::None;

        for i in 0..hand_sorted.len() {
            let value = hand_sorted[i].get_value().unwrap();
            for j in 0..board.len() {
                if let Option::Some(board_value) = board[j].get_value() {
                    if board_value == value {
                        copy_found = true;
                        break;
                    }
                }
            };
            if !copy_found {
                highest_unique_card = Option::Some(value);
            }
        };

        return highest_unique_card;
    }
}

#[generate_trait]
pub impl PlayerImpl of IPlayer {
    fn new(table_id: u32, owner: ContractAddress) -> ComponentPlayer {
        ComponentPlayer {
            m_table_id: table_id,
            m_owner: owner,
            m_table_chips: 0,
            m_position: EnumPosition::None,
            m_state: EnumPlayerState::Waiting,
            m_current_bet: 0,
            m_is_created: true,
            m_is_dealer: false,
            m_auth_hash: ""
        }
    }

    fn set_ready(ref self: ComponentPlayer) {
        assert!(self.m_state != EnumPlayerState::NotCreated, "Player is not created");
        assert!(self.m_state == EnumPlayerState::Waiting, "Player is not waiting");

        self.m_state = EnumPlayerState::Ready;
    }

    fn place_bet(ref self: ComponentPlayer, added_amount: u32) -> u32 {
        assert!(self.m_state != EnumPlayerState::NotCreated, "Player is not created");
        assert!(self.m_table_chips >= added_amount, "Insufficient chips");

        if self.m_table_chips == added_amount {
            self.m_state = EnumPlayerState::AllIn;
            self.m_current_bet += self.m_table_chips;
            self.m_table_chips = 0;
            return self.m_current_bet;
        }
        
        self.m_table_chips -= added_amount;
        self.m_current_bet += added_amount;
        return added_amount;
    }

    fn fold(ref self: ComponentPlayer) -> u32 {
        assert!(self.m_state != EnumPlayerState::NotCreated, "Player is not created");

        self.m_state = EnumPlayerState::Folded;
        let player_bet: u32 = self.m_current_bet;
        self.m_current_bet = 0;
        return player_bet;
    }

    fn _is_created(self: @ComponentPlayer) -> bool {
        return *self.m_is_created;
    }
}

#[generate_trait]
pub impl SidepotImpl of ISidepot {
    fn new(
        table_id: u32, sidepot_id: u8, amount: u32, eligible_players: Array<ContractAddress>, min_bet: u32
    ) -> ComponentSidepot nopanic {
        return ComponentSidepot {
            m_table_id: table_id,
            m_sidepot_id: sidepot_id,
            m_amount: amount,
            m_eligible_players: eligible_players,
            m_min_bet: min_bet,
        };
    }

    fn contains_player(self: @ComponentSidepot, player: @ContractAddress) -> bool {
        return self.find_player(player).is_some();
    }

    fn find_player(self: @ComponentSidepot, player: @ContractAddress) -> Option<usize> {
        return utils::position_player(self.m_eligible_players, player);
    }
}

#[generate_trait]
pub impl TableImpl of ITable {
    fn new(
        id: u32,
        players: Array<ContractAddress>
    ) -> ComponentTable {
        assert!(players.len() <= 6, "Maximum 6 players allowed");

        let mut table = ComponentTable {
            m_table_id: id,
            m_deck: array![],
            m_community_cards: array![],
            m_players: players,
            m_pot: 0,
            m_num_sidepots: 0,
            m_current_round: 0,
        };
        
        table._initialize_deck();
        return table;
    }

    fn shuffle_deck(ref self: ComponentTable, seed: felt252) {
        let mut shuffled_deck: Array<StructCard> = array![];
        let mut deck = DeckTrait::new(seed, self.m_deck.len());

        while deck.remaining > 0 {
            // Draw a random number from 0 to 52.
            let card_index: u8 = deck.draw();

            // Avoid going out of bounds since the second param for DeckTrait is inclusive.
            if card_index != 0 {
                if let Option::Some(_) = self.m_deck.get(card_index.into() - 1) {
                    shuffled_deck.append(self.m_deck[card_index.into() - 1].clone());
                }
                continue;
            }

            if let Option::Some(_) = self.m_deck.get(card_index.into()) {
                shuffled_deck.append(self.m_deck[card_index.into()].clone());
            }
        };
        self.m_deck = shuffled_deck;
    }

    fn contains_player(self: @ComponentTable, player: @ContractAddress) -> bool {
        return self.find_player(player).is_some();
    }

    fn find_player(self: @ComponentTable, player: @ContractAddress) -> Option<usize> {
        return utils::position_player(self.m_players, player);
    }

    fn remove_player(ref self: ComponentTable, player: @ContractAddress) {
        let player_position: Option<usize> = self.find_player(player);
        assert!(player_position.is_some(), "Cannot find player");

        let removed_player_position: usize = player_position.unwrap();
        let mut new_players: Array<ContractAddress> = array![];
        // Set the player to 0 to indicate empty seat.
        for i in 0..self.m_players.len() {
            if i != removed_player_position {
                new_players.append(self.m_players[i].clone());
            }
        };
        self.m_players = new_players;
    }

    fn add_to_pot(ref self: ComponentTable, amount: u32) {
        self.m_pot += amount;
    }

    fn reset_table(ref self: ComponentTable) {
        self.m_pot = 0;
        self.m_deck = array![];
        self.m_community_cards = array![];
        self.m_num_sidepots = 0;
        self.m_current_round += 1;
    }

    fn _initialize_deck(ref self: ComponentTable) {
        // Initialize a standard 52-card deck
        self.m_deck = array![];

        // Add cards for each suit and value
        let suits = array![
            EnumCardSuit::Spades, EnumCardSuit::Hearts, EnumCardSuit::Diamonds, EnumCardSuit::Clubs
        ];

        let values = array![
            EnumCardValue::Two,
            EnumCardValue::Three,
            EnumCardValue::Four,
            EnumCardValue::Five,
            EnumCardValue::Six,
            EnumCardValue::Seven,
            EnumCardValue::Eight,
            EnumCardValue::Nine,
            EnumCardValue::Ten,
            EnumCardValue::Jack,
            EnumCardValue::Queen,
            EnumCardValue::King,
            EnumCardValue::Ace
        ];

        // Initialize the deck with 52 cards.
        let mut suit_index: u32 = 0;
        let mut value_index: u32 = 0;

        for _ in 0
            ..52_u32 {
                self.m_deck.append(ICard::new(*values[value_index], *suits[suit_index]));

                // Check if we've created every value for the current suit.
                value_index += 1;
                value_index = value_index % 13;
                if value_index == 0 {
                    suit_index += 1;
                }
            };

        assert!(self.m_deck.len() == 52, "Deck should have contained 52 cards");
    }
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////// DEFAULT /////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

pub impl HandDefaultImpl of Default<ComponentHand> {
    fn default() -> ComponentHand {
        return ComponentHand {
            m_table_id: 0,
            m_owner: starknet::contract_address_const::<0x0>(),
            m_cards: array![],
            m_commitment_hash: array![],
        };
    }
}

pub impl PlayerDefaultImpl of Default<ComponentPlayer> {
    fn default() -> ComponentPlayer {
        return ComponentPlayer {
            m_table_id: 0,
            m_owner: starknet::contract_address_const::<0x0>(),
            m_table_chips: 0,
            m_position: EnumPosition::None,
            m_state: EnumPlayerState::Waiting,
            m_current_bet: 0,
            m_is_created: false,
            m_is_dealer: false,
            m_auth_hash: ""
        };
    }
}

pub impl TableDefaultImpl of Default<ComponentTable> {
    fn default() -> ComponentTable {
        return ComponentTable {
            m_table_id: 0,
            m_current_round: 0,
            m_deck: array![],
            m_community_cards: array![],
            m_players: array![],
            m_pot: 0,
            m_num_sidepots: 0,
        };
    }
}

#[generate_trait]
pub impl RoundImpl of IRound {
    fn new(
        table_id: u32, 
        round_id: u32, 
        current_dealer: u8,
        current_turn: ContractAddress,
    ) -> ComponentRound {
        // Current dealer must be a valid player index (0-5 for 6 max tables)
        assert!(current_dealer <= 5, "Invalid dealer index");
        // Current turn address cannot be zero
        assert!(current_turn != starknet::contract_address_const::<0x0>(), "Invalid turn address");

        ComponentRound {
            m_table_id: table_id,
            m_round_id: round_id,
            m_last_raiser: 0, // Initialize to 0 as no raises yet
            m_last_raiser_addr: starknet::contract_address_const::<0x0>(), // Initialize to 0 as no raises yet
            m_highest_raise: 0,
            m_last_played_ts: starknet::get_block_timestamp(),
            m_current_turn: current_turn,
            m_current_dealer: current_dealer,
        }
    }

    fn reset(ref self: ComponentRound) {
        self.m_last_raiser = 0;
        self.m_highest_raise = 0;
        self.m_last_played_ts = 0;
        self.m_current_dealer = 0;
    }

    fn check_turn(self: @ComponentRound, player: @ContractAddress) -> bool {
        return self.m_current_turn == player;
    }

    fn advance_turn(
        ref self: ComponentRound, 
        players: @Array<ContractAddress>,
        players_folded: Array<EnumPlayerState>
    ) {
        assert!(!players.is_empty(), "Cannot advance turn with no players");

        // Find next valid player
        let current_index = utils::position_player(players, @self.m_current_turn).unwrap_or(0);
        let mut next_index = (current_index + 1) % players.len();

        if players_folded.is_empty() {
            self.m_current_turn = *players[next_index];
            self.m_last_played_ts = starknet::get_block_timestamp();
            return;
        }

        while next_index != current_index {
            if players_folded.get(next_index).is_some() {
                next_index = (next_index + 1) % players.len();
                continue;
            }

            if let Option::Some(next_player) = players.get(next_index) {
                self.m_current_turn = *next_player.unbox();
                break;
            }
        };

        self.m_last_played_ts = starknet::get_block_timestamp();
    }
}

#[generate_trait]
pub impl StreetImpl of IStreet {
    fn new(table_id: u32, round_id: u32) -> ComponentStreet {
        ComponentStreet {
            m_table_id: table_id,
            m_round_id: round_id,
            m_state: EnumStreetState::PreFlop, // Always starts at preflop
            m_finished_street: false,
        }
    }

    fn advance_street(ref self: ComponentStreet) {
        self.m_state = match self.m_state {
            EnumStreetState::PreFlop => EnumStreetState::Flop,
            EnumStreetState::Flop => EnumStreetState::Turn,
            EnumStreetState::Turn => EnumStreetState::River,
            EnumStreetState::River => EnumStreetState::Showdown,
            EnumStreetState::Showdown => EnumStreetState::PreFlop,
        };
        self.m_finished_street = false;
    }
}

#[generate_trait]
pub impl ProofImpl of IProof {
    fn new(
        table_id: u32, 
        shuffle_proof: ByteArray,
        deck_proof: ByteArray
    ) -> ComponentProof {
        // Proofs cannot be empty
        assert!(shuffle_proof != "", "Empty shuffle proof");
        assert!(deck_proof != "", "Empty deck proof");

        ComponentProof {
            m_table_id: table_id,
            m_shuffle_proof: shuffle_proof,
            m_deck_proof: deck_proof,
            m_encrypted_deck_posted: false
        }
    }

    fn reset(ref self: ComponentProof) {
        self.m_deck_proof = "";
        self.m_shuffle_proof = "";
        self.m_encrypted_deck_posted = false;
    }

    fn is_deck_encrypted(self: @ComponentProof) -> bool {
        return self.m_deck_proof != @"" && self.m_shuffle_proof != @"" && *self.m_encrypted_deck_posted;
    }
}

#[generate_trait]
pub impl TableInfoImpl of ITableInfo {
    fn new(
        table_id: u32,
        small_blind: u32,
        big_blind: u32,
        min_buy_in: u32,
        max_buy_in: u32,
    ) -> ComponentTableInfo {
        // Validate blinds and buy-in amounts
        assert!(big_blind > small_blind, "Big blind must be greater than small blind");
        assert!(min_buy_in >= big_blind * 10, "Min buy-in must be at least 10x big blind");
        assert!(max_buy_in > min_buy_in, "Max buy-in must be greater than min buy-in");
        assert!(max_buy_in <= big_blind * 100, "Max buy-in cannot exceed 100x big blind");

        ComponentTableInfo {
            m_table_id: table_id,
            m_small_blind: small_blind,
            m_big_blind: big_blind,
            m_min_buy_in: min_buy_in,
            m_max_buy_in: max_buy_in,
            m_state: EnumTableState::WaitingForPlayers
        }
    }

    fn increase_blinds(ref self: ComponentTableInfo, multiplier: u32) {
        self.m_small_blind *= multiplier;
        self.m_big_blind *= multiplier;
    }

    fn get_blind_amount(self: @ComponentTableInfo, position: @EnumPosition) -> u32 {
        match position {
            EnumPosition::SmallBlind => *self.m_small_blind,
            EnumPosition::BigBlind => *self.m_big_blind,
            _ => 0,
        }
    }
}

#[generate_trait]
pub impl BankImpl of IBank {
    fn new(owner: ContractAddress) -> ComponentBank {
        ComponentBank {
            m_owner: owner,
            m_balance: 0,
        }
    }

    fn deposit(ref self: ComponentBank, amount: u32) {
        self.m_balance += amount;
    }

    fn withdraw(ref self: ComponentBank, amount: u32) {
        assert!(self.m_balance >= amount, "Insufficient balance");
        self.m_balance -= amount;
    }

    fn transfer(ref self: ComponentBank, ref recipient: ComponentBank, amount: u32) {
        assert!(self.m_balance >= amount, "Insufficient balance");
        self.m_balance -= amount;
        recipient.m_balance += amount;
    }
}

pub impl BankDefaultImpl of Default<ComponentBank> {
    fn default() -> ComponentBank {
        return ComponentBank {
            m_owner: starknet::contract_address_const::<0x0>(),
            m_balance: 0,
        };
    }
}
