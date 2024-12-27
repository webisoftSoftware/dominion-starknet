use crate::tests::integration::utils::deploy_world;
use crate::systems::cashier::{ICashierDispatcher, ICashierDispatcherTrait};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorageTrait};
use dojo_cairo_test::{ContractDefTrait, WorldStorageTestTrait};
use starknet::ContractAddress;

#[test]
fn test_deposit_erc20() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let cashier: ICashierDispatcher = deploy_cashier(ref world);

    let player_address = starknet::contract_address_const::<0x1A>();
    let initial_chips = 0;
    let deposit_amount = 1000000000000000000; // 1 ETH in wei

    cashier.deposit_erc20(deposit_amount);

    let player: ComponentPlayer = world.read_model(player_address);
    assert_eq!(player.m_total_chips, initial_chips + (deposit_amount / ETH_TO_CHIPS_RATIO).try_into().unwrap());
}

#[test]
fn test_cashout_erc20() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let cashier: ICashierDispatcher = deploy_cashier(ref world);

    let player_address = starknet::contract_address_const::<0x1A>();
    let initial_chips = 1000;
    let cashout_amount = 500;

    let mut player: ComponentPlayer = world.read_model(player_address);
    player.m_total_chips = initial_chips;
    world.write_model(@player);

    cashier.cashout_erc20(cashout_amount);

    let player: ComponentPlayer = world.read_model(player_address);
    assert_eq!(player.m_total_chips, initial_chips - cashout_amount);
}

#[test]
fn test_transfer_chips() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let cashier: ICashierDispatcher = deploy_cashier(ref world);

    let sender_address = starknet::contract_address_const::<0x1A>();
    let recipient_address = starknet::contract_address_const::<0x1B>();
    let initial_chips_sender = 1000;
    let initial_chips_recipient = 500;
    let transfer_amount = 300;

    let mut sender: ComponentPlayer = world.read_model(sender_address);
    sender.m_total_chips = initial_chips_sender;
    world.write_model(@sender);

    let mut recipient: ComponentPlayer = world.read_model(recipient_address);
    recipient.m_total_chips = initial_chips_recipient;
    world.write_model(@recipient);

    cashier.transfer_chips(recipient_address, transfer_amount);

    let sender: ComponentPlayer = world.read_model(sender_address);
    let recipient: ComponentPlayer = world.read_model(recipient_address);

    assert_eq!(sender.m_total_chips, initial_chips_sender - transfer_amount);
    assert_eq!(recipient.m_total_chips, initial_chips_recipient + transfer_amount);
}

#[test]
fn test_set_treasury_address() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let cashier: ICashierDispatcher = deploy_cashier(ref world);

    let new_treasury_address = starknet::contract_address_const::<0x1C>();
    cashier.set_treasury_address(new_treasury_address);

    let treasury_address = cashier.get_treasury_address();
    assert_eq!(treasury_address, new_treasury_address);
}

// Helper function to deploy the cashier system
fn deploy_cashier(ref world: dojo::world::WorldStorage) -> ICashierDispatcher {
    let (contract_address, _) = world.dns(@"cashier_system").unwrap();
    let system: ICashierDispatcher = ICashierDispatcher { contract_address };
    let system_def = ContractDefTrait::new(@"dominion", @"cashier_system")
        .with_writer_of([dojo::utils::bytearray_hash(@"dominion")].span());
    world.sync_perms_and_inits([system_def].span());
    return system;
}
