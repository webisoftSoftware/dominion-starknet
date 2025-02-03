import type { SchemaType as ISchemaType } from "@dojoengine/sdk";

import { CairoCustomEnum, BigNumberish } from 'starknet';

type WithFieldOrder<T> = T & { fieldOrder: string[] };

// Type definition for `dominion::models::components::ComponentHand` struct
export interface ComponentHand {
	m_owner: string;
	m_cards: Array<StructCard>;
	m_commitment_hash: Array<BigNumberish>;
}

// Type definition for `dominion::models::components::ComponentHandValue` struct
export interface ComponentHandValue {
	m_cards: Array<StructCard>;
	m_commitment_hash: Array<BigNumberish>;
}

// Type definition for `dominion::models::components::ComponentPlayer` struct
export interface ComponentPlayer {
	m_table_id: BigNumberish;
	m_owner: string;
	m_table_chips: BigNumberish;
	m_total_chips: BigNumberish;
	m_position: EnumPositionEnum;
	m_state: EnumPlayerStateEnum;
	m_current_bet: BigNumberish;
	m_is_created: boolean;
	m_is_dealer: boolean;
}

// Type definition for `dominion::models::components::ComponentPlayerValue` struct
export interface ComponentPlayerValue {
	m_table_chips: BigNumberish;
	m_total_chips: BigNumberish;
	m_position: EnumPositionEnum;
	m_state: EnumPlayerStateEnum;
	m_current_bet: BigNumberish;
	m_is_created: boolean;
	m_is_dealer: boolean;
}

// Type definition for `dominion::models::components::ComponentRake` struct
export interface ComponentRake {
	m_rake_address: string;
	m_chip_amount: BigNumberish;
}

