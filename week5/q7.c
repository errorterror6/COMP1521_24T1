#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void reverseBits(uint32_t w);

int main() {
    uint32_t input_num = 0x01234567;
    reverseBits(input_num);
    return 0;
}

void reverseBits(uint32_t w) {
    uint32_t copy = 0;
    uint64_t mask_copy = (uint64_t) 1;
    uint64_t mask = ((uint64_t) 1 )<< 31;
    for (int i = 0; i < 32; i++) {
        // int reverse = 31-i;

        uint64_t w_out = w & mask;
        // 0001
        // 1000 mask
        // 0000 after and operator


        if (w_out != 0) {
            copy = copy | mask_copy;
            // 0000 copy
            // 0001 mask_copy
            // 0001
        }

        mask =  mask >> 1;
        mask_copy =  mask_copy << 1;


    }

    printf("%x\n", copy);

}