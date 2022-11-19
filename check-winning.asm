.data
winingMessage: .asciiz "\nWinning"
.text
.globl check_winning 

# $a0 = row index, $a1 = column index, $a2 = 'X',
# $a3 == 0 ? "check horizontal" : $a3 == 1 ? "check vertical" : "check diagonal"
check_winning:
	li $t0, 0						# initialize counter when checking the larger partition
	li $s7, 5						# initialize condition to win
	move $t8, $a0						# $t8 = row index
	move $t7, $a1						# $t7 = column index
	j initialize_smaller_partition

	loop_on_the_smaller_partition:
	blt $t9, $t6, initialize_larger_partition		# if pointer is less than lower bound jump to initialize_larger_partition
	lb $t1, ($t9)						# load symbol at address t5 
	bne $t1, $t2, initialize_larger_partition		# if t1 is not "X" jump to initialize_larger_partition 
	addi $t3, $t3, 1					# winning counter += 1
	beq $t3, $s7, necessary_condition			# if winning counter == 5 go to necessary_condition
	add $t9, $t9, $t4					# backtracking 1 move 
	j loop_on_the_smaller_partition

	necessary_condition:	
	beq $t9, $t6, initialize_larger_partition 		# if pointer moves out of lower_bound
	add $t9, $t9, $t4					# backtracking 1 move 
	lb $t1, ($t9)						# load symbol at address t1
	bne $t1, $t2, initialize_larger_partition 		# if t1 is not "X" jump to sufficient_condition
	j done_checking_row					# if it is (overline) -> done_checking_row	

	set_up_larger_partition:
	move $t9, $t5						# initialize pointer to move
	add $t9, $t9, $t4					# pointer begins at larger partition

	loop_on_the_larger_partition:
	beq $t9, $t6, done_checking_row				# if pointer move to upper bound -> done_checking_row
	lb $t1, ($t9)						# load symbol at address t1
	bne $t1, $t2, done_checking_row				# if it is not X -> done_checking_row
	addi $t3, $t3, 1					# winning counter += 1
	add $t0, $t0, $t4					# moves moved on the larger partition += the number of steps for each move for pointer
	beq $t3, $s7, sufficient_condition			# if winning counter == 5 go to sufficient_condition
	add $t9, $t9, $t4					# move pointer to next poistion

	j loop_on_the_larger_partition				# jump to loop_on_the_left 

initialize_smaller_partition:
	li $t3, 0						# winning counter
	move $t2, $a2						# load X
	mul $t5, $t8, $s2					# $t5 (partition) <-- row index* column size 
	add $t5, $t5, $t7               			# $t5 <-- row index * column size + column index
	add $t5, $s0, $t5					# $t5 <-- base address + (row index * column size + column index)
	move $t9, $t5						# $t9 <-- initialize pointer to move

	beq $a3, 0, lower_bound_for_horizontal
	beq $a3, 1, lower_bound_for_vertical
	#beq $a3, 2, lower_bound_for_R_diagonal
	beq $a3, 2, lower_bound_for_L_diagonal

initialize_larger_partition:
	beq $a3, 0, upper_bound_for_horizontal
	beq $a3, 1, upper_bound_for_vertical
	#beq $a3, 2, upper_bound_for_R_diagonal
	beq $a3, 2, upper_bound_for_L_diagonal
	
lower_bound_for_horizontal:
	mul $t6, $t8, $s2					# lower_bound <-- row index* column size 
	add $t6, $t6, $s0					# lower_bound += baseAddress
	li $t4, -1						# the number of steps for each move for pointer = -1
	j loop_on_the_smaller_partition 

lower_bound_for_vertical:
	move $t6, $t7						# lower bound is column index 
	add $t6, $t6, $s0					# lower_bound += baseAddress
	sub $t4, $zero, $s2					# the number of steps for each move for pointer =- column size 
	j loop_on_the_smaller_partition 

