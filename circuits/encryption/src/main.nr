fn main(key: Field, deck: [Field; 52]) -> pub [Field; 52] {
    println("Input Deck:");
    println(deck);  // Print the original deck values

    let mut encoded_deck: [Field; 52] = [0; 52];
    println("Encoded Cards:");
    for i in 0..52 {
        let mut card: [Field; 2] = [deck[i], deck[i]];  // Use same value twice for single card
        let mut encoded_cards = gmimc::bn254::enc::x5_2(card, key);
        println(encoded_cards);
        encoded_deck[i] = encoded_cards[0];
    }

    println("Encoded Deck:");
    println(encoded_deck);
    encoded_deck
}