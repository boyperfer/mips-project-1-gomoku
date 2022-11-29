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
		addi $sp, $sp, -4			# make room for stack fram
		sw $ra, 0($sp)				# store $ra	
		
		jal read_input				# jump to read_input
		sw $v0, rowI				# store to rowI
		sw $v1, colI				# store to colI
				
		lw $a0, rowI				# load rowIComp
		lw $a1, colI				# load colIComp
		li $a2, 'X'				# load 'X' 
		li $a3, 0				# check row
		jal check_winning			# jump check_winning
		sw $v0, winningCounterHorizontal	# store winningCounter of horizontal to globl pointer offset 0
		sw $v1, ($gp)				# store the cell stopped checking	


		lw $a0, rowI				# load rowIComp
		lw $a1, colI				# load colIComp
		li $a2, 'X'               		# load 'X' 
		li $a3, 1                 		# check col
		jal check_winning         		# jump check_winning
		sw $v0, winningCounterVertical		# store winningCounter of vertical to globl pointer offset 4
		sw $v1, 4($gp)				# store the cell stopped checking	

		lw $a0, rowI				# load rowIComp
		lw $a1, colI				# load colIComp
		li $a2, 'X'              	   	# load 'X' 
		li $a3, 2                 	  	# check left diagonal
		jal check_winning         		# jump check_winning
		sw $v0, winningCounterLeftDiagonal	# store winningCounter of left diagonal to globl pointer offset 8
		sw $v1, 8($gp)				# store the cell stopped checking
		
		lw $a0, rowI				# load rowIComp
		lw $a1, colI 				# load colIComp
		li $a2, 'X'				# load 'X'
		li $a3, 3 				# check right diagonal
		jal check_winning 			# jump check_winning
		sw $v0, winningCounterRightDiagonal	 # store winningCounter of left diagonal to globl pointer offset 8
		sw $v1, 12($gp)				# store the cell stopped checking

		lw $t1, winningCounterHorizontal	# load winningCounterHorizontal
		lw $t2, winningCounterVertical		# load winningCounterVertical 
		lw $t3, winningCounterLeftDiagonal	# load winningCounterLeftDiagonal
		lw $t4, winningCounterRightDiagonal # load winningCounterRightDiagonal

		bge $t1, $t2, compareHorAndLDiagAndRDiag	# winningCounterHorizontal >= winningCounterVertical ? compareHorAndLDiag : compareVerAndLDiag
		j compareVerAndLDiagAndRDiag


compareHorAndLDiagAndRDiag:
	bge $t1, $t3, compareHorAndRDiag 
	j compareLDiagAndRDiag 

compareVerAndLDiagAndRDiag:
	bge $t2, $t3, compareVerAndRDiag 
	j compareLDiagAndRDiag 

compareHorAndRDiag:
	bge $t1, $t4, horizontalProbing	
	j rightDiagProbing

compareLDiagAndRDiag:
	bge $t3, $t4, leftDiagProbing
	j rightDiagProbing

compareVerAndRDiag:
	bge $t2, $t4, verticalProbing
	j rightDiagProbing

	
horizontalProbing:
	lw $v0, ($gp)					# return the cell
	li $v1, 1					# return the steps for probing (1)
	j backToCalling

verticalProbing:
	lw $v0, 4($gp)					# return the cell
	move $v1, $s2              			# return the steps for probing (column size)
	j backToCalling

leftDiagProbing:
	lw $v0, 8($gp)					# return the cell
	move $v1, $s2					# $v1 <-- column size 
	addi $v1, $v1, 1				# return the steps for probing (column size + 1)
	j backToCalling

rightDiagProbing:
	lw $v0, 12($gp)
	move $v1, $s2
	addi $v1, $v1, -1
	j backToCalling

backToCalling:
	lw $ra, 0($sp)					# load register address
	addi $sp, $sp, 4           			# restore stack pointer
	lw  $t0, rowI
	addi $t0, $t0, 1
	lw $t1, colI
	addi $t1, $t1, 65
	jr $ra                     			# jump to calling function

