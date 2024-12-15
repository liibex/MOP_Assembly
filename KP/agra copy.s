    .global setPixColor
    .global pixel
    .global line
    .global triangleFill
    .global circle
    .extern printf

    .data
current_color: 
    .word 0x0  @ Current color storage (32-bit)

debug_msg_color:
    .asciz "Current color set: R=%u, G=%u, B=%u, OP=%u\n"

debug_msg_pixel:
    .asciz "Pixel: Writing to offset=0x%08x, color=0x%08x\n"

debug_msg_framebuffer:
    .asciz "FrameBuffer address: 0x%08x\n"

    .text

@ Function: setPixColor
@ R0: pointer to pixcolor_t structure
setPixColor:
    PUSH {R4-R7, LR}

    LDR R6, =current_color
    LDMIA R0, {R7}             @ Load the pixcolor_t from memory
    STMIA R6, {R7}             @ Store to current_color

    @ Extract R, G, B, OP
    MOV R1, R7, LSR #0
    LDR R5, =0x3FF
    AND R1, R1, R5             @ R

    MOV R2, R7, LSR #10
    AND R2, R2, R5             @ G

    MOV R3, R7, LSR #20
    AND R3, R3, R5             @ B

    MOV R4, R7, LSR #30
    LDR R5, =0x3
    AND R4, R4, R5             @ OP

    @ We have 5 arguments total for printf: format, R, G, B, OP
    @ Place OP on stack as the 5th argument
    LDR R0, =debug_msg_color
    PUSH {R4}                  @ Push OP on stack
    BL printf
    ADD SP, SP, #4             @ Clean up stack

    POP {R4-R7, LR}
    BX LR


@ Function: pixel
@ R0: x, R1: y
pixel:
    PUSH {R4-R7, LR}

    MOV R6, R0     @ Save x in callee-saved register R6
    MOV R7, R1     @ Save y in callee-saved register R7

    @ Load current color into a callee-saved register (R5)
    LDR R4, =current_color
    LDR R5, [R4]   @ R5 = current_color (preserved across calls)

    @ Get frame buffer base address
    LDR R4, =FrameBufferGetAddress
    BLX R4
    MOV R4, R0     @ R4 = framebuffer base address (safe in R4)

    @ Debug: Print frame buffer address
    LDR R0, =debug_msg_framebuffer
    MOV R1, R4
    BL printf       @ R0-R3 might be altered, but R4-R7 and R5 are safe

    @ Get frame buffer width
    LDR R0, =FrameBufferGetWidth
    BLX R0
    MOV R2, R0     @ R2 = width

    @ Bounds checking with saved x,y in R6,R7
    CMP R6, #0
    BLT pixel_exit
    CMP R7, #0
    BLT pixel_exit
    CMP R6, R2
    BGE pixel_exit

    @ Get frame buffer height
    LDR R0, =FrameBufferGetHeight
    BLX R0
    MOV R3, R0     @ R3 = height
    CMP R7, R3
    BGE pixel_exit

    @ Calculate pixel offset = ((y * width) + x) * 4
    MUL R3, R7, R2    @ R3 = y * width
    ADD R3, R3, R6    @ R3 = (y * width) + x
    LSL R3, R3, #2    @ R3 *= 4

    @ Debug: Print offset and color
    LDR R0, =debug_msg_pixel
    MOV R1, R3        @ offset
    MOV R2, R5        @ color from R5 (stable register)
    BL printf
    @ After printf, R5 still holds the correct color

    @ Write the color to frame buffer
    ADD R3, R4, R3    @ Address = base + offset
    STR R5, [R3]      @ Store the color from R5

pixel_exit:
    POP {R4-R7, LR}
    BX LR


@ Function: line
line:
    PUSH {R4-R8, LR}
    @ Placeholder
    POP {R4-R8, LR}
    BX LR

@ Function: triangleFill
triangleFill:
    PUSH {R4, LR}
    @ Placeholder
    POP {R4, LR}
    BX LR

@ Function: circle
circle:
    PUSH {R4, LR}
    @ Placeholder
    POP {R4, LR}
    BX LR
