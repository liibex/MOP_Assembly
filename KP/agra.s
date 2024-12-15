    .global setPixColor
    .global pixel
    .global line
    .global triangleFill
    .global circle
    .global current_color
    .extern FrameBufferGetAddress
    .extern FrameBufferGetWidth
    .extern FrameBufferGetHeight
    .extern printf

    .data

current_color:
    .word 0x0

debug_msg_color:
    .asciz "Current color set: R=%u, G=%u, B=%u, OP=%u\n"
debug_msg_coord:
    .asciz "Pixel: Drawing at (x=%d, y=%d)\n"
debug_msg_framebuffer:
    .asciz "FrameBuffer address: 0x%08x\n"
debug_msg_pixel:
    .asciz "Pixel: Writing to offset=0x%08x, color=0x%08x\n"

    .text

@------------------------------------------------------------------------------
@ setPixColor(pixcolor_t *color_op)
@ Input:
@   R0: pointer to pixcolor_t
@
@ This function:
@ 1. Loads the color value from *color_op into current_color
@ 2. Extracts R,G,B,OP from the 32-bit value
@ 3. Prints debug info about the current color
@
@ Registers used:
@ - R6: Address of current_color
@ - R7: Holds loaded color value
@ - R4, R5: Temporary for bit masks and OP extraction
@ - R1, R2, R3: Used to hold extracted R, G, B
@------------------------------------------------------------------------------
setPixColor:
    PUSH {R4-R7, LR}          @ Save R4-R7, LR

    LDR R6, =current_color    @ R6 = &current_color
    LDR R7, [R0]              @ R7 = *color_op (32-bit packed color)
    STR R7, [R6]              @ current_color = R7

    @ Extract R,G,B,OP
    LDR R4, =0x3FF
    MOV R1, R7
    AND R1, R1, R4             @ R = bits 0-9

    MOV R2, R7, LSR #10
    AND R2, R2, R4             @ G = bits 10-19

    MOV R3, R7, LSR #20
    AND R3, R3, R4             @ B = bits 20-29

    MOV R4, R7, LSR #30
    LDR R5, =0x3
    AND R4, R4, R5             @ OP = bits 30-31

    @ Print color info
    LDR R0, =debug_msg_color   @ Format string in R0
    PUSH {R4}                  @ Push OP on stack (5th arg)
    BL printf
    ADD SP, SP, #4             @ Pop OP from stack

    POP {R4-R7, LR}
    BX LR

@------------------------------------------------------------------------------
@ pixel(int x, int y, pixcolor_t *color_op)
@ Inputs:
@   R0 = x
@   R1 = y
@   R2 = pointer to color_op
@
@ After loading:
@ - R6 = x
@ - R7 = y
@ - R5 = color loaded from *color_op
@ - R4 = framebuffer base address (after calling FrameBufferGetAddress)
@ - R2 = width (after calling FrameBufferGetWidth)
@ - R3 = height (after calling FrameBufferGetHeight) [dedicated for height only]
@ - R8 = loop sum register for (y * width)
@
@ Steps:
@ 1. Save registers, copy x,y to R6,R7
@ 2. Load color into R5
@ 3. Print debug info: coordinates, framebuffer address
@ 4. Get width, height; do bounds checks
@ 5. Use R8 as sum for (y * width). R0 as loop counter (y), and leave R3 as height only.
@ 6. Compute offset = ((y * width) + x) * 4
@ 7. Print offset & color
@ 8. Write pixel
@------------------------------------------------------------------------------
pixel:
    PUSH {R4-R7, R8, LR}    @ Save R4-R7, R8, and LR (since we use R8)

    MOV R6, R0              @ R6 = x
    MOV R7, R1              @ R7 = y

    LDR R5, [R2]            @ R5 = color (*color_op)
    
    @ Print coordinates
    LDR R0, =debug_msg_coord
    MOV R1, R6              @ x
    MOV R2, R7              @ y
    BL printf

    @ Get framebuffer base address
    LDR R0, =FrameBufferGetAddress
    BLX R0
    MOV R4, R0              @ R4 = fb base

    @ Print framebuffer address
    LDR R0, =debug_msg_framebuffer
    MOV R1, R4
    BL printf

    @ Get width
    LDR R0, =FrameBufferGetWidth
    BLX R0
    MOV R2, R0              @ R2 = width

    @ Bounds check (x,y)
    CMP R6, #0
    BLT pixel_exit
    CMP R7, #0
    BLT pixel_exit
    CMP R6, R2
    BGE pixel_exit

    @ Get height
    LDR R0, =FrameBufferGetHeight
    BLX R0
    MOV R3, R0              @ R3 = height (dedicated for height only!)

    CMP R7, R3
    BGE pixel_exit

    @ Compute offset = ((y * width) + x)*4
    @ Use R8 for sum, R0 as loop counter.
    MOV R8, #0              @ R8 = sum = 0
    MOV R0, R7              @ R0 = y (loop counter)

calc_loop:
    CMP R0, #0
    BEQ calc_done
    ADD R8, R8, R2          @ sum += width
    SUB R0, R0, #1          @ decrement y
    B calc_loop

calc_done:
    ADD R8, R8, R6          @ R8 = (y*width) + x
    LSL R8, R8, #2          @ R8 *= 4 (bytes/pixel)
    @ Now R8 has the final offset

    @ Print offset & color
    LDR R0, =debug_msg_pixel
    MOV R1, R8              @ offset in R1
    MOV R2, R5              @ color in R2
    BL printf

    @ Write pixel
    ADD R8, R4, R8          @ R8 = framebuffer_base + offset
    STR R5, [R8]            @ *pixel_ptr = color

pixel_exit:
    POP {R4-R7, R8, LR}
    BX LR

@------------------------------------------------------------------------------
@ line(int x1,int y1,int x2,int y2) - stub
line:
    BX LR

@------------------------------------------------------------------------------
@ triangleFill(int x1,int y1,int x2,int y2,int x3,int y3) - stub
triangleFill:
    BX LR

@------------------------------------------------------------------------------
@ circle(int x,int y,int r) - stub
circle:
    BX LR
