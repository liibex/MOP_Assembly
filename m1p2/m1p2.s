        .text
        .align 2
        .global m1p2
        .type m1p2, %function

@ m1p2(int N)
@ Finds and prints special numbers with exactly three 1-bits in the range 1 to N.

@ R0 - Used for `printf` format string (temporary)
@ R1 - Used for `printf` argument (current number to print)
@ R4 - Stores the upper limit N (passed as parameter)
@ R5 - Loop counter, the current number being checked
@ R6 - Bit count (number of 1-bits in the binary representation of R5)
@ R3 - Temporary register for bit manipulation during count

m1p2:
        PUSH    {R4, R5, R6, LR}     @ Save LR, R4 (for N), R5 (loop counter), and R6 (bit count)

        MOV     R4, R0               @ Store N in R4 (the upper limit)
        MOV     R5, #1               @ Initialize loop counter (1 to N)

loop:
        CMP     R5, R4               @ Check if counter <= N (stored in R4)
        BGT     end                  @ Exit if counter > N

        MOV     R3, R5               @ Copy loop counter to R3 for bit counting
        MOV     R6, #0               @ Reset bit count

count_bits:
        TST     R3, #1               @ Test if LSB is 1
        ADDNE   R6, R6, #1           @ If so, increment bit count
        MOV     R3, R3, LSR #1       @ Logical shift right by 1
        CMP     R3, #0               @ Check if R3 is zero
        BNE     count_bits           @ Repeat if more bits to check

        CMP     R6, #3               @ Check if bit count is exactly 3
        BNE     next                 @ If not, go to next number

@ Print special number in hex
        LDR     R0, =printf_fmt      @ Load address of format string into R0
        MOV     R1, R5               @ Move the current number to R1 for printing
        BL      printf               @ Call printf (R0 = format, R1 = number)

next:
        ADD     R5, R5, #1           @ Increment loop counter
        B       loop                 @ Repeat loop

end:
        POP     {R4, R5, R6, PC}     @ Restore registers and return

printf_fmt:
        .asciz  "%x\n"               @ Format string for printf (hexadecimal)
