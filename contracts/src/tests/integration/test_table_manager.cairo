
use crate::systems::table_manager::{table_management_system, ITableManagementDispatcher, ITableManagementDispatcherTrait};
use crate::systems::actions::{IActionsDispatcher, IActionsDispatcherTrait};

use crate::models::enums::{EnumGameState, EnumPlayerState, EnumCardValue, EnumCardSuit, EnumPosition};
use crate::models::components::{ComponentTable, ComponentPlayer, ComponentHand, ComponentSidepot, StructCard};
use crate::models::traits::{
    EnumCardValueDisplay, EnumCardSuitDisplay, StructCardDisplay, ICard, ITable, StructCardEq,
    IPlayer, EnumPlayerStateDisplay, ComponentTableDisplay, ComponentHandDisplay, ComponentPlayerDisplay,
    ComponentSidepotDisplay, EnumGameStateDisplay
};




use alexandria_data_structures::array_ext::ArrayTraitExt;
use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest, ModelValueStorageTest};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorageTrait};
use dojo_cairo_test::{ContractDefTrait, WorldStorageTestTrait};
use starknet::ContractAddress;

use crate::tests::integration::utils::deploy_world;
use crate::tests::integration::test_actions::deploy_actions;

// Deploy table manager with supplied components registered.
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
    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);
    let table: ComponentTable = world.read_model(1);

    assert_eq!(table.m_state, EnumGameState::WaitingForPlayers);
}

#[test]
fn test_table_manager_shutdown_table() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager = deploy_table_manager(ref world);

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
    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);
    let table: ComponentTable = world.read_model(1);

    assert_eq!(table.m_deck.len(), 52);
}

#[test]
fn test_shuffle_deck() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    let initial_deck = table.m_deck.clone();

    starknet::testing::set_block_timestamp(1000);
    table.shuffle_deck(starknet::get_block_timestamp().into());

    assert_eq!(table.m_deck.len(), 52);
    assert_ne!(table.m_deck[0], initial_deck[0]);
}

#[test]
#[should_panic(expected: "Game is not in a valid state to start a round")]
fn test_table_manager_start_round_invalid_state() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);
    let mut table: ComponentTable = world.read_model(1);
    table.m_state = EnumGameState::PreFlop;
    world.write_model_test(@table);

    table_management_system::InternalImpl::_start_round(ref world, ref table);
    world.write_model_test(@table);
}

#[test]
#[should_panic(expected: "Not enough players to start the round")]
fn test_table_manager_start_round_not_enough_players() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);
    let mut table: ComponentTable = world.read_model(1);
    table_management_system::InternalImpl::_start_round(ref world, ref table);
    world.write_model_test(@table);
}

#[test]
fn test_table_manager_start_round_player_states() {
    let mut world: dojo::world::WorldStorage = deploy_world();

    let mut player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let mut player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x2B>());

    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);

    player_1.m_table_chips = 1000;
    player_2.m_table_chips = 1000;
    world.write_models_test(array![@player_1, @player_2].span());

    table_management_system::InternalImpl::_start_round(ref world, ref table);
    world.write_model_test(@table);

    let player_1: ComponentPlayer = world.read_model((1, player_1.m_owner));
    let player_2: ComponentPlayer = world.read_model((1, player_2.m_owner));
    let mut table: ComponentTable = world.read_model(1);

    assert!(table.m_players.len() == 2, "Table should have 2 players");
    assert!(player_1.m_position == EnumPosition::BigBlind, "Player 1 should be big blind");
    assert!(player_2.m_position == EnumPosition::SmallBlind, "Player 2 should be small blind");
    assert!(player_1.m_state == EnumPlayerState::Active, "Player 1 should be active");
    assert!(player_2.m_state == EnumPlayerState::Active, "Player 2 should be active");
}

#[test]
#[should_panic(expected: ("Only the table manager can update the deck", 'ENTRYPOINT_FAILED'))]
fn test_table_manager_update_deck_invalid_caller() {
    let mut world: dojo::world::WorldStorage = deploy_world();

    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);
    let table: ComponentTable = world.read_model(1);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    table_manager.post_encrypt_deck(1, table.m_deck);
}

