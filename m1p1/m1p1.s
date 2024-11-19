        .text
        .align 2
        .global m1p1
        .type m1p1, %function

@ R0 buffer
@ R4 first flag
@ R5 current character
m1p1:
        PUSH    {R4, R5, LR}
        MOV     R4, #1                  @ R4 = 'first' flag, 1=true

loop:
        LDRB    R5, [R0]                @ Load character to R5
        CMP     R5, #0                  @ end of string?
        BEQ     end                     @ Exit

check_first:
        CMP     R4, #1                  @ If first == true
        BNE     not_first

first:
        CMP     R5, #'a'
        BLT     skip_case_change        @ < 'a'
        CMP     R5, #'z'
        BGT     skip_case_change        @ 'z' >
@ lower2upper
        BIC     R5, R5, #0x20           @ Convert to upper change 5th bit
        B       set_first_false

not_first:
        CMP     R5, #'A'                @ If uppercase
        BLT     skip_case_change
        CMP     R5, #'Z'
        BGT     skip_case_change
@ upper2lower
        ORR     R5, R5, #0x20           @ Convert to lowercase
        B       set_first_false

skip_case_change:
        CMP     R5, #' '                @ Check if space
        BEQ     set_first_true          @ If space, set first flag
        CMP     R5, #9                  @ Check if tab
        BEQ     set_first_true          @ If tab, set first flag
        B       set_first_false         @ Otherwise, reset first flag

set_first_false:
        MOV     R4, #0                  @ first = false
        B       store_char

set_first_true:
        MOV     R4, #1                  @ first = true
        B       store_char

store_char:
        STRB    R5, [R0], #1
        CMP     R5, #0                  @ Check if null terminator
        BEQ     end                     @ Exit if null terminator
        B       loop                    @ back to loop

end:
        MOV     R0, #0                  @ Set return value to 0 (success)
        POP     {R4, R5, LR}
        MOV     PC, LR

@ store_char:
@         STRB    R5, [R0], #1    
@         B       loop                    @ back to loop

@ end:
@         POP     {R4, R5, PC}            @ Return

