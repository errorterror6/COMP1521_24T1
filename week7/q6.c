#include <stdio.h>
#include <stdint.h>

int main() {

    uint32_t number = 0b10011001100110011001100110011001;
// expected ans: 001100 or 12

    uint64_t mask = 0b111111;
    mask = mask << 13;
    uint32_t result = number & mask;
    // 10011001100110011001100110011001
    // 00000000000001111110000000000000   mask
    // 00000000000000011000000000000000   mask result
    // 00000000000000000000000000001100
    result = result >> 13;

    printf("%d\n", result);

    return 0;
}


uint32_t six_middle_bits(uint32_t u) {
    return (u >> 13) & 0x3F;
    // 0x3f = 0011 1111
}
