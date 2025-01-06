mod models {
    mod utils;
    mod components;
    mod enums;
    mod structs;
    mod traits;
}

mod systems {
    mod actions;
    mod table_manager;
    mod cashier;
}

#[cfg(test)]
mod tests {
    mod unit {
        mod test_card;
        mod test_utils;
        mod test_traits;
    }
    mod integration {
        mod utils;
        mod test_actions;
        mod test_table_manager;
        // mod test_cashier;
    }
}
