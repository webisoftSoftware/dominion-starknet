fn main(key: Field, hand: pub [Field; 2]) -> pub [Field; 2] {
    let decoded_hand: [Field; 2] = gmimc::bn254::dec::x5_2(hand, key);
    decoded_hand
}

