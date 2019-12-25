# CSE 220 Programming Project #3
# Justin Chan
# juschan
# 112116921

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text
initialize:
	# Checking for $a1 
	bltz $a1,initialize_invalid
	beqz $a1,initialize_invalid
	
	# Checking for $a2
	bltz $a2,initialize_invalid
	beqz $a2,initialize_invalid
	
	#Move to $v0, $v1 
	move $v0, $a1
	move $v1, $a2
	#Calculate 
	mult $a1,$a2
	mflo $t0 
	
	lbu $t1, 0($a0)
	sb $v0,($a0)
	addi $a0,$a0, 1
	
	lbu $t1, 0($a0)
	sb $v1,($a0) 
	addi $a0,$a0, 1
	#$a3 contains the character content
	store_in_field:
		beqz $t0,add_null_terminator
		lbu $t1, 0($a0)
		sb $a3,($a0) 
		addi $a0 ,$a0 ,1
		addi $t0, $t0, -1
		j store_in_field
add_null_terminator:
	j initialize_tangent
initialize_invalid:
	li $v0, -1
	li $v1, -1		
initialize_tangent:
	jr $ra

load_game:
	addi $sp, $sp ,-24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s1, 8($sp)
	sw $s1, 12($sp)
	sw $s1, 16($sp)
	sw $s1, 20($sp)
	
	move $s0, $a0 # state with data 
	move $s1, $a1 #File name
	
	#Read the file 
	li $v0, 13
	move $a0,$s1
	li $a1, 0  # Read-only 
	li $a2,0
	syscall 
	
	#$s2 is the file descriptor
	move $s2,$v0
	bltz $s2, initialize_invalid_2

	addi $sp, $sp, -1  # Allocate 1 byte memory
	
	li $t0, 2 
	li $t1, '\n'
	li $t9 ,-48
	#**************Start processing********
	#Obtain the first row bit
	li $v0, 14
	move $a0, $s2  # a0 is the file descriptor
	move $a1, $sp
	li $a2, 1
	syscall
	
	lbu $t2, 0($sp)
	add $t2 ,$t2,$t9
	move $s3, $t2 #store the byte into $s3 
	
	#Obtain the final row byte if it exist
	li $v0, 14
	move $a0, $s2  # a0 is the file descriptor
	move $a1, $sp
	li $a2, 1
	syscall
	
	lbu $t2, 0($sp)
	beq $t2, $t1 store_row_bits
	add $t2 ,$t2, $t9
	
	li $t8, 10
	mult $s3, $t8
	mflo $s3 
	#s3 contains the results rows
	add $s3,$s3, $t2 

	#Obtain new line
	li $v0, 14
	move $a0, $s2  # a0 is the file descriptor
	move $a1, $sp
	li $a2, 1
	syscall
store_row_bits:
	#Store the row bits
	lbu $t3, 0($s0)
	sb $s3, ($s0) 
	addi $s0, $s0 ,1
obtain_num_columns:
	#Obtain the first column bit
	li $v0, 14
	move $a0, $s2  # a0 is the file descriptor
	move $a1, $sp
	li $a2, 1
	syscall
	
	lbu $t2, 0($sp)
	add $t2 ,$t2,$t9
	move $s4, $t2 
	
	#Obtain the final column bit if it exist
	li $v0, 14
	move $a0, $s2  # a0 is the file descriptor
	move $a1, $sp
	li $a2, 1
	syscall
	
	lbu $t2, 0($sp)
	beq $t2, $t1, store_columns
	add $t2 ,$t2, $t9
	
	li $t8, 10
	mult $s4, $t8
	mflo $s4 
	#s3 contains the results rows
	add $s4,$s4, $t2 
	
	#Obtain the new line
	li $v0, 14
	move $a0, $s2  # a0 is the file descriptor
	move $a1, $sp
	li $a2, 1
	syscall
store_columns:
	#Store the row bits
	lbu $t3, 0($s0)
	sb $s4, ($s0) 
	addi $s0, $s0 ,1 
start_block:	
	#Process the block of O,. ,letters 
	li $t5, 'O' 
	li $t6, '.'
	li $t7, '\n' # Check to see if there is a new lin
	li $t8, 0 # Count the number of 'O'
	li $t9, 0 # Count the number of invalid characters
	
	#Count the number of elements 
	mult $s3,$s4
	mflo $s5
	#Load and Store into the address
	loop_by_byte:
		beqz $s5,close_file
		li $v0, 14
		move $a0, $s2  # a0 is the file descriptor
		move $a1, $sp
		li $a2, 1
		syscall
		
		lbu $t0, 0($sp)
		lbu $t1, 0($s0)
		
		beq $t0, $t7,ignore_newline
		beq $t0, $t5, to_O
		beq $t0, $t6, to_period
		
		#not valid =>change to '.'; add 1 to $t9 
		addi $t9, $t9 ,1 
		sb $t6,($s0)
		addi $s5,$s5, -1
		addi $s0, $s0,1
	ignore_newline:	 
		j loop_by_byte
	close_file:
		addi $sp, $sp, 1
		
		#Close the file
		li $v0,16
		move $a0, $s0 
		syscall
