.data
winingMessage: .asciiz "\nWinning"
.text
.globl check_row 

# $a0 = row index, $a1 = 'X'
check_row:
	li $t0, 0									# initialize column counter for checking entire row
	li $t4, 5									# initialize condition to win
	move $t8, $a0								# $t8 = row index
	initialize_winning_counter:
		li $t3, 0 
		move $t2, $a1

		loop_on_the_row:
		mul $t5, $t8, $s2						# $t5 (array pointer) <-- row index* column size 
		bgt $t0, $s2, done_checking_row 		# if column counter > column size
		add $t5, $t5, $t0               		# $t5 <-- row index * column size + column counter
		add $t5, $s0, $t5						# $t5 <-- base address + (row index * column size + column counter)

		lb $t1, ($t5)							# load symbol at address t5

		beq $t1, $t2, winning_counter			# if t1 is "X" jump to winning_counter
		addi $t0, $t0, 1						# column counter += 1
		j initialize_winning_counter			# jump to initialize_winning_counter

winning_counter:
	addi $t3, $t3, 1							# winning counter incresed by 1 for every "X" on the row
	addi $t0, $t0, 1							# column counter += 1
	beq $t3, $t4, necessary_condition			# if winning counter == 5 -> necessary_condition 
	j loop_on_the_row							# jump back to loop_on_the_row

done_checking_row:
	jr $ra

necessary_condition:
	bgt $t0, $s2, winning						# if column counter > column size -> jump to winning
	addi $t5, $t5, 1							# $t5 <-- next address of memory

	lb $t1, ($t5)								# load next column
	li $t2, '.'									# $t2 <-- "."
	beq $t1, $t2, sufficient_condition			# if next column is ".", jump to sufficient_condition 
	j initialize_winning_counter				# otherwise jump to initialize_winning_counter 
	
	
sufficient_condition:
	addi $t7, $t0, -6							# column counter backtracking 6 steps
	blt $t7, $zero, winning						# if necessary_condition started at colum index = 0 -> jump to winning
	addi $t5, $t5, -6							# backtracking 6 column
	lb $t1, ($t5)								# load next column
	li $t2, 'X'									# $t2 <-- "X"
	beq $t1, $t2, initialize_winning_counter	# if overline -> jump back to initialize_winning_counter
	
winning:
	jal clear_screen							# clear screen
	jal print_table								# print winning table
	
	li $v0, 4									# code for print string
	la $a0, winingMessage						# load message winning
	syscall										# print

	li $v0, 10									# code for exit
	syscall										# exit
