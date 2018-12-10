.data 

msgIntro:	.asciiz "--- Filtr minimalny bmp ---\n"
msgIn:		.asciiz "Podaj nazwe pliku wejsciowego \n" 
msgOut:		.asciiz "Podaj nazwe pliku wyjsciowego \n" 
msgFrame:	.asciiz "Podaj wielkosc maski do filtru (liczba nieparzysta wieksza od 3): \n" 
msgFileExc:	.asciiz "Blad zwiazany z plikiem\n"
msgFileExc1:	.asciiz "Blad w petli\n"
msgFileExc2:	.asciiz "Plik za duzy\n"

fileNameIn:	.space 128
fileNameOut:	.space 128
buffor: 	.space 6000
buffor_out:	.space 2000
pad:		.space 4

.align 2 
in_descriptor:	.space 4
out_descriptor:	.space 4
header:		.space 100
size_used:	.space 64

.text 
main:
	# wyswietlenie informacji powitalnej:
	la $a0, msgIntro
	li $v0, 4
	syscall
	
	#wczytanie nazwy pliku wejsciowego 
	
	la $a0, msgIn 
	li $v0, 4
	syscall 
	
	li $v0, 8
	la $a0, fileNameIn
	li $a1, 128 
	syscall
	
	# wczytanie nazwy pliku wyjsciowego 
	
	la $a0, msgOut 
	li $v0, 4
	syscall 
	
	li $v0, 8
	la $a0, fileNameOut
	li $a1, 64 
	syscall
	
	#wczytanie wielkosci ramki: 
	
	la $a0, msgFrame 
	li $v0, 4
	syscall 
	
	li $v0, 5 
	syscall
	move $s7, $v0  
	
	subu $s6, $s7, 1 
	sra $s6, $s6, 1 
	
	# remove newline 
	li  $t0, '\n'		
	li  $t1, 128
	li  $t2, 0	
	
		
			
out_remove_newline:
	beqz	$t1, newline_loop_init		# if end of string, jump to remove newline from input string
	subu	$t1, $t1, 1			# decrement the index
	lb	$t2, fileNameOut($t1)		# load the character at current index position
	bne	$t2, $t0, out_remove_newline	# if current character != '\n', jump to loop beginning
	
	li	$t0, 0			
	sb	$t0, fileNameOut($t1) 
	
newline_loop_init:
	li	$t0, '\n'	
	li	$t1, 128# length of the input_file
	li	$t2, 0		
	
newline_loop:
	beqz	$t1, newline_loop_end	# if end of string, jump to loop end
	subu	$t1, $t1, 1			# decrement the index
	lb	$t2, fileNameIn($t1)	# load the character at current index position
	bne	$t2, $t0, newline_loop	# if current character != '\n', jump to loop beginning
	li	$t0, 0			# else store null character
	sb	$t0, fileNameIn($t1) # and overwrite newline character with null
	