results:
 	move $v0, $t8
 	move $v1, $t9
 	j load_game_tangent
to_O:
	addi $t8,$t8 ,1
	sb $t5,($s0)
	addi $s5,$s5, -1
	addi $s0, $s0,1
	j ignore_newline
to_period:
	sb $t6,($s0)
	addi $s5,$s5, -1
	addi $s0, $s0,1
	j ignore_newline
	
initialize_invalid_2:
	li $v0, -1
	li $v1,-1
load_game_tangent:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    addi $sp, $sp ,24
    jr $ra

get_slot:
	addi $sp, $sp ,-20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	
	move $s0, $a0 
	move $s1, $a1 
	move $s2, $a2
	# Check the number of rows
	lbu $t0, 0($s0)
	ble $t0, $s1, initialize_invalid_3
	bltz $s1, initialize_invalid_3
	move $s3,$t0  #Store the number of rows
	
	# Check the number of columns 
	lbu $t0, 1($s0)
	ble $t0, $s2, initialize_invalid_3
	bltz $s2, initialize_invalid_3
	move $s4,$t0  #Store the number of columns
	
	#Subtract one from row to get the full set
	addi $s1, $s1,-1
	find_row:
		bltz $s1, find_character # row =3,2,1,0
		move $t1, $s4 # num of columns 
		search_row:
			lbu $t0 ,2($s0)
			beqz $t1,next_row
			addi $t1, $t1, -1
			addi $s0, $s0,1 
			j search_row
	next_row:
		addi $s1,$s1,-1	
		j find_row
	find_character:
		beqz $s2, found_character
		lbu $t0 ,2($s0)
		addi $s0, $s0,1 
		addi $s2, $s2, -1
		j find_character
	found_character:
		lbu $t0 ,2($s0)
		move $v0, $t0 
		j get_slot_tangent
initialize_invalid_3:
	li $v0 ,-1
get_slot_tangent:
   
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    addi $sp, $sp ,20
    jr $ra

set_slot:
	addi $sp, $sp ,-24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	
 	move $s0, $a0 
	move $s1, $a1 
	move $s2, $a2
	move $s3 ,$a3
	# Check the number of rows
	lbu $s4, 0($s0)
	ble $s4, $s1, initialize_invalid_4
	bltz $s1, initialize_invalid_4
	
	# Check the number of columns 
	lbu $s5, 1($s0)
	ble $s5, $s2, initialize_invalid_4
	bltz $s2, initialize_invalid_4
	
	li $t2, 'O'
	li $t3, '.'
	beqz $s1,find_character2
	addi $s1, $s1,-1#Subtract one from row to get the full set
ignore_subtraction:
	find_row2:
		bltz $s1, find_character2
		move $t1, $s5 # num of columns
		search_row2:
			beqz $t1,next_row2
			lbu $t0,2($s0)
			addi $t1, $t1, -1
			addi $s0, $s0,1
			j search_row2
		next_row2:
			addi $s1,$s1,-1	#Subtract the rows
			j find_row2
		find_character2:
			bltz $s2, replace_character_if
			lbu $t0 ,2($s0)
			addi $s0, $s0,1 
			addi $s2, $s2, -1
			j find_character2
	replace_character_if:
		beq $t2, $t0,replacing  
		beq $t3, $t0,replacing
		j initialize_invalid_4
	replacing:
		addi $s0,$s0,1
		lbu $t0,2($s0)
		move $v0,$s3 #Move the ASCII value into $v0
		sb $s3,($s0)
		j set_slot_tangent
initialize_invalid_4:
	li $v0 ,-1
set_slot_tangent:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    addi $sp, $sp ,24
    jr $ra

