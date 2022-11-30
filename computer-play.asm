.data
	rowIComp: .word 0
	colIComp: .word 0
.text

.globl computer_play 

computer_play:
	move $t9, $a0					# the cell recommended for computer to move
	move $t4, $a1					# the number of steps for probing
	mul $t4, $t4, -1				# $t4 = -$t4 

	move $t5, $s1					# $t5 upper bound <-- row size
	mul $t5, $t5, $s2				# $t5 <-- row size * column size
	add $t5, $t5, $s0				# address of upper bound

	move $t6, $t9					# pointer for probing 
	bge $t6, $t5, probing

	li $t7, '.'					# load '.'
	lb $t8, ($t6)					# load $t9 operand
	bne $t8, $t7, probing				# if value of the pointer is not ".", jump to probing 
	li $t7, 'O'					# load 'O'                                       	
	sb $t7, 0($t6)					# store 'O' into the array

	sub $t6, $t6, $s0				# get offset 
	div $t6, $s2					# $t7 divide column size
	mfhi $t2					# extract column index	
	sw $t2, colIComp				# store column index

	sub $t6, $t6, $t2				# $t7 <-- $t7 - $t2
	div $t6, $s2					# $t7 divide column size
	mflo $t2					# extract row index
	sw $t2, rowIComp				# store row index

	j check_winning_comp				# jump check_winning_comp


probing:
	blt $t6, $s0, random_play			# if pointer moves out of lower bound
	li $t7, '.'					# load '.'
	add $t6, $t6, $t4				# probing bac
	lb $t8, ($t6)					# load operand
	bne $t8, $t7, probing				# if value of the pointer is not ".", jump to probing 

	li $t7, 'O'					# load 'O'
   	sb $t7, 0($t6)					# store 'O' into the array
	
	sub $t6, $t6, $s0				# get offset 
	div $t6, $s2					# $t7 divide column size
	mfhi $t2					# extract column index	
	sw $t2, colIComp				# store column index

	sub $t6, $t6, $t2				# $t7 <-- $t7 - $t2
	div $t6, $s2					# $t7 divide column size
	mflo $t2					# extract row index
	sw $t2, rowIComp				# store row index

	j check_winning_comp				# jump check_winning_comp

random_play:
	li $v0, 42					# code to generate random int
	move $a1, $s1					# $a1 is where to set the upper bound
	syscall						# generated number will be at $a0
	move $t1, $a0					# $t1 <-- row index
	sw $t1, rowIComp

	li $v0, 42					# code to generate random int
	move $a1, $s2					# $a1 is where to set the upper bound
	syscall						# generated number will be at $a0
	move $t2, $a0					# $t2 <-- column index
	sw $t2, colIComp

	mul $t3, $t1, $s2				# $t5 (array pointer) <-- row index* column size 
	add $t3, $t3, $t2               		# $t5 <-- row index * column size + column index
	add $t3, $s0, $t3				# $t5 <-- base address + (row index * column size + column index)

	li $t7, '.'					# load '.'
	lb $t8, ($t3)					# load $t3 operand
	bne $t8, $t7, linear_probing			# if value of the pointer not ".", jump to linear_probing 

	li $t7, 'O'					# load 'O'                                       	
	sb $t7, 0($t3)					# store 'O' into array
	j check_winning_comp				# jump check_winning_comp

linear_probing:
	bge $t3, $t5, zero_pointer			# if pointer moving out of bound -> zero it 
	addi $t3, $t3, 1				# pointer += 1

	lb $t8, ($t3)					# load $t3 operand
	bne $t8, $t7, linear_probing			# if value of the pointer not ".", jump to linear_probing 
	
	li $t7, 'O'					# load 'O'                                       	
	sb $t7, 0($t3)					# store 'O' into array
	j check_winning_comp				# jump check_winning_comp

zero_pointer:
	li $t3, -1					# t3 = -1
	add $t3, $t3, $s0				# address of t3
	j linear_probing				# jump to linear_probing
	
check_winning_comp:
		addi $sp, $sp, -4			# make room for stack fram
		sw $ra, 0($sp)				# store return address of calling function

		lw $a0, rowIComp			# load rowIComp
		lw $a1, colIComp			# load colIComp
		li $a2, 'O'				# load 'O' 
		li $a3, 0				# check row
		jal check_winning			# jump check_winning

		lw $a0, rowIComp			# load rowIComp
		lw $a1, colIComp            		# load colIComp
		li $a2, 'O'                 		# load 'O' 
		li $a3, 1                   		# check col
		jal check_winning           		# jump check_winning

		lw $a0, rowIComp			# load rowIComp
		lw $a1, colIComp            		# load colIComp
		li $a2, 'O'                 		# load 'O' 
		li $a3, 2                 		# check left diagonal
		jal check_winning           		# jump check_winning
		
		lw $a0, rowIComp			# load rowIComp
		lw $a1, colIComp           		# load colIComp
		li $a2, 'O'                		# load 'O' 
		li $a3, 3                  		# check right diagonal
		jal check_winning			# jump check_winning

		lw $ra, 0($sp)				# load register address
		addi $sp, $sp, 4			# restore stack pointer
		lw  $v0, rowIComp			# load row index of computer
		addi $v0, $v0, 1			# return for displaying row move of computer
		lw $v1, colIComp			# load column index of computer
		addi $v1, $v1, 65			# convert to uppercase letter for displaying col move of computer
		jr $ra					# jump to calling function

