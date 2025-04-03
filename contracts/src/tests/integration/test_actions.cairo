use crate::systems::actions::{IActionsDispatcher, IActionsDispatcherTrait};
use crate::systems::table_manager::{ITableManagementDispatcher, ITableManagementDispatcherTrait};

use crate::models::enums::{EnumTableState};
use crate::models::components::{
    ComponentTable, ComponentPlayer, ComponentBank,
    ComponentProof, ComponentTableInfo
};
use crate::models::traits::{IPlayer, IBank};

use dojo::model::{ModelStorage, ModelStorageTest};
use dojo::world::{WorldStorageTrait};
use dojo_cairo_test::{ContractDefTrait, WorldStorageTestTrait};
use starknet::ContractAddress;

use crate::tests::integration::utils::deploy_world;
use crate::tests::integration::test_table_manager::deploy_table_manager;

// Deploy actions contract with supplied components registered.
pub fn deploy_actions(ref world: dojo::world::WorldStorage) -> IActionsDispatcher {
    let (contract_address, _) = world.dns(@"actions_system").unwrap();

    let system: IActionsDispatcher = IActionsDispatcher { contract_address };

    let system_def = ContractDefTrait::new(@"dominion", @"actions_system")
        .with_writer_of([dojo::utils::bytearray_hash(@"dominion")].span());

    world.sync_perms_and_inits([system_def].span());

    return system;
}

#[test]
#[should_panic(expected: ("Table is full", 'ENTRYPOINT_FAILED'))]
fn test_join_table_full() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
    let mut actions: IActionsDispatcher = deploy_actions(ref world);

    let player_1: ContractAddress = starknet::contract_address_const::<0x1A>();
    let player_2: ContractAddress = starknet::contract_address_const::<0x1B>();
    let player_3: ContractAddress = starknet::contract_address_const::<0x1C>();
    let player_4: ContractAddress = starknet::contract_address_const::<0x1D>();
    let player_5: ContractAddress = starknet::contract_address_const::<0x1E>();
    let player_6: ContractAddress = starknet::contract_address_const::<0x1F>();
    let player_7: ContractAddress = starknet::contract_address_const::<0x20>();

    // Create the players in advance to give them total chips.
    let mut player_1_component: ComponentPlayer = IPlayer::new(1, player_1);
    let mut player_1_bank: ComponentBank = IBank::new(player_1);
    player_1_bank.m_balance = 10000;
    let mut player_2_component: ComponentPlayer = IPlayer::new(1, player_2);
    let mut player_2_bank: ComponentBank = IBank::new(player_2);
    player_2_bank.m_balance = 10000;
    let mut player_3_component: ComponentPlayer = IPlayer::new(1, player_3);
    let mut player_3_bank: ComponentBank = IBank::new(player_3);
    player_3_bank.m_balance = 10000;
    let mut player_4_component: ComponentPlayer = IPlayer::new(1, player_4);
    let mut player_4_bank: ComponentBank = IBank::new(player_4);
    player_4_bank.m_balance = 10000;
    let mut player_5_component: ComponentPlayer = IPlayer::new(1, player_5);
    let mut player_5_bank: ComponentBank = IBank::new(player_5);
    player_5_bank.m_balance = 10000;
    let mut player_6_component: ComponentPlayer = IPlayer::new(1, player_6);
    let mut player_6_bank: ComponentBank = IBank::new(player_6);
    player_6_bank.m_balance = 10000;
    let mut player_7_component: ComponentPlayer = IPlayer::new(1, player_7);
    let mut player_7_bank: ComponentBank = IBank::new(player_7);
    player_7_bank.m_balance = 10000;

    world.write_models_test(array![
        @player_1_component,
        @player_2_component,
        @player_3_component,
        @player_4_component,
        @player_5_component,
        @player_6_component,
        @player_7_component,
    ].span());
    world.write_models_test(array![
        @player_1_bank,
        @player_2_bank,
        @player_3_bank,
        @player_4_bank,
        @player_5_bank,
        @player_6_bank,
        @player_7_bank,
    ].span());

    table_manager.create_table(100, 200, 2000, 4000, 5);

    starknet::testing::set_contract_address(player_1);
    actions.join_table(1, 2000);

    starknet::testing::set_contract_address(player_2);
    actions.join_table(1, 2000);

    starknet::testing::set_contract_address(player_3);
    actions.join_table(1, 2000);

    starknet::testing::set_contract_address(player_4);
    actions.join_table(1, 2000);

    starknet::testing::set_contract_address(player_5);
    actions.join_table(1, 2000);

    starknet::testing::set_contract_address(player_6);
    actions.join_table(1, 2000);

    starknet::testing::set_contract_address(player_7);
    actions.join_table(1, 2000);
}

