.data 
	mat1: .word 1 ,2 ,3,4, 5, 6, 7, 8,9,10,11,12, 13,14,15,16
	mat2: .word 13 ,14 ,15,16, 9, 10, 11, 12,5,6,7,8, 1,2,3,4
	resMat: .space 64
.text
slti $1, $0, 1
move $7, $0 #index
move $6, $0 #sum
lw $8, mat1($7)
lw $9, mat2($7)
addi $11, $0, 16 # loop index
LOOP: beq $11, $0 END
add $10, $8, $9
sw $10, resMat($7)
sub $11, $11, $1
addi $7, $7, 4
lw $8, mat1($7)
lw $9, mat2($7)
j LOOP

END: add $16, $0, $0
