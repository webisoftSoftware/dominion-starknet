use crate::tests::integration::utils::deploy_world;
use crate::models::traits::{
    EnumCardValueDisplay, EnumCardSuitDisplay, StructCardDisplay, ICard, ITable, StructCardEq,
    IPlayer, EnumPlayerStateDisplay
};
use crate::models::enums::{EnumGameState, EnumPlayerState, EnumCardValue, EnumCardSuit};
use crate::models::components::{ComponentTable, ComponentPlayer, ComponentHand};
use crate::systems::table_manager::{ITableManagementDispatcher, ITableManagementDispatcherTrait};
use alexandria_data_structures::array_ext::ArrayTraitExt;
use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest, ModelValueStorageTest};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorageTrait};
use dojo_cairo_test::{ContractDefTrait, WorldStorageTestTrait};
use starknet::ContractAddress;

// Deploy world with supplied components registered.
pub fn deploy_table_manager(ref world: dojo::world::WorldStorage) -> ITableManagementDispatcher {
    let (contract_address, _) = world.dns(@"table_management_system").unwrap();

    let system: ITableManagementDispatcher = ITableManagementDispatcher { contract_address };

    let system_def = ContractDefTrait::new(@"dominion", @"table_management_system")
        .with_writer_of([dojo::utils::bytearray_hash(@"dominion")].span());

    world.sync_perms_and_inits([system_def].span());

    return system;
}

#[test]
fn test_table_manager_create_table() {
    let mut world: dojo::world::WorldStorage = deploy_world();

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);
    let table: ComponentTable = world.read_model(1);

    assert_eq!(table.m_state, EnumGameState::WaitingForPlayers);
}

#[test]
fn test_table_manager_shutdown_table() {
    let mut world: dojo::world::WorldStorage = deploy_world();

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);
    let table: ComponentTable = world.read_model(1);

    assert_eq!(table.m_state, EnumGameState::WaitingForPlayers);

    table_manager.shutdown_table(1);
    let table: ComponentTable = world.read_model(1);

    assert_eq!(table.m_state, EnumGameState::Shutdown);
}

#[test]
fn test_table_deck() {
    let mut world: dojo::world::WorldStorage = deploy_world();

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);
    let table: ComponentTable = world.read_model(1);

    assert_eq!(table.m_deck.len(), 52);
}

#[test]
fn test_shuffle_deck() {
    let mut world: dojo::world::WorldStorage = deploy_world();

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    let initial_deck = table.m_deck.clone();

    starknet::testing::set_block_timestamp(1000);
    table.shuffle_deck(starknet::get_block_timestamp().into());

    assert_eq!(table.m_deck.len(), 52);
    assert_ne!(table.m_deck[0], initial_deck[0]);
}

#[test]
#[should_panic(expected: ("Game is not in a valid state to start a round", 'ENTRYPOINT_FAILED'))]
fn test_table_manager_start_round_invalid_state() {
    let mut world: dojo::world::WorldStorage = deploy_world();

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);
    let mut table: ComponentTable = world.read_model(1);
    table.m_state = EnumGameState::PreFlop;
    world.write_model_test(@table);

    table_manager.start_round(1);
}

#[test]
#[should_panic(expected: ("Not enough players to start the round", 'ENTRYPOINT_FAILED'))]
fn test_table_manager_start_round_not_enough_players() {
    let mut world: dojo::world::WorldStorage = deploy_world();

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);
    table_manager.start_round(1);
}

#[test]
fn test_table_manager_start_round_player_states() {
    let mut world: dojo::world::WorldStorage = deploy_world();

    let player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x2B>());

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);
    world.write_models_test(array![@player_1, @player_2].span());

    table_manager.start_round(1);

    let player_1: ComponentPlayer = world.read_model((1, player_1.m_owner));
    let player_2: ComponentPlayer = world.read_model((1, player_2.m_owner));
    let mut table: ComponentTable = world.read_model(1);

    assert!(table.m_players.len() == 2, "Table should have 2 players");
    assert!(player_1.m_state == EnumPlayerState::Active, "Player 1 should be active");
    assert!(player_2.m_state == EnumPlayerState::Active, "Player 2 should be active");
}

#[test]
#[should_panic(expected: ("Only the table manager can update the deck", 'ENTRYPOINT_FAILED'))]
fn test_table_manager_update_deck_invalid_caller() {
    let mut world: dojo::world::WorldStorage = deploy_world();

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    table_manager.post_encrypt_deck(1, array![]);
}

