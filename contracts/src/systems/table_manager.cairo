use core::starknet::ContractAddress;
use dominion::models::structs::StructCard;
use dominion::models::components::{ComponentSidepot};

#[starknet::interface]
pub trait ITableManagement<TContractState> {
    // Backend entrypoints.
    fn post_encrypt_deck(
        ref self: TContractState, table_id: u32, encrypted_deck: Array<StructCard>
    );
    fn post_decrypted_community_cards(
        ref self: TContractState, table_id: u32, cards: Array<StructCard>
    );
    fn post_proofs(ref self: TContractState, table_id: u32, shuffle_proof: ByteArray,
        deck_proof: ByteArray);
    
    // Admin Functions.
    fn kick_player(ref self: TContractState, table_id: u32, player: ContractAddress);
    fn create_table(
        ref self: TContractState, small_blind: u32, big_blind: u32, min_buy_in: u32,
         max_buy_in: u32, rake_fee: u32
    );
    fn shutdown_table(ref self: TContractState, table_id: u32);
    fn change_table_manager(ref self: TContractState, new_table_manager: ContractAddress);

    // Getters.
    fn get_table_manager(self: @TContractState) -> ContractAddress;
    fn get_table_length(self: @TContractState) -> u32;
    fn get_table_state(self: @TContractState, table_id: u32) -> ByteArray;
    fn get_table_players(self: @TContractState, table_id: u32) -> Array<ContractAddress>;
    fn get_current_turn(self: @TContractState, table_id: u32) -> Option<ContractAddress>;
    fn get_current_sidepots(self: @TContractState, table_id: u32) -> Array<ComponentSidepot>;
    fn get_table_community_cards(self: @TContractState, table_id: u32) -> Array<StructCard>;
    fn is_deck_encrypted(self: @TContractState, table_id: u32) -> bool;
    fn get_table_deck(self: @TContractState, table_id: u32) -> Array<StructCard>;
    fn get_table_last_played_ts(self: @TContractState, table_id: u32) -> u64;
    fn get_table_min_buy_in(self: @TContractState, table_id: u32) -> u32;
    fn get_table_max_buy_in(self: @TContractState, table_id: u32) -> u32;
    fn get_table_rake_fee(self: @TContractState, table_id: u32) -> u32;
    fn get_table_small_blind(self: @TContractState, table_id: u32) -> u32;
    fn get_table_big_blind(self: @TContractState, table_id: u32) -> u32;
    fn get_table_last_raiser(self: @TContractState, table_id: u32) -> Option<ContractAddress>;
}

#[dojo::contract]
pub(crate) mod table_management_system {
    use starknet::{ContractAddress, get_caller_address, TxInfo, get_tx_info};
    use dojo::{model::ModelStorage};
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use dominion::models::components::{
        ComponentTable, ComponentPlayer, ComponentHand, ComponentSidepot, ComponentRake,
        ComponentProof, ComponentBank, ComponentStreet, ComponentRound, ComponentTableInfo,
        ComponentOriginalDeck, ComponentWinners
    };
    use dominion::models::enums::{
        EnumTableState, EnumPlayerState, EnumStreetState, EnumRankMask, EnumHandRank,
        EnumPosition
    };
    use dominion::models::traits::{
        ITable, EnumHandRankPartialOrd, ComponentPlayerDisplay,
        EnumRankMaskPartialOrd, EnumHandRankSnapshotInto, EnumHandRankSnapshotIntoMask,
        ComponentHandDisplay, StructCardEq, IProof, ITableInfo, ISidepot, IHand,
        IEnumRankMask, IStreet, IRound, IPlayer, EnumTableStateInto, EnumErrorDisplay
    };
    use dominion::models::utils;
    use dominion::models::structs::StructCard;
    use dojo::event::{EventStorage};

    const MIN_PLAYERS: u32 = 2;

    #[storage]
    struct Storage {
        table_manager: ContractAddress,
        counter: u32,
    }

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    pub(crate) struct EventTableCreated {
        #[key]
        m_table_id: u32,
        m_timestamp: u64
    }

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    pub(crate) struct EventTableShutdown {
        #[key]
        m_table_id: u32,
        m_timestamp: u64
    }

