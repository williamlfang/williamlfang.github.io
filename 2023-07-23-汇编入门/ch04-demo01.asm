.global _start
.section .text

_start:
                        ## rdi      ## rax
    movq $3, %rdi       ## 3
    movq %rdi, %rax                 ## 3
    add %rdi, %rax                  ## 3+3=6
    mulq %rdi                       ## 3*6=18
    subq %rdi, %rax                 ## 18-3=15
    divq %rdi                       ## 15/3=5
    movq %rax, %rdi     ## 5

    ## -------------
    movq $60, %rax
    syscall