#[test]
fn test_table_manager_distribute_cards() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let mut player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);

    player_1.m_table_chips = 1000;
    player_2.m_table_chips = 1000;
    world.write_models_test(array![@player_1, @player_2].span());

    table_management_system::InternalImpl::_start_round(ref world, ref table);
    world.write_model_test(@table);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x0>());
    table_manager.post_encrypt_deck(1, table.m_deck);

    let table: ComponentTable = world.read_model(1);
    let player_1_hand: ComponentHand = world.read_model(*table.m_players[0]);
    let player_2_hand: ComponentHand = world.read_model(*table.m_players[1]);
    let player_1: ComponentPlayer = world.read_model((1, *table.m_players[0]));
    let player_2: ComponentPlayer = world.read_model((1, *table.m_players[1]));

    assert!(
        table.m_deck.len() == 48,
        "Deck should contain 48 cards after distributing 2 cards to two players"
    );
    assert!(table.m_community_cards.len() == 0, "Community cards should be empty");
    assert!(table.m_deck == table.m_deck.dedup(), "Deck should not contain duplicates");
    assert!(player_1_hand.m_cards.len() == 2, "Player 1 should have 2 cards");
    assert!(player_2_hand.m_cards.len() == 2, "Player 2 should have 2 cards");
    assert!(table.m_deck_encrypted, "Deck should be encrypted");
    assert!(table.m_players.len() == 2, "Table should have 2 players");
    assert!(player_1.m_position == EnumPosition::BigBlind, "Player 1 should be big blind");
    assert!(player_2.m_position == EnumPosition::SmallBlind, "Player 2 should be small blind");
}

#[test]
#[should_panic(expected: "Street has not finished")]
fn test_advance_street_not_all_players_played() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let mut player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);

    player_1.m_table_chips = 1000;
    player_2.m_table_chips = 1000;
    world.write_models_test(array![@player_1, @player_2].span());

    table_management_system::InternalImpl::_start_round(ref world, ref table);
    table.m_deck_encrypted = true;

    table_management_system::InternalImpl::_advance_street(ref world, ref table);
    // Try to advance the street again without all players having played their turn.
    table_management_system::InternalImpl::_advance_street(ref world, ref table);
    world.write_model_test(@table);
}

#[test]
#[should_panic(expected: "Deck is not encrypted")]
fn test_advance_street_deck_not_encrypted() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let mut player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);

    player_1.m_table_chips = 1000;
    player_2.m_table_chips = 1000;
    world.write_models_test(array![@player_1, @player_2].span());

    table_management_system::InternalImpl::_start_round(ref world, ref table);
    world.write_model_test(@table);

    let mut table: ComponentTable = world.read_model(1);
    assert!(table.m_state == EnumGameState::PreFlop, "Table should be in PreFlop state");

    table_management_system::InternalImpl::_advance_street(ref world, ref table);
    world.write_model_test(@table);
}

#[test]
#[should_panic(expected: "Street has not finished")]
fn test_advance_street_skip_turns() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let mut player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);

    player_1.m_table_chips = 1000;
    player_2.m_table_chips = 1000;
    world.write_models_test(array![@player_1, @player_2].span());

    table_management_system::InternalImpl::_start_round(ref world, ref table);
    world.write_model_test(@table);

    let mut table: ComponentTable = world.read_model(1);
    assert!(table.m_state == EnumGameState::PreFlop, "Table should be in PreFlop state");

    table.m_deck_encrypted = true;
    table.m_community_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs));

    table_management_system::InternalImpl::_advance_street(ref world, ref table);
    world.write_model_test(@table);
}

#[test]
#[should_panic(expected: "Street was not at pre-flop")]
#[should_panic(expected: "Street was not at pre-flop")]
fn test_invalid_street_invalid_flop() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let mut player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);

    player_1.m_table_chips = 1000;
    player_2.m_table_chips = 1000;
    world.write_models_test(array![@player_1, @player_2].span());

    table_management_system::InternalImpl::_start_round(ref world, ref table);
    world.write_model_test(@table);

    let mut table: ComponentTable = world.read_model(1);
    assert!(table.m_state == EnumGameState::PreFlop, "Table should be in PreFlop state");

    table.m_deck_encrypted = true;
    table.m_state = EnumGameState::PreFlop;
    table.m_community_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs));
    table.m_finished_street = true;

    table_management_system::InternalImpl::_advance_street(ref world, ref table);
    world.write_model_test(@table);
}