rotate:
	addi $sp, $sp ,-64
   	sw $s0, 0($sp)
    	sw $s1, 4($sp)
    	sw $s2, 8($sp)
    	sw $s3, 12($sp)
    	sw $s4, 16($sp)
    	sw $s5, 20($sp)
    	sw $s6, 24($sp)
    	sw $s7, 28($sp)
    	
	move $s0, $a0 #Address of piece
	move $s1, $a1 # Rotation
	move $s2, $a2 # address of rotated piece 
	# Store all bytes into stack from $s0
	#Load each byte and store into stack
	#Row 
	lbu $t0, 0($s0)	 #row 
   	sb $t0, 32($sp)
   	move $s3,$t0 
   	#Column
    	lbu $t0, 1($s0)
   	sb $t0, 36($sp)
   	move $s4,$t0 
   	# 'O's and '.'s
   	#Number 1 
   	lbu $t0, 2($s0)
   	sb $t0, 40($sp)
   	#Number 2 
   	lbu $t0, 3($s0)
   	sb $t0, 44($sp)
   	#Number 3 
   	lbu $t0, 4($s0)
   	sb $t0, 48($sp)
   	#Number 4 
   	lbu $t0, 5($s0)
   	sb $t0, 52($sp)
   	#Number 5 
   	lbu $t0, 6($s0)
   	sb $t0, 56($sp)
   	#Number 6 
   	lbu $t0, 7($s0)
   	sb $t0, 60($sp)
 
	bltz $s1, initialize_invalid_5
	
	# Utilize initialize, get_slot, set_slot
	# $s3 stores the rows
	# $s4 stores the columns
	# Initialize
	move $t0, $s2
	addi $sp, $sp, -4
	sw $ra,0($sp)
	
	move $a0, $t0
	move $a1, $s3
	move $a2, $s4
	li $a3, '.' 
	jal initialize
	
	lw $ra,0($sp)
	addi $sp, $sp, 4
	
	#$v0, $v1 contains the results 
	blez $v0,initialize_invalid_5#$v0<=0
	blez $v1,initialize_invalid_5#$v1<=0
	#Calculate the number of rotations
	#************
	li $t9,4
	div $s1,$t9
	mfhi $t7 # Contains the remainders of rotations 
	#*************
	bnez $t7, rotation_calculation
	li $t9, 8
	move $t2, $s0  # Store it temporarily
	transfer_to_s2:  # Transfer the results to $s2 
		beqz $t9, finished_rotation 
		lbu $t0, 0($t2)
		lbu $t1, 0($s2)
		sb $t0,($s2)
		addi $t2,$t2, 1
		addi $s2,$s2, 1
		addi $t9,$t9,-1
		j transfer_to_s2
rotation_calculation:
	#Check for O block
	li $t9 ,2
	beq $s3,$t9, check_column 
	j skip_block_O
check_column:
	beq $s4,$t9, classified_O
skip_block_O:
	#Check for I block
	li $t9,1
	beq $s3,$t9,  classified_I
	beq $s4,$t9,  classified_I
	
	#Check the row number
	li $t9, 3
	beq $t9, $s3,rotations_90_2
#Perform rotation for all others(2,3 )
rotations_90:
	beqz $t7 ,finished_rotation
	# Keep track of rows and columns using $t5,$t6(Get)
	li $t5,0
	li $t6,0
	#Use Get_slot for piece struct
	li $t8, 6
	lbu $s3, 0($s0) #**
	lbu $s4, 1($s0)
	li $s5, 0 #Row of manipulated rotated piece**
	addi $s6, $s3,-1 #Column of manipulated rotated piece
	#Swap the rows and columns
	move $t0,$s3
	move $s3,$s4
	move $s4,$t0
	
	sb $s3,0($s2)
	sb $s4,1($s2)
	rotate_all:
		beqz $t8, move_piece_to_struct		
		addi $sp,$sp ,-24
		sw $s0, 0($sp)
		sw $s1, 4($sp)
		sw $s2, 8($sp)
		sw $s3, 12($sp)
		sw $s4, 16($sp)
		sw $ra, 20($sp)
	
		move $a0, $s0
		move $a1, $t5 # Keep track of rows
		move $a2, $t6 # Keep track of columns
		jal get_slot
	
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $ra, 20($sp)
		addi $sp,$sp ,24
		#$v0 has the results
	
		#Use set_slot for rotated-piece struct
		addi $sp,$sp ,-28
		sw $s0, 0($sp)
		sw $s1, 4($sp)
		sw $s2, 8($sp)
		sw $s3, 12($sp)
		sw $s4, 16($sp)
		sw $s5, 20($sp)
		sw $ra, 24($sp)
	
		move $a0, $s2 # Base
		move $a1, $s5  #Row(i) 
		move $a2, $s6  # Column(j)
		move $a3, $v0 
		jal set_slot

		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $ra, 24($sp)
		addi $sp,$sp ,28
	
		beq $s5, $s4, reset_column_new
		addi $s5,$s5,1 #increment the rows
		j check_org
	reset_column_new:
		li $s5, 0
		addi $s6, $s6, -1
	check_org:
		beq $t6, $s4,reset_column_org
		addi $t6, $t6,1
		addi $t8,$t8 ,-1
		j rotate_all
	reset_column_org:
		li $t6,0 # column
		addi $t5,$t5,1 #row 
		addi $t8,$t8 ,-1
		j rotate_all
move_piece_to_struct:
	move $t1, $s0
	move $t2, $s2
	li $t8, 8
move_piece_to_struct_runner:
	beqz $t8, repeat_rotations
	lbu $t3, 0($t1)
	lbu $t3, 0($t2)
	sb $t3 ,($t1)
	addi $t1,$t1,1 
	addi $t2,$t2,1 
	addi $t8,$t8,-1
	j move_piece_to_struct_runner
repeat_rotations:
	addi $t7, $t7, -1   #Account for the number of rotations
	j rotations_90_2