// Type definition for `dominion::models::components::ComponentRakeValue` struct
export interface ComponentRakeValue {
	m_chip_amount: BigNumberish;
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

// Type definition for `dominion::models::components::ComponentTable` struct
export interface ComponentTable {
	m_table_id: BigNumberish;
	m_deck: Array<StructCard>;
	m_community_cards: Array<StructCard>;
	m_players: Array<string>;
	m_current_turn: BigNumberish;
	m_current_dealer: BigNumberish;
	m_last_raiser: BigNumberish;
	m_pot: BigNumberish;
	m_small_blind: BigNumberish;
	m_big_blind: BigNumberish;
	m_min_buy_in: BigNumberish;
	m_max_buy_in: BigNumberish;
	m_state: EnumGameStateEnum;
	m_last_played_ts: BigNumberish;
	m_num_sidepots: BigNumberish;
	m_finished_street: boolean;
	m_rake_address: string;
	m_rake_fee: BigNumberish;
	m_deck_encrypted: boolean;
}

// Type definition for `dominion::models::components::ComponentTableValue` struct
export interface ComponentTableValue {
	m_deck: Array<StructCard>;
	m_community_cards: Array<StructCard>;
	m_players: Array<string>;
	m_current_turn: BigNumberish;
	m_current_dealer: BigNumberish;
	m_last_raiser: BigNumberish;
	m_pot: BigNumberish;
	m_small_blind: BigNumberish;
	m_big_blind: BigNumberish;
	m_min_buy_in: BigNumberish;
	m_max_buy_in: BigNumberish;
	m_state: EnumGameStateEnum;
	m_last_played_ts: BigNumberish;
	m_num_sidepots: BigNumberish;
	m_finished_street: boolean;
	m_rake_address: string;
	m_rake_fee: BigNumberish;
	m_deck_encrypted: boolean;
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

// Type definition for `dominion::systems::table_manager::table_management_system::EventRequestBet` struct
export interface EventRequestBet {
	m_table_id: BigNumberish;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventRequestBetValue` struct
export interface EventRequestBetValue {
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventRevealShowdownRequested` struct
export interface EventRevealShowdownRequested {
	m_table_id: BigNumberish;
	m_player: string;
	m_hand: Array<StructCard>;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventRevealShowdownRequestedValue` struct
export interface EventRevealShowdownRequestedValue {
	m_hand: Array<StructCard>;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventShowdownRequested` struct
export interface EventShowdownRequested {
	m_table_id: BigNumberish;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventShowdownRequestedValue` struct
export interface EventShowdownRequestedValue {
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventStreetAdvanced` struct
export interface EventStreetAdvanced {
	m_table_id: BigNumberish;
	m_timestamp: BigNumberish;
}

// Type definition for `dominion::systems::table_manager::table_management_system::EventStreetAdvancedValue` struct
export interface EventStreetAdvancedValue {
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

// Type definition for `dominion::models::enums::EnumGameState` enum
export type EnumGameState = {
	Shutdown: string;
	WaitingForPlayers: string;
	PreFlop: string;
	Flop: string;
	Turn: string;
	River: string;
	Showdown: string;
}
export type EnumGameStateEnum = CairoCustomEnum;

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

export interface SchemaType extends ISchemaType {
	dominion: {
		ComponentHand: WithFieldOrder<ComponentHand>,
		ComponentHandValue: WithFieldOrder<ComponentHandValue>,
		ComponentPlayer: WithFieldOrder<ComponentPlayer>,
		ComponentPlayerValue: WithFieldOrder<ComponentPlayerValue>,
		ComponentRake: WithFieldOrder<ComponentRake>,
		ComponentRakeValue: WithFieldOrder<ComponentRakeValue>,
		ComponentSidepot: WithFieldOrder<ComponentSidepot>,
		ComponentSidepotValue: WithFieldOrder<ComponentSidepotValue>,
		ComponentTable: WithFieldOrder<ComponentTable>,
		ComponentTableValue: WithFieldOrder<ComponentTableValue>,
		StructCard: WithFieldOrder<StructCard>,
		EventAllPlayersReady: WithFieldOrder<EventAllPlayersReady>,
		EventAllPlayersReadyValue: WithFieldOrder<EventAllPlayersReadyValue>,
		EventAuthHashRequested: WithFieldOrder<EventAuthHashRequested>,
		EventAuthHashRequestedValue: WithFieldOrder<EventAuthHashRequestedValue>,
		EventHandRevealed: WithFieldOrder<EventHandRevealed>,
		EventHandRevealedValue: WithFieldOrder<EventHandRevealedValue>,
		EventPlayerJoined: WithFieldOrder<EventPlayerJoined>,
		EventPlayerJoinedValue: WithFieldOrder<EventPlayerJoinedValue>,
		EventPlayerLeft: WithFieldOrder<EventPlayerLeft>,
		EventPlayerLeftValue: WithFieldOrder<EventPlayerLeftValue>,
		EventAuthHashVerified: WithFieldOrder<EventAuthHashVerified>,
		EventAuthHashVerifiedValue: WithFieldOrder<EventAuthHashVerifiedValue>,
		EventDecryptCCRequested: WithFieldOrder<EventDecryptCCRequested>,
		EventDecryptCCRequestedValue: WithFieldOrder<EventDecryptCCRequestedValue>,
		EventDecryptHandRequested: WithFieldOrder<EventDecryptHandRequested>,
		EventDecryptHandRequestedValue: WithFieldOrder<EventDecryptHandRequestedValue>,
		EventEncryptDeckRequested: WithFieldOrder<EventEncryptDeckRequested>,
		EventEncryptDeckRequestedValue: WithFieldOrder<EventEncryptDeckRequestedValue>,
		EventRequestBet: WithFieldOrder<EventRequestBet>,
		EventRequestBetValue: WithFieldOrder<EventRequestBetValue>,
		EventRevealShowdownRequested: WithFieldOrder<EventRevealShowdownRequested>,
		EventRevealShowdownRequestedValue: WithFieldOrder<EventRevealShowdownRequestedValue>,
		EventShowdownRequested: WithFieldOrder<EventShowdownRequested>,
		EventShowdownRequestedValue: WithFieldOrder<EventShowdownRequestedValue>,
		EventStreetAdvanced: WithFieldOrder<EventStreetAdvanced>,
		EventStreetAdvancedValue: WithFieldOrder<EventStreetAdvancedValue>,
		EventTableCreated: WithFieldOrder<EventTableCreated>,
		EventTableCreatedValue: WithFieldOrder<EventTableCreatedValue>,
		EventTableShutdown: WithFieldOrder<EventTableShutdown>,
		EventTableShutdownValue: WithFieldOrder<EventTableShutdownValue>,
	},
}
export const schema: SchemaType = {
	dominion: {
		ComponentHand: {
			fieldOrder: ['m_owner', 'm_cards', 'm_commitment_hash'],
			m_owner: "",
			m_cards: [{ m_num_representation: 0, }],
			m_commitment_hash: [0],
		},
		ComponentHandValue: {
			fieldOrder: ['m_cards', 'm_commitment_hash'],
			m_cards: [{ m_num_representation: 0, }],
			m_commitment_hash: [0],
		},
		ComponentPlayer: {
			fieldOrder: ['m_table_id', 'm_owner', 'm_table_chips', 'm_total_chips', 'm_position', 'm_state', 'm_current_bet', 'm_is_created', 'm_is_dealer'],
			m_table_id: 0,
			m_owner: "",
			m_table_chips: 0,
			m_total_chips: 0,
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
			m_is_dealer: false,
		},
		ComponentPlayerValue: {
			fieldOrder: ['m_table_chips', 'm_total_chips', 'm_position', 'm_state', 'm_current_bet', 'm_is_created', 'm_is_dealer'],
			m_table_chips: 0,
			m_total_chips: 0,
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
			m_is_dealer: false,
		},
		ComponentRake: {
			fieldOrder: ['m_rake_address', 'm_chip_amount'],
			m_rake_address: "",
			m_chip_amount: 0,
		},
		ComponentRakeValue: {
			fieldOrder: ['m_chip_amount'],
			m_chip_amount: 0,
		},
		ComponentSidepot: {
			fieldOrder: ['m_table_id', 'm_sidepot_id', 'm_min_bet', 'm_amount', 'm_eligible_players'],
			m_table_id: 0,
			m_sidepot_id: 0,
			m_min_bet: 0,
			m_amount: 0,
			m_eligible_players: [""],
		},
		ComponentSidepotValue: {
			fieldOrder: ['m_min_bet', 'm_amount', 'm_eligible_players'],
			m_min_bet: 0,
			m_amount: 0,
			m_eligible_players: [""],
		},
		ComponentTable: {
			fieldOrder: ['m_table_id', 'm_deck', 'm_community_cards', 'm_players', 'm_current_turn', 'm_current_dealer', 'm_last_raiser', 'm_pot', 'm_small_blind', 'm_big_blind', 'm_min_buy_in', 'm_max_buy_in', 'm_state', 'm_last_played_ts', 'm_num_sidepots', 'm_finished_street', 'm_rake_address', 'm_rake_fee', 'm_deck_encrypted'],
			m_table_id: 0,
			m_deck: [{ m_num_representation: 0, }],
			m_community_cards: [{ m_num_representation: 0, }],
			m_players: [""],
			m_current_turn: 0,
			m_current_dealer: 0,
			m_last_raiser: 0,
			m_pot: 0,
			m_small_blind: 0,
			m_big_blind: 0,
			m_min_buy_in: 0,
			m_max_buy_in: 0,
		m_state: new CairoCustomEnum({ 
					Shutdown: "",
				WaitingForPlayers: undefined,
				PreFlop: undefined,
				Flop: undefined,
				Turn: undefined,
				River: undefined,
				Showdown: undefined, }),
			m_last_played_ts: 0,
			m_num_sidepots: 0,
			m_finished_street: false,
			m_rake_address: "",
			m_rake_fee: 0,
			m_deck_encrypted: false,
		},
		ComponentTableValue: {
			fieldOrder: ['m_deck', 'm_community_cards', 'm_players', 'm_current_turn', 'm_current_dealer', 'm_last_raiser', 'm_pot', 'm_small_blind', 'm_big_blind', 'm_min_buy_in', 'm_max_buy_in', 'm_state', 'm_last_played_ts', 'm_num_sidepots', 'm_finished_street', 'm_rake_address', 'm_rake_fee', 'm_deck_encrypted'],
			m_deck: [{ m_num_representation: 0, }],
			m_community_cards: [{ m_num_representation: 0, }],
			m_players: [""],
			m_current_turn: 0,
			m_current_dealer: 0,
			m_last_raiser: 0,
			m_pot: 0,
			m_small_blind: 0,
			m_big_blind: 0,
			m_min_buy_in: 0,
			m_max_buy_in: 0,
		m_state: new CairoCustomEnum({ 
					Shutdown: "",
				WaitingForPlayers: undefined,
				PreFlop: undefined,
				Flop: undefined,
				Turn: undefined,
				River: undefined,
				Showdown: undefined, }),
			m_last_played_ts: 0,
			m_num_sidepots: 0,
			m_finished_street: false,
			m_rake_address: "",
			m_rake_fee: 0,
			m_deck_encrypted: false,
		},
		StructCard: {
			fieldOrder: ['m_num_representation'],
		m_num_representation: 0,
		},
		EventAllPlayersReady: {
			fieldOrder: ['m_table_id', 'm_players', 'm_timestamp'],
			m_table_id: 0,
			m_players: [""],
			m_timestamp: 0,
		},
		EventAllPlayersReadyValue: {
			fieldOrder: ['m_players', 'm_timestamp'],
			m_players: [""],
			m_timestamp: 0,
		},
		EventAuthHashRequested: {
			fieldOrder: ['m_table_id', 'm_player', 'm_auth_hash', 'm_timestamp'],
			m_table_id: 0,
			m_player: "",
		m_auth_hash: "",
			m_timestamp: 0,
		},
		EventAuthHashRequestedValue: {
			fieldOrder: ['m_auth_hash', 'm_timestamp'],
		m_auth_hash: "",
			m_timestamp: 0,
		},
		EventHandRevealed: {
			fieldOrder: ['m_table_id', 'm_player', 'm_request', 'm_player_hand', 'm_timestamp'],
			m_table_id: 0,
			m_player: "",
		m_request: "",
			m_player_hand: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventHandRevealedValue: {
			fieldOrder: ['m_request', 'm_player_hand', 'm_timestamp'],
		m_request: "",
			m_player_hand: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventPlayerJoined: {
			fieldOrder: ['m_table_id', 'm_player', 'm_timestamp'],
			m_table_id: 0,
			m_player: "",
			m_timestamp: 0,
		},
		EventPlayerJoinedValue: {
			fieldOrder: ['m_timestamp'],
			m_timestamp: 0,
		},
		EventPlayerLeft: {
			fieldOrder: ['m_table_id', 'm_player', 'm_timestamp'],
			m_table_id: 0,
			m_player: "",
			m_timestamp: 0,
		},
		EventPlayerLeftValue: {
			fieldOrder: ['m_timestamp'],
			m_timestamp: 0,
		},
		EventAuthHashVerified: {
			fieldOrder: ['m_table_id', 'm_timestamp'],
			m_table_id: 0,
			m_timestamp: 0,
		},
		EventAuthHashVerifiedValue: {
			fieldOrder: ['m_timestamp'],
			m_timestamp: 0,
		},
		EventDecryptCCRequested: {
			fieldOrder: ['m_table_id', 'm_cards', 'm_timestamp'],
			m_table_id: 0,
			m_cards: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventDecryptCCRequestedValue: {
			fieldOrder: ['m_cards', 'm_timestamp'],
			m_cards: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventDecryptHandRequested: {
			fieldOrder: ['m_table_id', 'm_player', 'm_hand', 'm_timestamp'],
			m_table_id: 0,
			m_player: "",
			m_hand: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventDecryptHandRequestedValue: {
			fieldOrder: ['m_hand', 'm_timestamp'],
			m_hand: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventEncryptDeckRequested: {
			fieldOrder: ['m_table_id', 'm_deck', 'm_timestamp'],
			m_table_id: 0,
			m_deck: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventEncryptDeckRequestedValue: {
			fieldOrder: ['m_deck', 'm_timestamp'],
			m_deck: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventRequestBet: {
			fieldOrder: ['m_table_id', 'm_timestamp'],
			m_table_id: 0,
			m_timestamp: 0,
		},
		EventRequestBetValue: {
			fieldOrder: ['m_timestamp'],
			m_timestamp: 0,
		},
		EventRevealShowdownRequested: {
			fieldOrder: ['m_table_id', 'm_player', 'm_hand', 'm_timestamp'],
			m_table_id: 0,
			m_player: "",
			m_hand: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventRevealShowdownRequestedValue: {
			fieldOrder: ['m_hand', 'm_timestamp'],
			m_hand: [{ m_num_representation: 0, }],
			m_timestamp: 0,
		},
		EventShowdownRequested: {
			fieldOrder: ['m_table_id', 'm_timestamp'],
			m_table_id: 0,
			m_timestamp: 0,
		},
		EventShowdownRequestedValue: {
			fieldOrder: ['m_timestamp'],
			m_timestamp: 0,
		},
		EventStreetAdvanced: {
			fieldOrder: ['m_table_id', 'm_timestamp'],
			m_table_id: 0,
			m_timestamp: 0,
		},
		EventStreetAdvancedValue: {
			fieldOrder: ['m_timestamp'],
			m_timestamp: 0,
		},
		EventTableCreated: {
			fieldOrder: ['m_table_id', 'm_timestamp'],
			m_table_id: 0,
			m_timestamp: 0,
		},
		EventTableCreatedValue: {
			fieldOrder: ['m_timestamp'],
			m_timestamp: 0,
		},
		EventTableShutdown: {
			fieldOrder: ['m_table_id', 'm_timestamp'],
			m_table_id: 0,
			m_timestamp: 0,
		},
		EventTableShutdownValue: {
			fieldOrder: ['m_timestamp'],
			m_timestamp: 0,
		},
	},
};
export enum ModelsMapping {
	ComponentHand = 'dominion-ComponentHand',
	ComponentHandValue = 'dominion-ComponentHandValue',
	ComponentPlayer = 'dominion-ComponentPlayer',
	ComponentPlayerValue = 'dominion-ComponentPlayerValue',
	ComponentRake = 'dominion-ComponentRake',
	ComponentRakeValue = 'dominion-ComponentRakeValue',
	ComponentSidepot = 'dominion-ComponentSidepot',
	ComponentSidepotValue = 'dominion-ComponentSidepotValue',
	ComponentTable = 'dominion-ComponentTable',
	ComponentTableValue = 'dominion-ComponentTableValue',
	EnumGameState = 'dominion-EnumGameState',
	EnumPlayerState = 'dominion-EnumPlayerState',
	EnumPosition = 'dominion-EnumPosition',
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
	EventAuthHashVerified = 'dominion-EventAuthHashVerified',
	EventAuthHashVerifiedValue = 'dominion-EventAuthHashVerifiedValue',
	EventDecryptCCRequested = 'dominion-EventDecryptCCRequested',
	EventDecryptCCRequestedValue = 'dominion-EventDecryptCCRequestedValue',
	EventDecryptHandRequested = 'dominion-EventDecryptHandRequested',
	EventDecryptHandRequestedValue = 'dominion-EventDecryptHandRequestedValue',
	EventEncryptDeckRequested = 'dominion-EventEncryptDeckRequested',
	EventEncryptDeckRequestedValue = 'dominion-EventEncryptDeckRequestedValue',
	EventRequestBet = 'dominion-EventRequestBet',
	EventRequestBetValue = 'dominion-EventRequestBetValue',
	EventRevealShowdownRequested = 'dominion-EventRevealShowdownRequested',
	EventRevealShowdownRequestedValue = 'dominion-EventRevealShowdownRequestedValue',
	EventShowdownRequested = 'dominion-EventShowdownRequested',
	EventShowdownRequestedValue = 'dominion-EventShowdownRequestedValue',
	EventStreetAdvanced = 'dominion-EventStreetAdvanced',
	EventStreetAdvancedValue = 'dominion-EventStreetAdvancedValue',
	EventTableCreated = 'dominion-EventTableCreated',
	EventTableCreatedValue = 'dominion-EventTableCreatedValue',
	EventTableShutdown = 'dominion-EventTableShutdown',
	EventTableShutdownValue = 'dominion-EventTableShutdownValue',
}