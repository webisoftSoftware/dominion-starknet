use dominion::{
    models::components::{m_ComponentTable, m_ComponentPlayer, m_ComponentSidepot, m_ComponentHand,
     m_ComponentRake, m_ComponentTableInfo, m_ComponentStreet, m_ComponentRound, m_ComponentProof,
     m_ComponentBank, m_ComponentOriginalDeck, m_ComponentWinners},
    systems::table_manager::table_management_system::{
        e_EventTableCreated, e_EventTableShutdown, e_EventEncryptDeckRequested,
        e_EventDecryptHandRequested, e_EventRequestBet, e_EventStreetAdvanced,
        e_EventDecryptCCRequested, e_EventShowdownRequested,
        e_EventRevealShowdownRequested
    },
    systems::actions::actions_system::{
        e_EventPlayerJoined, e_EventAllPlayersReady, e_EventPlayerLeft, e_EventHandRevealed,
        e_EventAuthHashRequested
    },
};

use crate::systems::actions::actions_system;
use crate::systems::cashier::cashier_system;
use crate::systems::table_manager::table_management_system;

use dojo_cairo_test::{spawn_test_world, NamespaceDef, TestResource};

pub fn deploy_world() -> dojo::world::WorldStorage {
    return spawn_test_world([namespace_def()].span());
}

pub fn namespace_def() -> NamespaceDef {
    let ndef = NamespaceDef {
        namespace: "dominion", resources: [
            TestResource::Contract(table_management_system::TEST_CLASS_HASH),
            TestResource::Contract(actions_system::TEST_CLASS_HASH),
            TestResource::Contract(cashier_system::TEST_CLASS_HASH),
            TestResource::Model(m_ComponentTable::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentPlayer::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentSidepot::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentHand::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentRake::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentStreet::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentRound::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentProof::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentBank::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentTableInfo::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentOriginalDeck::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentWinners::TEST_CLASS_HASH.try_into().unwrap()),
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
            TestResource::Event(e_EventDecryptCCRequested::TEST_CLASS_HASH),
            TestResource::Event(e_EventShowdownRequested::TEST_CLASS_HASH),
            TestResource::Event(e_EventRevealShowdownRequested::TEST_CLASS_HASH),
            TestResource::Event(e_EventHandRevealed::TEST_CLASS_HASH),
        ].span()
    };

    ndef
}
