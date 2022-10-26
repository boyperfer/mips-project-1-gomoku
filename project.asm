.data
X: .byte 'X'
O: .byte 'O'
dSpace: .asciiz "  "
tSpace: .asciiz "   "
qSpace: .asciiz "     "
read_row_matrix_prompt_p:   .asciiz "Enter an integer: "
line: .asciiz "\n"
###########################################################

.text
.global main
main:
li  $t1, 15 # Column
li  $t2, 26 # Row

li  $v0, 9
syscall
move $s0,$v0   # save array address in $s0

read_row_matrix:
    li $t3, 0               # initialize outer-loop counter to 0

read_row_matrix_loop_outer:
    bge $t3, $t1, read_row_matrix_loop_outer_end

    li $t4, 0               # initialize inner-loop counter to 0

read_row_matrix_loop_inner:
    bge $t4, $t2, read_row_matrix_loop_inner_end

    mul $t5, $t3, $t2       # $t5 <-- width * i
    add $t5, $t5, $t4       # $t5 <-- width * i + j
    add $t5, $s0, $t5       # $t5 <-- base address + (width * i + j)

	li $t7, '.'				# load '.'
    sb $t7, 0($t5)          # store '.' into array
    addiu $t4, $t4, 1       # increment inner-loop counter

    j read_row_matrix_loop_inner    # jump back to beginning of the inner loop

read_row_matrix_loop_inner_end:
    addiu $t3, $t3, 1       # increment outer-loop counter

    j read_row_matrix_loop_outer    # jump back to beginning of the outer loop

read_row_matrix_loop_outer_end:

li $t3, 0
li $v0, 4
la $a0, qSpace 
syscall
print_number:
	beq $t3, $t2, print_matrix	
	beq $t3, 8, print_J

	li $v0, 11 
	addi $a0, $t3, 65
	syscall

	li $v0, 4 
	la $a0, dSpace
	syscall
#	li $v0, 11
#	li $a0, 9 
#	syscall

	addi $t3, $t3, 1

	j print_number

print_J:
	slti $t0, $t3, 10
	beq $t0, $zero, print_number
	li $v0, 11 
	li $a0, ' '
	syscall


	li $v0, 11 
	addi $a0, $t3, 65
	syscall

	li $v0, 4 
	la $a0, dSpace
	syscall
#	li $v0, 11
#	li $a0, 9 
#	syscall

	addi $t3, $t3, 1

	j print_J 

print_matrix:
	li $v0, 4
	la $a0, line
	syscall

	li $t3, 0

print_matrix_row:
	bge $t3, $t1, print_matrix_row_end

	li $t4, 0

	div $t8, $t3, 10
	mflo $t8
	beq $t8, $zero, print_column_1_digit

	li $v0, 1 
	move $a0, $t3
	syscall

	#li $v0, 11
	#li $a0, ' '
	#syscall
	li $v0, 4
	la $a0, dSpace
	syscall


	print_matrix_column:
	bge $t4, $t2, print_matrix_column_end

    mul $t5, $t3, $t2       # $t5 <-- width * i
    add $t5, $t5, $t4       # $t5 <-- width * i + j
    add $t5, $s0, $t5       # $t5 <-- base address + (width * i + j)


	li $v0, 11
	lb $a0, 0($t5) 
	syscall

#	li $v0, 11
#	li $a0, 9 
#	syscall

	li $v0, 4
	la $a0, tSpace 
	syscall

    addiu $t4, $t4, 1       # increment inner-loop counter

	j print_matrix_column
	
	print_matrix_column_end:
	li $v0, 4
	la $a0, line
	syscall

	addiu $t3, $t3, 1
	j print_matrix_row
	
print_matrix_row_end:

li $v0, 10
syscall

print_column_1_digit:
	li $v0, 4 
	la $a0, dSpace
	syscall
	
	li $v0, 1 
	move $a0, $t3
	syscall

	#li $v0, 11
	#li $a0, ' '
	#syscall
	li $v0, 4
	la $a0, dSpace
	syscall

	j print_matrix_column