#Perform rotation for all others(3,2 )
rotations_90_2:
	beqz $t7 ,finished_rotation
	# Keep track of rows and columns using $t5,$t6(Get)
	li $t5,0
	li $t6,0
	#Use Get_slot for piece struct
	li $t8, 6
	lbu $s3, 0($s0) #**
	lbu $s4, 1($s0)
	li $s5, 0 #Row of manipulated rotated piece**
	addi $s6, $s3,-1 #Column of manipulated rotated piece
	#Swap the rows and columns
	move $t0,$s3
	move $s3,$s4
	move $s4,$t0
	
	sb $s3,0($s2)
	sb $s4,1($s2)
	addi $s7, $s3  ,-1  
	rotate_all2:
		beqz $t8, move_piece_to_struct		
		addi $sp,$sp ,-24
		sw $s0, 0($sp)
		sw $s1, 4($sp)
		sw $s2, 8($sp)
		sw $s3, 12($sp)
		sw $s4, 16($sp)
		sw $ra, 20($sp)
	
		move $a0, $s0
		move $a1, $t5 # Keep track of rows
		move $a2, $t6 # Keep track of columns
		jal get_slot
	
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $ra, 20($sp)
		addi $sp,$sp ,24
		#$v0 has the results
	
		#Use set_slot for rotated-piece struct
		addi $sp,$sp ,-28
		sw $s0, 0($sp)
		sw $s1, 4($sp)
		sw $s2, 8($sp)
		sw $s3, 12($sp)
		sw $s4, 16($sp)
		sw $s5, 20($sp)
		sw $ra, 24($sp)
	
		move $a0, $s2 # Base
		move $a1, $s5  #Row(i) 
		move $a2, $s6  # Column(j)
		move $a3, $v0 
		jal set_slot

		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $ra, 24($sp)
		addi $sp,$sp ,28

		beq $s5, $s7, reset_column_new2
		addi $s5,$s5,1 #increment the rows
		j check_org2
	reset_column_new2:
		li $s5, 0
		addi $s6, $s6, -1
	check_org2:
		beq $t6, $s7,reset_column_org2
		addi $t6, $t6,1
		addi $t8,$t8 ,-1
		j rotate_all2
	reset_column_org2:
		li $t6,0 # column
		addi $t5,$t5,1 #row 
		addi $t8,$t8 ,-1
		j rotate_all2

move_piece_to_struct2:
	move $t1, $s0
	move $t2, $s2
	li $t8, 8
move_piece_to_struct_runner2:
	beqz $t8, repeat_rotations2
	lbu $t3, 0($t1)
	lbu $t3, 0($t2)
	sb $t3 ,($t1)
	addi $t1,$t1,1 
	addi $t2,$t2,1 
	addi $t8,$t8,-1
	j move_piece_to_struct_runner2
repeat_rotations2:
	addi $t7, $t7, -1   #Account for the number of rotations
	j rotations_90
finished_rotation:
	move $v0, $s1  # Returns the number of rotations
	j rotate_tangent	
classified_I:
	move $v0, $s1 #return the number of rotations
	#$s3 and $s4 contains the row and columns
	#use $t0 to alternate between the two
	
	switch_numbers:
		beqz $t7, store_rotated_piece
		#swapping numbers
		move $t0,$s3
		move $s3,$s4
		move $s4,$t0
		addi $t7,$t7,-1
		j switch_numbers
	store_rotated_piece:
		li $t9, 6
		#Store the rows($s3)
		lbu $t2, 0($s2)
		sb $s3,($s2)
		addi $s2, $s2, 1
		#Store the rows($s4)
		lbu $t2, 0($s2)
		sb $s4,($s2)
		addi $s2, $s2, 1
		move $t0, $s0
		store_rotated_piece_runner:
			beqz $t9, rotate_tangent
			lbu $t1 ,2($t0)
			lbu $t2, 0($s2)
			sb $t1, ($s2)
			addi $s2,$s2, 1
			addi $t0,$t0, 1
			addi $t9, $t9,-1 
		j store_rotated_piece_runner
classified_O:
	move $v0, $s1
	li $t9, 8
	move $t0, $s0
	move_O:
		beqz $t9, rotate_tangent
		lbu $t1 ,0($t0)
		lbu $t2, 0($s2)
		sb $t1, ($s2)
		addi $s2,$s2, 1
		addi $t0,$t0, 1
		addi $t9, $t9,-1 
		j move_O
initialize_invalid_5:
	li $v0 ,-1
