.data
read_row_matrix_prompt_p:   .asciiz "Enter a number for row: "
read_column_matrix_prompt_p: .asciiz "Enter a number for column: "
input_greater_than_5_message: .asciiz "Please enter a number greater than 5\n"
line: .asciiz "\n"
###########################################################

.text
.globl read_table 
read_table:
	li $v0, 4							# code to print string
	la $a0, read_row_matrix_prompt_p				# load read row prompt
	syscall								# print

	li $v0,	5							# code to read integer from input buffer
	syscall								# read
	li $s1, 5							# load $s1 = 5
	blt $v0, $s1, less_than_5_error					# if the read integer < 5 ? less_than_5_error : assign $s1
	move $s1, $v0							# $s1 = row size

	li $v0,	4							# code to print string		
	la $a0, read_column_matrix_prompt_p				# load read column prompt
	syscall								# print

	li $v0, 5							# code to read integer from input buffer 
	syscall								# read 
	li $s2, 5							# load $s2 = 5
	blt $v0, $s2, less_than_5_error					# if the read integer < 5 ? less_than_5_error : assign $s2
	move $s2, $v0							# $s2 = column size

	li $v0, 9							# code to allocate memory
	mul $a0, $s1, $s2						# $a0 = number of bytes to read chars
	syscall								# allocate
	move $s0, $v0							# $s0 = array address
	

read_matrix:
    li $t3, 0								# initialize row counter

	read_matrix_row:
		bge $t3, $s1, read_matrix_row_end			# if row counter == row size ? done

		li $t4, 0						# initialize column counter 

	read_matrix_column:
		bge $t4, $s2, read_matrix_column_end

		mul $t5, $t3, $s2					# $t5 (array pointer) <-- row counter * row size 
		add $t5, $t5, $t4					# $t5 <-- row counter* row size + column counter
		add $t5, $s0, $t5					# $t5 <-- base address + (row counter * row size + column counter)

		li $t7, '.'						# load '.'
		sb $t7, 0($t5)						# store '.' into array

		addiu $t4, $t4, 1					# increment inner-loop counter
		j read_matrix_column					# jump back to the column loop

	read_matrix_column_end:
		addiu $t3, $t3, 1					# increment row counter
		j read_matrix_row					# jump back to beginning of the row loop

	read_matrix_row_end:
		jr $ra							# jump back to calling function	

less_than_5_error:
	li $v0, 4							# code to print string
	la $a0, input_greater_than_5_message				# load input_greater_than_5_message
	syscall								# call
	j read_table							# jump to read_table
