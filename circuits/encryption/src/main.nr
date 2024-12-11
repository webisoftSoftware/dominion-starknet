fn main(key: [Field; 4], iv: [Field; 4], deck: [Field; 52]) -> pub [Field; 52] {
    // Encrypt the deck of 52 cards
    let encrypted_deck = hydra::bn254::enc::encrypt(deck, key, iv);

    // Decrypt the deck of 52 cards for assertion
    let decrypted_deck = hydra::bn254::dec::decrypt(encrypted_deck, key, iv);

    // Assert that the decrypted deck is the same as the original deck (hasn't been tampered)
    assert(decrypted_deck == deck);

    // Return the encrypted deck
    encrypted_deck
}