#[test]
#[should_panic(expected: "Street was not at flop")]
fn test_invalid_street_invalid_turn() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let mut player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);

    player_1.m_table_chips = 1000;
    player_2.m_table_chips = 1000;
    world.write_models_test(array![@player_1, @player_2].span());

    table_management_system::InternalImpl::_start_round(ref world, ref table);
    world.write_model_test(@table);

    let mut table: ComponentTable = world.read_model(1);
    assert!(table.m_state == EnumGameState::PreFlop, "Table should be in PreFlop state");

    table.m_deck_encrypted = true;
    table.m_state = EnumGameState::Flop;
    table.m_community_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs));
    table.m_finished_street = true;

    table_management_system::InternalImpl::_advance_street(ref world, ref table);
    world.write_model_test(@table);
}

#[test]
#[should_panic(expected: "Street was not at turn")]
fn test_invalid_street_invalid_river() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let mut player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);

    player_1.m_table_chips = 1000;
    player_2.m_table_chips = 1000;
    world.write_models_test(array![@player_1, @player_2].span());

    table_management_system::InternalImpl::_start_round(ref world, ref table);
    world.write_model_test(@table);

    let mut table: ComponentTable = world.read_model(1);
    assert!(table.m_state == EnumGameState::PreFlop, "Table should be in PreFlop state");

    table.m_deck_encrypted = true;
    table.m_state = EnumGameState::Turn;
    table.m_community_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs));
    table.m_community_cards.append(ICard::new(EnumCardValue::Ace, EnumCardSuit::Clubs));
    table.m_finished_street = true;

    table_management_system::InternalImpl::_advance_street(ref world, ref table);
    world.write_model_test(@table);
}

#[test]
#[should_panic(expected: ("Cannot skip player's turn: Not player's turn", 'ENTRYPOINT_FAILED'))]
fn test_skip_turn_invalid_player_turn() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let mut player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    world.write_model_test(@table);

    player_1.m_table_chips = 1000;
    player_2.m_table_chips = 1000;
    world.write_models_test(array![@player_1, @player_2].span());

    table_management_system::InternalImpl::_start_round(ref world, ref table);
    world.write_model_test(@table);

    let player_1: ComponentPlayer = world.read_model((1, *table.m_players[0]));
    let player_2: ComponentPlayer = world.read_model((1, *table.m_players[1]));

    assert!(player_1.m_state == EnumPlayerState::Active, "Player 1 should be active");
    assert!(player_1.m_position == EnumPosition::BigBlind, "Player 1 should be big blind");
    assert!(player_2.m_state == EnumPlayerState::Active, "Player 2 should be active");
    assert!(player_2.m_position == EnumPosition::SmallBlind, "Player 2 should be small blind");
    table_manager.skip_turn(1, starknet::contract_address_const::<0x1A>());
}

#[test]
#[should_panic(expected: "Round is not at showdown")]
fn test_showdown_invalid_state() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);
    let mut table: ComponentTable = world.read_model(1);
    table_management_system::InternalImpl::_showdown(ref world, ref table);
    world.write_model_test(@table);
}

#[test]
#[should_panic(expected: "Player is not revealed")]
fn test_showdown_not_all_players_revealed() {
    // Create a table with 2 players.
    let player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager = deploy_table_manager(ref world);

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
    table_management_system::InternalImpl::_showdown(ref world, ref table);
    world.write_model_test(@table);
}

#[test]
fn test_showdown_simple() {
    // Create a table with 2 players.
    let player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager = deploy_table_manager(ref world);
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

    table_management_system::InternalImpl::_showdown(ref world, ref table);
    world.write_model_test(@table);

    let mut table: ComponentTable = world.read_model(1);

    assert!(!table.m_deck_encrypted, "Deck should be decrypted");
    assert!(table.m_community_cards.len() == 0, "Community cards should be cleared");
    assert!(table.m_state == EnumGameState::PreFlop, "Next round should have started");

    let mut player_1: ComponentPlayer = world.read_model((1, *table.m_players[0]));
    assert!(player_1.m_state == EnumPlayerState::Active, "Player 1 should be in Active state");
    assert!(player_1.m_table_chips == 290, "Player 1 should have 190 chips (300 + (200 - 5%) - 200 (BB)) at the table");

    let mut player_2: ComponentPlayer = world.read_model((1, *table.m_players[1]));
    assert!(player_2.m_state == EnumPlayerState::Active, "Player 2 should be in Active state");
    assert!(player_2.m_table_chips == 200, "Player 2 should have 200 chips (300 - 100 (SB)) at the table");
}

