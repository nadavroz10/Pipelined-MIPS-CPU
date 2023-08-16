.data
	i: .word 4
	k: .word 4 
	j: .word 35
.text
lw $1, i
lw $2, 4($1)
xor $2, $2, $1
sw $2, 8($1)
lui $2, 1
or $1, $2, $1
bne $1,$2, next
j failA
failA: ori $27, $26,1
failB: ori $25, $26,1

next: beq $1, $2, failB
move $2, $1
jal nextt

nextt: srl $1,$1,2
srl $1,$1,2
srl $1,$1,2
sll $3, $1, 6
sub $4, $3, $2
add $4, $4, $31
addi $4, $4, 36
jr $4
done: lui $20 , 8
