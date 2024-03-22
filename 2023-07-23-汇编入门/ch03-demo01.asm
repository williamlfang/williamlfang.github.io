.global _start

_start:
    movq $60, %rax
    movq $123, %rdi
    syscall
