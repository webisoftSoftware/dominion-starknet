mod models {
    mod utils;
    mod components;
    mod enums;
    mod structs;
    mod traits;
}

mod systems {
    mod actions;
    mod game_master;
    mod table;
    mod bank;
}

#[cfg(test)]
mod tests {
    mod unit {
        mod test_utils;
        mod test_hand;
        mod test_traits;
    }
    mod integration {
        mod test_actions;
        mod test_game_master;
        mod test_table;
        mod test_bank;
    }
}