lower_bound_for_L_diagonal:
	beq $t7, $0, self_lower					# if the column index = 0 then the lower bound is the cell itself
	
	move $t6, $t9						# get the current cell
	move $s3, $t8						# get the row index
	addi $s4, $s2, 1					# $s4 <-- column size + 1
	mul $t4, $s4, $s3					# $t4 <-- (column size + 1) * row index
	sub $t6, $t6, $t4					# $t6 <-- current cell - [(column size + 1 ) * row index]
	add $t6, $t6, $s0					# lower_bound += baseAddress
	mul $t4, $s4, -1					# the number of steps for each move for pointer = -(column size + 1)
	
	blt $t6, $0, adjust_lower				# if $t6 is negative, adjust the lower bound
	j loop_on_the_smaller_partition		
			
	self_lower:
		li $t4, 0					# the number of steps for each move for pointer = 0
		move $t6, $t9					# get the current cell
		j loop_on_the_smaller_partition
		
	adjust_lower:
		add $t6, $t6, $s4				# $t4 <-- current cell - [(column size + 1) * (row index - 1)] 
		j loop_on_the_smaller_partition

upper_bound_for_horizontal:
	li $t4, 1
	beq $t3, $s7, sufficient_condition			# if winning counter == 5 go to sufficient_condition
	add $t6, $t6, $s2					# upper bound is lower bound adding column size

	j set_up_larger_partition 

upper_bound_for_vertical:
	move $t4, $s2						# the number of steps for each move for pointer =  column size
	beq $t3, $s7, sufficient_condition			# if winning counter == 5 go to sufficient_condition

	move $t6, $s1						# $t6 <-- row size
	mul $t6, $t6, $s2					# $t6 <-- row size * col size
	add $t6, $t6, $t7					# $t6 <-- row size * col size + col index
	add $t6, $t6, $s0					# $t6 <-- (row size * col size + col index) + baseAddress

	j set_up_larger_partition 

upper_bound_for_L_diagonal:
	beq $t3, $s7, sufficient_condition			# if winning counter == 5 go to sufficient_condition
	mul $s4, $s1, $s2					# $s4 <-- row size * column size
	sub $s4, $s4, 1						# $s4(last cell) <-- (row size * column size) - 1
	sub $s3, $s4, 1						# $s3 <-- column size - 1
	beq $t7, $s3, self_upper				# if the column index = column size - 1 then the upper bound is the cell itself
	
	move $t6, $t9						# get the current cell
	addi $s5, $s2, 1					# $s5 <-- column size + 1
	addi $t4, $t8, 1					# $t4 <-- row index + 1
	sub $t4, $s1, $t4					# $t4 <-- row size - row index + 1
	mul $t4, $t4, $s5					# $t4 <-- (row size - row index + 1) * (column size + 1)
	add  $t6, $t6, $t4					# $t6 <-- current cell + [(row size - row index + 1) * (column size + 1)]
	add $t6, $t6, $s0					# upper_bound += baseAddress
	move $t4, $s5						# the number of steps for each move for pointer = column size + 1
	
	bgt $t6, $s4, adjust_upper				# if $t6 is greater than the last index, adjust the upper bound (last row)
	j set_up_larger_partition		
			
	self_upper:
		li $t4, 0					# the number of steps for each move for pointer = 0
		move $t6, $t9					# get the current cell
		j set_up_larger_partition
		
	adjust_upper:
		sub $t6, $t6, $s4				# $t6 <-- current cell + [(row size - row index) * (column size + 1)]
		j set_up_larger_partition

sufficient_condition:
	move $t9, $t5						# $t9 <-- initialize pointer to move
	add $t9, $t9, $t0					# is pointer moving on the larger partition ? add steps it moved : add zero
	add $t9, $t9, $t4					# pointer go to next poistion
	lb $t1, ($t9)						# load symbol

	move $a0, $t1
	li $v0, 11 
	syscall

	bne $t1, $t2, winning					# if not "X" jump to winning


done_checking_row:
	jr $ra							# return to main
	
winning:
	jal clear_screen					# clear screen
	jal print_table						# print winning table
	
	li $v0, 4						# code for print string
	la $a0, winingMessage					# load message winning
	syscall							# print

	li $v0, 10						# code for exit
	syscall							# exit