#[test]
fn test_showdown_tie() {
    // Create a table with 2 players who will tie
    let player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());

    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager = deploy_table_manager(ref world);
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

    table_management_system::InternalImpl::_showdown(ref world, ref table);
    world.write_model_test(@table);

    let table: ComponentTable = world.read_model(1);

    assert!(!table.m_deck_encrypted, "Deck should be decrypted");
    assert!(table.m_community_cards.len() == 0, "Community cards should be cleared");
    assert!(table.m_state == EnumGameState::PreFlop, "Next round should have started");

    // Both players should split the pot evenly
    let player_1: ComponentPlayer = world.read_model((1, *table.m_players[0]));
    assert!(player_1.m_table_chips == 195, "Player 1 should have 195 chips (200 + (100 - 5%) - 200 (BB)) at the table");

    let player_2: ComponentPlayer = world.read_model((1, *table.m_players[1]));
    assert!(player_2.m_table_chips == 295, "Player 2 should have 295 chips (200 + (100 - 5%) - 100 (SB)) at the table");
}

#[test]
fn test_showdown_complex() {
    // Create a table with 4 players.
    let player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());
    let player_3: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1C>());
    let player_4: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1D>());

    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager = deploy_table_manager(ref world);
    
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

    table_management_system::InternalImpl::_showdown(ref world, ref table);
    world.write_model_test(@table);

    let table: ComponentTable = world.read_model(1);

    assert!(!table.m_deck_encrypted, "Deck should be decrypted");
    assert!(table.m_community_cards.len() == 0, "Community cards should be cleared");
    assert!(table.m_state == EnumGameState::PreFlop, "Next round should have started");

    // Player 1 should win with Royal Flush.
    let player_1: ComponentPlayer = world.read_model((1, *table.m_players[0]));
    assert!(player_1.m_table_chips == 1450, "Player 1 should have won the entire pot (1500 - 5%)");

    // Other players should not receive any chips.
    let player_2: ComponentPlayer = world.read_model((1, *table.m_players[1]));
    assert!(player_2.m_table_chips == 400, "Player 2 should not have won any chips");

    let player_3: ComponentPlayer = world.read_model((1, *table.m_players[2]));
    assert!(player_3.m_table_chips == 300, "Player 3 should not have won any chips");

    let player_4: ComponentPlayer = world.read_model((1, *table.m_players[3]));
    assert!(player_4.m_table_chips == 500, "Player 4 should not have won any chips");
}

#[test]
fn test_assign_sidepots_simple() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager = deploy_table_manager(ref world);
    table_manager.create_table(100, 200, 2000, 4000, 5);

    // All 4 players are all in.
    let mut player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    player_1.m_table_chips = 5000;
    player_1.m_current_bet = 5000;
    player_1.m_state = EnumPlayerState::Revealed;
    world.write_model_test(@player_1);

    let mut player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());
    player_2.m_table_chips = 4000;
    player_2.m_current_bet = 4000;
    player_2.m_state = EnumPlayerState::Revealed;
    world.write_model_test(@player_2);

    let mut player_3: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1C>());
    player_3.m_table_chips = 3000;
    player_3.m_current_bet = 3000;
    player_3.m_state = EnumPlayerState::Revealed;
    world.write_model_test(@player_3);

    let mut player_4: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1D>());
    player_4.m_table_chips = 2000;
    player_4.m_current_bet = 2000;
    player_4.m_state = EnumPlayerState::Revealed;
    world.write_model_test(@player_4);

    let mut table: ComponentTable = world.read_model(1);
    table.m_players.append(player_1.m_owner);
    table.m_players.append(player_2.m_owner);
    table.m_players.append(player_3.m_owner);
    table.m_players.append(player_4.m_owner);
    table.m_pot = 14000;
    world.write_model_test(@table);

    let players = array![player_4, player_3, player_2, player_1];

    for player in players {
        table_management_system::InternalImpl::_assign_player_to_sidepot(ref world, ref table,
            player.m_owner, player.m_current_bet);
    };
    world.write_model_test(@table);

    let table: ComponentTable = world.read_model(1);
    let sidepot_1: ComponentSidepot = world.read_model((1, 0));
    let sidepot_2: ComponentSidepot = world.read_model((1, 1));
    let sidepot_3: ComponentSidepot = world.read_model((1, 2));
    let sidepot_4: ComponentSidepot = world.read_model((1, 3));

    assert!(table.m_num_sidepots == 4, "There should be 4 sidepots");

    assert!(sidepot_1.m_amount == 8000, "Sidepot 1 should have 8000 chips");
    assert!(sidepot_2.m_amount == 3000, "Sidepot 2 should have 3000 chips");
    assert!(sidepot_3.m_amount == 2000, "Sidepot 3 should have 2000 chips");
    assert!(sidepot_4.m_amount == 1000, "Sidepot 4 should have 1000 chips");
}

