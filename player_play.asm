.data
	rowI: .word 0
	colI: .word 0
	winningCounterHorizontal: .word 0
	winningCounterVertical: .word 0
	winningCounterLeftDiagonal: .word 0
	winningCounterRightDiagonal: .word 0
.text

.globl player_play

player_play:
		addi $gp, $gp, 1000
		addi $sp, $sp, -4				# make room for stack fram
		sw $ra, 0($sp)					# store return address of calling function
		
		jal read_input					# jump to read_input
		sw $v0, rowI					# store to rowI
		sw $v1, colI					# store to colI
				
		lw $a0, rowI					# load rowIComp
		lw $a1, colI					# load colIComp
		li $a2, 'X'					# load 'X' 
		li $a3, 0					# check row
		jal check_winning				# jump check_winning
		sw $v0, winningCounterHorizontal		# store winningCounter of horizontal to globl pointer offset 0
		sw $v1, ($gp)					# store the cell stopped checking	


		lw $a0, rowI					# load rowIComp
		lw $a1, colI					# load colIComp
		li $a2, 'X'               			# load 'X' 
		li $a3, 1                 			# check col
		jal check_winning         			# jump check_winning
		sw $v0, winningCounterVertical			# store winningCounter of vertical to globl pointer offset 4
		sw $v1, 4($gp)					# store the cell stopped checking	

		lw $a0, rowI					# load rowIComp
		lw $a1, colI					# load colIComp
		li $a2, 'X'              	   		# load 'X' 
		li $a3, 2                 	  		# check left diagonal
		jal check_winning         			# jump check_winning
		sw $v0, winningCounterLeftDiagonal		# store winningCounter of left diagonal to globl pointer offset 8
		sw $v1, 8($gp)					# store the cell stopped checking
		
		lw $a0, rowI					# load rowIComp
		lw $a1, colI 					# load colIComp
		li $a2, 'X'					# load 'X'
		li $a3, 3 					# check right diagonal
		jal check_winning 				# jump check_winning
		sw $v0, winningCounterRightDiagonal		# store winningCounter of left diagonal to globl pointer offset 8
		sw $v1, 12($gp)					# store the cell stopped checking

		lw $t1, winningCounterHorizontal		# load winningCounterHorizontal
		lw $t2, winningCounterVertical			# load winningCounterVertical 
		lw $t3, winningCounterLeftDiagonal		# load winningCounterLeftDiagonal
		lw $t4, winningCounterRightDiagonal 		# load winningCounterRightDiagonal

		bge $t1, $t2, compareHorAndLDiagAndRDiag	# winningCounterHorizontal >= winningCounterVertical ? compareHorAndLDiagAndRDiag 
		j compareVerAndLDiagAndRDiag			# else jump to compareVerAndLDiagAndRDiag


compareHorAndLDiagAndRDiag:
	bge $t1, $t3, compareHorAndRDiag			# winningCounterHorizontal >= winningCounterLeftDiagonal ? compareHorAndRDiag 
	j compareLDiagAndRDiag					# else jump to compareLDiagAndRDiag

compareVerAndLDiagAndRDiag:				
	bge $t2, $t3, compareVerAndRDiag			# winningCounterVertical >= winningCounterLeftDiagonal ? compareVerAndRDiag
	j compareLDiagAndRDiag					# else jump to compareLDiagAndRDiag

compareHorAndRDiag:
	bge $t1, $t4, horizontalProbing				# winningCounterHorizontal >= winningCounterRightDiagonal ? horizontalProbing
	j rightDiagProbing					# else jump to rightDiagProbing

compareLDiagAndRDiag:
	bge $t3, $t4, leftDiagProbing				# winningCounterLeftDiagonal >= winningCounterRightDiagonal ? leftDiagProbing
	j rightDiagProbing					# else jump to rightDiagProbing

compareVerAndRDiag:
	bge $t2, $t4, verticalProbing				# winningCounterVertical >= winningCounterRightDiagonal ? verticalProbing
	j rightDiagProbing					# else jump to rightDiagProbing

	
horizontalProbing:
	lw $v0, ($gp)						# return the cell
	li $v1, 1						# return the number of steps for probing (1)
	j backToCalling

verticalProbing:
	lw $v0, 4($gp)						# return the cell
	move $v1, $s2              				# return the number of steps for probing (column size)
	j backToCalling

leftDiagProbing:
	lw $v0, 8($gp)						# return the cell
	move $v1, $s2						# $v1 <-- column size 
	addi $v1, $v1, 1					# return the number of steps for probing (column size + 1)
	j backToCalling

rightDiagProbing:
	lw $v0, 12($gp)						# return the cell
	move $v1, $s2						# $v1 <-- column size
	addi $v1, $v1, -1					# return the number of steps for probing (column size - 1)
	j backToCalling

backToCalling:
	lw $ra, 0($sp)						# load register address
	addi $sp, $sp, 4           				# restore stack pointer
	lw  $t0, rowI						# load row index of player
	addi $t0, $t0, 1					# return row index for displaying row move
	lw $t1, colI						# load column index of player
	addi $t1, $t1, 65					# convert to uppercase letter for displaying column move
	jr $ra                     				# jump to calling function

