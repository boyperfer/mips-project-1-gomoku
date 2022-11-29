.data
winingMessage: .asciiz "\nWinning"
check:	.asciiz	"Here"
winingMessage: .asciiz " Win"
player: .asciiz "\nPlayer"
computer: .asciiz "\nComputer"
symbol: .word 0
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
	lb $t1, ($t9)						# load symbol at register $t9
	bne $t1, $t2, initialize_larger_partition		# if t1 is not "X" jump to initialize_larger_partition 
	addi $t3, $t3, 1					# winning counter += 1
	beq $t3, $s7, necessary_condition			# if winning counter == 5 go to necessary_condition
	add $t9, $t9, $t4					# backtracking 1 move 
	j loop_on_the_smaller_partition

	necessary_condition:		
	beq $t9, $t6, initialize_larger_partition 		# if pointer moves out of lower_bound
	add $t9, $t9, $t4					# backtracking 1 move 
	lb $t1, ($t9)						# load symbol at address t1
	bne $t1, $t2, initialize_larger_partition 		# if t1 is not "X" jump to initialize_larger_partition 
	j done_checking						# if it is (overline) -> done_checking_row	

	set_up_larger_partition:
	move $t9, $t5						# initialize pointer to move
	add $t9, $t9, $t4					# pointer begins at larger partition
	sw $a2, symbol						# store the symbol for print message

	loop_on_the_larger_partition:
	bge $t9, $t6, done_checking				# if pointer move to or over upper bound (>= upper bound) -> done_checking_row
	lb $t1, ($t9)						# load symbol at address t1
	bne $t1, $t2, done_checking				# if it is not X -> done_checking_row	
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
	sw $a2, symbol						# store the symbol for print message


	beq $a3, 0, lower_bound_for_horizontal
	beq $a3, 1, lower_bound_for_vertical
	beq $a3, 2, lower_bound_for_L_diagonal
	beq $a3, 3, lower_bound_for_R_diagonal

initialize_larger_partition:
	beq $a3, 0, upper_bound_for_horizontal
	beq $a3, 1, upper_bound_for_vertical
	beq $a3, 2, upper_bound_for_L_diagonal
	beq $a3, 3, upper_bound_for_R_diagonal
	
lower_bound_for_horizontal:
	beq $t7, $0, lower_H					# if the col index = 0 then the current cell is the lower bound of the row
	mul $t6, $t8, $s2					# lower_bound <-- row index* column size 
	add $t6, $t6, $s0					# lower_bound += baseAddress
	li $t4, -1						# the number of steps for each move for pointer = -1
	j loop_on_the_smaller_partition	
	
	lower_H: 
		lb $t1, ($t9)					# load symbol at register $t9
		bne $t1, $t2, initialize_larger_partition	# if the symbol is not "X or O" branch to initialize_larger_partition
		addi $t3, $t3, 1				# if the symbol is "X or O" increase winning counter by 1
		j initialize_larger_partition			# jump to initialize_larger_partition

lower_bound_for_vertical:
	beq $t8, $0, lower_V					# if the row index = 0 then the current cell is the lower bound of the column
	move $t6, $t7						# lower bound is column index 
	add $t6, $t6, $s0					# lower_bound += baseAddress
	sub $t4, $zero, $s2					# the number of steps for each move for pointer =- column size 
	j loop_on_the_smaller_partition 
	
	lower_V:
		lb $t1, ($t9)							# load symbol at register $t9
		bne $t1, $t2, initialize_larger_partition		# if the symbol is not "X or O" branch to initialize_larger_partition
		addi $t3, $t3, 1						# if the symbol is "X or O" increase winning counter by 1
		j initialize_larger_partition				# jump to initialize_larger_partition

lower_bound_for_L_diagonal:
	beq $t8, $0, lower_L					# if the row index = 0 then the lower bound is the cell itself
	beq $t7, $0, lower_L					# if the column index = 0 then the lower bound is the cell itself
	sub $t6, $t8, $t7					# row index - col index	
	mul $t6, $t6, $s2					# (row index - col index) * col size
	add $t6, $t6, $s0					# address of lower bound
	addi $t4, $s2, 1					# $t4 = column size + 1
	mul $t4, $t4, -1					# the number of steps for each move for pointer = -(column size + 1)
	j loop_on_the_smaller_partition		
			
	lower_L:
		lb $t1, ($t9)						# load symbol at address t9
		bne $t1, $t2, initialize_larger_partition		# if the symbol is not "X or O" branch to initialize_larger_partition
		addi	$t3, $t3, 1					# if the symbol is "X or O" increase winning counter by 1
		j initialize_larger_partition				# jump to inialize_larger_partition