#[test]
#[should_panic(expected: ("Table is not in a valid state to update the deck", 'ENTRYPOINT_FAILED'))]
fn test_table_manager_update_deck_invalid_state() {
    let mut world: dojo::world::WorldStorage = deploy_world();

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_state = EnumGameState::WaitingForPlayers;
    world.write_model_test(@table);

    table_manager.post_encrypt_deck(1, table.m_deck);
}

#[test]
#[should_panic(expected: ("Deck must contain 52 cards", 'ENTRYPOINT_FAILED'))]
fn test_table_manager_update_deck_invalid_deck_length() {
    let mut world: dojo::world::WorldStorage = deploy_world();

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    table_manager.post_encrypt_deck(1, array![ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs)]);
}

#[test]
fn test_table_manager_distribute_cards() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

        table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);
    world.write_models_test(array![@player_1, @player_2].span());

    table_manager.start_round(1);
    let table: ComponentTable = world.read_model(1);
    table_manager.post_encrypt_deck(1, table.m_deck);

    let table: ComponentTable = world.read_model(1);
    let player_1_hand: ComponentHand = world.read_model(*table.m_players[0]);
    let player_2_hand: ComponentHand = world.read_model(*table.m_players[1]);

    assert!(
        table.m_deck.len() == 48,
        "Deck should contain 48 cards after distributing 2 cards to two players"
    );
    assert!(table.m_community_cards.len() == 0, "Community cards should be empty");
    assert!(table.m_deck == table.m_deck.dedup(), "Deck should not contain duplicates");
    assert!(player_1_hand.m_cards.len() == 2, "Player 1 should have 2 cards");
    assert!(player_2_hand.m_cards.len() == 2, "Player 2 should have 2 cards");
    assert!(
        table.m_state == EnumGameState::DeckEncrypted, "Table should be in DeckEncrypted state"
    );
    assert!(table.m_players.len() == 2, "Table should have 2 players");
}

#[test]
#[should_panic(expected: ("Not all players have played their turn", 'ENTRYPOINT_FAILED'))]
fn test_advance_street_not_all_players_played() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

        table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);
    world.write_models_test(array![@player_1, @player_2].span());

    table_manager.start_round(1);
    table_manager.post_encrypt_deck(1, table.m_deck);
    table_manager.advance_street(1);

    // Try to advance the street again without all players having played their turn.
    table_manager.advance_street(1);
}

#[test]
#[should_panic(expected: ("Round has not started or deck is not encrypted", 'ENTRYPOINT_FAILED'))]
fn test_advance_street_deck_not_encrypted() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

        table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);
    world.write_models_test(array![@player_1, @player_2].span());

    table_manager.start_round(1);

    let table: ComponentTable = world.read_model(1);
    assert!(table.m_state == EnumGameState::RoundStarted, "Table should be in RoundStarted state");

    table_manager.advance_street(1);
}

#[test]
#[should_panic(expected: ("Street was not just started", 'ENTRYPOINT_FAILED'))]
fn test_advance_street_invalid_pre_flop() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

        table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);
    world.write_models_test(array![@player_1, @player_2].span());

    table_manager.start_round(1);

    let table: ComponentTable = world.read_model(1);
    assert!(table.m_state == EnumGameState::RoundStarted, "Table should be in RoundStarted state");

    table_manager.post_encrypt_deck(1, table.m_deck);

    let mut table: ComponentTable = world.read_model(1);
    table.m_community_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs));
    world.write_model_test(@table);

    table_manager.advance_street(1);
}

#[test]
#[should_panic(expected: ("Street was not at pre-flop", 'ENTRYPOINT_FAILED'))]
fn test_invalid_street_invalid_flop() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

        table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);
    world.write_models_test(array![@player_1, @player_2].span());

    table_manager.start_round(1);

    let table: ComponentTable = world.read_model(1);
    assert!(table.m_state == EnumGameState::RoundStarted, "Table should be in RoundStarted state");

    table_manager.post_encrypt_deck(1, table.m_deck);

    let mut table: ComponentTable = world.read_model(1);
    table.m_state = EnumGameState::PreFlop;
    table.m_community_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs));
    table.m_community_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs));
    table.m_finished_street = true;
    world.write_model_test(@table);

    table_manager.advance_street(1);
}

