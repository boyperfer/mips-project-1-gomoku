.data
rowI: .word 0
colI: .word 0
maxMove:	.word	0
drawMsg:	.asciiz	"Draw"
.text

.globl main
main:

	jal read_table
	mul $s5, $s2, $s1			# calculate total cell
	srl $s5, $s5, 1			# calculate the maximum move for player
	sw	$s5, maxMove		# store the move in maxMove label
	li $s5, 0					# clear register $s5

	play:
		jal print_table
		jal read_input
		sw $v0, rowI 
		sw $v1, colI
		addi $s5, $s5, 1		# increase move count by 1

		lw $a0, rowI
		lw $a1, colI 
		li $a2, 'X'
		li $a3, 0 
		jal check_winning 

		lw $a0, rowI
		lw $a1, colI 
		li $a2, 'X'
		li $a3, 1 
		jal check_winning 

		lw $a0, rowI
		lw $a1, colI 
		li $a2, 'X'
		li $a3, 2 
		jal check_winning 
		
		lw $a0, rowI
		lw $a1, colI 
		li $a2, 'X'
		li $a3, 3 
		jal check_winning 
		
		lw $s6, maxMove
		beq	$s5, $s6, draw
		
		jal clear_screen
		j play
		
	draw:
		li $v0, 4
		la $a0, drawMsg
		syscall
		
		li $v0, 10
		syscall