fn main(key: Field, hand: pub [Field; 2]) -> pub [Field; 2] {
    let decoded_hand: [Field; 2] = gmimc::bn254::dec::x5_2(hand, key);
    let encoded_hand: [Field; 2] = gmimc::bn254::enc::x5_2(decoded_hand, key);
    assert(hand == encoded_hand);

    //println(decoded_hand);
    decoded_hand
}

