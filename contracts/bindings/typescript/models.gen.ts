import type { SchemaType as ISchemaType } from "@dojoengine/sdk";

import { BigNumberish } from 'starknet';

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
	m_position: EnumPosition;
	m_state: EnumPlayerState;
	m_current_bet: BigNumberish;
	m_is_created: boolean;
	m_is_dealer: boolean;
}

// Type definition for `dominion::models::components::ComponentPlayerValue` struct
export interface ComponentPlayerValue {
	m_table_chips: BigNumberish;
	m_total_chips: BigNumberish;
	m_position: EnumPosition;
	m_state: EnumPlayerState;
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
	m_state: EnumGameState;
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
	m_state: EnumGameState;
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

// Type definition for `dominion::models::enums::EnumGameState` enum
export enum EnumGameState {
	Shutdown,
	WaitingForPlayers,
	PreFlop,
	Flop,
	Turn,
	River,
	Showdown,
}

// Type definition for `dominion::models::enums::EnumPlayerState` enum
export enum EnumPlayerState {
	NotCreated,
	Waiting,
	Ready,
	Active,
	Checked,
	Called,
	Raised,
	Folded,
	AllIn,
	Left,
	Revealed,
}

// Type definition for `dominion::models::enums::EnumPosition` enum
export enum EnumPosition {
	None,
	SmallBlind,
	BigBlind,
}

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
	},
}
export const schema: SchemaType = {
	dominion: {
		ComponentHand: {
			fieldOrder: ['m_owner', 'm_cards', 'm_commitment_hash'],
			m_owner: "",
			m_cards: [{ fieldOrder: ['m_num_representation'], m_num_representation: 0, }],
			m_commitment_hash: [0],
		},
		ComponentHandValue: {
			fieldOrder: ['m_cards', 'm_commitment_hash'],
			m_cards: [{ fieldOrder: ['m_num_representation'], m_num_representation: 0, }],
			m_commitment_hash: [0],
		},
		ComponentPlayer: {
			fieldOrder: ['m_table_id', 'm_owner', 'm_table_chips', 'm_total_chips', 'm_position', 'm_state', 'm_current_bet', 'm_is_created', 'm_is_dealer'],
			m_table_id: 0,
			m_owner: "",
			m_table_chips: 0,
			m_total_chips: 0,
		m_position: EnumPosition.None,
		m_state: EnumPlayerState.NotCreated,
			m_current_bet: 0,
			m_is_created: false,
			m_is_dealer: false,
		},
		ComponentPlayerValue: {
			fieldOrder: ['m_table_chips', 'm_total_chips', 'm_position', 'm_state', 'm_current_bet', 'm_is_created', 'm_is_dealer'],
			m_table_chips: 0,
			m_total_chips: 0,
		m_position: EnumPosition.None,
		m_state: EnumPlayerState.NotCreated,
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
			m_deck: [{ fieldOrder: ['m_num_representation'], m_num_representation: 0, }],
			m_community_cards: [{ fieldOrder: ['m_num_representation'], m_num_representation: 0, }],
			m_players: [""],
			m_current_turn: 0,
			m_current_dealer: 0,
			m_last_raiser: 0,
			m_pot: 0,
			m_small_blind: 0,
			m_big_blind: 0,
			m_min_buy_in: 0,
			m_max_buy_in: 0,
		m_state: EnumGameState.Shutdown,
			m_last_played_ts: 0,
			m_num_sidepots: 0,
			m_finished_street: false,
			m_rake_address: "",
			m_rake_fee: 0,
			m_deck_encrypted: false,
		},
		ComponentTableValue: {
			fieldOrder: ['m_deck', 'm_community_cards', 'm_players', 'm_current_turn', 'm_current_dealer', 'm_last_raiser', 'm_pot', 'm_small_blind', 'm_big_blind', 'm_min_buy_in', 'm_max_buy_in', 'm_state', 'm_last_played_ts', 'm_num_sidepots', 'm_finished_street', 'm_rake_address', 'm_rake_fee', 'm_deck_encrypted'],
			m_deck: [{ fieldOrder: ['m_num_representation'], m_num_representation: 0, }],
			m_community_cards: [{ fieldOrder: ['m_num_representation'], m_num_representation: 0, }],
			m_players: [""],
			m_current_turn: 0,
			m_current_dealer: 0,
			m_last_raiser: 0,
			m_pot: 0,
			m_small_blind: 0,
			m_big_blind: 0,
			m_min_buy_in: 0,
			m_max_buy_in: 0,
		m_state: EnumGameState.Shutdown,
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
}