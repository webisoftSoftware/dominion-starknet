use starknet::ContractAddress;

#[starknet::interface]
trait ICashier<TContractState> {
    fn deposit_erc20(ref self: TContractState, amount: u256);
    fn cashout_erc20(ref self: TContractState, chips_amount: u32);
    fn claim_fees(ref self: TContractState);
    fn transfer_chips(ref self: TContractState, to: ContractAddress, amount: u32);
    fn set_treasury_address(ref self: TContractState, treasury_address: ContractAddress);
    fn set_vault_address(ref self: TContractState, vault_address: ContractAddress);
    fn set_paymaster_address(ref self: TContractState, paymaster_address: ContractAddress);
    fn get_player_balance(self: @TContractState, player: ContractAddress) -> u32;
    fn get_treasury_address(self: @TContractState) -> ContractAddress;
    fn get_vault_address(self: @TContractState) -> ContractAddress;
    fn get_paymaster_address(self: @TContractState) -> ContractAddress;
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
    use starknet::{ContractAddress, get_caller_address, get_contract_address, get_tx_info, TxInfo};
    use dominion::models::traits::IPlayer;
    use dojo::{model::ModelStorage, world::IWorldDispatcher};
    use dominion::models::components::{ComponentPlayer, ComponentRake};
    use super::{IERC20Dispatcher, IERC20DispatcherTrait};

    // Constants
    const ETH_TO_CHIPS_RATIO: u256 =
        10000000000000; // 100,000 chips per ETH // TODO: Change this to 1,000,000 chips per ETH
    const PAYMASTER_FEE_PERCENTAGE: u32 = 0; // Turned off for now
    const WITHDRAWAL_FEE_PERCENTAGE: u32 = 0; // 2% withdrawal fee

    const ETH_CONTRACT_ADDRESS: felt252 =
        0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7; // Sepolia ETH on StarkNet
    
    #[storage]
    struct Storage {
        treasury_address: ContractAddress,
        vault_address: ContractAddress,
        paymaster_address: ContractAddress,
    }

    fn dojo_init(ref self: ContractState) {
        let tx_info: TxInfo = get_tx_info().unbox();

        // Access the account_contract_address field
        let sender: ContractAddress = tx_info.account_contract_address;

        // Set the table manager to the sender
        self.treasury_address.write(sender);
        self.vault_address.write(sender);
        self.paymaster_address.write(sender);
    }

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
                    paymaster_amount, self.paymaster_address.read()
                );
            }

            // Transfer net ETH to vault
            InternalImpl::_transfer_eth_to(
                net_amount, self.vault_address.read()
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
            let mut player: ComponentPlayer = world.read_model((0, caller));
            assert!(player.m_total_chips >= chips_amount, "Insufficient chips");

            // Calculate ETH amount based on chips
            let eth_amount: u256 = chips_amount.into() * ETH_TO_CHIPS_RATIO;

            // Calculate withdrawal fee (2%)
            let fee_amount: u256 = (eth_amount * WITHDRAWAL_FEE_PERCENTAGE.into()) / 100;
            let net_eth_amount: u256 = eth_amount - fee_amount;

            // Transfer fee to treasury
            if WITHDRAWAL_FEE_PERCENTAGE > 0 {
                InternalImpl::_transfer_eth_to(
                    fee_amount, self.treasury_address.read()
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
            let mut sender: ComponentPlayer = world.read_model((0, caller));
            let mut recipient: ComponentPlayer = world.read_model((0, to));

            assert!(sender.m_total_chips >= amount, "Insufficient chips");

            // Update balances
            sender.m_total_chips -= amount;
            recipient.m_total_chips += amount;

            world.write_model(@sender);
            world.write_model(@recipient);
        }

        fn claim_fees(ref self: ContractState) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            // Get player component
            let mut rake: ComponentRake = world.read_model(caller);

            // Calculate ETH amount based on chips
            let eth_amount: u256 = rake.m_chip_amount.into() * ETH_TO_CHIPS_RATIO;

            // Transfer net ETH to caller
            // TODO: Approve ETH contract to transfer ETH to caller from Vault's wallet
            InternalImpl::_transfer_eth_to(eth_amount, caller);

            // Update rake's chips
            rake.m_chip_amount = 0;
            world.write_model(@rake);
        }

        fn set_treasury_address(ref self: ContractState, treasury_address: ContractAddress) {
            assert!(get_caller_address() == self.treasury_address.read(), "Only treasury can set treasury address");
            self.treasury_address.write(treasury_address);
        }

        fn set_vault_address(ref self: ContractState, vault_address: ContractAddress) {
            assert!(get_caller_address() == self.vault_address.read(), "Only vault can set vault address");
            self.vault_address.write(vault_address);
        }

        fn set_paymaster_address(ref self: ContractState, paymaster_address: ContractAddress) {
            assert!(get_caller_address() == self.paymaster_address.read(), "Only paymaster can set paymaster address");
            self.paymaster_address.write(paymaster_address);
        }

        fn get_treasury_address(self: @ContractState) -> ContractAddress {
            self.treasury_address.read()
        }

        fn get_vault_address(self: @ContractState) -> ContractAddress {
            self.vault_address.read()
        }

        fn get_paymaster_address(self: @ContractState) -> ContractAddress {
            self.paymaster_address.read()
        }

        fn get_player_balance(self: @ContractState, player: ContractAddress) -> u32 {
            let mut world = self.world(@"dominion");
            let player_component: ComponentPlayer = world.read_model((0, player));
            player_component.m_total_chips
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
