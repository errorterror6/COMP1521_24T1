	.text
FLAG_ROWS = 6
FLAG_COLS = 12

main:
	li	$t0, 0		#$t0 = row

main__rows_loop:
	bge	$t0, FLAG_ROWS, main__rows_end
	li	$t1, 0		#t1 = col
main__col_loop:
	bge 	$t1, FLAG_COLS, main__col_end

main__col_body:
	#get flag[row][col]
	# Total_offset = rows * num_cols + cols
	la	$t2, flag
	mul	$t3, $t0, FLAG_COLS	#row * NUM_COL
	add	$t3, $t3, $t1		#row * NUM_COL + cols
	mul 	$t3, $t3, 1

	add	$t2, $t2, $t3		#$t2 = flag[row][col]
	lb	$a0, ($t2)
	#print it out

	li	$v0, 11
	syscall

	addi	$t1, $t1, 1
	j 	main__col_loop

main__col_end:
	li	$v0, 11
	li	$a0, '\n'
	syscall

	addi	$t0, $t0, 1
	j	main__rows_loop
main__rows_end:
	jr	$ra

	.data
flag:
	.byte '#', '#', '#', '#', '#', '.', '.', '#', '#', '#', '#', '#'
	.byte '#', '#', '#', '#', '#', '.', '.', '#', '#', '#', '#', '#'
	.byte '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
	.byte '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.'
	.byte '#', '#', '#', '#', '#', '.', '.', '#', '#', '#', '#', '#'
	.byte '#', '#', '#', '#', '#', '.', '.', '#', '#', '#', '#', '#'
