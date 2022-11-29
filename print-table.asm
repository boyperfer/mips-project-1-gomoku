.data
Space: .asciiz " "
tSpace: .asciiz "   "
newline: .asciiz "\n"
lastMove: .asciiz "Last move: "
pvsc: .asciiz "X/you      vs.    O/computer"

.text
.globl print_table 

# s1 = row size, s2 = column size
print_table:
	li $t3, 0										# initialize t3 to print first row which is letters representing columns
	li $v0, 4										# code to print string
	la $a0, tSpace									# load triple space
	syscall											# print
	print_letter:
		beq $t3, $s2, print_matrix					# if t3 equals to column size, jump to print_matrix

		li $v0, 11									# code to print char
		addi $a0, $t3, 65							# get char's ascii value
		syscall										# print

		li $v0, 4									# code to print string
		la $a0, Space								# load space
		syscall										# print

		addi $t3, $t3, 1							# t3 += t3

		j print_letter								# jump back to print_letter

	print_matrix:
		li $v0, 4									# code to print string
		la $a0, newline								# load line
		syscall										# print

		li $t3, 0									# initialize row counter

	print_matrix_row:
		bge $t3, $s1, print_matrix_row_end			# if row counter >= row size ? done
		li $t4, 0									# initialize column counter

		addi $t7, $t3, 1							# initialize t7 to check if row counter is 1 digit
		div $t8, $t7, 10							# get quotient
		beq $t8, $zero, print_column_1_digit		# if row counter is 1 digit, print 1 digit
													# otherwise just print
		li $v0, 1									# code to print integer	
		move $a0, $t7								# $a0 = row number starting at 1
		syscall										# print

		li $v0, 4									# code to print string
		la $a0, Space								# load space
		syscall										# print

		print_matrix_column:
		bge $t4, $s2, print_matrix_column_end		# if column counter >= column size ? go to next row

		mul $t5, $t3, $s2							# $t5 (array pointer) <-- row counter * column size 
		add $t5, $t5, $t4							# $t5 <-- row counter* column size + column counter
		add $t5, $s0, $t5							# $t5 <-- base address + (row counter * row size + column counter)


		li $v0, 11									# code to print char
		lb $a0, 0($t5)								# load array pointer to $a0
		syscall										# print

		li $v0, 4									# code to print string
		la $a0, Space								# load space
		syscall										# print

		addiu $t4, $t4, 1							# increment column counter

		j print_matrix_column						# jump back to print_matrix_column
		
		print_matrix_column_end:
		li $v0, 4									# code to print string
		la $a0, newline								# load newline
		syscall										# print

		addiu $t3, $t3, 1							# increment row counter

		j print_matrix_row							# jump back to print_matrix_row
		
	print_matrix_row_end:
		li $v0, 4
		la $a0, pvsc
		syscall
		
		li $v0, 11
		li $a0, '\n'	
		syscall					
		jr $ra										# jump back to calling function

	print_column_1_digit:
		li $v0, 4									# code to print string
		la $a0, Space								# load space
		syscall										# print
		
		li $v0, 1									# code to print integer
		move $a0, $t7								# load row numer
		syscall										# print	

		li $v0, 4									# code to print string
		la $a0, Space								# load space
		syscall										# print

		j print_matrix_column						# jump to print_matrix_column

