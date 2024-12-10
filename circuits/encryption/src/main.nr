fn main(key: Field, deck: pub [Field; 16]) -> pub [Field; 16] {
    let mut encoded_deck: [Field; 16] = gmimc::bn254::enc::x5_16(deck, key);
       
    encoded_deck
}


