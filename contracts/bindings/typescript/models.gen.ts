import type { SchemaType as ISchemaType } from "@dojoengine/sdk";

import { CairoCustomEnum, BigNumberish } from 'starknet';

// Type definition for `dominion::models::components::ComponentBank` struct
export interface ComponentBank {
	m_owner: string;
	m_balance: BigNumberish;
}

// Type definition for `dominion::models::components::ComponentBankValue` struct
export interface ComponentBankValue {
	m_balance: BigNumberish;
}

// Type definition for `dominion::models::components::ComponentHand` struct
export interface ComponentHand {
	m_table_id: BigNumberish;
	m_owner: string;
	m_cards: Array<StructCard>;
	m_commitment_hash: Array<BigNumberish>;
}

// Type definition for `dominion::models::components::ComponentHandValue` struct
export interface ComponentHandValue {
	m_cards: Array<StructCard>;
	m_commitment_hash: Array<BigNumberish>;
}

// Type definition for `dominion::models::components::ComponentOriginalDeck` struct
export interface ComponentOriginalDeck {
	m_table_id: BigNumberish;
	m_deck: Array<StructCard>;
}

// Type definition for `dominion::models::components::ComponentOriginalDeckValue` struct
export interface ComponentOriginalDeckValue {
	m_deck: Array<StructCard>;
}

// Type definition for `dominion::models::components::ComponentPlayer` struct
export interface ComponentPlayer {
	m_table_id: BigNumberish;
	m_owner: string;
	m_table_chips: BigNumberish;
	m_position: EnumPositionEnum;
	m_state: EnumPlayerStateEnum;
	m_current_bet: BigNumberish;
	m_is_created: boolean;
	m_auth_hash: string;
	m_is_dealer: boolean;
}

// Type definition for `dominion::models::components::ComponentPlayerValue` struct
export interface ComponentPlayerValue {
	m_table_chips: BigNumberish;
	m_position: EnumPositionEnum;
	m_state: EnumPlayerStateEnum;
	m_current_bet: BigNumberish;
	m_is_created: boolean;
	m_auth_hash: string;
	m_is_dealer: boolean;
}

// Type definition for `dominion::models::components::ComponentProof` struct
export interface ComponentProof {
	m_table_id: BigNumberish;
	m_shuffle_proof: string;
	m_deck_proof: string;
	m_encrypted_deck_posted: boolean;
}

// Type definition for `dominion::models::components::ComponentProofValue` struct
export interface ComponentProofValue {
	m_shuffle_proof: string;
	m_deck_proof: string;
	m_encrypted_deck_posted: boolean;
}

// Type definition for `dominion::models::components::ComponentRake` struct
export interface ComponentRake {
	m_table_id: BigNumberish;
	m_rake_address: string;
	m_rake_fee: BigNumberish;
	m_chip_amount: BigNumberish;
}

// Type definition for `dominion::models::components::ComponentRakeValue` struct
export interface ComponentRakeValue {
	m_rake_address: string;
	m_rake_fee: BigNumberish;
	m_chip_amount: BigNumberish;
}

// Type definition for `dominion::models::components::ComponentRound` struct
export interface ComponentRound {
	m_table_id: BigNumberish;
	m_round_id: BigNumberish;
	m_last_raiser: BigNumberish;
	m_last_raiser_addr: string;
	m_highest_raise: BigNumberish;
	m_last_played_ts: BigNumberish;
	m_current_turn: string;
	m_current_dealer: BigNumberish;
}

// Type definition for `dominion::models::components::ComponentRoundValue` struct
export interface ComponentRoundValue {
	m_last_raiser: BigNumberish;
	m_last_raiser_addr: string;
	m_highest_raise: BigNumberish;
	m_last_played_ts: BigNumberish;
	m_current_turn: string;
	m_current_dealer: BigNumberish;
}

// Type definition for `dominion::models::components::ComponentSidepot` struct
export interface ComponentSidepot {
	m_table_id: BigNumberish;
	m_sidepot_id: BigNumberish;
	m_min_bet: BigNumberish;
	m_amount: BigNumberish;
	m_eligible_players: Array<string>;
}

// Type definition for `dominion::models::components::ComponentSidepotValue` struct
export interface ComponentSidepotValue {
	m_min_bet: BigNumberish;
	m_amount: BigNumberish;
	m_eligible_players: Array<string>;
}

