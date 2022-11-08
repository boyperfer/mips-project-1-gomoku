.data

.text

.globl main
main:

	jal read_table

	whileYes:
	
		jal print_table
		jal read_input
		jal clear_screen
		j whileYes

