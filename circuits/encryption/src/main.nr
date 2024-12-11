fn main(key: Field, deck: [Field; 52]) -> pub [Field; 104] {
    println("Input Deck:");
    println(deck);

    let mut encoded_deck: [Field; 104] = [0; 104];
    println("Encoded Cards:");
    
    for i in 0..52 {
        let card: [Field; 2] = [deck[i], deck[i]];
        let encoded_cards = gmimc::bn254::enc::x5_2(card, key);
        
        encoded_deck[i * 2] = encoded_cards[0];
        encoded_deck[i * 2 + 1] = encoded_cards[1];
        
        println(encoded_cards);
    }

    println("Encoded Deck:");
    println(encoded_deck);
    encoded_deck
}