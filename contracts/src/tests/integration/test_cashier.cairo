use crate::systems::cashier::{ICashierDispatcher, ICashierDispatcherTrait};
use crate::models::components::{ComponentPlayer};
use crate::models::traits::IPlayer;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorageTrait};
use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest};
use dojo_cairo_test::{ContractDefTrait, WorldStorageTestTrait};
use starknet::ContractAddress;
use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest, ModelValueStorageTest};
use dojo::world::storage::WorldStorage;
use crate::models::components::ComponentPlayer;

const ETH_TO_CHIPS_RATIO: u256 = 10000000000000;

#[test]
fn test_deposit_erc20() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let cashier: ICashierDispatcher = deploy_cashier(ref world);
    let eth_to_chips_ratio: u256 = 10000000000000;
    let player_address = starknet::contract_address_const::<0x1A>();
    set_contract_address(player_address);
    let initial_chips = 0;
    let deposit_amount = 1000000000000000000; // 1 ETH in wei

    // Ensure the player model is initialized correctly
    let mut player: ComponentPlayer = IPlayer::new(0, player_address);
    player.m_total_chips = initial_chips;
    world.write_model_test(@player);

    cashier.deposit_erc20(deposit_amount);

    let player: ComponentPlayer = world.read_model(player_address);
    assert_eq!(player.m_total_chips, initial_chips + (deposit_amount / eth_to_chips_ratio).try_into().unwrap());
}

#[test]
fn test_cashout_erc20() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let cashier: ICashierDispatcher = deploy_cashier(ref world);

    let player_address = starknet::contract_address_const::<0x1A>();
    set_contract_address(player_address);
    let initial_chips = 1000;
    let cashout_amount = 500;

    let mut player: ComponentPlayer = IPlayer::new(0, player_address);
    player.m_total_chips = initial_chips;
    world.write_model_test(@player);

    cashier.cashout_erc20(cashout_amount);

    let player: ComponentPlayer = world.read_model((0, player_address));
    assert_eq!(player.m_total_chips, initial_chips - cashout_amount);
}

#[test]
fn test_transfer_chips() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let cashier: ICashierDispatcher = deploy_cashier(ref world);

    let sender_address = starknet::contract_address_const::<0x1A>();
    let recipient_address = starknet::contract_address_const::<0x1B>();
    set_contract_address(sender_address);
    let initial_chips_sender = 1000;
    let initial_chips_recipient = 500;
    let transfer_amount = 300;

    let mut sender: ComponentPlayer = IPlayer::new(0, sender_address);
    sender.m_total_chips = initial_chips_sender;
    world.write_model_test(@sender);

    let mut recipient: ComponentPlayer = IPlayer::new(0, recipient_address);
    recipient.m_total_chips = initial_chips_recipient;
    world.write_model_test(@recipient);

    cashier.transfer_chips(recipient_address, transfer_amount);

    let sender: ComponentPlayer = world.read_model((0, sender_address));
    let recipient: ComponentPlayer = world.read_model((0, recipient_address));

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
