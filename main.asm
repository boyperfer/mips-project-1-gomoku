.data
rowI: .word 0
colI: .word 0
maxMove: .word 0
drawMessage: .asciiz "Draw"
again: .asciiz "\nPlay again?(Y/N) "
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
	move $t1, $s2
	mul  $t0, $t0, $t1
	srl $t0, $t0, 1			# (column size * row size) / 2
	sw $t0, maxMove
	li $k0, 0
	play:
		jal player_play
		move $a0, $v0			# $a0 = the cell recommended for computer to move
		move $a1, $v1			# $a1 = the number of steps or probing
		sw $t0, pri				# get the player row index
		sw $t1, pci				# get the player column index
		jal computer_play
		sw $v0, cri		# get the computer row index
		sw $v1, cci		# get the computer column index
		addi $k0, $k0, 1	# increase the move counter
		lw $t0, maxMove
		beq $k0, $t0, draw	# check for draw 
		jal clear_screen
		lw $a0, cri				# a0 = computer row index
		lw $a1, cci				# a1 = computer column index
		lw $a2, pri				# a2 = player row index
		lw $a3, pci				# a3 = player column index
		jal print_screen		# jump to print_screen
		j play					# jump back to play
	
	draw:
		li $v0, 4		# print out draw message
		la $a0, drawMessage
		syscall
		
		li $v0, 4						# ask the player if they want to play again
		la $a0, again
		syscall
	
		li $v0, 12						# get the user input
		syscall
	
		beq $v0, 89, play_again
		
		li $v0, 10		# terminate the program
		syscall
play_again:
	jal clear_screen				# clear the screen
	li $t3, 0						# reset winning counter
	j main						# start a new match from main
