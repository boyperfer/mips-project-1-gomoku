.data
winingMessage: .asciiz "\nWinning"
.text
.globl check_row 

# $a0 = row index, $a1 = column index, $a2 = 'X',
# $a3 == 0 ? "check horizontal" : $a3 == 1 ? "check vertical" : "check diagonal"
check_row:
	li $t0, 0									# initialize counter when checking the larger partition
	li $t4, 5									# initialize condition to win
	move $t8, $a0								# $t8 = row index
	move $t7, $a1								# $t7 = column index
	j initialize_lower_bound
	initialize_winning_counter:
		li $t3, 0								# winning counter
		move $t2, $a2							# load X
		mul $t5, $t8, $s2						# $t5 (partition) <-- row index* column size 
		add $t5, $t5, $t7               		# $t5 <-- row index * column size + column index
		add $t5, $s0, $t5						# $t5 <-- base address + (row index * column size + column counter)
		move $t9, $t5							# $t9 <-- initialize pointer to move

		loop_on_the_smaller_partition:
		blt $t9, $t6, set_up_larger_partition	# if pointer is less than lower bound jump to set_up_larger_partition
		lb $t1, ($t9)							# load symbol at address t5 
		bne $t1, $t2, set_up_larger_partition	# if t1 is not "X" jump to set_up_larger_partition 
		addi $t3, $t3, 1						# winning counter += 1
		addi $t9, $t9, -1						# backtracking 1 step
		beq $t3, $t4, necessary_condition		# if winning counter == 5 go to necessary_condition
		j loop_on_the_smaller_partition

		necessary_condition:	
		lb $t1, ($t9)							# load symbol at address t1
		bne $t1, $t2, sufficient_condition		# if t1 is not "X" jump to sufficient_condition
		j done_checking_row						# if it is (overline) -> done_checking_row	

		set_up_larger_partition:
		move $t9, $t5							# initialize pointer to move
		addi $t9, $t9, 1						# pointer begins at larger partition
		j initialize_upper_bound

		loop_on_the_larger_partition:
		beq $t9, $t6, done_checking_row			# if pointer move to next row -> done_checking_row
		lb $t1, ($t9)							# load symbol at address t1
		bne $t1, $t2, done_checking_row			# if it is not X -> done_checking_row
		addi $t3, $t3, 1						# winning counter += 1
		addi $t9, $t9, 1						# move pointer to next poistion
		addi $t0, $t0, 1						# steps moved on the larger partition += 1
		beq $t3, $t4, sufficient_condition		# if winning counter == 5 go to sufficient_condition

		j loop_on_the_larger_partition			# jump to loop_on_the_left 

initialize_lower_bound:
	beq $a3, 0, lower_bound_for_horizontal
	beq $a3, 1, lower_bound_for_vertical
	beq $a3, 2, lower_bound_for_diagonal

initialize_upper_bound:
	beq $a3, 0, upper_bound_for_horizontal
	beq $a3, 1, upper_bound_for_vertical
	beq $a3, 2, upper_bound_for_diagonal
	

lower_bound_for_horizontal:
	mul $t6, $t8, $s2						# $t5 (partition) <-- row index* column size 
	j initialize_winning_counter

lower_bound_for_vertical:
	move $t6, $t7							# lower bound is column index 
	j initialize_winning_counter	

lower_bound_for_diagonal:
	li $t6, 0
	j initialize_winning_counter

upper_bound_for_horizontal:
	add $t6, $t6, $s2						# upper bound is lower bound adding column size
	j loop_on_the_larger_partition 

upper_bound_for_vertical:
	j loop_on_the_larger_partition 

upper_bound_for_diagonal:
	j loop_on_the_larger_partition		


sufficient_condition:
	beq $t0, $zero, winning					# if pointer has not moved to the larger partition -> winning
	move $t9, $t5								# $t9 <-- initialize pointer to move
	add $t9, $t9, $t0							# is pointer moving on the larger partition ? add steps it moved : add zero
	addi $t9, $t9, 1							# pointer go to next poistion
	lb $t1, ($t9)								# load symbol
	bne $t1, $t2, winning						# if not "X" jump to winning


done_checking_row:
	jr $ra

	
winning:
	jal clear_screen							# clear screen
	jal print_table								# print winning table
	
	li $v0, 4									# code for print string
	la $a0, winingMessage						# load message winning
	syscall										# print

	li $v0, 10									# code for exit
	syscall										# exit
