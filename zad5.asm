#zadanie 3 odwracanie liczb z ciagu wejsciowego # 
.data 
out_string:	.asciiz "\n Give the input: \n" 
string:		.space 64
output:		.asciiz "\n \n Number of decimal numbers: " 

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
	
	add $t1, $zero, 0 	#iterator petli while do wczytywania 
	add $t3, $zero, 0 	#licznik liczb dziesietnych
	
while: 	
	lb $t2, string($t1) 
	beqz $t2, exit
	
	add $t1, $t1, 1		#zwiekszenie iterator 
	blt $t2, 48, while
	bgt $t2, 57, while
	
	#mam liczbe 
	add $t3, $t3,1
	j loop
	

loop:	
	lb $t2, string($t1)
	beqz $t2, exit 
	add $t1,$t1,1		# zwiekszenie iteratora 
	
	beq $t2, 46, doot
	blt $t2, 48, while 
	bgt $t2, 57, while 	

	j loop 

doot:
	lb $t2, string($t1) 
	beqz $t2, exit 
	add $t1, $t1, 1		# zwiekszenie iteratora 
	
	#jezeli nie liczba po pierwszej kropce 
	blt $t2, 48, while 
	bgt $t2, 57, while 
	
	#jezeli liczba
	j loop

exit: 
	#wyisanie odwroconego 
	li $v0, 4 
	la $a0, output 
	syscall 
	
	li $v0, 1 
	add $a0, $t3, 0
	syscall 	
	
