# int main() {
# 	array = [1, 2, 3, 4]
# 	length = 10
# 	max_num = max(array, length)
# 	printf("%d\n", max)
# }
ARRAY_LENGTH = 10
	.text
main:	
main__prologue:
	push	$ra
main__body:
	la	$a0, array
	li	$a1, ARRAY_LENGTH
	jal	max

	#result = $v0
	move	$a0, $v0
	li	$v0, 1
	syscall		#prints %d

	li	$a0, '\n'
	li	$v0, 11
	syscall

main__epilogue:
	pop	$ra
	jr	$ra




max:
max__prologue:
	begin
	push	$ra
	push	$s0
	push	$s1
max__body:
	move	$s0, $a0
	move	$s1, $a1
	# s0 = array, $s1 = length
	lw	$t0, 0($s0)	#t0 = first_element
max__first_if:
	bne	$s1, 1, max__else
	move	$v0, $t0
	j	max__epilogue
max__else:
	addi	$a0, $s0, 4
	addi	$a1, $s1, -1
	jal	max

	move	$t0, $v0	#t0 = max_so_far

max__second_if:
	lw	$t1, 0($s0)	#t1 = first_element
	ble	$t1, $t0, max__return_value
max__second_if_body:
	move	$t0, $t1
max__return_value:
	move	$v0, $t0
max__epilogue:
	pop	$s1
	pop	$s0
	pop	$ra
	end
	jr	$ra




	.data
array:
	.word 1, 2, 3, 4, 5, 6, 4, 3, 2, 1