// Type definition for `dominion::models::components::ComponentStreet` struct
export interface ComponentStreet {
	m_table_id: BigNumberish;
	m_round_id: BigNumberish;
	m_state: EnumStreetStateEnum;
	m_finished_street: boolean;
}

// Type definition for `dominion::models::components::ComponentStreetValue` struct
export interface ComponentStreetValue {
	m_state: EnumStreetStateEnum;
	m_finished_street: boolean;
}

// Type definition for `dominion::models::components::ComponentTable` struct
export interface ComponentTable {
	m_table_id: BigNumberish;
	m_deck: Array<StructCard>;
	m_community_cards: Array<StructCard>;
	m_players: Array<string>;
	m_pot: BigNumberish;
	m_num_sidepots: BigNumberish;
	m_current_round: BigNumberish;
}

// Type definition for `dominion::models::components::ComponentTableInfo` struct
export interface ComponentTableInfo {
	m_table_id: BigNumberish;
	m_small_blind: BigNumberish;
	m_big_blind: BigNumberish;
	m_min_buy_in: BigNumberish;
	m_max_buy_in: BigNumberish;
	m_state: EnumTableStateEnum;
}

// Type definition for `dominion::models::components::ComponentTableInfoValue` struct
export interface ComponentTableInfoValue {
	m_small_blind: BigNumberish;
	m_big_blind: BigNumberish;
	m_min_buy_in: BigNumberish;
	m_max_buy_in: BigNumberish;
	m_state: EnumTableStateEnum;
}

// Type definition for `dominion::models::components::ComponentTableValue` struct
export interface ComponentTableValue {
	m_deck: Array<StructCard>;
	m_community_cards: Array<StructCard>;
	m_players: Array<string>;
	m_pot: BigNumberish;
	m_num_sidepots: BigNumberish;
	m_current_round: BigNumberish;
}

// Type definition for `dominion::models::components::ComponentWinners` struct
export interface ComponentWinners {
	m_table_id: BigNumberish;
	m_round_id: BigNumberish;
	m_winners: Array<string>;
	m_hands: Array<EnumHandRankEnum>;
	m_amounts: Array<BigNumberish>;
}

// Type definition for `dominion::models::components::ComponentWinnersValue` struct
export interface ComponentWinnersValue {
	m_winners: Array<string>;
	m_hands: Array<EnumHandRankEnum>;
	m_amounts: Array<BigNumberish>;
}

// Type definition for `dominion::models::structs::StructCard` struct
export interface StructCard {
	m_num_representation: BigNumberish;
}

