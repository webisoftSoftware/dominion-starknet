use starknet::ContractAddress;

#[starknet::interface]
pub trait ICashier<TContractState> {
    fn deposit_erc20(ref self: TContractState, amount: u256);
    fn cashout_erc20(ref self: TContractState, chips_amount: u256);
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
pub trait IERC20<TContractState> {
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
}

#[dojo::contract]
pub(crate) mod cashier_system {
    use starknet::{ContractAddress, get_caller_address, get_tx_info, TxInfo};
    use dojo::{model::ModelStorage};
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use dominion::models::components::{ComponentBank, ComponentRake};
    use super::{IERC20Dispatcher, IERC20DispatcherTrait};

    // Constants
    const ETH_TO_CHIPS_RATIO: u256 =
        1_000_000_000_000; // 1,000,000 chips per ETH
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
            let chips_amount: u32 = (net_amount / ETH_TO_CHIPS_RATIO).try_into().expect('Cannot convert eth to chips');

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
            let mut player_bank: ComponentBank = world.read_model(caller);
            player_bank.m_balance += chips_amount;
            world.write_model(@player_bank);
        }

        fn cashout_erc20(ref self: ContractState, chips_amount: u256) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            // Get player component
            let mut player_bank: ComponentBank = world.read_model(caller);
            let chips_amount_u32: u32 = (chips_amount / ETH_TO_CHIPS_RATIO).try_into().expect('Cannot convert eth to chips');
            assert!(player_bank.m_balance >= chips_amount_u32, "Insufficient chips");

            // Calculate withdrawal fee (2%)
            let fee_amount: u256 = (chips_amount * WITHDRAWAL_FEE_PERCENTAGE.into()) / 100;
            let net_eth_amount: u256 = chips_amount - fee_amount;

            // Transfer net ETH to caller
            // Create ERC20 dispatcher
            let erc20 = IERC20Dispatcher {
                contract_address: starknet::contract_address_const::<ETH_CONTRACT_ADDRESS>()
            };

            // Transfer fee to treasury
            if WITHDRAWAL_FEE_PERCENTAGE > 0 {
                erc20.transfer(self.treasury_address.read(), fee_amount);
            }

            // Call transfer
            erc20.transfer(caller, net_eth_amount);

            // Update player's chips
            player_bank.m_balance -= chips_amount_u32;
            world.write_model(@player_bank);
        }

        fn transfer_chips(ref self: ContractState, to: ContractAddress, amount: u32) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            // Get sender and recipient components
            let mut sender_bank: ComponentBank = world.read_model(caller);
            let mut recipient_bank: ComponentBank = world.read_model(to);

            assert!(sender_bank.m_balance >= amount, "Insufficient chips");

            // Update balances
            sender_bank.m_balance -= amount;
            recipient_bank.m_balance += amount;

            world.write_model(@sender_bank);
            world.write_model(@recipient_bank);
        }

        fn claim_fees(ref self: ContractState) {
            let mut world = self.world(@"dominion");
            let caller = get_caller_address();

            // Get player component
            let mut rake: ComponentRake = world.read_model(caller);

            // Calculate ETH amount based on chips
            let eth_amount: u256 = rake.m_chip_amount.into() * ETH_TO_CHIPS_RATIO;

            // Transfer net ETH to caller
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
            let mut player_bank: ComponentBank = world.read_model(player);
            player_bank.m_balance
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
            erc20
                .transfer_from(get_caller_address(), // from
                 to, // to
                 amount // amount
                );
        }
    }
}
