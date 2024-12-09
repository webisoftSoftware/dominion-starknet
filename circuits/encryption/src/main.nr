fn main(key: Field, deck: pub [Field; 52]) -> pub [Field; 52] {
    let mut encoded_deck: [Field; 52] = [0; 52];
    for i in 0..26 {
        let mut card: [Field; 2] = [deck[i], deck[i + 26]];
        let mut encoded_cards = gmimc::bn254::enc::x5_2(card, key);
        encoded_deck[i] = encoded_cards[0];
        encoded_deck[i + 26] = encoded_cards[1];
    }
    //println(encoded_deck);
    encoded_deck
}


