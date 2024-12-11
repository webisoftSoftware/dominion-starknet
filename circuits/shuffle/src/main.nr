fn main(deck: pub [Field; 52], key: Field) -> pub [Field; 52] {
    // This function implements a cryptographic shuffle using Pedersen hashes
    // For each card (a) and (b) being compared:
    // 1. Calculate Pedersen hash of the card value combined with the secret key
    // 2. Use these hashes to determine the ordering of cards
    // 3. The sort_via function will use these comparisons to shuffle the deck
    let result: [Field; 52] = deck.sort_via(|a, b| {
        std::hash::pedersen_hash([a, key]).lt(std::hash::pedersen_hash([b, key]))
    });
    result
}