#[test]
#[should_panic(expected: ("Insufficient chips", 'ENTRYPOINT_FAILED'))]
fn test_join_table_insufficient_chips() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
    let mut actions: IActionsDispatcher = deploy_actions(ref world);

    let player: ContractAddress = starknet::contract_address_const::<0x1A>();

    table_manager.create_table(100, 200, 2000, 4000, 5);

    starknet::testing::set_contract_address(player);
    actions.join_table(1, 1000);
}

#[test]
#[should_panic(expected: ("Amount is less than min buy in", 'ENTRYPOINT_FAILED'))]
fn test_join_table_chips_less_than_min_buy_in() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
    let mut actions: IActionsDispatcher = deploy_actions(ref world);

    let player: ContractAddress = starknet::contract_address_const::<0x1A>();
    let mut player_component: ComponentPlayer = IPlayer::new(1, player);
    world.write_model_test(@player_component);

    let mut player_bank: ComponentBank = IBank::new(player);
    player_bank.m_balance = 10000;
    world.write_model_test(@player_bank);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    starknet::testing::set_contract_address(player);
    actions.join_table(1, 1000);
}

#[test]
#[should_panic(expected: ("Amount is more than max buy in", 'ENTRYPOINT_FAILED'))]
fn test_join_table_chips_more_than_max_buy_in() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
    let mut actions: IActionsDispatcher = deploy_actions(ref world);

    let player: ContractAddress = starknet::contract_address_const::<0x1A>();
    let mut player_component: ComponentPlayer = IPlayer::new(1, player);
    world.write_model_test(@player_component);

    let mut player_bank: ComponentBank = IBank::new(player);
    player_bank.m_balance = 10000;
    world.write_model_test(@player_bank);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    starknet::testing::set_contract_address(player);
    actions.join_table(1, 5000);
}

#[test]
#[should_panic(expected: ("Player is already at the table", 'ENTRYPOINT_FAILED'))]
fn test_join_table_twice() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
    let mut actions: IActionsDispatcher = deploy_actions(ref world);

    let player: ContractAddress = starknet::contract_address_const::<0x1A>();
    let mut player_component: ComponentPlayer = IPlayer::new(1, player);
    world.write_model_test(@player_component);

    let mut player_bank: ComponentBank = IBank::new(player);
    player_bank.m_balance = 10000;
    world.write_model_test(@player_bank);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    let player: ContractAddress = starknet::contract_address_const::<0x1A>();
    let mut player_component: ComponentPlayer = IPlayer::new(1, player);
    world.write_model_test(@player_component);

    let mut player_bank: ComponentBank = IBank::new(player);
    player_bank.m_balance = 10000;
    world.write_model_test(@player_bank);

    starknet::testing::set_contract_address(player);
    actions.join_table(1, 2000);

    starknet::testing::set_contract_address(player);
    actions.join_table(1, 2000);
}

#[test]
#[should_panic(expected: ("Player is not at the table", 'ENTRYPOINT_FAILED'))]
fn test_leave_table_not_joined() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
    let mut actions: IActionsDispatcher = deploy_actions(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);

    let player: ContractAddress = starknet::contract_address_const::<0x1A>();
    let mut player_component: ComponentPlayer = IPlayer::new(1, player);
    world.write_model_test(@player_component);

    let mut player_bank: ComponentBank = IBank::new(player);
    player_bank.m_balance = 10000;
    world.write_model_test(@player_bank);

    starknet::testing::set_contract_address(player);
    actions.leave_table(1);
}

