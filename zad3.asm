#zadanie 3 odwracanie liczb z ciagu wejsciowego # 
.data 
out_string:	.asciiz "\n Give the input: \n" 
string:		.space 64
output:		.space 64 
reverse:        .space 64

.text
main: 
	#asking for input 
	li $v0, 4 
	la $a0, out_string 
	syscall 
	#reading string 
	li $v0, 8 
	la $a0, string 
	li $a1, 64 
	syscall 
	
	add $t1, $zero, 0 #iterator petli while do wczytywania 
	add $t3, $zero, 0 #iterator do zapisywania cyfr
	
while: 	
	lb $t2, string($t1) 
	beqz $t2, exit1
	
	add $t1, $t1, 1 #zwiekszenie iterator 
	blt $t2, 48, while
	bgt $t2, 57, while
	
	#mam liczbe 
	sb $t2, output($t3)
	add $t3, $t3,1
	j while
	
exit1:	
	add $t4, $t3, -1
	j exitloop

	
exitloop: 

	
	lb $t5, output($t4) 
	sb $t5, reverse($t6) 
	add $t6, $t6,1 
	beq $t6, $t3, exit
	add $t4, $t4, -1
	
	j exitloop
		
exit: 
	#wyisanie odwroconego 
	li $v0, 4 
	la $a0, reverse 
	syscall 
	
	li $v0,10 
	syscall 	
	