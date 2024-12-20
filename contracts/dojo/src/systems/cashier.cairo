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

use starknet::ContractAddress;

#[starknet::interface]
trait ICashier<TContractState> {
    fn deposit_erc20(ref self: TContractState, amount: u256);
    fn cashout_erc20(ref self: TContractState, chips_amount: u32);
    fn transfer_chips(ref self: TContractState, to: ContractAddress, amount: u32);
}

#[starknet::interface]
trait IERC20<TContractState> {
    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
}

#[dojo::contract]
mod cashier_system {
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use dominion::models::traits::IPlayer;
    use dojo::{model::ModelStorage, world::IWorldDispatcher};
    use dominion::models::components::ComponentPlayer;
    use super::{IERC20Dispatcher, IERC20DispatcherTrait};

    // Constants
    const ETH_TO_CHIPS_RATIO: u256 = 10000000000000; // 100,000 chips per ETH // TODO: Change this to 1,000,000 chips per ETH
    const PAYMASTER_FEE_PERCENTAGE: u32 = 0; // Turned off for now
    const WITHDRAWAL_FEE_PERCENTAGE: u32 = 2; // 2% withdrawal fee

    const ETH_CONTRACT_ADDRESS: felt252 =
        0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7; // Sepolia ETH on StarkNet
    const PAYMASTER_ADDRESS: felt252 =
        0x0000000000000000000000000000000000000000000000000000000000000000; // TODO: Set this
    const TREASURY_ADDRESS: felt252 =
        0x0000000000000000000000000000000000000000000000000000000000000000; // TODO: Set this
    const VAULT_ADDRESS: felt252 =
        0x0000000000000000000000000000000000000000000000000000000000000000; // TODO: Set this

    #[abi(embed_v0)]
    impl BankImpl of super::ICashier<ContractState> {
        fn deposit_erc20(ref self: ContractState, amount: u256) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            // Calculate paymaster fee (5%)
            let paymaster_amount: u256 = (amount * PAYMASTER_FEE_PERCENTAGE.into()) / 100;

            // Calculate net amount after paymaster fee
            let net_amount: u256 = amount - paymaster_amount;

            // Calculate chips to mint based on net amount
            let chips_amount: u32 = (net_amount / ETH_TO_CHIPS_RATIO).try_into().unwrap();

            // Transfer ETH to paymaster
            if PAYMASTER_FEE_PERCENTAGE > 0 {
                InternalImpl::_transfer_eth_to(
                    paymaster_amount, starknet::contract_address_const::<PAYMASTER_ADDRESS>()
                );
            }

            // Transfer net ETH to vault
            InternalImpl::_transfer_eth_to(
                net_amount, starknet::contract_address_const::<VAULT_ADDRESS>()
            );

            // Update player's chips
            let mut player: ComponentPlayer = world.read_model((0, caller));
            if !player.m_is_created {
                player = IPlayer::new(0, caller);
            }
            player.m_total_chips += chips_amount;
            world.write_model(@player);
        }

        fn cashout_erc20(ref self: ContractState, chips_amount: u32) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            // Get player component
            let mut player: ComponentPlayer = world.read_model(caller);
            assert!(player.m_total_chips >= chips_amount, "Insufficient chips");

            // Calculate ETH amount based on chips
            let eth_amount: u256 = chips_amount.into() * ETH_TO_CHIPS_RATIO;

            // Calculate withdrawal fee (2%)
            let fee_amount: u256 = (eth_amount * WITHDRAWAL_FEE_PERCENTAGE.into()) / 100;
            let net_eth_amount: u256 = eth_amount - fee_amount;

            // Transfer fee to treasury
            if WITHDRAWAL_FEE_PERCENTAGE > 0 {
                InternalImpl::_transfer_eth_to(
                    fee_amount, starknet::contract_address_const::<TREASURY_ADDRESS>()
                );
            }

            // Transfer net ETH to caller
            // TODO: Approve ETH contract to transfer ETH to caller from Vault's wallet
            InternalImpl::_transfer_eth_to(net_eth_amount, caller);

            // Update player's chips
            player.m_total_chips -= chips_amount;
            world.write_model(@player);
        }

        fn transfer_chips(ref self: ContractState, to: ContractAddress, amount: u32) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            // Get sender and recipient components
            let mut sender: ComponentPlayer = world.read_model(caller);
            let mut recipient: ComponentPlayer = world.read_model(to);

            assert!(sender.m_total_chips >= amount, "Insufficient chips");

            // Update balances
            sender.m_total_chips -= amount;
            recipient.m_total_chips += amount;

            world.write_model(@sender);
            world.write_model(@recipient);
        }
    }

    // Helper functions
    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _transfer_eth_to(amount: u256, to: ContractAddress) {
            // Create ERC20 dispatcher
            let erc20 = IERC20Dispatcher {
                contract_address: starknet::contract_address_const::<ETH_CONTRACT_ADDRESS>()
            };

            // Call transferFrom
            // TODO: Approve contract to transfer ETH first.
            let transfer_result = erc20
                .transfer_from(get_caller_address(), // from
                 to, // to
                 amount // amount
                );

            assert!(transfer_result, "ERC20 transfer failed");
        }
    }
}
