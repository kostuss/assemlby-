## zad 7 
.data 

zapytanie: 	.asciiz "\n Podaj sekwencje znakow: \n" 
ktory:		.asciiz "\n Od ktorego znaku chcesz usunac?: \n" 
ile:		.asciiz "\n Ile wyrazow chcesz usunac?: \n" 
blad:		.asciiz "\n Podane argumenty nie sa prawidlowe. \n" 
string: 	.space 64

.text 

main: 
	#wczytanie wartosci
	li $v0, 4 
	la $a0, zapytanie 
	syscall 
	
	li $v0, 8
	la $a0, string 
	li $a1, 64 
	syscall 
	
	li $v0, 4 
	la $a0, ktory 
	syscall 
	
	li $v0, 5 
	syscall
	add $t1, $v0,0  #t1 od ktorego znaku zaczac 
	
	li $v0, 4 
	la $a0, ile 
	syscall 
	
	li $v0, 5
	syscall
	add $t2, $v0, 0 #t2 ile znakow usunac 
	
	j checkloop
	
	
checkloop: 

	lb $s1, string($t9)  #t9 liczba elementow w stringu 
	beqz $s1, check 
	add $t9, $t9, 1 
	
	j checkloop
	
check: 	
	add $t9, $t9,-1
	add $t3, $t2, $t1  #t3 koncowy element do usuniecia 
	add $t3, $t3, -1
	bgt $t3, $t9, error 
	
	add $t5, $t1, -1 
	add $t6, $t5, $t2
	add $t6, $t6, -1
	
	j mainloop
	
mainloop: 

	#t4 licznik glownej petli 
	#t5 numer od ktorego zaczac usuwanie 
	#t6 numer na ktorym skonczyc usuwanie 
	#t7 licznik koncowego stringa 
	
	beq $t4, $t5, usuwanie 
	lb $s2, string($t4) 
	beqz $s2, exit
	sb $s2, string($t7)
	add $t4, $t4, 1 
	add $t7, $t7, 1 
	j mainloop 
	
	
	
usuwanie:  
	
	add $t4, $t4,1 
	bgt $t4, $t6, mainloop 
	
	j usuwanie
		
	
error : 
	li $v0, 4 
	la $a0, blad 
	syscall 
	
	li $v0, 10 
	syscall 


exit: 
	lb $s2, string($t7) 
	beqz $s2, exit1 
	sb $zero, string($t7) 


exit1:

	li $v0, 4 
	la $a0, string
	syscall 

	li $v0, 10
	syscall 
	
	