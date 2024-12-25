use dominion::{
    models::components::{m_ComponentTable, m_ComponentPlayer, m_ComponentSidepot, m_ComponentHand},
    systems::table_manager::table_management_system::{
        e_EventTableCreated, e_EventTableShutdown, e_EventEncryptDeckRequested,
        e_EventDecryptHandRequested, e_EventRequestBet, e_EventStreetAdvanced,
        e_EventAuthHashRequested
    },
    systems::actions::actions_system::{
        e_EventPlayerJoined, e_EventAllPlayersReady, e_EventPlayerLeft
    },
};

use crate::systems::actions::actions_system;
use crate::systems::cashier::cashier_system;
use crate::systems::table_manager::table_management_system;

use starknet::ContractAddress;
use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest};
use dojo::world::{WorldStorage, WorldStorageTrait};
use dojo::world::{IWorldDispatcherTrait};
use dojo::world::IWorldDispatcher;
use dojo_cairo_test::WorldStorageTestTrait;
use dojo::model::Model;
use dojo_cairo_test::{spawn_test_world, NamespaceDef, TestResource, ContractDefTrait};

pub fn deploy_world() -> dojo::world::WorldStorage {
    return spawn_test_world([namespace_def()].span());
}

pub fn namespace_def() -> NamespaceDef {
    let ndef = NamespaceDef {
        namespace: "dominion", resources: [
            TestResource::Model(m_ComponentTable::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentPlayer::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentSidepot::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentHand::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Contract(table_management_system::TEST_CLASS_HASH),
            TestResource::Contract(cashier_system::TEST_CLASS_HASH),
            TestResource::Contract(actions_system::TEST_CLASS_HASH),
            TestResource::Event(e_EventTableCreated::TEST_CLASS_HASH),
            TestResource::Event(e_EventTableShutdown::TEST_CLASS_HASH),
            TestResource::Event(e_EventDecryptHandRequested::TEST_CLASS_HASH),
            TestResource::Event(e_EventEncryptDeckRequested::TEST_CLASS_HASH),
            TestResource::Event(e_EventRequestBet::TEST_CLASS_HASH),
            TestResource::Event(e_EventStreetAdvanced::TEST_CLASS_HASH),
            TestResource::Event(e_EventAuthHashRequested::TEST_CLASS_HASH),
            TestResource::Event(e_EventPlayerJoined::TEST_CLASS_HASH),
            TestResource::Event(e_EventAllPlayersReady::TEST_CLASS_HASH),
            TestResource::Event(e_EventPlayerLeft::TEST_CLASS_HASH),
        ].span()
    };

    ndef
}
