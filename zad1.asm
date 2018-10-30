.data 

question_string:   .asciiz "\nGive a number: " 

.text 
	# asking for number 
	li $v0, 4 
	la $a0, question_string 
	syscall 
	
	#reading number 
	li $v0, 5 
	syscall 
	
	#saving number 
	add $s1, $v0, 0 
	
	li  $v0, 1 
	add  $a0, $s1, 0
	syscall

	
	li $v0, 10 
	syscall 