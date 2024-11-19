    .text           @ code block start
    .align 2        @ Izlīdzīna 8 byte bloku
    .global asum    @ global asum

asum:
    CMP r0, #1      @ Compare n with 1
    BLT error       @ If n < 1, go to error

    MOV r1, #0      @ sum = 0
    MOV r2, #1      @ i = 1

loop:
    ADDS r1, r1, r2     @ sum += i, sets flags
    BVS overflow        @ If overflow (V flag set), go to overflow
    ADD r2, r2, #1      @ i++
    CMP r2, r0          @ Compare i with n
    BGT done            @ If i > n, go to done
    B loop              @ Repeat loop

done:
    MOV r0, r1      @ Return sum in r0
    BX lr           @ Return

error:
    MOV r0, #0      @ Return 0
    BX lr           @ Return

overflow:
    MOV r0, #0      @ Return 0 in case of overflow
    BX lr           @ Return