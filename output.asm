.text
.globl main
main:
# Função: main
li $t0, 5
sw $t0, -0($sp)
li $t0, 10
sw $t0, -4($sp)
move $t1, $t0
add $t0, $t1, $t0
sw $t0, -12($sp)
sw $t0, -8($sp)
lw $t0, -12($sp)
move $v0, $t0
li $v0, 10
syscall
