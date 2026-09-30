    .section .text.start
    .globl _start
_start:
    addi sp, zero, 256
    jal ra, main
completed:
    j completed
