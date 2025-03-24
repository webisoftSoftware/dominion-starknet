use crate::systems::cashier::{ICashierDispatcher, ICashierDispatcherTrait};
use crate::models::traits::{IBank};
use dojo::world::{WorldStorageTrait};
use dojo_cairo_test::{ContractDefTrait, WorldStorageTestTrait};
use dojo::model::{ModelStorage, ModelStorageTest};
use crate::models::components::{ComponentBank};

use crate::tests::integration::utils::deploy_world;

const ETH_TO_CHIPS_RATIO: u256 = 1_000_000_000_000; // 1,000,000 chips per ETH
const PAYMASTER_FEE_PERCENTAGE: u32 = 0; // Turned off for now
const WITHDRAWAL_FEE_PERCENTAGE: u32 = 0; // 2% withdrawal fee

// Deploy table manager with supplied components registered.
pub fn deploy_cashier(ref world: dojo::world::WorldStorage) -> ICashierDispatcher {
    let (contract_address, _) = world.dns(@"cashier_system").unwrap();

    let system: ICashierDispatcher = ICashierDispatcher { contract_address };

    let system_def = ContractDefTrait::new(@"dominion", @"cashier_system")
        .with_writer_of([dojo::utils::bytearray_hash(@"dominion")].span());

    world.sync_perms_and_inits([system_def].span());
    return system;
}

#[test]
fn test_deposit_erc20() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let cashier: ICashierDispatcher = deploy_cashier(ref world);
    let eth_to_chips_ratio: u256 = 10000000000000;
    let player_address = starknet::contract_address_const::<0x1A>();
    let initial_chips = 0;
    let deposit_amount: u256 = 1000000000000000000; // 1 ETH in wei

    // Ensure the player model is initialized correctly
    let mut player: ComponentBank = IBank::new(player_address);
    player.m_balance = initial_chips;
    world.write_model_test(@player);

    starknet::testing::set_contract_address(player_address);
    cashier.deposit_erc20(deposit_amount);

    let player: ComponentBank = world.read_model(player_address);
    assert_eq!(player.m_balance, initial_chips + (deposit_amount / eth_to_chips_ratio).try_into().unwrap());
}

#[test]
fn test_cashout_erc20() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let cashier: ICashierDispatcher = deploy_cashier(ref world);

    let player_address = starknet::contract_address_const::<0x1A>();
    let initial_chips = 1000;
    let cashout_amount: u256 = 50000000000000;

    let mut player: ComponentBank = IBank::new(player_address);
    player.m_balance = initial_chips;
    world.write_model_test(@player);

     // Calculate paymaster fee (5%)
    let paymaster_amount: u256 = (cashout_amount * PAYMASTER_FEE_PERCENTAGE.into()) / 100;
    println!("Paymaster amount: {}", paymaster_amount);

    // Calculate net amount after paymaster fee
    let net_amount: u256 = cashout_amount - paymaster_amount;
    println!("Net amount: {}", net_amount);

    // Calculate chips to mint based on net amount
    let chips_amount: u32 = (net_amount / ETH_TO_CHIPS_RATIO).try_into().expect('Cannot convert eth to chips');
    println!("Chips amount: {}", chips_amount);

    //starknet::testing::set_contract_address(player_address);
    //cashier.cashout_erc20(cashout_amount);  // 50 chips

    let player: ComponentBank = world.read_model((0, player_address));
    assert_eq!(player.m_balance, initial_chips - 50);
}

//#[test]
//fn test_transfer_chips() {
//    let mut world: dojo::world::WorldStorage = deploy_world();
//    let cashier: ICashierDispatcher = deploy_cashier(ref world);
//
//    let sender_address = starknet::contract_address_const::<0x1A>();
//    let recipient_address = starknet::contract_address_const::<0x1B>();
//    set_contract_address(sender_address);
//    let initial_chips_sender = 1000;
//    let initial_chips_recipient = 500;
//    let transfer_amount = 300;
//
//    let mut sender: ComponentPlayer = IPlayer::new(0, sender_address);
//    sender.m_total_chips = initial_chips_sender;
//    world.write_model_test(@sender);
//
//    let mut recipient: ComponentPlayer = IPlayer::new(0, recipient_address);
//    recipient.m_total_chips = initial_chips_recipient;
//    world.write_model_test(@recipient);
//
//    cashier.transfer_chips(recipient_address, transfer_amount);
//
//    let sender: ComponentPlayer = world.read_model((0, sender_address));
//    let recipient: ComponentPlayer = world.read_model((0, recipient_address));
//
//    assert_eq!(sender.m_total_chips, initial_chips_sender - transfer_amount);
//    assert_eq!(recipient.m_total_chips, initial_chips_recipient + transfer_amount);
//}

#[test]
fn test_set_treasury_address() {
    let mut world: dojo::world::WorldStorage = deploy_world();
    let cashier: ICashierDispatcher = deploy_cashier(ref world);

    let new_treasury_address = starknet::contract_address_const::<0x1C>();
    cashier.set_treasury_address(new_treasury_address);

    let treasury_address = cashier.get_treasury_address();
    assert_eq!(treasury_address, new_treasury_address);
}