rotate_tangent:
    #Temporaryily store the $s0
    move $t1, $s0
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $s6, 24($sp)
    lw $s7, 28($sp)
    #Row 
    lb $t0, 32($sp)
    sb $t0, 0($t1)
    #Column
    lw $t0, 36($sp)
    sb $t0, 1($t1 )
    # 'O's and '.'s
    #Number 1 
    lw $t0, 40($sp)
    sb $t0, 2($t1 )
    #Number 2 
    lw $t0, 44($sp)
    sb $t0, 3($t1 )
   #Number 3 
   lw $t0, 48($sp)
   sb $t0, 4($t1 )
   #Number 4 
   lw $t0, 52($sp)
   sb $t0, 5($t1)
   #Number 5 
   lw $t0, 56($sp)
   sb $t0, 6($t1)
   #Number 6 
   lw $t0, 60($sp)
   sb $t0, 7($t1)
   addi $sp, $sp ,64
   jr $ra

count_overlaps:
	addi $sp, $sp ,-28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	
	move $s0, $a0 #adress of state
	move $s1, $a1 # row 
	move $s2, $a2 # column 
	move $s3, $a3 # address of Piece struct
	
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $ra, 20($sp)
	
	move $a0, $s0 
	move $a1, $s1 
	move $a2, $s2
	jal get_slot
		
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 24
	
	li $t0, -1
	beq $v0, $t0, initialize_invalid_6
	li $t9, 0 #count the number of overlaps
	
	# Obtain the number of rows
	lbu $t0, 0($s3)
	move $s4 ,$t0  # $s4 stores the number of rows of $s3 

	# Obtain the number of columns
	lbu $t0, 1($s3)
	move $s5 ,$t0 # $s5 stores the number of columns of $s3
	
	#Check the bounds
	lbu $t0,0($s0) #Rows of $s0
	lbu $t1,1($s0) #columns of $s0
	
	add $t2,$s1, $s4 
	add $t3,$s2, $s5 
	
	mult $s4,$s5
	mflo $s6
	
	blt $t0, $t2,initialize_invalid_6
	blt $t1, $t3,initialize_invalid_6
	
I_and_O_block:
	#Adjust to obtain
	addi $s4, $s4, -1 
	addi $s5, $s5, -1 
	li $t2, 0   # Keep track of rows 
	li $t3, 0  # Keep track of columns
	li $t4 ,0 # Sum of rows(parameter)
	li $t5, 0 # Sum of columns(parameter)
	#Number  of iterations to check for overlaps
	check_overlap_loop:
		beqz $s6, return_overlaps
		addi $sp, $sp, -24
		sw $s0, 0($sp)
		sw $s1, 4($sp)
		sw $s2, 8($sp)
		sw $s3, 12($sp)
		sw $s4, 16($sp)
		sw $ra, 20($sp)
		
		add $t4, $t2, $s1
		add $t5, $t3, $s2
		move $a0, $s0 
		move $a1, $t4
		move $a2, $t5
		jal get_slot
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $ra, 20($sp)
		addi $sp, $sp, 24
		#$v0 contains the contents at that position
		li $t0, 'O'
		bne $t0, $v0, cont_check_loop
		
		lbu $t0, 2($s3)
		beq $v0, $t0, iterate_overlaps#Check if 'O'
	cont_check_loop:
		beq $s5, $t3, next_row3
		addi $t3 ,$t3, 1 
	default:
		addi $s6,$s6, -1 
		addi $s3,$s3, 1
		j check_overlap_loop
return_overlaps:
	move $v0, $t9
	j count_overlaps_tangent
iterate_overlaps:
	addi $t9,$t9,1 
	j cont_check_loop
next_row3:
	addi $t2, $t2, 1 #Obtain the next row
	li $t3, 0	# Reset columns
	j default
initialize_invalid_6:
	li $v0 ,-1
count_overlaps_tangent:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 28
	jr $ra