    #[derive(Copy, Clone, Serde, Drop)]
    #[dojo::event]
    pub(crate) struct EventRequestBet {
        #[key]
        m_table_id: u32,
        m_timestamp: u64,
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    pub(crate) struct EventEncryptDeckRequested {
        #[key]
        m_table_id: u32,
        m_deck: Array<StructCard>,
        m_timestamp: u64,
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    pub(crate) struct EventStreetAdvanced {
        #[key]
        m_table_id: u32,
        m_state: EnumStreetState,
        m_timestamp: u64,
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    pub(crate) struct EventDecryptHandRequested {
        #[key]
        m_table_id: u32,
        #[key]
        m_player: ContractAddress,
        m_hand: Array<StructCard>,
        m_timestamp: u64
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    pub(crate) struct EventDecryptCCRequested {
        #[key]
        m_table_id: u32,
        m_cards: Array<StructCard>,
        m_timestamp: u64
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    pub(crate) struct EventShowdownRequested {
        #[key]
        m_table_id: u32,
        m_timestamp: u64
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    pub(crate) struct EventRevealShowdownRequested {
        #[key]
        m_table_id: u32,
        #[key]
        m_player: ContractAddress,
        m_hand: Array<StructCard>,
        m_timestamp: u64
    }

    #[derive(Clone, Serde, Drop)]
    #[dojo::event]
    pub(crate) struct EventAuthHashVerified {
        #[key]
        m_table_id: u32,
        m_timestamp: u64
    }

    fn dojo_init(ref self: ContractState) {
        let tx_info: TxInfo = get_tx_info().unbox();

        // Access the account_contract_address field
        let sender: ContractAddress = tx_info.account_contract_address;

        // Set the table manager to the sender
        self.table_manager.write(sender);
        self.counter.write(1);
    }

    #[abi(embed_v0)]
    impl TableManagementImpl of super::ITableManagement<ContractState> {
        fn create_table(
            ref self: ContractState,
            small_blind: u32,
            big_blind: u32,
            min_buy_in: u32,
            max_buy_in: u32,
            rake_fee: u32
        ) {
            assert!(
                self.table_manager.read() == get_caller_address(),
                "Only the table manager can create tables"
            );

            assert!(small_blind > 0, "Small blind cannot be less than 0");
            assert!(big_blind > small_blind, "Big blind cannot be less than small blind");

            assert!(max_buy_in > 0, "Maximum buy-in cannot be less than 0");
            assert!(
                max_buy_in > min_buy_in, "Minimum buy-in cannot be greater than maximum buy-in"
            );

            assert!(rake_fee > 0, "Rake fee cannot be less than 0");
            assert!(rake_fee < 10, "Rake fee cannot be greater than 10");

            let mut world = self.world(@"dominion");

            let table_id: u32 = self.counter.read();
            let mut table_info: ComponentTableInfo = world.read_model(table_id);
            assert!(table_info.m_state == EnumTableState::Shutdown, "Table is already created");

            table_info = ITableInfo::new(
                table_id,
                small_blind,
                big_blind,
                min_buy_in,
                max_buy_in
            );
            let mut rake: ComponentRake = ComponentRake {
                m_table_id: table_id,
                m_rake_address: self.table_manager.read(),
                m_rake_fee: rake_fee,
                m_chip_amount: 0
            };

            // Initialize new table with provided parameters.
            let mut new_table: ComponentTable = ITable::new(table_id, array![]);
            new_table._initialize_deck();

            // Save table to world state and increment counter
            world.write_model(@table_info);
            world.write_model(@rake);
            world.write_model(@new_table);
            self.counter.write(table_id + 1);

            world
                .emit_event(
                    @EventTableCreated {
                        m_table_id: table_id, m_timestamp: starknet::get_block_timestamp()
                    }
                );
        }

        fn shutdown_table(ref self: ContractState, table_id: u32) {
            assert!(
                self.table_manager.read() == get_caller_address(),
                "Only the table manager can shutdown the table"
            );

            let mut world = self.world(@"dominion");

            let mut table_info: ComponentTableInfo = world.read_model(table_id);
            let mut table: ComponentTable = world.read_model(table_id);
            assert!(table_info.m_state != EnumTableState::Shutdown, "Table is already shutdown");
            table_info.m_state = EnumTableState::Shutdown;
            world.erase_model(@table_info);
            world.erase_model(@table);
            world.emit_event(
                    @EventTableShutdown {
                        m_table_id: table_id, m_timestamp: starknet::get_block_timestamp()
                    }
                );
        }

        fn post_proofs(ref self: ContractState, table_id: u32, shuffle_proof: ByteArray,
                deck_proof: ByteArray) {
            assert!(
                self.table_manager.read() == get_caller_address(),
                "Only the table manager can post proofs"
            );

            let mut world = self.world(@"dominion");

            let table: ComponentTable = world.read_model(table_id);
            let current_street: ComponentStreet = world.read_model((table_id, table.m_current_round));
            assert!(current_street.m_state == EnumStreetState::PreFlop, "Can only post proofs at the start of each round");

            let mut proofs: ComponentProof = world.read_model(table_id);
            proofs.m_shuffle_proof = shuffle_proof;
            proofs.m_deck_proof = deck_proof;
            world.write_model(@proofs)
        }

        // Update deck with encrypted deck, update game state.
        fn post_encrypt_deck(
            ref self: ContractState, table_id: u32, encrypted_deck: Array<StructCard>
        ) {
            assert!(
                self.table_manager.read() == get_caller_address(),
                "Only the table manager can update the deck"
            );

            let mut world = self.world(@"dominion");
            let mut proofs: ComponentProof = world.read_model(table_id);
            assert!(
                proofs.m_shuffle_proof != "" && proofs.m_deck_proof != "",
                "Cannot post encrypted deck with no proof"
            );
            assert!(encrypted_deck.len() == 52, "Deck must contain 52 cards");

            let mut table: ComponentTable = world.read_model(table_id);
            let table_info: ComponentTableInfo = world.read_model(table_id);
            assert!(table_info.m_state == EnumTableState::InProgress, "Game has not started");

            let mut original_deck: ComponentOriginalDeck = world.read_model(table_id);
            let current_street: ComponentStreet = world.read_model((table_id, table.m_current_round));
            assert!(
                current_street.m_state == EnumStreetState::PreFlop,
                "Deck encryption is only allowed when round starts"
            );

            //for card in table.m_deck.span() {
            //    assert!(!utils::contains_card(@encrypted_deck, card), "Deck not encrypted");
            //};

            table.m_deck = encrypted_deck.clone();
            original_deck.m_deck = encrypted_deck.clone();

            // Shuffle the deck.
            table.shuffle_deck(starknet::get_block_timestamp().into());

            // Distribute cards to each player.
            for i in 0..table.m_players.len() {
                // Give card pair to each player and update table and player's hands.
                let mut player_hand: ComponentHand = world.read_model((table_id, *table.m_players[i]));
                assert!(player_hand.m_cards.len() < 2, "Player already has 2 cards");

                if let Option::Some(card) = table.m_deck.pop_front() {
                    player_hand.m_cards.append(card);
                }

                if let Option::Some(card) = table.m_deck.pop_front() {
                    player_hand.m_cards.append(card);
                }

                if player_hand.m_cards.len() == 2 {
                    world.emit_event(
                        @EventDecryptHandRequested {
                            m_table_id: table.m_table_id,
                            m_player: *table.m_players[i],
                            m_hand: player_hand.m_cards.clone(),
                            m_timestamp: starknet::get_block_timestamp()
                        }
                    );
                    world.write_model(@player_hand);
                }
            };

            proofs.m_encrypted_deck_posted = true;
            world.write_model(@proofs);
            world.write_model(@original_deck);
            world.write_model(@table);
        }

        fn post_decrypted_community_cards(
            ref self: ContractState, table_id: u32, mut cards: Array<StructCard>
        ) {
            assert!(
                self.table_manager.read() == get_caller_address(),
                "Only the table manager can update the community cards"
            );

            let mut world = self.world(@"dominion");

            let mut table: ComponentTable = world.read_model(table_id);
            let table_info: ComponentTableInfo = world.read_model(table_id);
            assert!(table_info.m_state == EnumTableState::InProgress, "Game has not started");

            let current_street: ComponentStreet = world.read_model((table_id, table.m_current_round));
            assert!(
                current_street.m_state == EnumStreetState::Flop
                    || current_street.m_state == EnumStreetState::Turn
                    || current_street.m_state == EnumStreetState::River,
                "Game is not in a valid state to update the community cards"
            );

            utils::append_all_cards(ref table.m_community_cards, ref cards);
            world.write_model(@table);
        }

        fn kick_player(ref self: ContractState, table_id: u32, player: ContractAddress) {
            assert!(
                self.table_manager.read() == get_caller_address(),
                "Only the table manager can kick players"
            );

            let mut world = self.world(@"dominion");
            let mut table: ComponentTable = world.read_model(table_id);
            let table_info: ComponentTableInfo = world.read_model(table_id);
            assert!(table_info.m_state == EnumTableState::InProgress, "Game has not started");

            let mut player_model: ComponentPlayer = world.read_model((table_id, player));
            assert!(table.contains_player(@player_model.m_owner), "Player not found");

            let mut player_bank: ComponentBank = world.read_model(player);

            // Reset player's table state and return chips
            table.m_pot += player_model.m_current_bet;

            player_bank.m_balance += player_model.m_table_chips;

            player_model.m_table_id = 0;
            player_model.m_table_chips = 0;
            player_model.m_state = EnumPlayerState::Left;

            table.remove_player(@player);

            world.write_model(@table);
            world.write_model(@player_bank);
            world.write_model(@player_model);
        }

        fn change_table_manager(ref self: ContractState, new_table_manager: ContractAddress) {
            assert!(
                self.table_manager.read() == get_caller_address(),
                "Only the table manager can change the table manager"
            );
            self.table_manager.write(new_table_manager);
        }

        /////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////
        //////////////////////////////// GETTERS ////////////////////////////////
        /////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////
        
        fn get_table_manager(self: @ContractState) -> ContractAddress {
            self.table_manager.read()
        }

        
        fn get_table_length(self: @ContractState) -> u32 {
            self.counter.read() - 1
        }
        
        fn get_table_state(self: @ContractState, table_id: u32) -> ByteArray {
            let world = self.world(@"dominion");
            let table_info: ComponentTableInfo = world.read_model(table_id);
            table_info.m_state.into()
        }
        
        fn get_table_players(self: @ContractState, table_id: u32) -> Array<ContractAddress> {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            table.m_players
        }
        
        fn get_table_last_raiser(self: @ContractState, table_id: u32) -> Option<ContractAddress> {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            let current_round: ComponentRound = world.read_model((table_id, table.m_current_round));
            if current_round.m_last_raiser_addr != starknet::contract_address_const::<0x0>() {
                Option::Some(current_round.m_last_raiser_addr)
            } else {
                Option::None
            }
        }
        
        fn get_current_turn(self: @ContractState, table_id: u32) -> Option<ContractAddress> {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            let current_round: ComponentRound = world.read_model((table_id, table.m_current_round));
            if current_round.m_current_turn != starknet::contract_address_const::<0x0>() {
                Option::Some(current_round.m_current_turn)
            } else {
                Option::None
            }
        }

        fn get_current_sidepots(self: @ContractState, table_id: u32) -> Array<ComponentSidepot> {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            let mut sidepots: Array<ComponentSidepot> = array![];
            for i in 0..table.m_num_sidepots {
                let sidepot: ComponentSidepot = world.read_model((table_id, i));
                sidepots.append(sidepot);
            };
            sidepots
        }
        
        fn get_table_community_cards(self: @ContractState, table_id: u32) -> Array<StructCard> {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            table.m_community_cards
        }
        
        fn is_deck_encrypted(self: @ContractState, table_id: u32) -> bool {
            let world = self.world(@"dominion");
            let proofs: ComponentProof = world.read_model(table_id);
            proofs.is_deck_encrypted()
        }

        fn get_table_deck(self: @ContractState, table_id: u32) -> Array<StructCard> {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            table.m_deck
        }
        
        fn get_table_last_played_ts(self: @ContractState, table_id: u32) -> u64 {
            let world = self.world(@"dominion");
            let table: ComponentTable = world.read_model(table_id);
            let current_round: ComponentRound = world.read_model((table_id, table.m_current_round));
            current_round.m_last_played_ts
        }

        fn get_table_min_buy_in(self: @ContractState, table_id: u32) -> u32 {
            let world = self.world(@"dominion");
            let table_info: ComponentTableInfo = world.read_model(table_id);
            table_info.m_min_buy_in
        }

        fn get_table_max_buy_in(self: @ContractState, table_id: u32) -> u32 {
            let world = self.world(@"dominion");
            let table_info: ComponentTableInfo = world.read_model(table_id);
            table_info.m_max_buy_in
        }

        fn get_table_rake_fee(self: @ContractState, table_id: u32) -> u32 {
            let world = self.world(@"dominion");
            let rake: ComponentRake = world.read_model(table_id);
            rake.m_rake_fee
        }

        fn get_table_small_blind(self: @ContractState, table_id: u32) -> u32 {
            let world = self.world(@"dominion");
            let table_info: ComponentTableInfo = world.read_model(table_id);
            table_info.m_small_blind
        }

        fn get_table_big_blind(self: @ContractState, table_id: u32) -> u32 {
            let world = self.world(@"dominion");
            let table_info: ComponentTableInfo = world.read_model(table_id);
            table_info.m_big_blind
        }
    }

    #[generate_trait]
    pub(crate) impl InternalImpl of InternalTrait {
        fn _start_round(ref world: dojo::world::WorldStorage, ref table: ComponentTable) {
            let mut table_info: ComponentTableInfo = world.read_model(table.m_table_id);
            assert!(
                table_info.m_state != EnumTableState::Shutdown,
                "Table is shutdown"
            );
            assert!(table.m_players.len() >= 2, "Not enough players to start the round");

            // Reset proofs.
            let mut current_proofs: ComponentProof = world.read_model(table.m_table_id);
            current_proofs.reset();

            // Reset player's hands and bets.
            for player in table.m_players.span() {
                let mut player_hand: ComponentHand = world.read_model((table.m_table_id, *player));
                if player_hand.m_cards.len() > 0 {
                    player_hand.m_cards = array![];
                    player_hand.m_commitment_hash = array![];
                    world.write_model(@player_hand);
                }

                let mut player_model: ComponentPlayer = world.read_model((table.m_table_id, *player));
                if player_model.m_current_bet > 0 {
                    player_model.m_current_bet = 0;
                    if player_model.m_table_chips == 0 {
                        player_model.m_state = EnumPlayerState::Left;
                    }
                    world.write_model(@player_model);
                }
            };

            // Reset the table (Community cards, pot, and deck are cleared out) and increment round.
            table.reset_table();
            // Reset deck too, so we can re-encrypt it.
            table._initialize_deck();

            // Update order and dealer chip position (Small Blind, Big Blind, etc.).
            Self::_update_roles(ref world, ref table);

            // Remove players sitting out.
            Self::_remove_sitting_out_players(ref world, ref table);

            let mut current_round: ComponentRound = world.read_model((table.m_table_id, table.m_current_round));

            // Make small blind and big blind bet automatically.
            let small_blind_position = (current_round.m_current_dealer + 1) % table.m_players.len().try_into().expect('Cannot downsize table length');
            let big_blind_position = (current_round.m_current_dealer + 2) % table.m_players.len().try_into().expect('Cannot downsize table length');

            if let Option::Some(small_blind_player) = table.m_players.get(small_blind_position.into()) {
                let mut small_blind_player: ComponentPlayer = world.read_model((table.m_table_id, *small_blind_player.unbox()));
                if small_blind_player.m_table_chips > 0 {
                    Self::_place_bet(ref world, ref table, ref small_blind_player, table_info.m_small_blind.clone(), ref current_round);
                    small_blind_player.m_state = EnumPlayerState::Active;
                    world.write_model(@small_blind_player);
                }
            }
            if let Option::Some(big_blind_player) = table.m_players.get(big_blind_position.into()) {
                let mut big_blind_player: ComponentPlayer = world.read_model((table.m_table_id, *big_blind_player.unbox()));
                if big_blind_player.m_table_chips > 0 {
                    Self::_place_bet(ref world, ref table, ref big_blind_player, table_info.m_big_blind, ref current_round);
                    big_blind_player.m_state = EnumPlayerState::Active;
                    world.write_model(@big_blind_player);
                }
            }

            let mut current_street: ComponentStreet = world.read_model((table.m_table_id, current_round.m_round_id));
            current_street.m_state = EnumStreetState::PreFlop;
            table_info.m_state = EnumTableState::InProgress;

            world.write_model(@table_info);
            world.write_model(@current_proofs);
            world.emit_event(
                @EventEncryptDeckRequested {
                    m_table_id: table.m_table_id,
                    m_deck: table.m_deck.clone(),
                    m_timestamp: starknet::get_block_timestamp()
                }
            );
            world.write_model(@table);
            world.write_model(@current_round);
            world.write_model(@current_street);
        }

        fn _skip_folded_players(ref world: dojo::world::WorldStorage, ref table: ComponentTable) {
            let players_len = table.m_players.len();
            let mut current_round: ComponentRound = world.read_model((table.m_table_id, table.m_current_round));
            let mut index: u32 = table.find_player(@current_round.m_current_turn).unwrap_or(0);

            let mut players_folded: Array<EnumPlayerState> = array![];
            let mut player_component: ComponentPlayer = world.read_model((table.m_table_id, *table.m_players[(index + 1) % players_len.try_into().unwrap()]));

            while player_component.m_state == EnumPlayerState::Folded {
                players_folded.append(player_component.m_state);
                index += 1;
                player_component = world.read_model((table.m_table_id, *table.m_players[index % players_len.try_into().unwrap()]));
            };
            current_round.advance_turn(@table.m_players, players_folded);
            world.write_model(@current_round);
        }

        /// Assign a player to a sidepot. A player needs to meet the minimum bet of the sidepot to be added to it.
        /// If the player does not meet the minimum bet of any sidepot, a new sidepot is created for them.
        ///
        /// @param world: The world storage.
        /// @param table_id: The table ID.
        /// @param player: The player to assign to a sidepot.
        /// @param amount: The amount the player has bet.
        /// @returns: Nothing.
        /// Can Panic? Yes.
        fn _assign_player_to_sidepot(
            ref world: dojo::world::WorldStorage,
            ref table: ComponentTable,
            player: ContractAddress,
            amount: u32
        ) {
            let mut remaining_amount: u32 = amount;

            // Check all sidepots to see if the player can be added to one.
            let table_info: ComponentTableInfo = world.read_model(table.m_table_id);
            for i in 0..table.m_num_sidepots {
                let mut sidepot: ComponentSidepot = world.read_model((table.m_table_id, i));
                // If the player qualifies for this sidepot, add them to the sidepot.
                if remaining_amount >= sidepot.m_min_bet && sidepot.m_min_bet >= table_info.m_small_blind {
                    sidepot.m_eligible_players.append(player);
                    sidepot.m_amount += sidepot.m_min_bet;
                    world.write_model(@sidepot);
                    remaining_amount -= sidepot.m_min_bet;
                }
            };

            // If the player was not added to any sidepot, create a new sidepot for them.
            if remaining_amount >= table_info.m_small_blind {
                let mut sidepot: ComponentSidepot = world.read_model((table.m_table_id, table.m_num_sidepots));
                sidepot = ISidepot::new(table.m_table_id, table.m_num_sidepots, remaining_amount,
                    array![player], remaining_amount);
                world.write_model(@sidepot);
                table.m_num_sidepots += 1;
            }
        }

        /// Remove a player from all sidepots.
        /// IF there are no players left in a sidepot, remove the sidepot.
        ///
        /// @param world: The world storage.
        /// @param table_id: The table ID.
        /// @param player: The player to remove from all sidepots.
        /// @returns: Nothing.
        /// Can Panic? Yes.
        fn _remove_player_from_sidepots(
            ref world: dojo::world::WorldStorage,
            ref table: ComponentTable,
            player: ContractAddress
        ) {
            for i in 0..table.m_num_sidepots {
                let mut sidepot: ComponentSidepot = world.read_model((table.m_table_id, i));
                if let Option::Some(index) = sidepot.find_player(@player) {
                    if sidepot.m_eligible_players.len() == 1 {
                        // If there's only one player left in the sidepot, remove the sidepot.
                        world.erase_model(@sidepot);
                        table.m_num_sidepots -= 1;
                    } else {
                        let mut eligible_players: Array<ContractAddress> = array![];
                        for j in 0..sidepot.m_eligible_players.len() {
                            if j != index {
                                eligible_players.append(sidepot.m_eligible_players[j].clone());
                            }
                        };
                        sidepot.m_eligible_players = eligible_players;
                        world.write_model(@sidepot);
                    }
                }
            };
        }

        fn _remove_sitting_out_players(
            ref world: dojo::world::WorldStorage,
            ref table: ComponentTable
        ) {
            for i in 0..table.m_players.len() {
                let mut player: ComponentPlayer = world.read_model((table.m_table_id, *table.m_players[i]));
                let mut player_bank: ComponentBank = world.read_model(*table.m_players[i]);
                if player.m_state == EnumPlayerState::Left {
                    // Reset player's table state and return chips
                    table.m_pot += player.m_current_bet;
                    player_bank.m_balance += player.m_table_chips;

                    player.m_table_id = 0;
                    player.m_table_chips = 0;
                    player.m_state = EnumPlayerState::Left;

                    table.remove_player(table.m_players[i]);
                    world.write_model(@table);
                    world.write_model(@player_bank);
                    world.write_model(@player);
                }
            };
        }

        fn _update_roles(ref world: dojo::world::WorldStorage, ref table: ComponentTable) {
            if table.m_players.len() <= 1 {
                return;
            }

            let last_round: ComponentRound = world.read_model((table.m_table_id, table.m_current_round - 1));

            // Advance positions.
            let mut dealer_position: u32 = 0;

            // Determine if this is the first round or not.
            if last_round.m_current_turn != starknet::contract_address_const::<0x0>() {
                let last_dealer_position: u32 = last_round.m_current_dealer.into();
                dealer_position = (last_dealer_position + 1) % table.m_players.len();
            }

            let mut small_blind_position: u32 = (dealer_position + 1) % table.m_players.len();
            let mut big_blind_position: u32 = (dealer_position + 2) % table.m_players.len();
            let mut first_turn: u32 = (dealer_position + 3) % table.m_players.len();

            let mut round: ComponentRound = world.read_model((table.m_table_id, table.m_current_round));
            round.m_current_dealer = dealer_position.try_into().expect('Cannot downsize dealer position');
            round.m_current_turn = *table.m_players[first_turn];
            round.m_last_raiser = big_blind_position.try_into().expect('Cannot downsize last raiser');
            round.m_last_raiser_addr = round.m_current_turn;

            let table_info: ComponentTableInfo = world.read_model(table.m_table_id);
            round.m_highest_raise = table_info.m_big_blind;
            world.write_model(@round);

            // Update Roles.
            let mut dealer: ComponentPlayer = world.read_model((table.m_table_id, *table.m_players[dealer_position]));
            dealer.m_is_dealer = true;
            dealer.m_state = EnumPlayerState::Active;

            let mut small_blind: ComponentPlayer = world.read_model((table.m_table_id, *table.m_players[small_blind_position]));
            small_blind.m_position = EnumPosition::SmallBlind;
            small_blind.m_state = EnumPlayerState::Active;

            let mut big_blind: ComponentPlayer = world.read_model((table.m_table_id, *table.m_players[big_blind_position]));
            big_blind.m_position = EnumPosition::BigBlind;
            big_blind.m_state = EnumPlayerState::Active;

            world.write_models(array![@dealer, @small_blind, @big_blind].span());

            // Update positions for everyone else.
            for i in 0..table.m_players.len() {
                // If we are not part of the three new assigned roles, set player position to none.
                if i != dealer_position && i != small_blind_position && i != big_blind_position {
                    let mut player: ComponentPlayer = world
                        .read_model((table.m_table_id, *table.m_players[i]));

                    // Include only players that are waiting to fill in or are ready if the game hasn't started yet,
                    // since we might call this again mid-round and don't want to change the states of players mid-bets.
                    if player.m_is_created && (player.m_state == EnumPlayerState::Waiting ||
                        player.m_state == EnumPlayerState::Ready) {
                        player.m_position = EnumPosition::None;
                        player.m_state = EnumPlayerState::Active;
                        world.write_model(@player);
                    }
                }
            };
        }

        fn _place_bet(ref world: dojo::world::WorldStorage, ref table: ComponentTable, ref player: ComponentPlayer,
            current_bet: u32, ref current_round: ComponentRound) {
            assert!(current_bet > 0, "Amount must be greater than 0 to place a bet");

            table.m_pot += player.place_bet(current_bet);
            if player.m_state == EnumPlayerState::AllIn {
                Self::_assign_player_to_sidepot(
                    ref world,
                    ref table,
                    player.m_owner,
                    player.m_current_bet);
            }
        }

        fn _advance_street(ref world: dojo::world::WorldStorage, ref table: ComponentTable) {
            let table_info: ComponentTableInfo = world.read_model(table.m_table_id);
            assert!(table_info.m_state == EnumTableState::InProgress, "Round has not started");

            let proofs: ComponentProof = world.read_model(table.m_table_id);
            assert!(proofs.is_deck_encrypted(), "Deck is not encrypted");

            // Check if all players are All-in, if they are, street is automatically finished.
            let mut all_players_all_in: bool = true;
            let mut players_remaining: Array<ContractAddress> = array![];
            for player in table.m_players.span() {
                let mut player_component: ComponentPlayer = world.read_model((table.m_table_id, *player));
                if player_component.m_state != EnumPlayerState::AllIn {
                    all_players_all_in = false;
                }

                if player_component.m_state != EnumPlayerState::Folded {
                    players_remaining.append(*player);
                }
            };

            let mut current_street: ComponentStreet = world.read_model((table.m_table_id, table.m_current_round));

            // Check if all players but one folded, in that case, assign the winner immediately
            // and skip to next round.
            if players_remaining.len() == 1 {
                // Set the player as 'Revealed' even though they won't show their cards, since they won by default.
                let mut player_component: ComponentPlayer = world.read_model((table.m_table_id, *players_remaining[0]));

                let mut winners_model: ComponentWinners = world.read_model((table.m_table_id, table.m_current_round));
                let mut winners: Array<(ContractAddress, EnumHandRank)> = array![(player_component.m_owner,
                    EnumHandRank::None)];

                winners_model.m_winners = array![player_component.m_owner];
                winners_model.m_hands = array![EnumHandRank::None];

                world.write_model(@winners_model);
                Self::_distribute_sidepots(ref world, ref table, ref winners);
                Self::_start_round(ref world, ref table);
                return;
            }

            if all_players_all_in {
                current_street.m_finished_street = true;
            } else {
                // Reset players' states if they are not all in.
                for player in table.m_players.span() {
                    let mut player_component: ComponentPlayer = world.read_model((table.m_table_id, *player));
                    if player_component.m_state != EnumPlayerState::Folded {
                        player_component.m_state = EnumPlayerState::Active;
                        world.write_model(@player_component);
                    }
                };
            }

            assert!(current_street.m_finished_street, "Street has not finished");

            // Advance table state to the next street.
            current_street.advance_street();

            match current_street.m_state {
                // Betting round.
                EnumStreetState::PreFlop => {
                    assert!(table.m_community_cards.is_empty(), "Street was not just started");
                    world.emit_event(
                        @EventRequestBet {
                            m_table_id: table.m_table_id, m_timestamp: starknet::get_block_timestamp()
                        }
                    );
                },
                // Flip 3 cards.
                EnumStreetState::Flop => {
                    assert!(table.m_community_cards.is_empty(), "Street was not at pre-flop");
                    let mut cards_to_reveal: Array<StructCard> = array![];
                    for _ in 0..3_u8 {
                        if let Option::Some(card_to_reveal) = table.m_deck.pop_front() {
                            cards_to_reveal.append(card_to_reveal);
                        }
                    };
                    world.emit_event(
                        @EventDecryptCCRequested {
                            m_table_id: table.m_table_id,
                            m_cards: cards_to_reveal,
                            m_timestamp: starknet::get_block_timestamp()
                        }
                    );
                },
                // Flip 1 card.
                EnumStreetState::Turn => {
                    assert!(table.m_community_cards.len() == 3, "Street was not at flop");
                    if let Option::Some(card_to_reveal) = table.m_deck.pop_front() {
                        world.emit_event(
                            @EventDecryptCCRequested {
                                m_table_id: table.m_table_id,
                                m_cards: array![card_to_reveal],
                                m_timestamp: starknet::get_block_timestamp()
                            }
                        );
                    }
                },
                // Flip last card.
                EnumStreetState::River => {
                    assert!(table.m_community_cards.len() == 4, "Street was not at turn");
                    if let Option::Some(card_to_reveal) = table.m_deck.pop_front() {
                        world.emit_event(
                            @EventDecryptCCRequested {
                                m_table_id: table.m_table_id,
                                m_cards: array![card_to_reveal],
                                m_timestamp: starknet::get_block_timestamp()
                            }
                        );
                    }
                },
                // Showdown.
                EnumStreetState::Showdown => {
                    assert!(table.m_community_cards.len() == 5, "Street was not at river");
                    world.emit_event(
                        @EventShowdownRequested {
                            m_table_id: table.m_table_id, m_timestamp: starknet::get_block_timestamp()
                        }
                    );

                    // Request each player to reveal their hand.
                    for player in table.m_players.span() {
                        let player_hand: ComponentHand = world.read_model((table.m_table_id, *player));
                        world.emit_event(
                            @EventRevealShowdownRequested {
                                m_table_id: table.m_table_id,
                                m_player: *player,
                                m_hand: player_hand.m_cards,
                                m_timestamp: starknet::get_block_timestamp()
                            }
                        );
                    };
                },
                _ => {}
            }

            world.emit_event(
                @EventStreetAdvanced {
                    m_table_id: table.m_table_id,
                    m_state: current_street.m_state,
                    m_timestamp: starknet::get_block_timestamp()
                }
            );
            world.write_model(@current_street);
            world.write_model(@table);
        }

        fn _showdown(ref world: dojo::world::WorldStorage, ref table: ComponentTable) {
            let current_street: ComponentStreet = world.read_model((table.m_table_id, table.m_current_round));
            assert!(current_street.m_state == EnumStreetState::Showdown, "Round is not at showdown");

            // Only take into account, active players that have revealed their hand.
            let mut eligible_players: Array<ContractAddress> = array![];
            for i in 0..table.m_players.len() {
                let player_component: ComponentPlayer = world.read_model((table.m_table_id, *table.m_players[i]));
                if player_component.m_state == EnumPlayerState::Revealed {
                    eligible_players.append(*table.m_players[i]);
                }
            };

            // Determine winners.
            let mut winners: Array<(ContractAddress, EnumHandRank)> = Self::_determine_winners(@world, @table, @eligible_players);
            let mut winners_model: ComponentWinners = world.read_model((table.m_table_id, table.m_current_round));

            for (winner, hand) in winners.span() {
                winners_model.m_winners.append(*winner);
                winners_model.m_hands.append(hand.clone());
            };
            world.write_model(@winners_model);

            Self::_distribute_sidepots(ref world, ref table, ref winners);
            Self::_start_round(ref world, ref table);
        }

        fn _distribute_sidepots(
            ref world: dojo::world::WorldStorage,
            ref table: ComponentTable,
            ref winners: Array<(ContractAddress, EnumHandRank)> // (player address, hand strength)
        ) {
            if winners.len() > 0 && table.m_num_sidepots == 0 {
                // Calculate rake once per pot.
                let mut current_rake: ComponentRake = world.read_model(table.m_table_id);
                let house_rake_fee = table.m_pot * current_rake.m_rake_fee / 100;
                let amount_after_rake = table.m_pot - house_rake_fee;
                let share_per_winner = amount_after_rake / winners.len().into();

                current_rake.m_chip_amount += house_rake_fee;
                world.write_model(@current_rake);

                for (addr, _) in winners.span() {
                    let mut player_component: ComponentPlayer = world.read_model((table.m_table_id, *addr));
                    // Keep house fee in mind.
                    player_component.m_table_chips += share_per_winner;
                    world.write_model(@player_component);
                };
                return;
            }

            // Process each sidepot from highest to lowest
            for pot_id in 0..table.m_num_sidepots {
                let mut pot_winners: Array<ContractAddress> = array![];
                let mut best_hand_strength: u32 = 0;
                let sidepot: ComponentSidepot = world.read_model((table.m_table_id, pot_id));

                // Find winners for this specific sidepot
                for i in 0..winners.len() {
                    let (winner_address, hand_strength) = winners[i];
                    let hand_strength_into_u32: u32 =  hand_strength.into();

                    if sidepot.m_min_bet > 0 && sidepot.contains_player(winner_address) {
                        if hand_strength_into_u32 > best_hand_strength {
                            pot_winners = array![*winner_address];
                            best_hand_strength = hand_strength_into_u32;
                        } else if hand_strength_into_u32 == best_hand_strength {
                            pot_winners.append(*winner_address);
                        }
                    }
                };

                // Distribute this sidepot among eligible winners
                if !pot_winners.is_empty() {
                    // Calculate rake once per pot
                    let mut current_rake: ComponentRake = world.read_model(table.m_table_id);
                    let house_rake_fee = sidepot.m_amount * current_rake.m_rake_fee / 100;
                    let amount_after_rake = sidepot.m_amount - house_rake_fee;
                    let share_per_winner = amount_after_rake / pot_winners.len().into();

                    current_rake.m_chip_amount += house_rake_fee;
                    world.write_model(@current_rake);

                    // Subtract pot amount once per sidepot
                    table.m_pot -= sidepot.m_amount;

                    for winner in pot_winners.span() {
                        let mut player_component: ComponentPlayer = world.read_model((table.m_table_id, *winner));
                        player_component.m_table_chips += share_per_winner;
                        world.write_model(@player_component);
                    };
                }
            };

            // Clean up sidepot entries
            for i in 0..table.m_num_sidepots {
                let sidepot: ComponentSidepot = world.read_model((table.m_table_id, i));
                world.erase_model(@sidepot);
            };

            table.m_num_sidepots = 0;
        }

        fn _determine_winners(
            world: @dojo::world::WorldStorage,
            table: @ComponentTable,
            eligible_players: @Array<ContractAddress>
        ) -> Array<(ContractAddress, EnumHandRank)> {
            let mut winners: Array<(ContractAddress, EnumHandRank)> = array![];
            let mut best_rank = EnumHandRank::None;  // Lowest value.
            let mut current_best_hand: Option<ComponentHand> = Option::None;

            // Find winners among eligible players.
            for player in eligible_players.span() {
                let player_component: ComponentPlayer = world.read_model((*table.m_table_id, *player));
                assert!(player_component.m_state == EnumPlayerState::Revealed, "Player is not revealed");
                let hand: ComponentHand = world.read_model((*table.m_table_id, *player));

                let mut rank_mask: EnumRankMask = EnumRankMask::RoyalFlush;
                let result = hand.evaluate_hand(table.m_community_cards, rank_mask);

                match result {
                    Result::Err(err) => panic!("Error evaluating hand from player {0:?}: {err}", *player),
                    Result::Ok(mut hand_rank) => {
                        match @current_best_hand {
                            Option::None => {
                                current_best_hand = Option::Some(hand.clone());
                                best_rank = hand_rank.clone();
                                winners.append((*player, hand_rank));
//                                println!("Best Hand: {:?} from Player {:?}", best_rank, *player);
                            },
                            Option::Some(best_hand) => {
//                                println!("Player {:?}'s Hand: {:?}", player_component.m_owner, hand_rank);
                                let mut comparison = utils::tie_breaker(@hand_rank, @best_rank);
                                rank_mask = (@hand_rank).into();

                                while comparison == 0 && rank_mask != EnumRankMask::None {
                                    rank_mask.increment_depth();
                                    hand_rank = hand
                                        .evaluate_hand(table.m_community_cards, rank_mask)
                                        .expect('Hand evaluation failed');
                                    best_rank = best_hand
                                        .evaluate_hand(table.m_community_cards, rank_mask)
                                        .expect('Hand evaluation failed');
//                                    println!("[Tie Breaker]: Player {:?}'s Hand: {:?} VS Best hand: {:?}",
//                                     player_component.m_owner, hand_rank, best_rank);
                                    comparison = utils::tie_breaker(@hand_rank, @best_rank);
                                };

                                if comparison == 2 {
                                    // New best hand found- clear previous winners.
                                    winners = array![(*player, hand_rank.clone())];
                                    current_best_hand = Option::Some(hand.clone());
                                    hand_rank = hand_rank;
//                                    println!("New Best Hand: {:?} from Player {:?}", hand_rank, player_component.m_owner);
                                } else if comparison == 0 {
                                    // Tied for best hand- add to winners.
                                    winners.append((*player, hand_rank));
                                }
                            }
                        };
                    }
                };
            };

//            println!("Winners: {:?}", winners);
            return winners;
        }
    }
}
