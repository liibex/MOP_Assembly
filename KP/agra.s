    .text
    .align 2
    .global matmul
    .type matmul, %function


@ int matmul(int h1, int w1, int *m1, int h2, int w2, int *m2, int *m3)
@ h1 -> r0
@ w1 -> r1
@ *m1 -> r2
@ h2 -> r3
@ w2 -> SP     !!! Neaizmirst nobīdi pēc push SP+40
@ *m2 -> SP+4  !!! Neaizmirst nobīdi pēc push SP+44
@ *m3 -> SP+8  !!! Neaizmirst nobīdi pēc push SP+48

matmul:
    @ Save callee-saved registers and link register
    push {r4, r5, r6, r7, r8, r9, r10, r11, r12, lr}    @SP 0 -> SP 40

    @ Reasign params
    mov r8, r0         @ r8 = h1
    mov r9, r1         @ r9 = w1
    mov r10, r2        @ r10 = m1
    mov r11, r3        @ r11 = h2
    ldr r4, [sp, #40]  @ Load 5th parameter (w2) into r4
    ldr r5, [sp, #44]  @ Load 6th parameter (m2) into r5
    ldr r6, [sp, #48]  @ Load 7th parameter (m3) into r6

    @ Check if any of the dimensions (h1, w1, h2, w2) are smaller than 0
    cmp r8, #0
    ble error
    cmp r9, #0
    ble error
    cmp r11, #0
    ble error
    cmp r4, #0
    ble error

    @ For matrix multiplication, the number of columns in the first matrix 
    @ must be equal to the number of rows in the second matrix.
    cmp r9, r11
    bne error
    
    mov r0, #0         @ Initialize row counter (i) to 0

outer_loop:
    cmp r0, r8         @ Compare i with h1
    bge success        @ Exit if i >= h1
    
    mov r1, #0         @ Initialize column counter (j) to 0

column_loop:
    cmp r1, r4         @ Compare j with w2
    bge next_row       @ Exit if j >= w2
    
    mov r2, #0         @ Initialize sum to 0
    mov r3, #0         @ Initialize element counter (k) to 0

inner_loop:
    cmp r3, r9         @ Compare k with w1
    bge store_result   @ Exit if k >= w1
    
    @ Load m1[i * w1 + k]
    mul r7, r0, r9     @ r7 = i * w1
    add r7, r7, r3     @ r7 = i * w1 + k
    lsl r7, r7, #2     @ r7 = (i * w1 + k) * 4
    ldr r12, [r10, r7] @ r12 = m1[i * w1 + k]
    
    @ Load m2[k * w2 + j]
    mul r7, r3, r4     @ r7 = k * w2
    add r7, r7, r1     @ r7 = k * w2 + j
    lsl r7, r7, #2     @ r7 = (k * w2 + j) * 4
    ldr r7, [r5, r7]   @ r7 = m2[k * w2 + j]

    @ Perform sum += m1[i * w1 + k] * m2[k * w2 + j]
    mla r2, r12, r7, r2

    add r3, r3, #1     @ Increment k
    b inner_loop       @ Continue to next k

store_result:
    @ Store result in m3[i * w2 + j]
    mul r7, r0, r4     @ r7 = i * w2
    add r7, r7, r1     @ r7 = i * w2 + j
    lsl r7, r7, #2     @ r7 = (i * w2 + j) * 4
    str r2, [r6, r7]   @ m3[i * w2 + j] = sum
    
    add r1, r1, #1     @ Increment j
    b column_loop      @ Continue to next column

next_row:
    add r0, r0, #1     @ Increment i
    b outer_loop       @ Continue to next row

error:
    mov r0, #1         @ Return 1 (error)
    b end

success:
    mov r0, #0         @ Return 0 (success)
    b end

end:
    pop {r4, r5, r6, r7, r8, r9, r10, r11, r12, pc}  @ Restore registers and return
