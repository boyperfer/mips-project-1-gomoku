.data

.text

.globl main
main:

	jal read_table

	play:
		jal print_table
		jal read_input

		move $a0, $v0
		li $a1, 'X'
		jal check_row

		jal clear_screen
		j play

