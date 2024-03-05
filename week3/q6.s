#define N_SIZE 10

#include <stdio.h>

# int main(void) {
#     int i;
#     int numbers[N_SIZE] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

#     i = 0;
#     while (i < N_SIZE) {
#         printf("%d\n", numbers[i]);
#         i++;
#     }
# }


N_SIZE = 10
	.text
main:
	li	$t0, 0
loop:
	bge 	$t0, N_SIZE, loop_end
loop_contents:
	li	$v0, 1
	la	$t2, numbers
	mul	$t3, $t0, 4

	lw	$a0, numbers($t3)
	syscall

	li	$v0, 11
	li	$a0, '\n'
	syscall

	addi 	$t0, $t0, 1
	j 	loop

loop_end:	
end:
	jr	$ra


	.data
numbers: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

