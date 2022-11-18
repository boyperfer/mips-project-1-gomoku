.data
winingMessage: .asciiz "\nWinning"
.text
.globl check_winning 

# $a0 = row index, $a1 = column index, $a2 = 'X',
# $a3 == 0 ? "check horizontal" : $a3 == 1 ? "check vertical" : "check diagonal"
check_winning:
	li $t0, 0									# initialize counter when checking the larger partition
	li $s7, 5									# initialize condition to win
	move $t8, $a0								# $t8 = row index
	move $t7, $a1								# $t7 = column index
	j initialize_smaller_partition

	loop_on_the_smaller_partition:
	blt $t9, $t6, initialize_larger_partition	# if pointer is less than lower bound jump to initialize_larger_partition
	lb $t1, ($t9)								# load symbol at address t5 
	bne $t1, $t2, initialize_larger_partition	# if t1 is not "X" jump to initialize_larger_partition 
	addi $t3, $t3, 1							# winning counter += 1
	beq $t3, $s7, necessary_condition			# if winning counter == 5 go to necessary_condition
	add $t9, $t9, $t4							# backtracking 1 move 
	j loop_on_the_smaller_partition

	necessary_condition:	
	beq $t9, $t6, initialize_larger_partition # if pointer moves out of lower_bound
	add $t9, $t9, $t4						# backtracking 1 move 
	lb $t1, ($t9)							# load symbol at address t1
	bne $t1, $t2, initialize_larger_partition # if t1 is not "X" jump to sufficient_condition
	j done_checking_row						# if it is (overline) -> done_checking_row	

	set_up_larger_partition:
	move $t9, $t5							# initialize pointer to move
	add $t9, $t9, $t4						# pointer begins at larger partition

	loop_on_the_larger_partition:
	beq $t9, $t6, done_checking_row			# if pointer move to upper bound -> done_checking_row
	lb $t1, ($t9)							# load symbol at address t1
	bne $t1, $t2, done_checking_row			# if it is not X -> done_checking_row
	addi $t3, $t3, 1						# winning counter += 1
	add $t0, $t0, $t4						# moves moved on the larger partition += the number of steps for each move for pointer
	beq $t3, $s7, sufficient_condition		# if winning counter == 5 go to sufficient_condition
	add $t9, $t9, $t4						# move pointer to next poistion

	j loop_on_the_larger_partition			# jump to loop_on_the_left 

initialize_smaller_partition:
	li $t3, 0								# winning counter
	move $t2, $a2							# load X
	mul $t5, $t8, $s2						# $t5 (partition) <-- row index* column size 
	add $t5, $t5, $t7               		# $t5 <-- row index * column size + column index
	add $t5, $s0, $t5						# $t5 <-- base address + (row index * column size + column counter)
	move $t9, $t5							# $t9 <-- initialize pointer to move

	beq $a3, 0, lower_bound_for_horizontal
	beq $a3, 1, lower_bound_for_vertical
	beq $a3, 2, lower_bound_for_diagonal

initialize_larger_partition:
	beq $a3, 0, upper_bound_for_horizontal
	beq $a3, 1, upper_bound_for_vertical
	beq $a3, 2, upper_bound_for_diagonal
	

lower_bound_for_horizontal:
	mul $t6, $t8, $s2						# lower_bound <-- row index* column size 
	add $t6, $t6, $s0						# lower_bound += baseAddress
	li $t4, -1								# the number of steps for each move for pointer = -1
	j loop_on_the_smaller_partition 

lower_bound_for_vertical:
	move $t6, $t7							# lower bound is column index 
	add $t6, $t6, $s0						# lower_bound += baseAddress
	sub $t4, $zero, $s2						# the number of steps for each move for pointer =- column size 
	j loop_on_the_smaller_partition 

lower_bound_for_diagonal:
	li $t6, 0
	j loop_on_the_smaller_partition 

upper_bound_for_horizontal:
	li $t4, 1
	beq $t3, $s7, sufficient_condition		# if winning counter == 5 go to sufficient_condition
	add $t6, $t6, $s2						# upper bound is lower bound adding column size

	j set_up_larger_partition 

upper_bound_for_vertical:
	move $t4, $s2							# the number of steps for each move for pointer =  column size
	beq $t3, $s7, sufficient_condition		# if winning counter == 5 go to sufficient_condition

	move $t6, $s1							# $t6 <-- row size
	mul $t6, $t6, $s2						# $t6 <-- row size * col size
	add $t6, $t6, $t7						# $t6 <-- row size * col size + col index
	add $t6, $t6, $s0						# $t6 <-- (row size * col size + col index) + baseAddress

	j set_up_larger_partition 

upper_bound_for_diagonal:
	j set_up_larger_partition 


sufficient_condition:
	move $t9, $t5								# $t9 <-- initialize pointer to move
	add $t9, $t9, $t0							# is pointer moving on the larger partition ? add steps it moved : add zero
	add $t9, $t9, $t4							# pointer go to next poistion
	lb $t1, ($t9)								# load symbol

	move $a0, $t1
	li $v0, 11 
	syscall

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
