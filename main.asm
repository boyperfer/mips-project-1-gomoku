.data
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
	move $t0, $s1
	move $t1, $s0
	mul  $t0, $t0, $t1
	srl $t0, $t0, 1
	sw $t0, maxMove
	li $k0, 0
	play:
		jal player_play
		move $a0, $v0	
		move $a1, $v1
		sw $t0, pri
		sw $t1, pci
		jal computer_play
		sw $v0, cri
		sw $v1, cci
		addi $k0, $k0, 1
		lw $t0, maxMove
		beq $k0, $t0, draw
		jal clear_screen
		lw $a0, cri
		lw $a1, cci
		lw $a2, pri
		lw $a3, pci
		jal print_screen
		j play
	
	draw:
		li $v0, 4
		la $a0, drawMessage
		syscall
		
		li $v0, 10
		syscall