#[test]
fn test_chip_amount_after_leave() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
    let mut actions: IActionsDispatcher = deploy_actions(ref world);

    let player: ContractAddress = starknet::contract_address_const::<0x1A>();

    table_manager.create_table(100, 200, 2000, 4000, 5);

    let mut player_component: ComponentPlayer = IPlayer::new(1, player);
    world.write_model_test(@player_component);

    let mut player_bank: ComponentBank = IBank::new(player);
    player_bank.m_balance = 10000;
    world.write_model_test(@player_bank);

    starknet::testing::set_contract_address(player);
    actions.join_table(1, 2000);

    starknet::testing::set_contract_address(player);
    actions.leave_table(1);

    let table: ComponentTable = world.read_model(1);
    let player_component: ComponentPlayer = world.read_model((1, player));
    let player_bank: ComponentBank = world.read_model(player);

    assert!(player_bank.m_balance == 10000, "Player's total chips should be 10000");
    assert!(player_component.m_table_chips == 0, "Player's table chips should be 0");
    assert!(table.m_pot == 0, "Table pot should be 0");
}

#[test]
#[should_panic(expected: ("Game has not started", 'ENTRYPOINT_FAILED'))]
fn test_post_auth_hash_invalid_state() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager = deploy_table_manager(ref world);
    let mut actions = deploy_actions(ref world);

    table_manager.create_table(100, 200, 2000, 4000, 5);
    let mut table_info: ComponentTableInfo = world.read_model(1);
    table_info.m_state = EnumTableState::Shutdown;
    world.write_model_test(@table_info);

    actions.post_auth_hash(1, "test");
}

// #[test]
// fn test_roles_after_leave() {
//     let mut world: dojo::world::WorldStorage = deploy_world();
//     let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
//     let mut actions: IActionsDispatcher = deploy_actions(ref world);

//     table_manager.create_table(100, 200, 2000, 4000, 5);
// }

// #[test]
// fn test_roles_after_multiple_rounds() {
//     let mut world: dojo::world::WorldStorage = deploy_world();
//     let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
//     let mut actions: IActionsDispatcher = deploy_actions(ref world);

//     table_manager.create_table(100, 200, 2000, 4000, 5);
// }

#[test]
#[should_panic(expected: ("Insufficient chips", 'ENTRYPOINT_FAILED'))]
fn test_insufficient_chips_for_bet() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
    let mut actions: IActionsDispatcher = deploy_actions(ref world);

    let player: ContractAddress = starknet::contract_address_const::<0x1A>();
    let player_2: ContractAddress = starknet::contract_address_const::<0x1B>();
    
    let player_component: ComponentPlayer = IPlayer::new(1, player);
    world.write_model_test(@player_component);

    let mut player_bank: ComponentBank = IBank::new(player);
    player_bank.m_balance = 4400;
    world.write_model_test(@player_bank);

    let player_2_component: ComponentPlayer = IPlayer::new(1, player_2);
    world.write_model_test(@player_2_component);

    let mut player_2_bank: ComponentBank = IBank::new(player_2);
    player_2_bank.m_balance = 4200;
    world.write_model_test(@player_2_bank);

    table_manager.create_table(200, 400, 4000, 6000, 5);

    starknet::testing::set_contract_address(player);  // Dealer + Big Blind.
    actions.join_table(1, 4000);
    actions.set_ready(1);

    starknet::testing::set_contract_address(player_2);  // Small Blind.
    actions.join_table(1, 4000);
    actions.set_ready(1);

    let mut proof: ComponentProof = world.read_model(1);
    proof.m_deck_proof = "TEST";
    world.write_model_test(@proof);

    starknet::testing::set_contract_address(player_2);
    actions.bet(1, 4000);
}

