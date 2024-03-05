

#define N_SIZE 10

#include <stdio.h>

# int main(void) {
#     int i;
#     int numbers[N_SIZE] = {0};

#     i = 0;

# loop:
# 	if (i >= N_SIZE) goto else:
# loop_main:
#     scanf("%d", &numbers[i]);
#     i++;
#     goto loop;

# else:


# }
N_SIZE = 10
    .text
main:

    li  $t0, 0
    # $t0 = i

loop:
    bge $t0, N_SIZE, else

loop_main:
    li	$v0, 5
    syscall
    #input is in $v0

    #calculating address of numbers[i]
    la	$t1, numbers
    mul $t2, $t0, 4
    add $t1, $t2, $t1
    #address of numbers[i] = numbers + i*4


    sw	$v0, ($t1)
    addi $t0, $t0, 1
    j   loop

else:

end:
    jr  $ra

    .data
numbers: 
    .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