#[test]
fn test_assign_sidepots_complex() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager = deploy_table_manager(ref world);
    let mut action_manager = deploy_actions(ref world);

    table_manager.create_table(100, 200, 2000, 6000, 5);

    let mut player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    player_1.m_total_chips = 5000;
    world.write_model_test(@player_1);

    let mut player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());
    player_2.m_total_chips = 4000;
    world.write_model_test(@player_2);

    let mut player_3: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1C>());
    player_3.m_total_chips = 3000;
    world.write_model_test(@player_3);

    let mut player_4: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1D>());
    player_4.m_total_chips = 2000;
    world.write_model_test(@player_4);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());  // Dealer
    action_manager.join_table(1, 5000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1B>());  // Small blind
    action_manager.join_table(1, 4000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1C>());  // Big blind
    action_manager.join_table(1, 3000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1D>());  // Player 4
    action_manager.join_table(1, 2000);
    
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    action_manager.set_ready(1);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1B>());
    action_manager.set_ready(1);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1C>());
    action_manager.set_ready(1);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1D>());
    action_manager.set_ready(1);

    // Round starts automatically and set to pre-flop...

    // Encrypt deck and distribute cards.
    let table: ComponentTable = world.read_model(1);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x0>());
    table_manager.post_encrypt_deck(1, table.m_deck.clone());

    // First betting street, all players go all in.
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1D>());  // First player to play
    action_manager.bet(1, 2000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());  // Dealer
    action_manager.bet(1, 5000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1B>());  // Small blind
    action_manager.bet(1, 3900);  // Take into account the small blind from player's chips.

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1C>());  // Big blind
    action_manager.bet(1, 2800);  // Take into account the big blind from player's chips.

    // Check that sidepots have been created.
    let table: ComponentTable = world.read_model(1);
    assert!(table.m_num_sidepots == 4, "There should already be 4 sidepots");

    let sidepot_1: ComponentSidepot = world.read_model((1, 0));
    let sidepot_2: ComponentSidepot = world.read_model((1, 1));
    let sidepot_3: ComponentSidepot = world.read_model((1, 2));
    let sidepot_4: ComponentSidepot = world.read_model((1, 3));

    // Check that sidepots amounts are correct.
    assert!(sidepot_1.m_amount == 8000, "Sidepot 1 should have 6000 chips");
    assert!(sidepot_2.m_amount == 3000, "Sidepot 2 should have 3000 chips");
    assert!(sidepot_3.m_amount == 2000, "Sidepot 3 should have 2000 chips");
    assert!(sidepot_4.m_amount == 1000, "Sidepot 4 should have 1000 chips");
}

