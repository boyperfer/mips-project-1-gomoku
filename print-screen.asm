.data
space: .asciiz "  "
anotherSpace: .asciiz "     "
lastMove: .asciiz "Last Move: "
ins: .asciiz "   X     O"
.text
.globl print_screen

print_screen:
		move $t0, $a0				# computer row index
		move $t1, $a1				# computer column index
		move $t2, $a2				# player row index
		move $t9, $a3				# player column index
		
		addi $sp, $sp, -4			# make room for stack frame
		sw $ra, 0($sp)				# store return address of calling function
		jal print_table
		
		li $v0, 4				# print string
		la $a0, lastMove
		syscall
		
		li $v0, 11
		li $a0, '\n'
		syscall
		
		li $v0, 4
		la $a0, ins
		syscall
		
		li $v0, 11
		li $a0, '\n'
		syscall
		
		li $v0, 4
		la $a0, space
		syscall
		
		li $v0, 1				# print player row index
		move $a0, $t2
		syscall
		
		li $v0, 11				# print player column index
		move $a0, $t9
		syscall
		
		li $v0, 4
		la $a0, anotherSpace
		syscall
		
		li $v0, 1				# print computer row index
		move $a0, $t0
		syscall
		
		li $v0, 11				# print computer column index
		move $a0, $t1
		syscall
		
		li $v0, 11
		li $a0, '\n'
		syscall
		
		lw $ra, 0($sp)				# load register address
		addi $sp, $sp, 4           		# restore stack 
		jr $ra
		
	
