.data           
array: .space 6    #reserves space for a 6 elem array
char: .space 2
prompt: .asciiz "move (EX: 2 A)? "
errorMessage: .asciiz "Please enter proper syntax: \n"
overlapMessage: .asciiz "Overlap!! please enter another: \n"
space: .ascii " "
newline: .asciiz "\n"
.text           #instructions follow
.globl read_input

read_input:
	li $v0, 4						# code for print string
	la $a0, prompt					# load prompt message 
	syscall							# print prompt message

	la $s4, array					# set base address of array to s4
	li $t2, 0
	loop:					
		li $v0, 8					# code for read string
		la $a0, char				# load address of char for read
		li $a1, 2					# length = 2 (1byte char and 1byte null)
		syscall						# store the char byte from input buffer into char

		lb $t0, char				# load the char from char buffer into t0, stripping null
		sb $t0, 0($s4)				# store the char into the nth elem of array
		addi $t2, $t2, 1			# length of array += 1

		lb $t1, newline				# load newline 
		beq $t0, $t1, parse_string  # end of string (when press enter)?  jump to parse_string 

		addi $s4, $s4, 1			# increments base address of array
		j loop						# jump to loop

parse_string:           
	li $t1, 6						# $t1 = 6 
	bge $t2, $t1, error				# if length of input >= 6 ? jump to error

	addi $s4, $s4, -1				# reposition array pointer to last char before newline char

	la $s3, array					# set base address of array to s3 for use as counter
	addi $s3, $s3, -1				# reposition base array to read leftmost char in string

	lb $t1, 0($s4)					# load char from array into t1
	blt $t1, 65, error				# check if char is not an uppercase letter (ascii<'A')
	bgt $t1, 90, error				# check if char is not an uppercase letter (ascii>'Z')


	j set_column					# jump to set_column

	digits_for_row:
		add $t6, $zero, $zero		# initialize row index to 0
		li $t0, 10					# set t0 = 10 for decimal conversion
		li $t3, 1					# t3 for power of 10 	

		lb $t1, 0($s4)				# load char from array into t1
		blt $t1, 48, error			# check if char is not a digit (ascii<'0')
		bgt $t1, 57, error			# check if char is not a digit (ascii>'9')

		addi $t1, $t1, -48			# converts t1's ascii value to dec value
		add $t6, $t6, $t1			# row index = $t1's dec value
		addi $s4, $s4, -1			# decrement array address	
	multiDigits:         
		mul $t3, $t3, $t0			# multiply power by 10

		beq $s4, $s3, set_row		# set row if beginning of string is reached

		lb $t1, ($s4)				# load char from array into t1
		addi $t1, $t1, -48			# converts t1's ascii value to dec value
		mul $t1, $t1, $t3			# t1*10^(counter)
		add $t6, $t6, $t1			# row index = row index + t1

		addi $s4, $s4, -1			# decrement array address
		j multiDigits 

	set_column:
		addi $t1, $t1, -65			# convert char's ascii value to integer 
		move $t7, $t1				# t7 = index column

		addi $s4, $s4, -2			# reposition array pointer to the next char (skip space)
		j digits_for_row			# jump to digits_for_row

	set_row:
		addi $t6, $t6, -1			# actual row index

done:
	bgt $t6, $s1, error				# erorr if row index > row size
	bgt $t7, $s2, error				# erorr if column index > column size
		
	mul $t5, $t6, $s2				# $t5 (array pointer) <-- row index* column size 
	add $t5, $t5, $t7               # $t5 <-- row index * column size + column index
	add $t5, $s0, $t5				# $t5 <-- base address + (row index * column size + column index)

	move $v0, $t6					# return row index
	move $v1, $t7					# return column index

	li $t7, '.'						# load '.'
	lb $t8, ($t5)					# load $t5 operand
	bne $t8, $t7, overlap			# if $t7 is not equal to $t8, jump to overlap
	li $t7, 'X'						# load 'X'
	sb $t7, 0($t5)					# store 'X' into array
	jr $ra							# jump back to calling function

overlap:
li $v0, 4							# code to print string
la $a0, overlapMessage				# load overlapMessage 
syscall								# print

j read_input						# print read_input

error:
li $v0, 4							# code to print string
la $a0, errorMessage				# load errorMessage
syscall								# print

j read_input						# print read_input

