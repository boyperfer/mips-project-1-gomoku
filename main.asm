.data
rowI: .word 0
colI: .word 0
maxMove:	.word	0
drawMsg:	.asciiz	"Draw"
maxMove: .word 0
drawMessage: .asciiz "Draw"
pri: .word 0
pci: .word 0
cri: .word 0
cci: .word 0
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
	jal print_table
	move $t0, $s1			# calculate the maximum move for draw condition
	move $t1, $s0
	mul  $t0, $t0, $t1
	srl $t0, $t0, 1
	sw $t0, maxMove
	li $k0, 0
	play:
		jal player_play
		move $a0, $v0		# get the player row index
		move $a1, $v1		# get the player column index
		sw $t0, pri
		sw $t1, pci
		jal computer_play
		sw $v0, cri		# get the computer row index
		sw $v1, cci		# get the computer column index
		addi $k0, $k0, 1	# increase the move counter
		lw $t0, maxMove
		beq $k0, $t0, draw	# check for draw 
		jal clear_screen
		lw $a0, cri
		lw $a1, cci
		lw $a2, pri
		lw $a3, pci
		jal print_screen
		j play
	
	draw:
		li $v0, 4		# print out draw message
		la $a0, drawMessage
		syscall
		
		li $v0, 10		# terminate the program
		syscall