#[test]
fn test_sidepot_distribution_simple() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    // Set three players going all in with different chip stacks, creating three sidepots.
    let mut player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    player_1.m_table_chips = 0;
    world.write_model_test(@player_1);

    let mut player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());
    player_2.m_table_chips = 0;
    world.write_model_test(@player_2);

    let mut player_3: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1C>());
    player_3.m_table_chips = 0;
    world.write_model_test(@player_3);

    let mut player_4: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1D>());
    player_4.m_table_chips = 1600;
    world.write_model_test(@player_4);

    let mut sidepot: ComponentSidepot = world.read_model((1, 0));
    sidepot.m_min_bet = 1000;
    sidepot.m_amount = 1000;
    sidepot.m_eligible_players.append(starknet::contract_address_const::<0x1A>());
    world.write_model_test(@sidepot);

    let mut sidepot: ComponentSidepot = world.read_model((1, 1));
    sidepot.m_min_bet = 1000;
    sidepot.m_amount = 2000;
    sidepot.m_eligible_players.append(starknet::contract_address_const::<0x1A>());
    sidepot.m_eligible_players.append(starknet::contract_address_const::<0x1B>());
    world.write_model_test(@sidepot);

    let mut sidepot: ComponentSidepot = world.read_model((1, 2));
    sidepot.m_min_bet = 2600;
    sidepot.m_amount = 7800;
    sidepot.m_eligible_players.append(starknet::contract_address_const::<0x1A>());
    sidepot.m_eligible_players.append(starknet::contract_address_const::<0x1B>());
    sidepot.m_eligible_players.append(starknet::contract_address_const::<0x1C>());
    world.write_model_test(@sidepot);

    let mut table: ComponentTable = world.read_model(1);
    table.m_num_sidepots = 3;
    table.m_state = EnumGameState::Showdown;
    table.m_pot = 10800;
    world.write_model_test(@table);

    // Make it so player 1 and 2 tie for the second sidepot, and player 3 wins the main sidepot.
    table_management_system::InternalImpl::_distribute_sidepots(ref world,
         ref table,
          array![(starknet::contract_address_const::<0x1A>(), 2),
           (starknet::contract_address_const::<0x1B>(), 2),
           (starknet::contract_address_const::<0x1C>(), 3)]);
    world.write_model_test(@table);

    let table: ComponentTable = world.read_model(1);
    assert!(table.m_pot == 0, "Table pot should be 0");

    let player_1: ComponentPlayer = world.read_model((1, player_1.m_owner));
    assert!(player_1.m_table_chips == 1900, "Player 1 should have all of sidepot 1 (1000 - 5%) chips + half of sidepot 2 (2000 / 2 - 5%) chips");

    let player_2: ComponentPlayer = world.read_model((1, player_2.m_owner));
    assert!(player_2.m_table_chips == 950, "Player 2 should have half of sidepot 2 (2000 / 2 - 5%) chips");

    let player_3: ComponentPlayer = world.read_model((1, player_3.m_owner));
    assert!(player_3.m_table_chips == 7410, "Player 3 should have all of sidepot 3 (7800 - 5%) chips");
}