#[test]
#[should_panic(expected: ("Street was not at flop", 'ENTRYPOINT_FAILED'))]
fn test_invalid_street_invalid_turn() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

        table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);
    world.write_models_test(array![@player_1, @player_2].span());

    table_manager.start_round(1);

    let table: ComponentTable = world.read_model(1);
    assert!(table.m_state == EnumGameState::RoundStarted, "Table should be in RoundStarted state");

    table_manager.post_encrypt_deck(1, table.m_deck);

    let mut table: ComponentTable = world.read_model(1);
    table.m_state = EnumGameState::Flop;
    table.m_community_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs));
    table.m_community_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs));
    table.m_finished_street = true;
    world.write_model_test(@table);

    table_manager.advance_street(1);
}

#[test]
#[should_panic(expected: ("Street was not at turn", 'ENTRYPOINT_FAILED'))]
fn test_invalid_street_invalid_river() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

        table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);
    world.write_models_test(array![@player_1, @player_2].span());

    table_manager.start_round(1);

    let table: ComponentTable = world.read_model(1);
    assert!(table.m_state == EnumGameState::RoundStarted, "Table should be in RoundStarted state");

    table_manager.post_encrypt_deck(1, table.m_deck);

    let mut table: ComponentTable = world.read_model(1);
    table.m_state = EnumGameState::Turn;
    table.m_community_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs));
    table.m_community_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs));
    table.m_community_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs));
    table.m_finished_street = true;
    world.write_model_test(@table);

    table_manager.advance_street(1);
}

#[test]
#[should_panic(expected: ("Game is shutdown", 'ENTRYPOINT_FAILED'))]
fn test_post_auth_hash_invalid_state() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

        table_manager.create_table(100, 200, 2000, 4000, 5);
    let mut table: ComponentTable = world.read_model(1);
    table.m_state = EnumGameState::Shutdown;
    world.write_model_test(@table);

    table_manager.post_auth_hash(1, "test");
}

#[test]
#[should_panic(expected: ("Player is not the current turn", 'ENTRYPOINT_FAILED'))]
fn test_skip_turn_invalid_player_turn() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

        table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);
    world.write_models_test(array![@player_1, @player_2].span());

    table_manager.start_round(1);
    let player: ComponentPlayer = world.read_model((1, *table.m_players[0]));
    println!("Player 1 state: {}", player.m_state);
    let player_2: ComponentPlayer = world.read_model((1, *table.m_players[1]));
    println!("Player 2 state: {}", player_2.m_state);
    assert!(player.m_state == EnumPlayerState::Active, "Player 1 should be active");

    table_manager.skip_turn(1, starknet::contract_address_const::<0x1B>());
}

#[test]
#[should_panic(expected: ("Round is not at showdown", 'ENTRYPOINT_FAILED'))]
fn test_showdown_invalid_state() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

        table_manager.create_table(100, 200, 2000, 4000, 5);
    table_manager.showdown(1);
}

#[test]
#[should_panic(expected: ("All Players must have revealed their hand", 'ENTRYPOINT_FAILED'))]
fn test_showdown_not_all_players_revealed() {
    // Create a table with 2 players.
    let player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

        table_manager.create_table(100, 200, 2000, 4000, 5);

    // Meet the minimum requirements for showdown.
    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    table.m_state = EnumGameState::Showdown;
    table.m_community_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs));
    table.m_community_cards.append(ICard::new(EnumCardValue::King, EnumCardSuit::Hearts));
    table.m_community_cards.append(ICard::new(EnumCardValue::Queen, EnumCardSuit::Spades));
    table.m_community_cards.append(ICard::new(EnumCardValue::Jack, EnumCardSuit::Diamonds));
    table.m_community_cards.append(ICard::new(EnumCardValue::Ten, EnumCardSuit::Clubs));
    world.write_model_test(@table);

    // Create players.
    let player_1 = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    world.write_model_test(@player_1);

    let player_2 = IPlayer::new(1, starknet::contract_address_const::<0x1B>());
    world.write_model_test(@player_2);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    table_manager.showdown(1);
}

