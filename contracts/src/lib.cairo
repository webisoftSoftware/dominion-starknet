pub mod models {
    pub mod utils;
    pub mod components;
    pub mod enums;
    pub mod structs;
    pub mod traits;
}

pub mod systems {
    pub mod actions;
    pub mod table_manager;
    pub mod cashier;
}

#[cfg(test)]
pub mod tests {
    pub mod unit {
        pub mod test_card;
        pub mod test_utils;
        pub mod test_traits;
    }
    pub mod integration {
        pub mod utils;
        pub mod test_actions;
        pub mod test_table_manager;
        pub mod test_cashier;
    }
}