newline_loop_end:
		
				
	##########################################################################
	# Registers:
	##########################################################################
	## $s0 --> deskryptor pliku wejsciowego 
	## $s1 --> deskryptor pliku wyjsciowego
	# $s2 --> width
	# $s3 --> height
	# $s4 --> padding 
	# $s5 --> index of the top row in buffer
	# $s6 --> przesuniecie do ramki 
	# 
	# $s0 --> minB
	# $s1 --> minG
	# $s7 --> minR
	##########################################################################
	
	
	li	$v0, 13		# syscall 13, open file
	la	$a0, fileNameIn	# load filename address
	li 	$a1, 0		
	li	$a2, 0		
	syscall
	bltz	$v0, error	# a descriptor error 
	move	$s0, $v0	# save file descriptor
	sw	$s0, in_descriptor
	
	
	li	$v0,	14			# read header of the file
	lw	$a0,	in_descriptor
	la	$a1,	header+2		# header addresses aligend to 4 bytes 
	li	$a2,	54
	syscall
	bne	$v0,	54,	error 
	
	#lw	$t0,	buffor+16
	#bne	$t0,	40,	error	# bitmapinfoheader size error  (should be equal 40)
	
	lw	$s2,	header+20			# width
	lw	$s3,	header+24			# height
	
	#bgt	$s2,	2000,	close_in	# max width error
	lh	$t0,	header+2
	bne	$t0,	0x4D42,	error		# error  (should be equal 'BM' ) 
	lw	$t0,	header+8
	bnez	$t0,	error			# must-be-zero
	
	
	lw	$t8,	header+12			# offset to pixel array
	lw	$a0,	in_descriptor			
	la	$a1,	header+56
	sub	$a2,	$t8,	54		
	li	$v0,	14			# read till the beginning of the pixel array	
	syscall
	
	li	$v0,	13			# outfile
	la	$a0,	fileNameOut
	li	$a1,	1
	li	$a2,	0
	syscall
	sw	$v0,	out_descriptor	# save out_descriptor
	bltz	$v0,	error		
	
	li	$v0,	15		# write header to outputfile 
	lw	$a0,	out_descriptor
	la	$a1,	header+2
	move	$a2,	$t8
	syscall
	bne	$v0,	$t8,	error		# write to file error
		
	mul	$t0,	$s2,	3		# calculate padding
	li	$t1,	4
	div	$t0,	$t1
	mfhi	$s4				# remainder
	beqz	$s4,	check_box_size		
	sub	$s4,	$t1,	$s4		# padding 
	
	
	check_box_size:
	blez	$s7,	quit			# no need to go through the filtering algorithm if the box size is <= 0
	mul	$t0,	$s2,	3
	mul	$t0,	$t0,	$s7
	li	$t1,	6000
	bgt	$t0,	$t1,	error2		# the max box size for a given image is greater than buffer
	
	mul	$t9, 	$s7, 	$s2
	mul 	$t9,	$t9,	3 
	sw  $t9, size_used
 
	li 	$t0,	0
	
read_initial_rows:

	li	$v0,	14			
	lw	$a0,	in_descriptor
	mul	$t1,	$s2,	3
	mul	$t1,	$t1,	$t0		# calculate adress for new row in buffer (3*width)*(index_of_row)
	la	$a1,	buffor($t1)
	mul	$t9,	$s2,	3
	move	$a2,	$t9
	syscall
	
	
	bne	$v0,	$t9,	error		# error
	
	li	$v0,	14			# read padding
	la	$a1,	pad			#useless data 
	move	$a2,	$s4
	syscall
	bne	$v0,	$s4,	error
	
	move	$s5,	$t0			#index of the top row 
	addiu	$t0,	$t0,	1
	blt	$t0,	$s7,	read_initial_rows

	
	
init_filter:	
#####################################################
####### temporary registers of the filter ###########
####### t0 - column index of the current pixel
####### t1 - row index of the current pixel 
####### t2 - minimum column checked in the mask
####### t3 - maximum column checked in the mask 
####### t4 - minimum row checked in the mask 
####### t5 - maximum row checked in the mask 
####### t6 - column index of the current pixel in the loop 
####### t7 - row index of the current pixel in the loop
####### indexing is from 0 
####### t8 - index in buffer 
####### t9 - free register
###################################################
	li	$t0,	0
	li	$t1,	0
	li	$t2,	0
	li	$t3,	0
	li	$t4,	0
	li	$t5,	0
	li	$t6,	0
	li	$t7,	0
	
min_column:
	sub	$t2,	$t0,	$s6
	bgez	$t2,	max_column
	li	$t2,	0
max_column:
	add	$t3,	$t0,	$s6
	blt	$t3,	$s2,	min_row
	subiu	$t3,	$s2,	1
min_row:
	sub	$t4,	$t1,	$s6
	bgez	$t4,	max_row
	li	$t4,	0
max_row:
	add	$t5,	$t1,	$s6
	blt	$t5,	$s3,	set_RGB
	subiu	$t5,	$s3,	1
	
set_RGB: 
	li	$s0,	255   #maxium value of B 
	li	$s1,	255   #maxium value of G 
	li	$s7,	255   #maxium value of R 
	
init_row: 
	move	$t7,	$t4	  
	
init_column:  
	move	$t6,	$t2 
	
### t8 - index of the pixel to read in the buffer 
set_index:
	mulu 	$t9,	$s6,	2
	addu	$t9,	$t9,	1
	div	$t7,	$t9
	mfhi	$t9
	
	mulu 	$t8,	$t9,	$s2
	addu 	$t8, 	$t8, 	$t6
	mulu 	$t8, 	$t8, 	3  
	#lw   	$t9, size_used
	#ge  	$t8, $t9, end_of_buffer1 
	