#[test]
fn test_showdown_simple() {
    // Create a table with 2 players.
    let player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

        table_manager.create_table(100, 200, 2000, 4000, 5);

    // Meet the minimum requirements for showdown.
    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    table.m_state = EnumGameState::Showdown;
    table.m_community_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs));
    table.m_community_cards.append(ICard::new(EnumCardValue::King, EnumCardSuit::Hearts));
    table.m_community_cards.append(ICard::new(EnumCardValue::Queen, EnumCardSuit::Spades));
    table.m_community_cards.append(ICard::new(EnumCardValue::Jack, EnumCardSuit::Diamonds));
    table.m_community_cards.append(ICard::new(EnumCardValue::Ten, EnumCardSuit::Clubs));
    table.m_pot = 200;
    world.write_model_test(@table);

    // Create players.
    let mut player_1 = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    player_1.m_state = EnumPlayerState::Revealed;
    player_1.m_table_chips = 300;
    world.write_model_test(@player_1);

    let mut player_2 = IPlayer::new(1, starknet::contract_address_const::<0x1B>());
    player_2.m_state = EnumPlayerState::Revealed;
    player_2.m_table_chips = 300;
    world.write_model_test(@player_2);

    // Assign hands.
    let mut player_1_hand: ComponentHand = world.read_model(*table.m_players[0]);
    player_1_hand.m_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs));
    player_1_hand.m_cards.append(ICard::new(EnumCardValue::King, EnumCardSuit::Hearts));
    world.write_model_test(@player_1_hand);

    let mut player_2_hand: ComponentHand = world.read_model(*table.m_players[1]);
    player_2_hand.m_cards.append(ICard::new(EnumCardValue::Queen, EnumCardSuit::Spades));
    player_2_hand.m_cards.append(ICard::new(EnumCardValue::Jack, EnumCardSuit::Diamonds));
    world.write_model_test(@player_2_hand);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    table_manager.showdown(1);

    let mut table: ComponentTable = world.read_model(1);
    assert!(table.m_pot == 0, "Pot should be 0");
    assert!(table.m_community_cards.len() == 0, "Community cards should be cleared");
    assert!(table.m_state == EnumGameState::RoundStarted, "Next round should have started");

    let mut player_1: ComponentPlayer = world.read_model((1, *table.m_players[0]));
    assert!(player_1.m_state == EnumPlayerState::Active, "Player 1 should be in Active state");
    assert!(player_1.m_table_chips == 500, "Player 1 should have won 200 chips at the table");

    let mut player_2: ComponentPlayer = world.read_model((1, *table.m_players[1]));
    assert!(player_2.m_state == EnumPlayerState::Active, "Player 2 should be in Active state");
    assert!(player_2.m_table_chips == 300, "Player 2 should have lost 200 chips at the table");
}

#[test]
fn test_showdown_tie() {
    // Create a table with 2 players who will tie
    let player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

        table_manager.create_table(100, 200, 2000, 4000, 5);

    // Set up table with community cards that will result in a tie
    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    table.m_state = EnumGameState::Showdown;
    table.m_community_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs));
    table.m_community_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Hearts));
    table.m_community_cards.append(ICard::new(EnumCardValue::King, EnumCardSuit::Spades));
    table.m_community_cards.append(ICard::new(EnumCardValue::King, EnumCardSuit::Diamonds));
    table.m_community_cards.append(ICard::new(EnumCardValue::Two, EnumCardSuit::Clubs));
    table.m_pot = 200;
    world.write_model_test(@table);

    // Create players with same starting chips
    let mut player_1 = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    player_1.m_state = EnumPlayerState::Revealed;
    player_1.m_table_chips = 300;
    world.write_model_test(@player_1);

    let mut player_2 = IPlayer::new(1, starknet::contract_address_const::<0x1B>());
    player_2.m_state = EnumPlayerState::Revealed;
    player_2.m_table_chips = 300;
    world.write_model_test(@player_2);

    // Both players have same hand rank (two pair: Aces and Kings)
    let mut player_1_hand: ComponentHand = world.read_model(*table.m_players[0]);
    player_1_hand.m_cards.append(ICard::new(EnumCardValue::Queen, EnumCardSuit::Hearts));
    player_1_hand.m_cards.append(ICard::new(EnumCardValue::Queen, EnumCardSuit::Diamonds));
    world.write_model_test(@player_1_hand);

    let mut player_2_hand: ComponentHand = world.read_model(*table.m_players[1]);
    player_2_hand.m_cards.append(ICard::new(EnumCardValue::Queen, EnumCardSuit::Spades));
    player_2_hand.m_cards.append(ICard::new(EnumCardValue::Queen, EnumCardSuit::Clubs));
    world.write_model_test(@player_2_hand);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    table_manager.showdown(1);

    let table: ComponentTable = world.read_model(1);
    assert!(table.m_pot == 0, "Pot should be 0");
    assert!(table.m_community_cards.len() == 0, "Community cards should be cleared");
    assert!(table.m_state == EnumGameState::RoundStarted, "Next round should have started");

    // Both players should split the pot evenly
    let player_1: ComponentPlayer = world.read_model((1, *table.m_players[0]));
    assert!(player_1.m_table_chips == 400, "Player 1 should have won 100 chips at the table");

    let player_2: ComponentPlayer = world.read_model((1, *table.m_players[1]));
    assert!(player_2.m_table_chips == 400, "Player 2 should have won 100 chips at the table");
}

