.data
rowI: .word 0
colI: .word 0
.text

.globl main
main:

	jal read_table

	play:
		jal print_table
		jal read_input
		sw $v0, rowI 
		sw $v1, colI

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

		#jal clear_screen
		j play

