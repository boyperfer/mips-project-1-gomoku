.data

.text

.globl main
main:

	jal read_table

	play:
		jal print_table
		jal read_input
		
		move $a0, $v0
		move $a1, $v1
		li $a2, 'X'
		li $a3, 1 
		jal check_row

		jal clear_screen
		j play