#[test]
fn test_all_players_all_in_before_showdown() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager = deploy_table_manager(ref world);
    let mut action_manager = deploy_actions(ref world);

    table_manager.create_table(100, 200, 2000, 6000, 5);
    table_manager.change_table_manager(starknet::contract_address_const::<0x222>());

    let mut player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    player_1.m_total_chips = 5000;
    world.write_model_test(@player_1);

    let mut player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());
    player_2.m_total_chips = 4000;
    world.write_model_test(@player_2);

    let mut player_3: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1C>());
    player_3.m_total_chips = 3000;
    world.write_model_test(@player_3);

    let mut player_4: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1D>());
    player_4.m_total_chips = 2000;
    world.write_model_test(@player_4);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());  // Dealer
    action_manager.join_table(1, 5000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1B>());  // Small blind
    action_manager.join_table(1, 4000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1C>());  // Big blind
    action_manager.join_table(1, 3000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1D>());  // Player 4
    action_manager.join_table(1, 2000);
    
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    action_manager.set_ready(1);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1B>());
    action_manager.set_ready(1);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1C>());
    action_manager.set_ready(1);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1D>());
    action_manager.set_ready(1);

    // Round starts automatically and set to pre-flop...

    // Encrypt deck and distribute cards.
    let table: ComponentTable = world.read_model(1);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x222>());
    table_manager.post_encrypt_deck(1, table.m_deck.clone());

    // Set all players all in.
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1D>());
    action_manager.bet(1, 2000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    action_manager.bet(1, 5000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1B>());
    action_manager.bet(1, 3900);  // Take into account the small blind from player's chips.

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1C>());
    action_manager.bet(1, 2800);  // Take into account the big blind from player's chips.

    // Backend should automatically decrypt the Flop, Turn, and River, and advance to showdown.
    // Decrypt the Flop.

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x222>());
    table_manager.post_decrypted_community_cards(1, array![
        ICard::new(EnumCardValue::Ten, EnumCardSuit::Spades),
        ICard::new(EnumCardValue::Six, EnumCardSuit::Hearts),
        ICard::new(EnumCardValue::Two, EnumCardSuit::Diamonds)
    ]);
    let mut table: ComponentTable = world.read_model(1);
    starknet::testing::set_contract_address(table_manager.contract_address);
    table_management_system::InternalImpl::_advance_street(ref world, ref table);
    world.write_model_test(@table);

    // Decrypt the Turn.
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x222>());
    table_manager.post_decrypted_community_cards(1, array![
        ICard::new(EnumCardValue::King, EnumCardSuit::Clubs)
    ]);
    let mut table: ComponentTable = world.read_model(1);
    starknet::testing::set_contract_address(table_manager.contract_address);
    table_management_system::InternalImpl::_advance_street(ref world, ref table);
    world.write_model_test(@table);

    // Decrypt the River.
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x222>());
    table_manager.post_decrypted_community_cards(1, array![
        ICard::new(EnumCardValue::Eight, EnumCardSuit::Clubs)
    ]);
    let mut table: ComponentTable = world.read_model(1);
    starknet::testing::set_contract_address(table_manager.contract_address);
    table_management_system::InternalImpl::_advance_street(ref world, ref table);
    world.write_model_test(@table);

    let table: ComponentTable = world.read_model(1);
    assert!(table.m_state == EnumGameState::Showdown, "Round should be in showdown");
}

#[test]
#[available_gas(1000000000)]
fn test_advance_turn_skip_folded_players() {
    let mut player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let mut player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());
    let mut player_3: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1C>());
    let mut player_4: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1D>());

    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager = deploy_table_manager(ref world);

    table_manager.create_table(100, 200, 2000, 6000, 5);

    let mut action_manager = deploy_actions(ref world);

    // Add players and assign money so they can play.
    player_1.m_total_chips = 5000;
    world.write_model_test(@player_1);

    player_2.m_total_chips = 4000;
    world.write_model_test(@player_2);

    player_3.m_total_chips = 3000;
    world.write_model_test(@player_3);

    player_4.m_total_chips = 2000;
    world.write_model_test(@player_4);

    table_manager.create_table(100, 200, 2000, 6000, 5);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    action_manager.join_table(1, 5000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1B>());
    action_manager.join_table(1, 4000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1C>());
    action_manager.join_table(1, 3000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1D>());
    action_manager.join_table(1, 2000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1D>());
    action_manager.set_ready(1);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1C>());
    action_manager.set_ready(1);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1B>());
    action_manager.set_ready(1);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    action_manager.set_ready(1);

    let mut table: ComponentTable = world.read_model(1);
    table.m_deck_encrypted = true;
    world.write_model_test(@table);

    // Street starts and dealer (1A) gets skipped, and small blind (1B) pays 100.
    // Big blind (1C) pays 200.

    // Pre-flop
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1D>());
    action_manager.bet(1, 200);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    action_manager.fold(1);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1B>());
    action_manager.fold(1);

    let table: ComponentTable = world.read_model(1);
    assert!(table.m_current_turn == 2, "Current turn should be 2");
}

