        .text
        .align 2
        .global m1p2
        .type m1p2, %function

@ R0 input N
@ R4 upper limit
@ R5 current number
@ R6 bit count
m1p2:
        PUSH    {R4, R5, R6, LR}     @ Save state
        MOV     R4, R0               @ R4 = N
        MOV     R5, #1               @ Start at 1

loop:
        CMP     R5, R4               @ If R5 > N, exit
        BGT     end

        MOV     R3, R5               @ Copy R5 for bit count
        MOV     R6, #0               @ Reset bit count

count_bits:
        TST     R3, #1               @ Check LSB
        ADDNE   R6, R6, #1           @ Increment count if 1
        MOV     R3, R3, LSR #1       @ Shift R3
        CMP     R3, #0               @ Done?
        BNE     count_bits

        CMP     R6, #3               @ Exactly 3 bits?
        BNE     next

        LDR     R0, =printf_fmt      @ Load format
        MOV     R1, R5               @ Set argument
        BL      printf               @ Print R5

next:
        ADD     R5, R5, #1           @ Next number
        B       loop

end:
        POP     {R4, R5, R6, PC}     @ Restore state

printf_fmt:
        .asciz  "%x\n"               @ Hex format
