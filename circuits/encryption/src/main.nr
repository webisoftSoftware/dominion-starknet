fn main(key: Field, deck: [Field; 52]) -> pub [Field; 52] {
    let mut encoded_deck: [Field; 52] = [0; 52];
    for i in 0..52 {
        let mut card: [Field; 2] = [deck[i], deck[i]];
        let mut encoded_cards = gmimc::bn254::enc::x5_2(card, key);
        println(encoded_cards);
        encoded_deck[i] = encoded_cards[0];
    }
    println(encoded_deck);
    encoded_deck
}


