    .global _start

_start:
# write(1, message, 13)
# STDOUT FD = 1
    addi    a7, zero, 64
    addi    a0, zero, 1

# message
    la      a1, helloworld
    addi    a2, zero, 13
    ecall

# exit(0)
    addi    a7, zero, 93
    addi    a0, zero, 13
    ecall

helloworld:
    .string "Hello World!\n"