B:
	lb	$t9,	buffor($t8)
	bge	$t9,	$s0,	G
	move 	$s0,	$t9
G:
	addiu	$t8, 	$t8,	1
	lb	$t9,	buffor($t8)
	bge	$t9,	$s1,	R
	move 	$s1,	$t9 
R:	
	addiu	$t8, 	$t8,	1
	lb	$t9,	buffor($t8)
	bge	$t9,	$s7,	next_in_loop
	move 	$s7,	$t9
	
	
next_in_loop:
	addiu	$t6,	$t6,	1			
	addiu	$t8,	$t8,	1	
	ble	$t6,	$t3,	B    	# stay in the same row 
	addiu	$t7,	$t7,	1
	lw 	$t9,	size_used
	bge 	$t8, 	$t9, 	end_of_buffer
	
next_row_in_loop:
	ble	$t7,	$t5,	init_column  # change row and init column index 

save_pixel:
	mul	$t8,	$t0,	3     # calculate place for saving in out buffer  
	sb	$s0,	buffor_out($t8)
	addiu	$t8, 	$t8,	1	
	sb	$s1,	buffor_out($t8)
	addiu	$t8, 	$t8,	1	
	sb	$s7,	buffor_out($t8)

move_to_next_column_index:
	addiu	$t0,	$t0,	1	# column's index ++ ; if < width then  row's index stay the same
	blt	$t0,	$s2,	min_column
	
	# we filtered the whole line and now we need to save output and go to the next row
	# we nedd to add the padding to the output
	move 	$t9,	$s4 # iterator for padding loop
	
add_padding: 
	
	beqz $t9, write_to_file 
	sb $zero, buffor_out($t8)
	subiu $t9, $t9, 1 
	j add_padding

	#write to the file 	
write_to_file:	
	
	li	$v0,	15
	lw	$a0,	out_descriptor
	la	$a1,	buffor_out
	mulu	$a2,	$s2,	3
	addu	$a2,	$a2,	$s4   #add padding 
	syscall
	bltz	$v0,	quit	# error
	
	# move to the next row 
	addiu	$t1,	$t1,	1
	li 	$t0,	0
	mulu    $t9,	$s6,	2
	addu	$t9,	$t9,	1
	blt 	$t1, 	$t9, 	min_column 	#no need to load new row of pixels 
	
	# we need to load new row of pixels 
	addu	$s5,	$s5, 	1 	#index of the highest row in buffor increased 
	###### end #####
	beq	$t1,	$s3,	quit	# end of the program with s5 top row index 
	###### end #####
					
	
	# calculate place for inserting 
	mul 	$t9,	$s6,	2
	addu	$t9,	$t9,	1
	div 	$t4,	$t9
	mfhi 	$t8
	mul	$t8,	$t8,	3
	mul	$t8,	$t8,	$s2
		
	mul 	$t9,	$s2,	3	
	
	li	$v0,	14			# read row data
	lw	$a0,	in_descriptor
	la	$a1,	buffor($t8)
	move	$a2,	$t9
	syscall
	bne	$v0,	$t9,	error1			# error
	
	li	$v0,	14				# read padding
	lw	$a0,	in_descriptor
	la	$a1,	pad				#useless data 
	move	$a2,	$s4
	syscall
	bne	$v0,	$s4,	error1			# error
	
	j	min_column					# on to the next line
	
	
	quit:

	li	$v0,	16			# close outfile
	lw 	$a0,  	out_descriptor	
	syscall
	
	li	$v0,	16			# close infile
	lw 	$a0,	in_descriptor
	syscall
	
	li	$v0,	10			# exit
	syscall	 
	
end_of_buffer: 

	li $t8, 0 
	j next_row_in_loop			

#end_of_buffer1: 

#	div $t8, $t9 
#	mfhi $t8
#	j B
error: 
	la $a0, msgFileExc
	li $v0, 4
	syscall
	li	$v0,	10			# exit
	syscall	 
	
error1: 
	la $a0, msgFileExc1
	li $v0, 4
	syscall
	li	$v0,	10			# exit
	syscall	 

error2: 
	la $a0, msgFileExc2
	li $v0, 4
	syscall
	li	$v0,	10			# exit
	syscall	 