#[test]
#[should_panic(expected: ("It is not your turn", 'ENTRYPOINT_FAILED'))]
fn test_bet_twice() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
    let mut actions: IActionsDispatcher = deploy_actions(ref world);

    let player: ContractAddress = starknet::contract_address_const::<0x1A>();
    let player_2: ContractAddress = starknet::contract_address_const::<0x1B>();
    let mut player_component: ComponentPlayer = IPlayer::new(1, player);
    world.write_model_test(@player_component);

    let mut player_bank: ComponentBank = IBank::new(player);
    player_bank.m_balance = 4400;
    world.write_model_test(@player_bank);

    let mut player_2_component: ComponentPlayer = IPlayer::new(1, player_2);
    world.write_model_test(@player_2_component);

    let mut player_2_bank: ComponentBank = IBank::new(player_2);
    player_2_bank.m_balance = 4200;
    world.write_model_test(@player_2_bank);

    table_manager.create_table(200, 400, 4000, 6000, 5);

    starknet::testing::set_contract_address(player);  // Dealer + Big Blind.
    actions.join_table(1, 4000);
    actions.set_ready(1);

    starknet::testing::set_contract_address(player_2);  // Small Blind.
    actions.join_table(1, 4000);
    actions.set_ready(1);

    let mut proof: ComponentProof = world.read_model(1);
    proof.m_deck_proof = "TEST";
    world.write_model_test(@proof);

    starknet::testing::set_caller_address(player_2);
    actions.bet(1, 200);

    starknet::testing::set_caller_address(player_2);
    actions.bet(1, 200);
}

// #[test]
// fn test_advance_street_without_bet() {
//     let mut world: dojo::world::WorldStorage = deploy_world();
//     let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
//     let mut actions: IActionsDispatcher = deploy_actions(ref world);

//     table_manager.create_table(100, 200, 2000, 4000, 5);
// }

// #[test]
// fn test_advance_street_with_bet() {
//     let mut world: dojo::world::WorldStorage = deploy_world();
//     let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
//     let mut actions: IActionsDispatcher = deploy_actions(ref world);

//     table_manager.create_table(100, 200, 2000, 4000, 5);
// }

// #[test]
// fn test_set_ready_invalid_table() {
//     let mut world: dojo::world::WorldStorage = deploy_world();
//     let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
//     let mut actions: IActionsDispatcher = deploy_actions(ref world);
//     table_manager.create_table(100, 200, 2000, 4000, 5);
// }

// #[test]
// fn set_ready_when_all_players_ready() {
//     let mut world: dojo::world::WorldStorage = deploy_world();
//     let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
//     let mut actions: IActionsDispatcher = deploy_actions(ref world);
//     table_manager.create_table(100, 200, 2000, 4000, 5);
// }

// #[test]
// fn test_set_ready_twice() {
//     let mut world: dojo::world::WorldStorage = deploy_world();
//     let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
//     let mut actions: IActionsDispatcher = deploy_actions(ref world);
//     table_manager.create_table(100, 200, 2000, 4000, 5);
// }

// #[test]
// fn test_start_round_when_not_all_players_ready() {
//     let mut world: dojo::world::WorldStorage = deploy_world();
//     let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
//     let mut actions: IActionsDispatcher = deploy_actions(ref world);
//     table_manager.create_table(100, 200, 2000, 4000, 5);
// }

// #[test]
// fn test_start_round_when_all_players_ready() {
//     let mut world: dojo::world::WorldStorage = deploy_world();
//     let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
//     let mut actions: IActionsDispatcher = deploy_actions(ref world);
//     table_manager.create_table(100, 200, 2000, 4000, 5);
// }

// #[test]
// fn test_fold() {
//     let mut world: dojo::world::WorldStorage = deploy_world();
//     let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
//     let mut actions: IActionsDispatcher = deploy_actions(ref world);
//     table_manager.create_table(100, 200, 2000, 4000, 5);
// }

// #[test]
// fn test_all_in_sidepots() {
//     let mut world: dojo::world::WorldStorage = deploy_world();
//     let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
//     let mut actions: IActionsDispatcher = deploy_actions(ref world);
//     table_manager.create_table(100, 200, 2000, 4000, 5);
// }

// #[test]
// fn test_reveal_hand_to_all_before_showdown() {
//     let mut world: dojo::world::WorldStorage = deploy_world();
//     let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
//     let mut actions: IActionsDispatcher = deploy_actions(ref world);
//     table_manager.create_table(100, 200, 2000, 4000, 5);
// }

// #[test]
// fn test_reveal_hand_to_all_invalid_commit_hash() {
//     let mut world: dojo::world::WorldStorage = deploy_world();
//     let mut table_manager: ITableManagementDispatcher = deploy_table_manager(ref world);
//     let mut actions: IActionsDispatcher = deploy_actions(ref world);
//     table_manager.create_table(100, 200, 2000, 4000, 5);
// }