#[test]
fn test_showdown_complex() {
    // Create a table with 4 players.
    let player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());
    let player_3: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1C>());
    let player_4: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1D>());

    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);

        table_manager.create_table(100, 200, 2000, 4000, 5);

    // Set up table with community cards.
    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    table.m_players.append(player_3.m_owner);
    table.m_players.append(player_4.m_owner);
    table.m_state = EnumGameState::Showdown;
    table.m_community_cards.append(ICard::new(EnumCardValue::Ten, EnumCardSuit::Hearts));
    table.m_community_cards.append(ICard::new(EnumCardValue::Jack, EnumCardSuit::Hearts));
    table.m_community_cards.append(ICard::new(EnumCardValue::Queen, EnumCardSuit::Hearts));
    table.m_community_cards.append(ICard::new(EnumCardValue::Two, EnumCardSuit::Diamonds));
    table.m_community_cards.append(ICard::new(EnumCardValue::Three, EnumCardSuit::Clubs));
    table.m_pot = 1000;
    world.write_model_test(@table);

    // Create players with different chip stacks.
    let mut player_1 = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    player_1.m_state = EnumPlayerState::Revealed;
    player_1.m_table_chips = 500;
    world.write_model_test(@player_1);

    let mut player_2 = IPlayer::new(1, starknet::contract_address_const::<0x1B>());
    player_2.m_state = EnumPlayerState::Revealed;
    player_2.m_table_chips = 500;
    world.write_model_test(@player_2);

    let mut player_3 = IPlayer::new(1, starknet::contract_address_const::<0x1C>());
    player_3.m_state = EnumPlayerState::Revealed;
    player_3.m_table_chips = 500;
    world.write_model_test(@player_3);

    let mut player_4 = IPlayer::new(1, starknet::contract_address_const::<0x1D>());
    player_4.m_state = EnumPlayerState::Revealed;
    player_4.m_table_chips = 500;
    world.write_model_test(@player_4);

    // Assign different hands to create a clear winner.
    let mut player_1_hand: ComponentHand = world.read_model(*table.m_players[0]);
    player_1_hand.m_cards.append(ICard::new(EnumCardValue::King, EnumCardSuit::Hearts));
    player_1_hand.m_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Hearts));
    world.write_model_test(@player_1_hand);

    let mut player_2_hand: ComponentHand = world.read_model(*table.m_players[1]);
    player_2_hand.m_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Diamonds));
    player_2_hand.m_cards.append(ICard::new(EnumCardValue::King, EnumCardSuit::Diamonds));
    world.write_model_test(@player_2_hand);

    let mut player_3_hand: ComponentHand = world.read_model(*table.m_players[2]);
    player_3_hand.m_cards.append(ICard::new(EnumCardValue::Eight, EnumCardSuit::Clubs));
    player_3_hand.m_cards.append(ICard::new(EnumCardValue::Nine, EnumCardSuit::Spades));
    world.write_model_test(@player_3_hand);

    let mut player_4_hand: ComponentHand = world.read_model(*table.m_players[3]);
    player_4_hand.m_cards.append(ICard::new(EnumCardValue::Four, EnumCardSuit::Diamonds));
    player_4_hand.m_cards.append(ICard::new(EnumCardValue::Five, EnumCardSuit::Spades));
    world.write_model_test(@player_4_hand);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    table_manager.showdown(1);

    let table: ComponentTable = world.read_model(1);
    assert!(table.m_pot == 0, "Pot should be 0");
    assert!(table.m_community_cards.len() == 0, "Community cards should be cleared");
    assert!(table.m_state == EnumGameState::RoundStarted, "Next round should have started");

    // Player 1 should win with Royal Flush.
    let player_1: ComponentPlayer = world.read_model((1, *table.m_players[0]));
    println!("Player 1 chips: {}", player_1.m_table_chips);
    assert!(player_1.m_table_chips == 1500, "Player 1 should have won the entire pot");

    // Other players should not receive any chips.
    let player_2: ComponentPlayer = world.read_model((1, *table.m_players[1]));
    assert!(player_2.m_table_chips == 500, "Player 2 should not have won any chips");

    let player_3: ComponentPlayer = world.read_model((1, *table.m_players[2]));
    assert!(player_3.m_table_chips == 500, "Player 3 should not have won any chips");

    let player_4: ComponentPlayer = world.read_model((1, *table.m_players[3]));
    assert!(player_4.m_table_chips == 500, "Player 4 should not have won any chips");
}
