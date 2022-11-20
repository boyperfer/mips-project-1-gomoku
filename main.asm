.data
.text

.globl main
main:

	jal read_table

	play:
		jal print_table
		jal player_play

		move $a0, $v0	
		move $a1, $v1
		jal computer_play
		#jal clear_screen
		j play
