.data     
## Data declaration section
out_string:		.asciiz   "\nGive a input:\n"
my_string: 		.space 64 
buffer:			.space 32
.text     
## Assembly language instructions go in text segmen
main:       
	#asking for input
	li $v0, 4
	la $a0, out_string
	syscall
	
	
	#reading input 
	li $v0, 8
	la $a0, my_string  #string 
	li $a1, 64 
	syscall
	
	la $t2, my_string 
	lb  $t1, my_string($t4)
	
	add $a0, $t1, 0  
	li $v0, 1 
	syscall 
	
	
	