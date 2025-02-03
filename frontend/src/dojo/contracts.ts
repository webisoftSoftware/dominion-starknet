import { DojoProvider, DojoCall } from "@dojoengine/core";
import {
  Account,
  AccountInterface,
  BigNumberish,
  ByteArray,
  cairo, CallData,
} from 'starknet';
import {StructCard} from "./models";

export function setupWorld(provider: DojoProvider) {

	const build_actions_system_bet_calldata = (tableId: BigNumberish, amount: BigNumberish): DojoCall => {
		return {
			contractName: "actions_system",
			entrypoint: "bet",
			calldata: [tableId, amount],
		};
	};

	const actions_system_bet = async (snAccount: Account | AccountInterface, tableId: BigNumberish, amount: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_actions_system_bet_calldata(tableId, amount),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cashier_system_cashoutErc20_calldata = (chipsAmount: BigNumberish): DojoCall => {
		return {
			contractName: "cashier_system",
			entrypoint: "cashout_erc20",
			calldata: [chipsAmount],
		};
	};

	const cashier_system_cashoutErc20 = async (snAccount: Account | AccountInterface, chipsAmount: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_cashier_system_cashoutErc20_calldata(chipsAmount),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_changeTableManager_calldata = (newTableManager: string): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "change_table_manager",
			calldata: [newTableManager],
		};
	};

	const table_management_system_changeTableManager = async (snAccount: Account | AccountInterface, newTableManager: string) => {
		try {
			return await provider.execute(
				snAccount,
				build_table_management_system_changeTableManager_calldata(newTableManager),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cashier_system_claimFees_calldata = (): DojoCall => {
		return {
			contractName: "cashier_system",
			entrypoint: "claim_fees",
			calldata: [],
		};
	};

	const cashier_system_claimFees = async (snAccount: Account | AccountInterface) => {
		try {
			return await provider.execute(
				snAccount,
				build_cashier_system_claimFees_calldata(),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_createTable_calldata = (smallBlind: BigNumberish, bigBlind: BigNumberish, minBuyIn: BigNumberish, maxBuyIn: BigNumberish, rakeFee: BigNumberish): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "create_table",
			calldata: [smallBlind, bigBlind, minBuyIn, maxBuyIn, rakeFee],
		};
	};

	const table_management_system_createTable = async (snAccount: Account | AccountInterface, smallBlind: BigNumberish, bigBlind: BigNumberish, minBuyIn: BigNumberish, maxBuyIn: BigNumberish, rakeFee: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_table_management_system_createTable_calldata(smallBlind, bigBlind, minBuyIn, maxBuyIn, rakeFee),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cashier_system_depositErc20_calldata = (amount: BigNumberish): DojoCall => {
		return {
			contractName: "cashier_system",
			entrypoint: "deposit_erc20",
			calldata: [cairo.uint256(amount)],
		};
	};

	const cashier_system_depositErc20 = async (snAccount: Account | AccountInterface, amount: BigNumberish) => {
		try {
      console.log("[DOJO]: \tDepositing : ", build_cashier_system_depositErc20_calldata(amount));
			return await provider.execute(
				snAccount,
				build_cashier_system_depositErc20_calldata(amount),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_actions_system_fold_calldata = (tableId: BigNumberish): DojoCall => {
		return {
			contractName: "actions_system",
			entrypoint: "fold",
			calldata: [tableId],
		};
	};

	const actions_system_fold = async (snAccount: Account | AccountInterface, tableId: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_actions_system_fold_calldata(tableId),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_getCurrentSidepots_calldata = (tableId: BigNumberish): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "get_current_sidepots",
			calldata: [tableId],
		};
	};

	const table_management_system_getCurrentSidepots = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", build_table_management_system_getCurrentSidepots_calldata(tableId));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_getCurrentTurn_calldata = (tableId: BigNumberish): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "get_current_turn",
			calldata: [tableId],
		};
	};

	const table_management_system_getCurrentTurn = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", build_table_management_system_getCurrentTurn_calldata(tableId));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_getGameState_calldata = (tableId: BigNumberish): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "get_game_state",
			calldata: [tableId],
		};
	};

	const table_management_system_getGameState = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", build_table_management_system_getGameState_calldata(tableId));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cashier_system_getPaymasterAddress_calldata = (): DojoCall => {
		return {
			contractName: "cashier_system",
			entrypoint: "get_paymaster_address",
			calldata: [],
		};
	};

	const cashier_system_getPaymasterAddress = async () => {
		try {
			return await provider.call("dominion", build_cashier_system_getPaymasterAddress_calldata());
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cashier_system_getPlayerBalance_calldata = (player: string): DojoCall => {
		return {
			contractName: "cashier_system",
			entrypoint: "get_player_balance",
			calldata: [player],
		};
	};

	const cashier_system_getPlayerBalance = async (player: string) => {
		try {
			return await provider.call("dominion", build_cashier_system_getPlayerBalance_calldata(player));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_actions_system_getPlayerBet_calldata = (tableId: BigNumberish, player: string): DojoCall => {
		return {
			contractName: "actions_system",
			entrypoint: "get_player_bet",
			calldata: [tableId, player],
		};
	};

	const actions_system_getPlayerBet = async (tableId: BigNumberish, player: string) => {
		try {
			return await provider.call("dominion", build_actions_system_getPlayerBet_calldata(tableId, player));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_actions_system_getPlayerPosition_calldata = (tableId: BigNumberish, player: string): DojoCall => {
		return {
			contractName: "actions_system",
			entrypoint: "get_player_position",
			calldata: [tableId, player],
		};
	};

	const actions_system_getPlayerPosition = async (tableId: BigNumberish, player: string) => {
		try {
			return await provider.call("dominion", build_actions_system_getPlayerPosition_calldata(tableId, player));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_actions_system_getPlayerState_calldata = (tableId: BigNumberish, player: string): DojoCall => {
		return {
			contractName: "actions_system",
			entrypoint: "get_player_state",
			calldata: [tableId, player],
		};
	};

	const actions_system_getPlayerState = async (tableId: BigNumberish, player: string) => {
		try {
			return await provider.call("dominion", build_actions_system_getPlayerState_calldata(tableId, player));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_actions_system_getPlayerTableChips_calldata = (tableId: BigNumberish, player: string): DojoCall => {
		return {
			contractName: "actions_system",
			entrypoint: "get_player_table_chips",
			calldata: [tableId, player],
		};
	};

	const actions_system_getPlayerTableChips = async (tableId: BigNumberish, player: string) => {
		try {
			return await provider.call("dominion", build_actions_system_getPlayerTableChips_calldata(tableId, player));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_getTableCommunityCards_calldata = (tableId: BigNumberish): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "get_table_community_cards",
			calldata: [tableId],
		};
	};

	const table_management_system_getTableCommunityCards = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", build_table_management_system_getTableCommunityCards_calldata(tableId));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_getTableLastPlayedTs_calldata = (tableId: BigNumberish): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "get_table_last_played_ts",
			calldata: [tableId],
		};
	};

	const table_management_system_getTableLastPlayedTs = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", build_table_management_system_getTableLastPlayedTs_calldata(tableId));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_getTableLastRaiser_calldata = (tableId: BigNumberish): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "get_table_last_raiser",
			calldata: [tableId],
		};
	};

	const table_management_system_getTableLastRaiser = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", build_table_management_system_getTableLastRaiser_calldata(tableId));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_getTableLength_calldata = (): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "get_table_length",
			calldata: [],
		};
	};

	const table_management_system_getTableLength = async () => {
		try {
			return await provider.call("dominion", build_table_management_system_getTableLength_calldata());
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_getTableManager_calldata = (): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "get_table_manager",
			calldata: [],
		};
	};

	const table_management_system_getTableManager = async () => {
		try {
			return await provider.call("dominion", build_table_management_system_getTableManager_calldata());
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_getTableMaxBuyIn_calldata = (tableId: BigNumberish): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "get_table_max_buy_in",
			calldata: [tableId],
		};
	};

	const table_management_system_getTableMaxBuyIn = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", build_table_management_system_getTableMaxBuyIn_calldata(tableId));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_getTableMinBuyIn_calldata = (tableId: BigNumberish): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "get_table_min_buy_in",
			calldata: [tableId],
		};
	};

	const table_management_system_getTableMinBuyIn = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", build_table_management_system_getTableMinBuyIn_calldata(tableId));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_getTablePlayers_calldata = (tableId: BigNumberish): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "get_table_players",
			calldata: [tableId],
		};
	};

	const table_management_system_getTablePlayers = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", build_table_management_system_getTablePlayers_calldata(tableId));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_getTableRakeFee_calldata = (tableId: BigNumberish): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "get_table_rake_fee",
			calldata: [tableId],
		};
	};

	const table_management_system_getTableRakeFee = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", build_table_management_system_getTableRakeFee_calldata(tableId));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cashier_system_getTreasuryAddress_calldata = (): DojoCall => {
		return {
			contractName: "cashier_system",
			entrypoint: "get_treasury_address",
			calldata: [],
		};
	};

	const cashier_system_getTreasuryAddress = async () => {
		try {
			return await provider.call("dominion", build_cashier_system_getTreasuryAddress_calldata());
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cashier_system_getVaultAddress_calldata = (): DojoCall => {
		return {
			contractName: "cashier_system",
			entrypoint: "get_vault_address",
			calldata: [],
		};
	};

	const cashier_system_getVaultAddress = async () => {
		try {
			return await provider.call("dominion", build_cashier_system_getVaultAddress_calldata());
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_actions_system_hasPlayerRevealed_calldata = (tableId: BigNumberish, player: string): DojoCall => {
		return {
			contractName: "actions_system",
			entrypoint: "has_player_revealed",
			calldata: [tableId, player],
		};
	};

	const actions_system_hasPlayerRevealed = async (tableId: BigNumberish, player: string) => {
		try {
			return await provider.call("dominion", build_actions_system_hasPlayerRevealed_calldata(tableId, player));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_isDeckEncrypted_calldata = (tableId: BigNumberish): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "is_deck_encrypted",
			calldata: [tableId],
		};
	};

	const table_management_system_isDeckEncrypted = async (tableId: BigNumberish) => {
		try {
			return await provider.call("dominion", build_table_management_system_isDeckEncrypted_calldata(tableId));
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_actions_system_joinTable_calldata = (tableId: BigNumberish, chipsAmount: BigNumberish): DojoCall => {
		return {
			contractName: "actions_system",
			entrypoint: "join_table",
			calldata: [tableId, chipsAmount],
		};
	};

	const actions_system_joinTable = async (snAccount: Account | AccountInterface, tableId: BigNumberish, chipsAmount: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_actions_system_joinTable_calldata(tableId, chipsAmount),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_kickPlayer_calldata = (tableId: BigNumberish, player: string): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "kick_player",
			calldata: [tableId, player],
		};
	};

	const table_management_system_kickPlayer = async (snAccount: Account | AccountInterface, tableId: BigNumberish, player: string) => {
		try {
			return await provider.execute(
				snAccount,
				build_table_management_system_kickPlayer_calldata(tableId, player),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_actions_system_leaveTable_calldata = (tableId: BigNumberish): DojoCall => {
		return {
			contractName: "actions_system",
			entrypoint: "leave_table",
			calldata: [tableId],
		};
	};

	const actions_system_leaveTable = async (snAccount: Account | AccountInterface, tableId: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_actions_system_leaveTable_calldata(tableId),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_actions_system_postAuthHash_calldata = (tableId: BigNumberish, authHash: ByteArray): DojoCall => {
		return {
			contractName: "actions_system",
			entrypoint: "post_auth_hash",
			calldata: [tableId, authHash],
		};
	};

	const actions_system_postAuthHash = async (snAccount: Account | AccountInterface, tableId: BigNumberish, authHash: ByteArray) => {
		try {
			return await provider.execute(
				snAccount,
				build_actions_system_postAuthHash_calldata(tableId, authHash),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_actions_system_postCommitHash_calldata = (tableId: BigNumberish, commitmentHash: Array<BigNumberish>): DojoCall => {
		return {
			contractName: "actions_system",
			entrypoint: "post_commit_hash",
			calldata: [tableId, commitmentHash],
		};
	};

	const actions_system_postCommitHash = async (snAccount: Account | AccountInterface, tableId: BigNumberish, commitmentHash: Array<BigNumberish>) => {
		try {
			return await provider.execute(
				snAccount,
				build_actions_system_postCommitHash_calldata(tableId, commitmentHash),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_postDecryptedCommunityCards_calldata = (tableId: BigNumberish, cards: Array<StructCard>): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "post_decrypted_community_cards",
			calldata: [tableId, cards],
		};
	};

	const table_management_system_postDecryptedCommunityCards = async (snAccount: Account | AccountInterface, tableId: BigNumberish, cards: Array<StructCard>) => {
		try {
			return await provider.execute(
				snAccount,
				build_table_management_system_postDecryptedCommunityCards_calldata(tableId, cards),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_postEncryptDeck_calldata = (tableId: BigNumberish, encryptedDeck: Array<StructCard>): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "post_encrypt_deck",
			calldata: [tableId, encryptedDeck],
		};
	};

	const table_management_system_postEncryptDeck = async (snAccount: Account | AccountInterface, tableId: BigNumberish, encryptedDeck: Array<StructCard>) => {
		try {
			return await provider.execute(
				snAccount,
				build_table_management_system_postEncryptDeck_calldata(tableId, encryptedDeck),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_actions_system_revealHandToAll_calldata = (tableId: BigNumberish, decryptedHand: Array<StructCard>, request: ByteArray): DojoCall => {
		return {
			contractName: "actions_system",
			entrypoint: "reveal_hand_to_all",
			calldata: [tableId, decryptedHand, request],
		};
	};

	const actions_system_revealHandToAll = async (snAccount: Account | AccountInterface, tableId: BigNumberish, decryptedHand: Array<StructCard>, request: ByteArray) => {
		try {
			return await provider.execute(
				snAccount,
				build_actions_system_revealHandToAll_calldata(tableId, decryptedHand, request),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cashier_system_setPaymasterAddress_calldata = (paymasterAddress: string): DojoCall => {
		return {
			contractName: "cashier_system",
			entrypoint: "set_paymaster_address",
			calldata: [paymasterAddress],
		};
	};

	const cashier_system_setPaymasterAddress = async (snAccount: Account | AccountInterface, paymasterAddress: string) => {
		try {
			return await provider.execute(
				snAccount,
				build_cashier_system_setPaymasterAddress_calldata(paymasterAddress),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_actions_system_setReady_calldata = (tableId: BigNumberish): DojoCall => {
		return {
			contractName: "actions_system",
			entrypoint: "set_ready",
			calldata: [tableId],
		};
	};

	const actions_system_setReady = async (snAccount: Account | AccountInterface, tableId: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_actions_system_setReady_calldata(tableId),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cashier_system_setTreasuryAddress_calldata = (treasuryAddress: string): DojoCall => {
		return {
			contractName: "cashier_system",
			entrypoint: "set_treasury_address",
			calldata: [treasuryAddress],
		};
	};

	const cashier_system_setTreasuryAddress = async (snAccount: Account | AccountInterface, treasuryAddress: string) => {
		try {
			return await provider.execute(
				snAccount,
				build_cashier_system_setTreasuryAddress_calldata(treasuryAddress),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cashier_system_setVaultAddress_calldata = (vaultAddress: string): DojoCall => {
		return {
			contractName: "cashier_system",
			entrypoint: "set_vault_address",
			calldata: [vaultAddress],
		};
	};

	const cashier_system_setVaultAddress = async (snAccount: Account | AccountInterface, vaultAddress: string) => {
		try {
			return await provider.execute(
				snAccount,
				build_cashier_system_setVaultAddress_calldata(vaultAddress),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_shutdownTable_calldata = (tableId: BigNumberish): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "shutdown_table",
			calldata: [tableId],
		};
	};

	const table_management_system_shutdownTable = async (snAccount: Account | AccountInterface, tableId: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_table_management_system_shutdownTable_calldata(tableId),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_table_management_system_skipTurn_calldata = (tableId: BigNumberish, player: string): DojoCall => {
		return {
			contractName: "table_management_system",
			entrypoint: "skip_turn",
			calldata: [tableId, player],
		};
	};

	const table_management_system_skipTurn = async (snAccount: Account | AccountInterface, tableId: BigNumberish, player: string) => {
		try {
			return await provider.execute(
				snAccount,
				build_table_management_system_skipTurn_calldata(tableId, player),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_actions_system_topUpTableChips_calldata = (tableId: BigNumberish, chipsAmount: BigNumberish): DojoCall => {
		return {
			contractName: "actions_system",
			entrypoint: "top_up_table_chips",
			calldata: [tableId, chipsAmount],
		};
	};

	const actions_system_topUpTableChips = async (snAccount: Account | AccountInterface, tableId: BigNumberish, chipsAmount: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_actions_system_topUpTableChips_calldata(tableId, chipsAmount),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};

	const build_cashier_system_transferChips_calldata = (to: string, amount: BigNumberish): DojoCall => {
		return {
			contractName: "cashier_system",
			entrypoint: "transfer_chips",
			calldata: [to, amount],
		};
	};

	const cashier_system_transferChips = async (snAccount: Account | AccountInterface, to: string, amount: BigNumberish) => {
		try {
			return await provider.execute(
				snAccount,
				build_cashier_system_transferChips_calldata(to, amount),
				"dominion",
			);
		} catch (error) {
			console.error(error);
			throw error;
		}
	};



	return {
		actions_system: {
			bet: actions_system_bet,
			buildBetCalldata: build_actions_system_bet_calldata,
			fold: actions_system_fold,
			buildFoldCalldata: build_actions_system_fold_calldata,
			getPlayerBet: actions_system_getPlayerBet,
			buildGetPlayerBetCalldata: build_actions_system_getPlayerBet_calldata,
			getPlayerPosition: actions_system_getPlayerPosition,
			buildGetPlayerPositionCalldata: build_actions_system_getPlayerPosition_calldata,
			getPlayerState: actions_system_getPlayerState,
			buildGetPlayerStateCalldata: build_actions_system_getPlayerState_calldata,
			getPlayerTableChips: actions_system_getPlayerTableChips,
			buildGetPlayerTableChipsCalldata: build_actions_system_getPlayerTableChips_calldata,
			hasPlayerRevealed: actions_system_hasPlayerRevealed,
			buildHasPlayerRevealedCalldata: build_actions_system_hasPlayerRevealed_calldata,
			joinTable: actions_system_joinTable,
			buildJoinTableCalldata: build_actions_system_joinTable_calldata,
			leaveTable: actions_system_leaveTable,
			buildLeaveTableCalldata: build_actions_system_leaveTable_calldata,
			postAuthHash: actions_system_postAuthHash,
			buildPostAuthHashCalldata: build_actions_system_postAuthHash_calldata,
			postCommitHash: actions_system_postCommitHash,
			buildPostCommitHashCalldata: build_actions_system_postCommitHash_calldata,
			revealHandToAll: actions_system_revealHandToAll,
			buildRevealHandToAllCalldata: build_actions_system_revealHandToAll_calldata,
			setReady: actions_system_setReady,
			buildSetReadyCalldata: build_actions_system_setReady_calldata,
			topUpTableChips: actions_system_topUpTableChips,
			buildTopUpTableChipsCalldata: build_actions_system_topUpTableChips_calldata,
		},
		cashier_system: {
			cashoutErc20: cashier_system_cashoutErc20,
			buildCashoutErc20Calldata: build_cashier_system_cashoutErc20_calldata,
			claimFees: cashier_system_claimFees,
			buildClaimFeesCalldata: build_cashier_system_claimFees_calldata,
			depositErc20: cashier_system_depositErc20,
			buildDepositErc20Calldata: build_cashier_system_depositErc20_calldata,
			getPaymasterAddress: cashier_system_getPaymasterAddress,
			buildGetPaymasterAddressCalldata: build_cashier_system_getPaymasterAddress_calldata,
			getPlayerBalance: cashier_system_getPlayerBalance,
			buildGetPlayerBalanceCalldata: build_cashier_system_getPlayerBalance_calldata,
			getTreasuryAddress: cashier_system_getTreasuryAddress,
			buildGetTreasuryAddressCalldata: build_cashier_system_getTreasuryAddress_calldata,
			getVaultAddress: cashier_system_getVaultAddress,
			buildGetVaultAddressCalldata: build_cashier_system_getVaultAddress_calldata,
			setPaymasterAddress: cashier_system_setPaymasterAddress,
			buildSetPaymasterAddressCalldata: build_cashier_system_setPaymasterAddress_calldata,
			setTreasuryAddress: cashier_system_setTreasuryAddress,
			buildSetTreasuryAddressCalldata: build_cashier_system_setTreasuryAddress_calldata,
			setVaultAddress: cashier_system_setVaultAddress,
			buildSetVaultAddressCalldata: build_cashier_system_setVaultAddress_calldata,
			transferChips: cashier_system_transferChips,
			buildTransferChipsCalldata: build_cashier_system_transferChips_calldata,
		},
		table_management_system: {
			changeTableManager: table_management_system_changeTableManager,
			buildChangeTableManagerCalldata: build_table_management_system_changeTableManager_calldata,
			createTable: table_management_system_createTable,
			buildCreateTableCalldata: build_table_management_system_createTable_calldata,
			getCurrentSidepots: table_management_system_getCurrentSidepots,
			buildGetCurrentSidepotsCalldata: build_table_management_system_getCurrentSidepots_calldata,
			getCurrentTurn: table_management_system_getCurrentTurn,
			buildGetCurrentTurnCalldata: build_table_management_system_getCurrentTurn_calldata,
			getGameState: table_management_system_getGameState,
			buildGetGameStateCalldata: build_table_management_system_getGameState_calldata,
			getTableCommunityCards: table_management_system_getTableCommunityCards,
			buildGetTableCommunityCardsCalldata: build_table_management_system_getTableCommunityCards_calldata,
			getTableLastPlayedTs: table_management_system_getTableLastPlayedTs,
			buildGetTableLastPlayedTsCalldata: build_table_management_system_getTableLastPlayedTs_calldata,
			getTableLastRaiser: table_management_system_getTableLastRaiser,
			buildGetTableLastRaiserCalldata: build_table_management_system_getTableLastRaiser_calldata,
			getTableLength: table_management_system_getTableLength,
			buildGetTableLengthCalldata: build_table_management_system_getTableLength_calldata,
			getTableManager: table_management_system_getTableManager,
			buildGetTableManagerCalldata: build_table_management_system_getTableManager_calldata,
			getTableMaxBuyIn: table_management_system_getTableMaxBuyIn,
			buildGetTableMaxBuyInCalldata: build_table_management_system_getTableMaxBuyIn_calldata,
			getTableMinBuyIn: table_management_system_getTableMinBuyIn,
			buildGetTableMinBuyInCalldata: build_table_management_system_getTableMinBuyIn_calldata,
			getTablePlayers: table_management_system_getTablePlayers,
			buildGetTablePlayersCalldata: build_table_management_system_getTablePlayers_calldata,
			getTableRakeFee: table_management_system_getTableRakeFee,
			buildGetTableRakeFeeCalldata: build_table_management_system_getTableRakeFee_calldata,
			isDeckEncrypted: table_management_system_isDeckEncrypted,
			buildIsDeckEncryptedCalldata: build_table_management_system_isDeckEncrypted_calldata,
			kickPlayer: table_management_system_kickPlayer,
			buildKickPlayerCalldata: build_table_management_system_kickPlayer_calldata,
			postDecryptedCommunityCards: table_management_system_postDecryptedCommunityCards,
			buildPostDecryptedCommunityCardsCalldata: build_table_management_system_postDecryptedCommunityCards_calldata,
			postEncryptDeck: table_management_system_postEncryptDeck,
			buildPostEncryptDeckCalldata: build_table_management_system_postEncryptDeck_calldata,
			shutdownTable: table_management_system_shutdownTable,
			buildShutdownTableCalldata: build_table_management_system_shutdownTable_calldata,
			skipTurn: table_management_system_skipTurn,
			buildSkipTurnCalldata: build_table_management_system_skipTurn_calldata,
		},
	};
}
