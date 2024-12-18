////////////////////////////////////////////////////////////////////////////////////////////////////
// ██████████                             ███              ███
// ░░███░░░░███                           ░░░              ░░░
//  ░███   ░░███  ██████  █████████████
//  ████  ████████   ████   ██████
//  ████████
//  ░███    ░███
//  ███░░███░░███░░███░░███ ░░███
//  ░░███░░███ ░░███
//  ███░░███░░███░░███
//  ░███    ░███░███ ░███ ░███ ░███ ░███
//  ░███  ░███ ░███  ░███ ░███ ░███ ░███
//  ░███
//  ░███    ███ ░███ ░███ ░███ ░███ ░███
//  ░███  ░███ ░███  ░███ ░███ ░███ ░███
//  ░███
//  ██████████  ░░██████  █████░███
//  █████ █████ ████ █████
//  █████░░██████  ████ █████
// ░░░░░░░░░░    ░░░░░░  ░░░░░ ░░░ ░░░░░
// ░░░░░ ░░░░ ░░░░░ ░░░░░  ░░░░░░  ░░░░
// ░░░░░
//
// Copyright (c) 2024 Dominion
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software
// is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////////////////////////

use dominion::{
    models::components::{
        m_ComponentTable, m_ComponentPlayer, m_ComponentSidepot, m_ComponentHand
    },
    systems::table_manager::table_management_system::{
        e_EventTableCreated, e_EventTableShutdown
    }
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
        ].span()
    };

    ndef
}