#[test]
#[should_panic(expected: ("Commitment hash does not match", 'ENTRYPOINT_FAILED'))]
fn test_game_simple() {
    // Create a table with 4 players.
    let mut player_1: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1A>());
    let mut player_2: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1B>());
    let mut player_3: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1C>());
    let mut player_4: ComponentPlayer = IPlayer::new(1, starknet::contract_address_const::<0x1D>());

    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager = deploy_table_manager(ref world);
    let mut action_manager = deploy_actions(ref world);

    let table_manager_address: starknet::ContractAddress = table_manager.get_table_manager();

    // Add players and assign money so they can play.
    player_1.m_total_chips = 5000;
    world.write_model_test(@player_1);

    player_2.m_total_chips = 4000;
    world.write_model_test(@player_2);

    player_3.m_total_chips = 3000;
    world.write_model_test(@player_3);

    player_4.m_total_chips = 2000;
    world.write_model_test(@player_4);

    table_manager.create_table(100, 200, 2000, 6000, 5);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    action_manager.join_table(1, 5000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1B>());
    action_manager.join_table(1, 4000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1C>());
    action_manager.join_table(1, 3000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1D>());
    action_manager.join_table(1, 2000);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1D>());
    action_manager.set_ready(1);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1C>());
    action_manager.set_ready(1);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1B>());
    action_manager.set_ready(1);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    action_manager.set_ready(1);

    let table: ComponentTable = world.read_model(1);
    starknet::testing::set_contract_address(table_manager_address);
    table_manager.post_encrypt_deck(1, table.m_deck.clone());

    // Street starts and dealer (1A) gets skipped, and small blind (1B) pays 100.
    // Big blind (1C) pays 200.
    // Goes back around to 1A.

    // Pre-flop
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1D>());
    action_manager.bet(1, 200);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    action_manager.bet(1, 200);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1B>());
    action_manager.bet(1, 100);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1C>());
    action_manager.bet(1, 0);  // check.

    // Check if we have changed the to Flop.
    let table: ComponentTable = world.read_model(1);
    assert!(table.m_state == EnumGameState::Flop, "Table should be in Flop");

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    action_manager.post_commit_hash(1, array![0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8]);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1B>());
    action_manager.post_commit_hash(1, array![0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8]);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1C>());
    action_manager.post_commit_hash(1, array![0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8]);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1D>());
    action_manager.post_commit_hash(1, array![0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8]);

    starknet::testing::set_contract_address(table_manager_address);
    table_manager.post_decrypted_community_cards(1, array![
        ICard::new(EnumCardValue::Ten, EnumCardSuit::Spades),
        ICard::new(EnumCardValue::Six, EnumCardSuit::Hearts),
        ICard::new(EnumCardValue::Two, EnumCardSuit::Diamonds)
    ]);

    // Flop
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1D>());
    action_manager.bet(1, 100);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    action_manager.bet(1, 100);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1B>());
    action_manager.bet(1, 100);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1C>());
    action_manager.bet(1, 100);

    // Check if we have changed the to Turn.
    let table: ComponentTable = world.read_model(1);
    assert!(table.m_state == EnumGameState::Turn, "Table should be in Turn");

    starknet::testing::set_contract_address(table_manager_address);
    table_manager.post_decrypted_community_cards(1, array![
        ICard::new(EnumCardValue::King, EnumCardSuit::Clubs)
    ]);
    
    // Turn
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1D>());
    action_manager.bet(1, 100);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    action_manager.bet(1, 100);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1B>());
    action_manager.bet(1, 100);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1C>());
    action_manager.bet(1, 100);

    // Check if we have changed the to River.
    let table: ComponentTable = world.read_model(1);
    assert!(table.m_state == EnumGameState::River, "Table should be in River");

    starknet::testing::set_contract_address(table_manager_address);
    table_manager.post_decrypted_community_cards(1, array![
        ICard::new(EnumCardValue::Eight, EnumCardSuit::Clubs)
    ]);
    
    // River
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1D>());
    action_manager.fold(1);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    action_manager.bet(1, 4600);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1B>());
    action_manager.bet(1, 3600);
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1C>());
    action_manager.bet(1, 2600);

    // Check if we have changed the to Showdown.
    let table: ComponentTable = world.read_model(1);
    assert!(table.m_state == EnumGameState::Showdown, "Table should be in Showdown");

    // Players reveals their hand.
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1A>());
    action_manager.reveal_hand_to_all(1, array![], "TEST");
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1B>());
    action_manager.reveal_hand_to_all(1, array![], "TEST");
    starknet::testing::set_contract_address(starknet::contract_address_const::<0x1C>());
    action_manager.reveal_hand_to_all(1, array![], "TEST");

    // Showdown starts automatically.
    let table: ComponentTable = world.read_model(1);
    assert!(table.m_pot != 0, "Table pot should be having small blind and big blind");
    assert!(table.m_num_sidepots == 0, "Table should have no sidepots");
    assert!(table.m_state == EnumGameState::PreFlop, "Next round should have started");

}