drop_piece:
	lw $t0 ,0($sp) # contains the rotated piece
	addi $sp, $sp ,-32
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16 ($sp)
	sw $s5, 20 ($sp)
	sw $s6, 24 ($sp)
	sw $s7 28 ($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	move $s4, $t0
	
	bltz $s3, initialize_invalid_7.2 # Check rotation is not neg
	bltz $s1, initialize_invalid_7.2 # Check the column is not neg
	
	#Check the cols
	lbu $t0, 1($s0)
	bge $s1,$t0 ,initialize_invalid_7.2
	
	#Rotate the piece times
	addi $sp, $sp -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $ra, 20($sp)
	
	move $a0, $s2 
	move $a1, $s3 
	move $a2, $s4 
	jal rotate 
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp 24

	#$v0 contains the num of rotations

	#Check for row overlap
	lbu $t0, 0($s0) 
	lbu $t1, 0 ($s4)
	blt $t0, $t1 initialize_invalid_7.3
	
	#Check for column overlap
	lbu $t0, 1($s0) # $t0 contains columns from state.field
	lbu $t1, 1 ($s4) # $t0 contains columns from rotated piece
	#$s1 contains the starting end column
	add $t1,$t1, $s1
	blt $t0, $t1 initialize_invalid_7.3
	
	
#Try to fit piece into state.field	
	li $s5, 0
	li $s6,0  #Start with column 0 of piece
	li $s7, 1 # Check if  count_overlap is 0; else exit out of loop
check_row:
	beqz $s7, check_piece_doesnt_fit
	addi $sp, $sp -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $ra, 24($sp)
	
	add $s6, $s6, $s1
	move $a0, $s0 
	move $a1, $s5 # Row 
	move $a2, $s6 # Column
	move $a3, $s4 
	jal count_overlaps 
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp 28
	#$v0 contains the results
	addi $s7,$s7,-1
	j check_row
check_piece_doesnt_fit:
	bgtz $v0, initialize_invalid_7.1
	#Piece fits without overlap
check_other_rows:
	li $s5, 1
	li $s6,0  #Start with column 0 of piece	
	li $s7, 0
	lbu $t4, 0($s0)#Number of Rows 
	sub $t4, $t4 ,$s5 # Subtract 1 from the rows(state.rows)
	lbu $t5, 0($s4)
	sub $t5, $t5 ,$s5
	move $t6,$t5
	check_next_rows:
		move $t5,$t6
		bgtz $s7, update_into_real_state
		beq $s5, $t4, update_into_real_state # Check that it doesn't go beyond rows
		#Check that piece still fits in the field
		add $t5, $t5, $s5
		bgt $t5,$t4, update_into_real_state
		addi $sp, $sp -36
		sw $s0, 0($sp)
		sw $s1, 4($sp)
		sw $s2, 8($sp)
		sw $s3, 12($sp)
		sw $s4, 16($sp)
		sw $s5, 20($sp)
		sw $s6, 24($sp)
		sw $t4, 28($sp)
		sw $ra, 32($sp)
	
		add $s6, $s6, $s1
		move $a0, $s0 
		move $a1, $s5 # Row 
		move $a2, $s6 # Column
		move $a3, $s4 
		
		jal count_overlaps 
	
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $t4, 28($sp)
		lw $ra, 32($sp)
		addi $sp, $sp, 36
		#$v0 contains the results
		move $s7,$v0
		bgtz $s7, check_next_rows
		addi $s5,$s5,1 
		j check_next_rows
#Rerun the row # that piece rested		
update_into_real_state:	
	#$s5 contains the rows 
	#Subtract to find the row that doesn't overlap
	addi $s5,$s5,-1
	move $s6,$s5
	li $s7,6
	
	li $t1, 3
	lbu $t0, 0($s4)
	beq $t0, $t1, major_block_condition
	lbu $t0, 1($s4)
	beq $t0, $t1, major_block_condition

I_O_block_condition:
	addi $s7, $s7,-2
major_block_condition:
	# $s1 contains the column
	li $t0, 0 #Keep track of the row
	li $t1, 0 #Keep track of the columns
replace_next_content:
 	beqz $s7, return_last_row	
	addi $sp, $sp -32
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $t0, 20($sp)
	sw $t1, 24($sp)
	sw $ra, 28($sp)
	
	move $a0, $s4 
	move $a1, $t0 
	move $a2, $t1 
	jal get_slot 
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $t0, 20($sp)
	lw $t1, 24($sp)
	lw $ra, 28($sp)
	addi $sp, $sp 32
	#$v0 contains the character found
	li $t9,'.'
	beq $t9, $v0, cont
	
	#Set_slot
	addi $sp, $sp -36
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $t0, 24($sp)
	sw $t1, 28($sp)
	sw $ra, 32($sp)
	
	add $t0, $t0, $s5
	add $t1, $t1, $s1
	move $a0, $s0 
	move $a1, $t0
	move $a2, $t1 
	move $a3, $v0 
	jal set_slot 
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $t0, 24($sp)
	lw $t1, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp 36

cont:
	lbu $t2, 1($s4)
	addi $t2 ,$t2 -1 
	bne $t2, $t1, not_end_of_col
	addi $t0, $t0, 1 
	li $t1, 0
	j repeat_for_next
not_end_of_col:
	addi $t1,$t1,1
repeat_for_next:
	addi $s7,$s7,-1
	j replace_next_content
	
return_last_row: #No overlaps; floats to the bottom
	move $v0, $s6
	j drop_piece_tangent
initialize_invalid_7.1: # out of bounds
	li $v0 ,-1
	j drop_piece_tangent
initialize_invalid_7.2: # rotation is negative or col is neg
	li $v0 ,-2
	j drop_piece_tangent
initialize_invalid_7.3:
	li $v0 ,-3
drop_piece_tangent:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	addi $sp, $sp,32
	jr $ra

check_row_clear:
	addi $sp, $sp, -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	
	move $s0, $a0 # address of GameState struct
	move $s1 ,$a1 #row being checked
	
	lbu $s2, 0($s0)  # $s2 stores the rows
	lbu $s3, 1($s0)# $s3 stores the columns

	bge $s1, $s2,initialize_invalid_8 #Check whether row is valid
	
	li $s4, 0 # count the columns based on $s3 
check_process_row:	
	beq $s3, $s4, manipulate_rows
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $ra, 20($sp)
	
	move $a0 ,$s0
	move $a1, $s1
	move $a2, $s4
	jal get_slot
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 24
	
	li $t9, 'O'
	#$v0 returned the character result
	bne $t9, $v0, not_removed_row
	addi $s4 , $s4 ,1 
	j check_process_row 
manipulate_rows:
	addi $s5, $s1, -1 # Contains the new row to replace
	move $s6,$s1 #Track the original row
	replace_row:
		bltz $s5, replace_first_row
		li $s4, 0# Count the number of columns
		substitute_element_row:
			beq $s4, $s3, finished_with_row
			# Shift everything down one row
			#**************Get the element****************
			addi  $sp, $sp,-24
			sw $s0, 0($sp)
			sw $s1, 4($sp)
			sw $s2, 8($sp)
			sw $s3, 12($sp)
			sw $s4, 16($sp)
			sw $ra, 20($sp)
	
			move $a0 ,$s0 # Contains the address of struct
			move $a1, $s5
			move $a2, $s4
			jal get_slot
	
			lw $s0, 0($sp)
			lw $s1, 4($sp)
			lw $s2, 8($sp)
			lw $s3, 12($sp)
			lw $s4, 16($sp)
			lw $ra, 20($sp)
			addi $sp, $sp, 24
			
			move $t9,$v0
			#*****************Set the element***********
			addi  $sp, $sp, -28
			sw $s0, 0($sp)
			sw $s1, 4($sp)
			sw $s2, 8($sp)
			sw $s3, 12($sp)
			sw $s4, 16($sp)
			sw $s5, 20($sp)
			sw $ra, 24($sp)
	
			move $a0, $s0
			move $a1, $s6
			move $a2, $s4
			move $a3, $t9
			jal set_slot
		
			lw $s0, 0($sp)
			lw $s1, 4($sp)
			lw $s2, 8($sp)
			lw $s3, 12($sp)
			lw $s4, 16($sp)
			lw $s5, 20($sp)
			lw $ra, 24($sp)
			addi $sp, $sp, 28
			
			addi $s4 ,$s4, 1
			j substitute_element_row
	finished_with_row:
		addi $s5, $s5, -1
		addi $s6, $s6, -1
		j replace_row	
replace_first_row:	
	li $t9, '.'
	li $s4, 0 # Count the number of columns
	addi $s6,$s3, -1 
replace_with_dot:
	beq $s4, $s6, removed_row
	addi $sp, $sp, -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $ra, 24($sp)
	
	li $t0,0 #Set to 0 
	move $a0 ,$s0
	move $a1, $t0  #ROW 
	move $a2, $s4  # COLUMNs
	move $a3, $t9
	jal set_slot
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
	
	addi $s4 ,$s4 ,1 
	j replace_with_dot
removed_row:
	li $v0, 1 
	j check_row_clear_tangent
not_removed_row:
	li $v0, 0 
	j check_row_clear_tangent	
initialize_invalid_8:
	li $v0 ,-1	
check_row_clear_tangent:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 28
	jr $ra
	
simulate_game:	
	#$t0(32($sp) &&$t0(36($sp)) 
	addi $sp, $sp,-32
	sw $s0, 0($sp)
	sw $s1, 4($sp) 
	sw $s2, 8($sp)  
	sw $s3, 12($sp) 
	sw $s4, 16($sp) 
	sw $s5, 20($sp) 
	sw $s6, 24($sp) 
	sw $s7, 28($sp) 
	
	move $s0, $a0 
	move $s1, $a1
	move $s2, $a2 
	move $s3, $a3 

	#Initialize the game
	addi $sp, $sp, -20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	
	move $a0 ,$s0 
	move $a1 ,$s1
	jal load_game 
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20

	#Load Game(-1,-1)
	li $t0, -1 
	beq $t0 ,$v0, before_read_file
	j read_file
before_read_file:
	beq  $t0, $v1, simulate_results
read_file:
	li $s4,0  #number_successful drops
	li $s5,0  #move_number(number of pieces we have attempted to drop so far)

	#Find the move length
	move $t1, $s2 
	li $t3 ,0#Count the length of the string
move_length:
	lbu $t0,0($t1)
	beqz $t0, found_length
	addi $t3 ,$t3 ,1 
	addi $t1, $t1, 1 
	j move_length
found_length:	
	li $t9, 4
	div $t3,$t9
	mflo $s6   #moves_length

	li $s7, -1  #-1 represents False
	li $t9, 0 #Score
	
continue_game:	
	beqz $s7, condition2  #0 means game over; -1 means not game over
	lbu $t0, 32($sp)
	bgt $s5,$t0,end_game 
	j keep_playing_tetris
condition2:
	lbu $t0, 32($sp)
	bgt $s4,$t0, condition3
	addi $s4, $s4,1
	j keep_playing_tetris
condition3:
	bgt $s5,$s6, end_game
keep_playing_tetris:
	# extract the next piece, column and rotation from the string
	lbu $t3, 0($s2)#piece_type
	lbu $t4, 1($s2)#rotation
	addi $t4,$t4, -48
	
	lbu $t5, 2($s2)#column bit 1
	addi $t5,$t5, -48
	
	lbu $t6, 3($s2)#column bit 2 
	addi $t6,$t6, -48
	
	li $t0, 10
	mult $t5, $t0 
	mflo $t5
	add $t5,$t5,$t6
	
	li $t6, -1 #invalid
	addi $s2 ,$s2, 4
	#t3 stores the new piece
	#$t0 has the starting address of pieces
	lw $t0, 36($sp) # Load the instructions
	move $t2, $t0
	li $t1, 'T'
	beq $t1,$t3,T_instruction
	li $t1, 'J'
	beq $t1,$t3,J_instruction
	li $t1, 'Z'
	beq $t1,$t3,Z_instruction
	li $t1, 'O'
	beq $t1,$t3,O_instruction
	li $t1, 'S'
	beq $t1,$t3,S_instruction
	li $t1, 'L'
	beq $t1,$t3,L_instruction
	#I_instruction
	addi $t2, $t2, 48   
	j attempt_to_drop
T_instruction:
	j attempt_to_drop
J_instruction:
	addi $t2, $t2, 8
	j attempt_to_drop
Z_instruction:
	addi $t2, $t2, 16
	j attempt_to_drop
O_instruction:
	addi $t2, $t2, 24
	j attempt_to_drop
S_instruction:
	addi $t2, $t2, 32
	j attempt_to_drop
L_instruction:
	addi $t2, $t2, 40
	j attempt_to_drop
attempt_to_drop:
	move $t0,$s3
	# attempt to drop the piece
	addi $sp,$sp, -44
	sw $t0, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	sw $t9, 36($sp)
	sw $ra, 40($sp)
	
	move $a0, $s0
	move $a1, $t5	
	move $a2, $t2
	move $a3, $t4
	jal drop_piece
	
	lw $t0, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	lw $t9, 36($sp)
	lw $ra, 40($sp)
	addi $sp,$sp, 44
	move $t1, $v0  #Change back to $v0 *********************

	#$v0 contains the results
	li $t0, -2
	beq $t0, $t1 , invalid_true
	li $t0, -3
	beq $t0, $t1 , invalid_true
	li $t0, -1
	beq $t0, $t1 , game_over_true
	j check_clear_line
invalid_true:
	li $t6,0 #Set invalid to true
	addi $s5, $s5, 1
	j continue_game
game_over_true:
	li $s6, 0#Set invalid to true
	li $s7, 0#Set game_over to true
# check for line clears by starting at the 
# top of the game field and working our way down
check_clear_line:	
	li $t7,0 #Count 
	lbu $t0 ,0($s0)
	addi $t8, $t0, -1   #row _counter
row_counter_greater:
	bltz $t8, update_score
	#*********Call check_row_clear*************
	addi $sp, $sp,-36
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $t9, 28($sp)
	sw $ra, 32($sp)
	
	move $a0,$s0
	move $a1,$t8
	jal check_row_clear
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $t9, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36
	#$v0 contains the results
	li $t0, 1 
	beq $v0, $t0,increment_count
	addi $t8,$t8,-1
	j row_counter_greater
increment_count:
	addi $t7,$t7,1 
	j row_counter_greater
update_score:	

	#Update the score
	li $t0, 1 
	beq $t7,$t0,increment_40 #Add 40 to score
	li $t0, 2 
	beq $t7,$t0,increment_100#Add 100 to score
	li $t0, 3
	beq $t7, $t0,increment_300 #Add 300 to score
	li $t0, 4
	beq $t7, $t0,increment_1200 #Add 1200 to score
increment:

	#Increment the counters
	addi $s5, $s5, 1
	addi $s4, $s4, 1
	j continue_game
end_game:
	move $v0, $s4# Store the number of sucessful drops
	move $v1 ,$t9 # Store the total sum of points 
	j simulate_game_tangent
simulate_results:
	li $v0,0
	li $v1,0
	j simulate_game_tangent
increment_40:
	addi $t9, $t9, 40
	j increment
increment_100:
	addi $t9, $t9, 100
	j increment
increment_300:
	addi $t9, $t9, 300
	j increment
increment_1200:
	addi $t9, $t9, 1200
	j increment
initialize_invalid_9:
	li $v0 ,-1 
simulate_game_tangent:
	lw $s0, 0($sp)
	lw $s1, 4($sp) 
	lw $s2, 8($sp)  
	lw $s3, 12($sp) 
	lw $s4, 16($sp) 
	lw $s5, 20($sp) 
	lw $s6, 24($sp) 
	lw $s7, 28($sp) 
	addi $sp, $sp,32
	jr $ra

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
