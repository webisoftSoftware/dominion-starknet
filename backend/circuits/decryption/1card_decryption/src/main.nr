// Helper function to find the index of the hand in the encrypted deck
fn find_card(deck: [Field; 52], card: Field) -> u8 {
    let mut result: u8 = 0;
    for i in 0..52 {
        if deck[i] == card {
            result = i;
        }
    }
    result
}

fn main(key: [Field; 4], iv: [Field; 4], deck: [Field; 52], cards: [Field; 1]) -> pub [Field; 1] {
    // Decrypt the whole 52 card deck
    let decrypted_deck = hydra::bn254::dec::decrypt(deck, key, iv);

    // Encrypt the decrypted deck for assertion
    let encrypted_deck = hydra::bn254::enc::encrypt(decrypted_deck, key, iv);

    // Assert that the encrypted deck is the same as the original deck (hasn't been tampered)
    assert(encrypted_deck == deck);

    // Find the index of the card in the encrypted deck
    let card_index = find_card(deck, cards[0]);

    // Return the decrypted card
    [decrypted_deck[card_index]]
}
