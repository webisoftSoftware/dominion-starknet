// Helper function to find the index of the hand in the encrypted deck
fn find_hand(deck: [Field; 17], hand: [Field; 2]) -> [u8; 2] {
    let mut result: [u8; 2] = [0; 2];
    for i in 0..17 {
        if deck[i] == hand[0] {
            result[0] = i;
        }
        if deck[i] == hand[1] {
            result[1] = i;
        }
    }
    result
}

fn main(key: [Field; 4] , iv: [Field; 4], deck: [Field; 17], hand: [Field; 2]) -> pub [Field; 2] {

    // Find the index of the hand in the encrypted deck
    let hand_index = find_hand(deck, hand);

    // Decrypt the whole 17 card deck
    let decrypted_deck = hydra::bn254::dec::decrypt(deck, key, iv);

    // Encrypt the decrypted deck for assertion
    let encrypted_deck = hydra::bn254::enc::encrypt(decrypted_deck, key, iv);

    // Assert that the encrypted deck is the same as the original deck (hasn't been tampered)
    assert(encrypted_deck == deck);

    // Find the decrypted hand in the decrypted deck 
    let decrypted_hand = [decrypted_deck[hand_index[0]], decrypted_deck[hand_index[1]]];

    // Return the decrypted hand
    decrypted_hand
}