// Type definition for `dominion::systems::actions::actions_system::EventAllPlayersReady` struct
export interface EventAllPlayersReady {
	m_table_id: BigNumberish;
	m_players: Array<string>;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::actions::actions_system::EventAllPlayersReadyValue` struct
export interface EventAllPlayersReadyValue {
	m_players: Array<string>;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::actions::actions_system::EventAuthHashRequested` struct
export interface EventAuthHashRequested {
	m_table_id: BigNumberish;
	m_player: string;
	m_auth_hash: string;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::actions::actions_system::EventAuthHashRequestedValue` struct
export interface EventAuthHashRequestedValue {
	m_auth_hash: string;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::actions::actions_system::EventHandRevealed` struct
export interface EventHandRevealed {
	m_table_id: BigNumberish;
	m_player: string;
	m_request: string;
	m_player_hand: Array<StructCard>;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::actions::actions_system::EventHandRevealedValue` struct
export interface EventHandRevealedValue {
	m_request: string;
	m_player_hand: Array<StructCard>;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::actions::actions_system::EventPlayerJoined` struct
export interface EventPlayerJoined {
	m_table_id: BigNumberish;
	m_player: string;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::actions::actions_system::EventPlayerJoinedValue` struct
export interface EventPlayerJoinedValue {
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::actions::actions_system::EventPlayerLeft` struct
export interface EventPlayerLeft {
	m_table_id: BigNumberish;
	m_player: string;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::actions::actions_system::EventPlayerLeftValue` struct
export interface EventPlayerLeftValue {
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::actions::actions_system::EventRequestBet` struct
export interface EventRequestBet {
	m_table_id: BigNumberish;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::actions::actions_system::EventRequestBetValue` struct
export interface EventRequestBetValue {
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::actions::actions_system::EventRevealShowdownRequested` struct
export interface EventRevealShowdownRequested {
	m_table_id: BigNumberish;
	m_player: string;
	m_hand: Array<StructCard>;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::actions::actions_system::EventRevealShowdownRequestedValue` struct
export interface EventRevealShowdownRequestedValue {
	m_hand: Array<StructCard>;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::actions::actions_system::EventShowdownRequested` struct
export interface EventShowdownRequested {
	m_table_id: BigNumberish;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::actions::actions_system::EventShowdownRequestedValue` struct
export interface EventShowdownRequestedValue {
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventAuthHashVerified` struct
export interface EventAuthHashVerified {
	m_table_id: BigNumberish;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventAuthHashVerifiedValue` struct
export interface EventAuthHashVerifiedValue {
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventDecryptCCRequested` struct
export interface EventDecryptCCRequested {
	m_table_id: BigNumberish;
	m_cards: Array<StructCard>;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventDecryptCCRequestedValue` struct
export interface EventDecryptCCRequestedValue {
	m_cards: Array<StructCard>;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventDecryptHandRequested` struct
export interface EventDecryptHandRequested {
	m_table_id: BigNumberish;
	m_player: string;
	m_hand: Array<StructCard>;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventDecryptHandRequestedValue` struct
export interface EventDecryptHandRequestedValue {
	m_hand: Array<StructCard>;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventEncryptDeckRequested` struct
export interface EventEncryptDeckRequested {
	m_table_id: BigNumberish;
	m_deck: Array<StructCard>;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventEncryptDeckRequestedValue` struct
export interface EventEncryptDeckRequestedValue {
	m_deck: Array<StructCard>;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventStreetAdvanced` struct
export interface EventStreetAdvanced {
	m_table_id: BigNumberish;
	m_state: EnumStreetStateEnum;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventStreetAdvancedValue` struct
export interface EventStreetAdvancedValue {
	m_state: EnumStreetStateEnum;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventTableCreated` struct
export interface EventTableCreated {
	m_table_id: BigNumberish;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventTableCreatedValue` struct
export interface EventTableCreatedValue {
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventTableShutdown` struct
export interface EventTableShutdown {
	m_table_id: BigNumberish;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventTableShutdownValue` struct
export interface EventTableShutdownValue {
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::models::enums::EnumCardValue` enum
export type EnumCardValue = {
	Two: string;
	Three: string;
	Four: string;
	Five: string;
	Six: string;
	Seven: string;
	Eight: string;
	Nine: string;
	Ten: string;
	Jack: string;
	Queen: string;
	King: string;
	Ace: string;
}
export type EnumCardValueEnum = CairoCustomEnum;

// Type definition for `dominion::models::enums::EnumHandRank` enum
export type EnumHandRank = {
	None: string;
	HighCard: EnumCardValueEnum;
	Pair: EnumCardValueEnum;
	TwoPair: [EnumCardValue, EnumCardValue];
	ThreeOfAKind: EnumCardValueEnum;
	Straight: EnumCardValueEnum;
	Flush: Array<EnumCardValueEnum>;
	FullHouse: [EnumCardValue, EnumCardValue];
	FourOfAKind: EnumCardValueEnum;
	StraightFlush: string;
	RoyalFlush: string;
}
export type EnumHandRankEnum = CairoCustomEnum;

// Type definition for `dominion::models::enums::EnumPlayerState` enum
export type EnumPlayerState = {
	NotCreated: string;
	Waiting: string;
	Ready: string;
	Active: string;
	Checked: string;
	Called: string;
	Raised: BigNumberish;
	Folded: string;
	AllIn: string;
	Left: string;
	Revealed: string;
}
export type EnumPlayerStateEnum = CairoCustomEnum;

// Type definition for `dominion::models::enums::EnumPosition` enum
export type EnumPosition = {
	None: string;
	SmallBlind: string;
	BigBlind: string;
}
export type EnumPositionEnum = CairoCustomEnum;

// Type definition for `dominion::models::enums::EnumStreetState` enum
export type EnumStreetState = {
	PreFlop: string;
	Flop: string;
	Turn: string;
	River: string;
	Showdown: string;
}
export type EnumStreetStateEnum = CairoCustomEnum;

// Type definition for `dominion::models::enums::EnumTableState` enum
export type EnumTableState = {
	Shutdown: string;
	WaitingForPlayers: string;
	InProgress: string;
}
export type EnumTableStateEnum = CairoCustomEnum;

export interface SchemaType extends ISchemaType {
	dominion: {
		ComponentBank: ComponentBank,
		ComponentBankValue: ComponentBankValue,
		ComponentHand: ComponentHand,
		ComponentHandValue: ComponentHandValue,
		ComponentOriginalDeck: ComponentOriginalDeck,
		ComponentOriginalDeckValue: ComponentOriginalDeckValue,
		ComponentPlayer: ComponentPlayer,
		ComponentPlayerValue: ComponentPlayerValue,
		ComponentProof: ComponentProof,
		ComponentProofValue: ComponentProofValue,
		ComponentRake: ComponentRake,
		ComponentRakeValue: ComponentRakeValue,
		ComponentRound: ComponentRound,
		ComponentRoundValue: ComponentRoundValue,
		ComponentSidepot: ComponentSidepot,
		ComponentSidepotValue: ComponentSidepotValue,
		ComponentStreet: ComponentStreet,
		ComponentStreetValue: ComponentStreetValue,
		ComponentTable: ComponentTable,
		ComponentTableInfo: ComponentTableInfo,
		ComponentTableInfoValue: ComponentTableInfoValue,
		ComponentTableValue: ComponentTableValue,
		ComponentWinners: ComponentWinners,
		ComponentWinnersValue: ComponentWinnersValue,
		StructCard: StructCard,
		EventAllPlayersReady: EventAllPlayersReady,
		EventAllPlayersReadyValue: EventAllPlayersReadyValue,
		EventAuthHashRequested: EventAuthHashRequested,
		EventAuthHashRequestedValue: EventAuthHashRequestedValue,
		EventHandRevealed: EventHandRevealed,
		EventHandRevealedValue: EventHandRevealedValue,
		EventPlayerJoined: EventPlayerJoined,
		EventPlayerJoinedValue: EventPlayerJoinedValue,
		EventPlayerLeft: EventPlayerLeft,
		EventPlayerLeftValue: EventPlayerLeftValue,
		EventRequestBet: EventRequestBet,
		EventRequestBetValue: EventRequestBetValue,
		EventRevealShowdownRequested: EventRevealShowdownRequested,
		EventRevealShowdownRequestedValue: EventRevealShowdownRequestedValue,
		EventShowdownRequested: EventShowdownRequested,
		EventShowdownRequestedValue: EventShowdownRequestedValue,
		EventAuthHashVerified: EventAuthHashVerified,
		EventAuthHashVerifiedValue: EventAuthHashVerifiedValue,
		EventDecryptCCRequested: EventDecryptCCRequested,
		EventDecryptCCRequestedValue: EventDecryptCCRequestedValue,
		EventDecryptHandRequested: EventDecryptHandRequested,
		EventDecryptHandRequestedValue: EventDecryptHandRequestedValue,
		EventEncryptDeckRequested: EventEncryptDeckRequested,
		EventEncryptDeckRequestedValue: EventEncryptDeckRequestedValue,
		EventStreetAdvanced: EventStreetAdvanced,
		EventStreetAdvancedValue: EventStreetAdvancedValue,
		EventTableCreated: EventTableCreated,
		EventTableCreatedValue: EventTableCreatedValue,
		EventTableShutdown: EventTableShutdown,
		EventTableShutdownValue: EventTableShutdownValue,
	},
}
export const schema: SchemaType = {
	dominion: {
		ComponentBank: {
			m_owner: "",
			m_balance: 0,
		},
		ComponentBankValue: {
			m_balance: 0,
		},
		ComponentHand: {
			m_table_id: 0,
			m_owner: "",
			m_cards: [{ m_num_representation: 0, }],
			m_commitment_hash: [0],
		},
		ComponentHandValue: {
			m_cards: [{ m_num_representation: 0, }],
			m_commitment_hash: [0],
		},
		ComponentOriginalDeck: {
			m_table_id: 0,
			m_deck: [{ m_num_representation: 0, }],
		},
		ComponentOriginalDeckValue: {
			m_deck: [{ m_num_representation: 0, }],
		},
		ComponentPlayer: {
			m_table_id: 0,
			m_owner: "",
			m_table_chips: 0,
		m_position: new CairoCustomEnum({ 
					None: "",
				SmallBlind: undefined,
				BigBlind: undefined, }),
		m_state: new CairoCustomEnum({ 
					NotCreated: "",
				Waiting: undefined,
				Ready: undefined,
				Active: undefined,
				Checked: undefined,
				Called: undefined,
				Raised: undefined,
				Folded: undefined,
				AllIn: undefined,
				Left: undefined,
				Revealed: undefined, }),
			m_current_bet: 0,
			m_is_created: false,
		m_auth_hash: "",
			m_is_dealer: false,
		},
		ComponentPlayerValue: {
			m_table_chips: 0,
		m_position: new CairoCustomEnum({ 
					None: "",
				SmallBlind: undefined,
				BigBlind: undefined, }),
		m_state: new CairoCustomEnum({ 
					NotCreated: "",
				Waiting: undefined,
				Ready: undefined,
				Active: undefined,
				Checked: undefined,
				Called: undefined,
				Raised: undefined,
				Folded: undefined,
				AllIn: undefined,
				Left: undefined,
				Revealed: undefined, }),
			m_current_bet: 0,
			m_is_created: false,
		m_auth_hash: "",
			m_is_dealer: false,
		},
		ComponentProof: {
			m_table_id: 0,
		m_shuffle_proof: "",
		m_deck_proof: "",
			m_encrypted_deck_posted: false,
		},
		ComponentProofValue: {
		m_shuffle_proof: "",
		m_deck_proof: "",
			m_encrypted_deck_posted: false,
		},
		ComponentRake: {
			m_table_id: 0,
			m_rake_address: "",
			m_rake_fee: 0,
			m_chip_amount: 0,
		},
		ComponentRakeValue: {
			m_rake_address: "",
			m_rake_fee: 0,
			m_chip_amount: 0,
		},
		ComponentRound: {
			m_table_id: 0,
			m_round_id: 0,
			m_last_raiser: 0,
			m_last_raiser_addr: "",
			m_highest_raise: 0,
			m_last_played_ts: 0,
			m_current_turn: "",
			m_current_dealer: 0,
		},
		ComponentRoundValue: {
			m_last_raiser: 0,
			m_last_raiser_addr: "",
			m_highest_raise: 0,
			m_last_played_ts: 0,
			m_current_turn: "",
			m_current_dealer: 0,
		},
		ComponentSidepot: {
			m_table_id: 0,
			m_sidepot_id: 0,
			m_min_bet: 0,
			m_amount: 0,
			m_eligible_players: [""],
		},
		ComponentSidepotValue: {
			m_min_bet: 0,
			m_amount: 0,
			m_eligible_players: [""],
		},
		ComponentStreet: {
			m_table_id: 0,
			m_round_id: 0,
		m_state: new CairoCustomEnum({ 
					PreFlop: "",
				Flop: undefined,
				Turn: undefined,
				River: undefined,
				Showdown: undefined, }),
			m_finished_street: false,
		},
		ComponentStreetValue: {
		m_state: new CairoCustomEnum({ 
					PreFlop: "",
				Flop: undefined,
				Turn: undefined,
				River: undefined,
				Showdown: undefined, }),
			m_finished_street: false,
		},
		ComponentTable: {
			m_table_id: 0,
			m_deck: [{ m_num_representation: 0, }],
			m_community_cards: [{ m_num_representation: 0, }],
			m_players: [""],
			m_pot: 0,
			m_num_sidepots: 0,
			m_current_round: 0,
		},
		ComponentTableInfo: {
			m_table_id: 0,
			m_small_blind: 0,
			m_big_blind: 0,
			m_min_buy_in: 0,
			m_max_buy_in: 0,
		m_state: new CairoCustomEnum({ 
					Shutdown: "",
				WaitingForPlayers: undefined,
				InProgress: undefined, }),
		},
		ComponentTableInfoValue: {
			m_small_blind: 0,
			m_big_blind: 0,
			m_min_buy_in: 0,
			m_max_buy_in: 0,
		m_state: new CairoCustomEnum({ 
					Shutdown: "",
				WaitingForPlayers: undefined,
				InProgress: undefined, }),
		},
		ComponentTableValue: {
			m_deck: [{ m_num_representation: 0, }],
			m_community_cards: [{ m_num_representation: 0, }],
			m_players: [""],
			m_pot: 0,
			m_num_sidepots: 0,
			m_current_round: 0,
		},
		ComponentWinners: {
			m_table_id: 0,
			m_round_id: 0,
			m_winners: [""],
			m_hands: [new CairoCustomEnum({ 
					None: "",
				HighCard: undefined,
				Pair: undefined,
				TwoPair: undefined,
				ThreeOfAKind: undefined,
				Straight: undefined,
				Flush: undefined,
				FullHouse: undefined,
				FourOfAKind: undefined,
				StraightFlush: undefined,
				RoyalFlush: undefined, })],
			m_amounts: [0],
		},
		ComponentWinnersValue: {
			m_winners: [""],
			m_hands: [new CairoCustomEnum({ 
					None: "",
				HighCard: undefined,
				Pair: undefined,
				TwoPair: undefined,
				ThreeOfAKind: undefined,
				Straight: undefined,
				Flush: undefined,
				FullHouse: undefined,
				FourOfAKind: undefined,
				StraightFlush: undefined,
				RoyalFlush: undefined, })],
			m_amounts: [0],
		},
		StructCard: {
		m_num_representation: 0,
		},
		EventAllPlayersReady: {
			m_table_id: 0,
			m_players: [""],
			m_timestamp: 0,
		},
		EventAllPlayersReadyValue: {
			m_players: [""],
			m_timestamp: 0,
		},
		EventAuthHashRequested: {
			m_table_id: 0,
			m_player: "",
		m_auth_hash: "",
			m_timestamp: 0,
		},
		EventAuthHashRequestedValue: {
		m_auth_hash: "",
			m_timestamp: 0,
		},
		EventHandRevealed: {
			m_table_id: 0,
			m_player: "",
		m_request: "",
			m_player_hand: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventHandRevealedValue: {
		m_request: "",
			m_player_hand: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventPlayerJoined: {
			m_table_id: 0,
			m_player: "",
			m_timestamp: 0,
		},
		EventPlayerJoinedValue: {
			m_timestamp: 0,
		},
		EventPlayerLeft: {
			m_table_id: 0,
			m_player: "",
			m_timestamp: 0,
		},
		EventPlayerLeftValue: {
			m_timestamp: 0,
		},
		EventRequestBet: {
			m_table_id: 0,
			m_timestamp: 0,
		},
		EventRequestBetValue: {
			m_timestamp: 0,
		},
		EventRevealShowdownRequested: {
			m_table_id: 0,
			m_player: "",
			m_hand: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventRevealShowdownRequestedValue: {
			m_hand: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventShowdownRequested: {
			m_table_id: 0,
			m_timestamp: 0,
		},
		EventShowdownRequestedValue: {
			m_timestamp: 0,
		},
		EventAuthHashVerified: {
			m_table_id: 0,
			m_timestamp: 0,
		},
		EventAuthHashVerifiedValue: {
			m_timestamp: 0,
		},
		EventDecryptCCRequested: {
			m_table_id: 0,
			m_cards: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventDecryptCCRequestedValue: {
			m_cards: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventDecryptHandRequested: {
			m_table_id: 0,
			m_player: "",
			m_hand: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventDecryptHandRequestedValue: {
			m_hand: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventEncryptDeckRequested: {
			m_table_id: 0,
			m_deck: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventEncryptDeckRequestedValue: {
			m_deck: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventStreetAdvanced: {
			m_table_id: 0,
		m_state: new CairoCustomEnum({ 
					PreFlop: "",
				Flop: undefined,
				Turn: undefined,
				River: undefined,
				Showdown: undefined, }),
			m_timestamp: 0,
		},
		EventStreetAdvancedValue: {
		m_state: new CairoCustomEnum({ 
					PreFlop: "",
				Flop: undefined,
				Turn: undefined,
				River: undefined,
				Showdown: undefined, }),
			m_timestamp: 0,
		},
		EventTableCreated: {
			m_table_id: 0,
			m_timestamp: 0,
		},
		EventTableCreatedValue: {
			m_timestamp: 0,
		},
		EventTableShutdown: {
			m_table_id: 0,
			m_timestamp: 0,
		},
		EventTableShutdownValue: {
			m_timestamp: 0,
		},
	},
};
export enum ModelsMapping {
	ComponentBank = 'dominion-ComponentBank',
	ComponentBankValue = 'dominion-ComponentBankValue',
	ComponentHand = 'dominion-ComponentHand',
	ComponentHandValue = 'dominion-ComponentHandValue',
	ComponentOriginalDeck = 'dominion-ComponentOriginalDeck',
	ComponentOriginalDeckValue = 'dominion-ComponentOriginalDeckValue',
	ComponentPlayer = 'dominion-ComponentPlayer',
	ComponentPlayerValue = 'dominion-ComponentPlayerValue',
	ComponentProof = 'dominion-ComponentProof',
	ComponentProofValue = 'dominion-ComponentProofValue',
	ComponentRake = 'dominion-ComponentRake',
	ComponentRakeValue = 'dominion-ComponentRakeValue',
	ComponentRound = 'dominion-ComponentRound',
	ComponentRoundValue = 'dominion-ComponentRoundValue',
	ComponentSidepot = 'dominion-ComponentSidepot',
	ComponentSidepotValue = 'dominion-ComponentSidepotValue',
	ComponentStreet = 'dominion-ComponentStreet',
	ComponentStreetValue = 'dominion-ComponentStreetValue',
	ComponentTable = 'dominion-ComponentTable',
	ComponentTableInfo = 'dominion-ComponentTableInfo',
	ComponentTableInfoValue = 'dominion-ComponentTableInfoValue',
	ComponentTableValue = 'dominion-ComponentTableValue',
	ComponentWinners = 'dominion-ComponentWinners',
	ComponentWinnersValue = 'dominion-ComponentWinnersValue',
	EnumCardValue = 'dominion-EnumCardValue',
	EnumHandRank = 'dominion-EnumHandRank',
	EnumPlayerState = 'dominion-EnumPlayerState',
	EnumPosition = 'dominion-EnumPosition',
	EnumStreetState = 'dominion-EnumStreetState',
	EnumTableState = 'dominion-EnumTableState',
	StructCard = 'dominion-StructCard',
	EventAllPlayersReady = 'dominion-EventAllPlayersReady',
	EventAllPlayersReadyValue = 'dominion-EventAllPlayersReadyValue',
	EventAuthHashRequested = 'dominion-EventAuthHashRequested',
	EventAuthHashRequestedValue = 'dominion-EventAuthHashRequestedValue',
	EventHandRevealed = 'dominion-EventHandRevealed',
	EventHandRevealedValue = 'dominion-EventHandRevealedValue',
	EventPlayerJoined = 'dominion-EventPlayerJoined',
	EventPlayerJoinedValue = 'dominion-EventPlayerJoinedValue',
	EventPlayerLeft = 'dominion-EventPlayerLeft',
	EventPlayerLeftValue = 'dominion-EventPlayerLeftValue',
	EventRequestBet = 'dominion-EventRequestBet',
	EventRequestBetValue = 'dominion-EventRequestBetValue',
	EventRevealShowdownRequested = 'dominion-EventRevealShowdownRequested',
	EventRevealShowdownRequestedValue = 'dominion-EventRevealShowdownRequestedValue',
	EventShowdownRequested = 'dominion-EventShowdownRequested',
	EventShowdownRequestedValue = 'dominion-EventShowdownRequestedValue',
	EventAuthHashVerified = 'dominion-EventAuthHashVerified',
	EventAuthHashVerifiedValue = 'dominion-EventAuthHashVerifiedValue',
	EventDecryptCCRequested = 'dominion-EventDecryptCCRequested',
	EventDecryptCCRequestedValue = 'dominion-EventDecryptCCRequestedValue',
	EventDecryptHandRequested = 'dominion-EventDecryptHandRequested',
	EventDecryptHandRequestedValue = 'dominion-EventDecryptHandRequestedValue',
	EventEncryptDeckRequested = 'dominion-EventEncryptDeckRequested',
	EventEncryptDeckRequestedValue = 'dominion-EventEncryptDeckRequestedValue',
	EventStreetAdvanced = 'dominion-EventStreetAdvanced',
	EventStreetAdvancedValue = 'dominion-EventStreetAdvancedValue',
	EventTableCreated = 'dominion-EventTableCreated',
	EventTableCreatedValue = 'dominion-EventTableCreatedValue',
	EventTableShutdown = 'dominion-EventTableShutdown',
	EventTableShutdownValue = 'dominion-EventTableShutdownValue',
}