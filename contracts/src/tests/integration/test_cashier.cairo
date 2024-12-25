use crate::systems::cashier::{cashier_system, ICashierDispatcher, ICashierDispatcherTrait};

use crate::models::enums::{EnumGameState, EnumPlayerState, EnumCardValue, EnumCardSuit, EnumPosition};
use crate::models::components::{ComponentTable, ComponentPlayer, ComponentHand};
use crate::models::traits::{IPlayer, ITable};

use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest, ModelValueStorageTest};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorageTrait};
use dojo_cairo_test::{ContractDefTrait, WorldStorageTestTrait};
use starknet::ContractAddress;

use crate::tests::integration::utils::deploy_world;

pub fn deploy_cashier(ref world: dojo::world::WorldStorage) -> ICashierDispatcher {
    let (contract_address, _) = world.dns(@"cashier_system").unwrap();

    let system: ICashierDispatcher = ICashierDispatcher { contract_address };

    let system_def = ContractDefTrait::new(@"dominion", @"cashier_system")
        .with_writer_of([dojo::utils::bytearray_hash(@"dominion")].span());

    world.sync_perms_and_inits([system_def].span());

    return system;
}
