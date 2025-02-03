// Helper function to find the index of the cards in the encrypted deck
fn find_cards(deck: [Field; 52], cards: [Field; 3]) -> [u8; 3] {
    let mut result: [u8; 3] = [0; 3];
    for i in 0..52 {
        if deck[i] == cards[0] {
            result[0] = i;
        }
        if deck[i] == cards[1] {
            result[1] = i;
        }
        if deck[i] == cards[2] {
            result[2] = i;
        }
    }
    result
}

fn main(key: [Field; 4], iv: [Field; 4], deck: [Field; 52], cards: [Field; 3]) -> pub [Field; 3] {
    // Decrypt the whole 52 card deck
    let decrypted_deck = hydra::bn254::dec::decrypt(deck, key, iv);

    // Encrypt the decrypted deck for assertion
    let encrypted_deck = hydra::bn254::enc::encrypt(decrypted_deck, key, iv);

    // Assert that the encrypted deck is the same as the original deck (hasn't been tampered)
    assert(encrypted_deck == deck);

    // Find the index of the cards in the encrypted deck
    let cards_index = find_cards(deck, cards);

    // Find the decrypted hand in the decrypted deck
    let decrypted_hand = [decrypted_deck[cards_index[0]], decrypted_deck[cards_index[1]], decrypted_deck[cards_index[2]]];

    // Return the decrypted hand
    decrypted_hand
}
