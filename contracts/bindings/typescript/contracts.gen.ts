import { DojoProvider } from "@dojoengine/core";
import { Account, AccountInterface, BigNumberish, CairoOption, CairoCustomEnum, ByteArray } from "starknet";
import * as models from "./models.gen";

export function setupWorld(provider: DojoProvider) {

	const cashier_system_depositErc20 = async (snAccount: Account | AccountInterface, amount: U256) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "cashier_system",
					entrypoint: "deposit_erc20",
					calldata: [amount],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const cashier_system_cashoutErc20 = async (snAccount: Account | AccountInterface, chipsAmount: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "cashier_system",
					entrypoint: "cashout_erc20",
					calldata: [chipsAmount],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const cashier_system_claimFees = async (snAccount: Account | AccountInterface) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "cashier_system",
					entrypoint: "claim_fees",
					calldata: [],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const cashier_system_transferChips = async (snAccount: Account | AccountInterface, to: string, amount: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "cashier_system",
					entrypoint: "transfer_chips",
					calldata: [to, amount],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const cashier_system_setTreasuryAddress = async (snAccount: Account | AccountInterface, treasuryAddress: string) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "cashier_system",
					entrypoint: "set_treasury_address",
					calldata: [treasuryAddress],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const cashier_system_setVaultAddress = async (snAccount: Account | AccountInterface, vaultAddress: string) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "cashier_system",
					entrypoint: "set_vault_address",
					calldata: [vaultAddress],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const cashier_system_setPaymasterAddress = async (snAccount: Account | AccountInterface, paymasterAddress: string) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "cashier_system",
					entrypoint: "set_paymaster_address",
					calldata: [paymasterAddress],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const cashier_system_getTreasuryAddress = async () => {
		try {
			return await provider.call("dominion", {
				contractName: "cashier_system",
				entrypoint: "get_treasury_address",
				calldata: [],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const cashier_system_getVaultAddress = async () => {
		try {
			return await provider.call("dominion", {
				contractName: "cashier_system",
				entrypoint: "get_vault_address",
				calldata: [],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const cashier_system_getPaymasterAddress = async () => {
		try {
			return await provider.call("dominion", {
				contractName: "cashier_system",
				entrypoint: "get_paymaster_address",
				calldata: [],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_postEncryptDeck = async (snAccount: Account | AccountInterface, tableId: BigNumberish, encryptedDeck: Array<StructCard>) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "table_management_system",
					entrypoint: "post_encrypt_deck",
					calldata: [tableId, encryptedDeck],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_postDecryptedCommunityCards = async (snAccount: Account | AccountInterface, tableId: BigNumberish, cards: Array<StructCard>) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "table_management_system",
					entrypoint: "post_decrypted_community_cards",
					calldata: [tableId, cards],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_skipTurn = async (snAccount: Account | AccountInterface, tableId: BigNumberish, player: string) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "table_management_system",
					entrypoint: "skip_turn",
					calldata: [tableId, player],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_kickPlayer = async (snAccount: Account | AccountInterface, tableId: BigNumberish, player: string) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "table_management_system",
					entrypoint: "kick_player",
					calldata: [tableId, player],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_createTable = async (snAccount: Account | AccountInterface, smallBlind: BigNumberish, bigBlind: BigNumberish, minBuyIn: BigNumberish, maxBuyIn: BigNumberish, rakeFee: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "table_management_system",
					entrypoint: "create_table",
					calldata: [smallBlind, bigBlind, minBuyIn, maxBuyIn, rakeFee],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_shutdownTable = async (snAccount: Account | AccountInterface, tableId: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "table_management_system",
					entrypoint: "shutdown_table",
					calldata: [tableId],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_changeTableManager = async (snAccount: Account | AccountInterface, newTableManager: string) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "table_management_system",
					entrypoint: "change_table_manager",
					calldata: [newTableManager],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_getTableManager = async () => {
		try {
			return await provider.call("dominion", {
				contractName: "table_management_system",
				entrypoint: "get_table_manager",
				calldata: [],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_getTableLength = async () => {
		try {
			return await provider.call("dominion", {
				contractName: "table_management_system",
				entrypoint: "get_table_length",
				calldata: [],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_getGameState = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", {
				contractName: "table_management_system",
				entrypoint: "get_game_state",
				calldata: [tableId],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_getTablePlayers = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", {
				contractName: "table_management_system",
				entrypoint: "get_table_players",
				calldata: [tableId],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_getCurrentTurn = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", {
				contractName: "table_management_system",
				entrypoint: "get_current_turn",
				calldata: [tableId],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_getCurrentSidepots = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", {
				contractName: "table_management_system",
				entrypoint: "get_current_sidepots",
				calldata: [tableId],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_getTableCommunityCards = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", {
				contractName: "table_management_system",
				entrypoint: "get_table_community_cards",
				calldata: [tableId],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_isDeckEncrypted = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", {
				contractName: "table_management_system",
				entrypoint: "is_deck_encrypted",
				calldata: [tableId],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_getTableLastPlayedTs = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", {
				contractName: "table_management_system",
				entrypoint: "get_table_last_played_ts",
				calldata: [tableId],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_getTableMinBuyIn = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", {
				contractName: "table_management_system",
				entrypoint: "get_table_min_buy_in",
				calldata: [tableId],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_getTableMaxBuyIn = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", {
				contractName: "table_management_system",
				entrypoint: "get_table_max_buy_in",
				calldata: [tableId],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_getTableRakeFee = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", {
				contractName: "table_management_system",
				entrypoint: "get_table_rake_fee",
				calldata: [tableId],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const table_management_system_getTableLastRaiser = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", {
				contractName: "table_management_system",
				entrypoint: "get_table_last_raiser",
				calldata: [tableId],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const actions_system_bet = async (snAccount: Account | AccountInterface, tableId: BigNumberish, amount: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "actions_system",
					entrypoint: "bet",
					calldata: [tableId, amount],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const actions_system_fold = async (snAccount: Account | AccountInterface, tableId: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "actions_system",
					entrypoint: "fold",
					calldata: [tableId],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const actions_system_postAuthHash = async (snAccount: Account | AccountInterface, tableId: BigNumberish, authHash: ByteArray) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "actions_system",
					entrypoint: "post_auth_hash",
					calldata: [tableId, authHash],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const actions_system_postCommitHash = async (snAccount: Account | AccountInterface, tableId: BigNumberish, commitmentHash: Array<BigNumberish>) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "actions_system",
					entrypoint: "post_commit_hash",
					calldata: [tableId, commitmentHash],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const actions_system_topUpTableChips = async (snAccount: Account | AccountInterface, tableId: BigNumberish, chipsAmount: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "actions_system",
					entrypoint: "top_up_table_chips",
					calldata: [tableId, chipsAmount],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const actions_system_setReady = async (snAccount: Account | AccountInterface, tableId: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "actions_system",
					entrypoint: "set_ready",
					calldata: [tableId],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const actions_system_joinTable = async (snAccount: Account | AccountInterface, tableId: BigNumberish, chipsAmount: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "actions_system",
					entrypoint: "join_table",
					calldata: [tableId, chipsAmount],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const actions_system_leaveTable = async (snAccount: Account | AccountInterface, tableId: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "actions_system",
					entrypoint: "leave_table",
					calldata: [tableId],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const actions_system_revealHandToAll = async (snAccount: Account | AccountInterface, tableId: BigNumberish, decryptedHand: Array<StructCard>, request: ByteArray) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "actions_system",
					entrypoint: "reveal_hand_to_all",
					calldata: [tableId, decryptedHand, request],
				},
				"dominion",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const actions_system_getPlayerState = async (tableId: BigNumberish, player: string) => {
		try {
			return await provider.call("dominion", {
				contractName: "actions_system",
				entrypoint: "get_player_state",
				calldata: [tableId, player],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const actions_system_getPlayerBet = async (tableId: BigNumberish, player: string) => {
		try {
			return await provider.call("dominion", {
				contractName: "actions_system",
				entrypoint: "get_player_bet",
				calldata: [tableId, player],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const actions_system_getPlayerPosition = async (tableId: BigNumberish, player: string) => {
		try {
			return await provider.call("dominion", {
				contractName: "actions_system",
				entrypoint: "get_player_position",
				calldata: [tableId, player],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const actions_system_getPlayerTotalChips = async (tableId: BigNumberish, player: string) => {
		try {
			return await provider.call("dominion", {
				contractName: "actions_system",
				entrypoint: "get_player_total_chips",
				calldata: [tableId, player],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const actions_system_getPlayerTableChips = async (tableId: BigNumberish, player: string) => {
		try {
			return await provider.call("dominion", {
				contractName: "actions_system",
				entrypoint: "get_player_table_chips",
				calldata: [tableId, player],
			});
		} catch (error) {
			console.error(error);
		}
	};

	const actions_system_hasPlayerRevealed = async (tableId: BigNumberish, player: string) => {
		try {
			return await provider.call("dominion", {
				contractName: "actions_system",
				entrypoint: "has_player_revealed",
				calldata: [tableId, player],
			});
		} catch (error) {
			console.error(error);
		}
	};

	return {
		cashier_system: {
			depositErc20: cashier_system_depositErc20,
			cashoutErc20: cashier_system_cashoutErc20,
			claimFees: cashier_system_claimFees,
			transferChips: cashier_system_transferChips,
			setTreasuryAddress: cashier_system_setTreasuryAddress,
			setVaultAddress: cashier_system_setVaultAddress,
			setPaymasterAddress: cashier_system_setPaymasterAddress,
			getTreasuryAddress: cashier_system_getTreasuryAddress,
			getVaultAddress: cashier_system_getVaultAddress,
			getPaymasterAddress: cashier_system_getPaymasterAddress,
		},
		table_management_system: {
			postEncryptDeck: table_management_system_postEncryptDeck,
			postDecryptedCommunityCards: table_management_system_postDecryptedCommunityCards,
			skipTurn: table_management_system_skipTurn,
			kickPlayer: table_management_system_kickPlayer,
			createTable: table_management_system_createTable,
			shutdownTable: table_management_system_shutdownTable,
			changeTableManager: table_management_system_changeTableManager,
			getTableManager: table_management_system_getTableManager,
			getTableLength: table_management_system_getTableLength,
			getGameState: table_management_system_getGameState,
			getTablePlayers: table_management_system_getTablePlayers,
			getCurrentTurn: table_management_system_getCurrentTurn,
			getCurrentSidepots: table_management_system_getCurrentSidepots,
			getTableCommunityCards: table_management_system_getTableCommunityCards,
			isDeckEncrypted: table_management_system_isDeckEncrypted,
			getTableLastPlayedTs: table_management_system_getTableLastPlayedTs,
			getTableMinBuyIn: table_management_system_getTableMinBuyIn,
			getTableMaxBuyIn: table_management_system_getTableMaxBuyIn,
			getTableRakeFee: table_management_system_getTableRakeFee,
			getTableLastRaiser: table_management_system_getTableLastRaiser,
		},
		actions_system: {
			bet: actions_system_bet,
			fold: actions_system_fold,
			postAuthHash: actions_system_postAuthHash,
			postCommitHash: actions_system_postCommitHash,
			topUpTableChips: actions_system_topUpTableChips,
			setReady: actions_system_setReady,
			joinTable: actions_system_joinTable,
			leaveTable: actions_system_leaveTable,
			revealHandToAll: actions_system_revealHandToAll,
			getPlayerState: actions_system_getPlayerState,
			getPlayerBet: actions_system_getPlayerBet,
			getPlayerPosition: actions_system_getPlayerPosition,
			getPlayerTotalChips: actions_system_getPlayerTotalChips,
			getPlayerTableChips: actions_system_getPlayerTableChips,
			hasPlayerRevealed: actions_system_hasPlayerRevealed,
		},
	};
}