lower_bound_for_R_diagonal:
	beq $t8, $0, lower_R					# if the row index = 0 then the lower bound is the cell itself
	addi $t6, $s2, -1					# column size - 1
	move $s3, $t6
	beq $t7, $t6, lower_R					# if column index = column size -1 (last column) then the lower bound is the cell itself
	sub $t6, $t6, $t7					# $t6 <-- column size - 1 - column index 
	mul $t6, $t6, $s3					# row size * (column size - 1 - column index)
	sub $t6, $t5, $t6					# address of lower bound
	blt $t6, $0, adjust_lower				# if $t6 is negative	
	addi $t4, $s2, -1					# $t4 <-- column size - 1
	mul $t4, $t4, -1					# the number of steps for each move for pointer = - row size
	j loop_on_the_smaller_partition					
			
	lower_R:
		lb $t1, ($t9)						# load symbol at address t9
		bne $t1, $t2, initialize_larger_partition		# if the symbol is not "X or O" branch to initialize_larger_partition
		addi $t3, $t3, 1					# if the symbol is "X or O" increase winning counter by 1
		j initialize_larger_partition				# jump to inialize_larger_partition
		
	adjust_lower:
		addi $t4, $s2, -1					# $t4 <-- column size - 1
		mul $t4, $t4, -1					# the number of steps for each move for pointer = - row size
		add $s3, $t8, $t7 					# row index + column index
		sub $s3, $s1, $s3					# row size - (row index + column index)
		mul $s3, $s1, $s3					# row size * (row size - (row index + column index))
		add $t6, $t6, $s3					# address the lower bound
		j loop_on_the_smaller_partition									

upper_bound_for_horizontal:
	li $t4, 1						# the number of steps for ech move for pointer 
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
	move $s3, $t5						# current cell address
	addi $s4, $s2, -1					# column size - 1
	beq $t7, $s4, upper_L					# if column index = column size - 1 (last column)
	addi $t6, $s1, -1					# row size - 1
	beq $t8, $t6, upper_L					# if row index = row size - 1 (last row)
	li $s4, 0
	addi $s4, $s2, 1					# column size + 1
	sub $t6, $t6, $t8					# row size - 1 - row index
	mul $t6, $s4, $t6					# (column size + 1) * (row size - 1 - row index)
	add $t6, $t6, $s4					# adjust upper bound 
	add $t6, $s3, $t6					# current cell + (column size + 1) * (row size - 1 - row index)
	move $t4, $s4						# the number of steps for each move for pointer = column size + 1
	beq $t3, $s7, sufficient_condition			# if winning counter == 5 go to sufficient_condition
	j set_up_larger_partition			
	
	upper_L:
		add $t6, $t5, $s4				# upper bound is the current cell + number of steps for each move
		move $t4, $s4					# the number of steps for each move for pointer = column size + 1
		beq $t3, $s7, sufficient_condition		# if winning counter == 5 go to sufficient_condition
		j set_up_larger_partition
		
upper_bound_for_R_diagonal:					
	move $s3, $t5						# current cell address
	beq $t7, $0, upper_R					# if column index = 0 (first column) then the upper bound is the cell itself
	addi $t6, $s1, -1					# row size - 1
	beq $t8, $t6, upper_R					# if row index = row size - 1 (last row) then the upper bound is the cell itself
	sub $t6, $s2, $t7					# column size - column index
	sub $t6, $s2, $t6					# column size - (column size - column index)
	addi $s4, $s2, -1					# column size - 1
	mul $t6, $s4, $t6					# (column size - 1) * (column size - (column size - column index))
	add $t6, $t6, $s4					# adjust upper bound
	add $t6, $s3, $t6					# current cell address + row size * (column size - (column size - column index))
	move $t4, $s4						# the number of steps for each move for pointer = column size - 1
	beq $t3, $s7, sufficient_condition			# if winning counter == 5 go to sufficient_condition
	j set_up_larger_partition
	
	upper_R:
		add $t6, $t5, $s1				# adjust upper bound
		addi $t4, $s2, -1				# the number of steps for each move for pointer = row size
		beq $t3, $s7, sufficient_condition		# if winning counter == 5 go to sufficient_condition
		j set_up_larger_partition
		
sufficient_condition:
	move $t9, $t5						# $t9 <-- initialize pointer to move
	add $t9, $t9, $t0					# is pointer moving on the larger partition ? add steps it moved : add zero
	add $t9, $t9, $t4					# pointer go to next poistion
	lb $t1, ($t9)						# load symbol

	bne $t1, $t2, winning					# if not "X" jump to winning


done_checking:
	move $v0, $t3					# return winningCounter
	move $v1, $t9			
	jr $ra							# return to main
	
winning:
	jal clear_screen					# clear screen
	jal print_table						# print winning table
	
	lw $t1, symbol
	beq $t1, 88, playerwin					# if the symbol is X then the player win else the computer win
	
	li $v0, 4
	la $a0, computer
	syscall
	
	li $v0, 4						# code for print string
	la $a0, winingMessage					# load message winning
	syscall							# print

	li $v0, 10						# code for exit
	syscall							# exit
	
playerwin:
	li $v0, 4
	la $a0, player
	syscall
	
	li $v0, 4						# code for print string
	la $a0, winingMessage					# load message winning
	syscall							# print

	li $v0, 10						# code for exit
	syscall							# exit

