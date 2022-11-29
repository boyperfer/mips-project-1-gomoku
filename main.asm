.data
rowI: .word 0
colI: .word 0
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
