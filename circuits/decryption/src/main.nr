fn main(key: Field, card: [Field; 2]) -> pub Field {
    let decoded_card = gmimc::bn254::dec::x5_2(card, key);
    println(decoded_card[0]);
    println(decoded_card[1]);
    decoded_card[0]
}

