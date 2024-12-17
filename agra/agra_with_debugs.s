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
    SUB     SP, SP, #4             @ Align stack to 8 bytes (current SP % 8 = 0)
    @ PUSH    {R4-R7, LR}            @ Save R4-R7 and LR (Total bytes pushed: 24)
    PUSH {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,LR}

    LDR     R6, =current_color     @ R6 = &current_color
    LDR     R7, [R0]               @ R7 = *color_op (32-bit packed color)
    STR     R7, [R6]               @ current_color = R7

    @ Extract R,G,B,OP
    LDR     R4, =0x3FF
    MOV     R1, R7
    AND     R1, R1, R4             @ R = bits 0-9

    MOV     R2, R7, LSR #10
    AND     R2, R2, R4             @ G = bits 10-19

    MOV     R3, R7, LSR #20
    AND     R3, R3, R4             @ B = bits 20-29

    MOV     R4, R7, LSR #30
    LDR     R5, =0x3
    AND     R4, R4, R5             @ OP = bits 30-31

    @ Print color info
    LDR     R0, =debug_msg_color   @ Format string in R0
    MOV     R1, R1                 @ R (already in R1)
    MOV     R2, R2                 @ G (already in R2)
    MOV     R3, R3                 @ B (already in R3)
    PUSH    {R4}                   @ Push OP on stack (5th argument)
    BL      printf
    ADD     SP, SP, #4             @ Pop OP from stack

    @ POP     {R4-R7, LR}            @ Restore R4-R7 and LR
    POP  {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,LR}
    ADD     SP, SP, #4             @ Restore stack alignment
    BX      LR                     @ Return

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
    SUB     SP, SP, #8             @ Align stack to 8 bytes (current SP % 8 = 0)
    @ PUSH    {R4-R8, LR}            @ Save R4-R8 and LR (Total bytes pushed: 24)
    PUSH {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,LR}


    MOV     R6, R0                 @ R6 = x
    MOV     R7, R1                 @ R7 = y

    LDR     R5, [R2]               @ R5 = color (*color_op)

    @ Print coordinates
    LDR     R0, =debug_msg_coord   @ Format string in R0
    MOV     R1, R6                 @ x
    MOV     R2, R7                 @ y
    BL      printf

    @ Get framebuffer base address
    LDR     R0, =FrameBufferGetAddress
    BLX     R0
    MOV     R4, R0                 @ R4 = fb base

    @ Print framebuffer address
    LDR     R0, =debug_msg_framebuffer @ Format string
    MOV     R1, R4                 @ Framebuffer address
    BL      printf

    @ Get width
    LDR     R0, =FrameBufferGetWidth
    BLX     R0
    MOV     R2, R0                 @ R2 = width

    @ Bounds check (x >= 0)
    CMP     R6, #0
    BLT     pixel_exit

    @ Bounds check (y >= 0)
    CMP     R7, #0
    BLT     pixel_exit

    @ Bounds check (x < width)
    CMP     R6, R2
    BGE     pixel_exit

    @ Get height
    LDR     R0, =FrameBufferGetHeight
    BLX     R0
    MOV     R3, R0                 @ R3 = height (dedicated for height only!)

    @ Bounds check (y < height)
    CMP     R7, R3
    BGE     pixel_exit

    @ Compute offset = ((y * width) + x) * 4
    @ Use R8 for sum, R0 as loop counter.
    MOV     R8, #0                 @ R8 = sum = 0
    MOV     R0, R7                 @ R0 = y (loop counter)

calc_loop:
    CMP     R0, #0
    BEQ     calc_done
    ADD     R8, R8, R2             @ sum += width
    SUB     R0, R0, #1             @ decrement y
    B       calc_loop

calc_done:
    ADD     R8, R8, R6             @ R8 = (y * width) + x
    LSL     R8, R8, #2             @ R8 *= 4 (bytes per pixel)

    @ Print offset & color
    LDR     R0, =debug_msg_pixel    @ Format string
    MOV     R1, R8                 @ offset in R1
    MOV     R2, R5                 @ color in R2
    BL      printf

    @ Write pixel
    ADD     R8, R4, R8             @ R8 = framebuffer_base + offset
    STR     R5, [R8]               @ *pixel_ptr = color

pixel_exit:
    @ POP     {R4-R8, LR}            @ Restore R4-R8 and LR
    POP  {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,LR}
    ADD     SP, SP, #8             @ Restore stack alignment
    BX      LR                     @ Return

@ line(int x1, int y1, int x2, int y2)
@ R0=x1, R1=y1, R2=x2, R3=y2
@ We will:
@ 1. Push all registers
@ 2. Allocate local space
@ 3. Check steepness and swap if needed
@ 4. Compute dx, dy, sx, sy, err
@ 5. Run Bresenham until (x==x2 && y==y2)
@ 6. Pop registers and return

@ Local Variables Layout (after pushing all registers and sub sp):
@ We'll allocate 40 bytes:
@ SP Layout:
@ [SP, #0]:   steep (0 or 1)
@ [SP, #4]:   x1 (current x)
@ [SP, #8]:   y1 (current y)
@ [SP, #12]:  x2
@ [SP, #16]:  y2
@ [SP, #20]:  dx
@ [SP, #24]:  dy
@ [SP, #28]:  sx
@ [SP, #32]:  sy
@ [SP, #36]:  err (int)

    .global line
    .global current_color
    .extern pixel

    .text

@ line(int x1, int y1, int x2, int y2)
@ R0=x1, R1=y1, R2=x2, R3=y2
@ This code:
@ 1. PUSH all registers {R0-R12,LR} (SP moves by 56 bytes automatically).
@ 2. SUB SP, SP, #40 for local variables.
@ 3. Implements steep-line handling by swapping coordinates if needed.
@ 4. Uses standard Bresenham conditions with err, e2 checks.
@ 5. POP all registers at the end and return.

@ Stack layout after pushing all registers and subtracting 40:
@ Initial SP after push: SP lowered by 56 bytes.
@ Then SUB SP, SP, #40 lowers SP by another 40 bytes.
@ Total local space: 40 bytes.
@ Layout (top of stack at this point):
@ [SP, #0]:   steep (0 or 1)
@ [SP, #4]:   x
@ [SP, #8]:   y
@ [SP, #12]:  x2
@ [SP, #16]:  y2
@ [SP, #20]:  dx
@ [SP, #24]:  dy
@ [SP, #28]:  sx
@ [SP, #32]:  sy
@ [SP, #36]:  err

line:
    PUSH    {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,LR}
    SUB     SP, SP, #40

    @ Store parameters
    STR     R0, [SP, #4]    @ x1
    STR     R1, [SP, #8]    @ y1
    STR     R2, [SP, #12]   @ x2
    STR     R3, [SP, #16]   @ y2

    @ Compute dx, dy
    LDR     R0, [SP, #4]    @ x1
    LDR     R1, [SP, #8]    @ y1
    LDR     R2, [SP, #12]   @ x2
    LDR     R3, [SP, #16]   @ y2
    SUB     R4, R2, R0      @ dx = x2 - x1
    SUB     R5, R3, R1      @ dy = y2 - y1

    @ Check steep
    MOV     R6, R5
    CMP     R5, #0
    RSBLT   R6, R5, #0       @ R6 = |dy|
    MOV     R7, R4
    CMP     R4, #0
    RSBLT   R7, R4, #0       @ R7 = |dx|
    CMP     R6, R7
    BLE     no_steep
    MOV     R0, #1           @ steep=1
    B       do_steep
no_steep:
    MOV     R0, #0
do_steep:
    STR     R0, [SP, #0]

    @ If steep, swap x1,y1 and x2,y2
    LDR     R0, [SP, #0]
    CMP     R0, #0
    BEQ     after_swap

    LDR     R0, [SP, #4]    @ x1
    LDR     R1, [SP, #8]    @ y1
    STR     R1, [SP, #4]    @ x1=y1
    STR     R0, [SP, #8]    @ y1=x1

    LDR     R0, [SP, #12]   @ x2
    LDR     R1, [SP, #16]   @ y2
    STR     R1, [SP, #12]   @ x2=y2
    STR     R0, [SP, #16]   @ y2=x2
after_swap:
    @ Recompute dx, dy
    LDR     R0, [SP, #4]
    LDR     R1, [SP, #8]
    LDR     R2, [SP, #12]
    LDR     R3, [SP, #16]
    SUB     R4, R2, R0    @ dx
    SUB     R5, R3, R1    @ dy
    MOV     R8, #1        @ sx=1
    CMP     R4, #0
    MOVLT   R8, #-1
    RSBLT   R4, R4, #0    @ dx=|dx|
    MOV     R9, #1        @ sy=1
    CMP     R5, #0
    MOVLT   R9, #-1
    RSBLT   R5, R5, #0    @ dy=|dy|
    STR     R4, [SP, #20]
    STR     R5, [SP, #24]
    STR     R8, [SP, #28]
    STR     R9, [SP, #32]

    @ err = dx - dy
    SUB     R10, R4, R5
    STR     R10, [SP, #36]

line_loop:
    LDR     R0, [SP, #4]   @ x
    LDR     R1, [SP, #8]   @ y
    LDR     R2, [SP, #0]   @ steep
    CMP     R2, #0
    BEQ     draw_gentle
    @ If steep, swap x,y
    MOV     R2, R0
    MOV     R0, R1
    MOV     R1, R2
draw_gentle:
    LDR     R2, =current_color
    LDR     R2, [R2]
    BL      pixel

    @ Check end point
    LDR     R3, [SP, #12]   @ x2
    LDR     R11,[SP,#16]    @ y2
    LDR     R0, [SP, #4]    @ x
    LDR     R1, [SP, #8]    @ y
    CMP     R0, R3
    BNE     not_done
    CMP     R1, R11
    BEQ     line_done
not_done:

    @ e2 = 2*err
    LDR     R10,[SP,#36] @ err
    ADD     R0, R10, R10 @ e2
    LDR     R4, [SP,#20] @ dx
    LDR     R5, [SP,#24] @ dy
    LDR     R8, [SP,#28] @ sx
    LDR     R9, [SP,#32] @ sy

    @ if (e2 > -dy)
    RSBS    R1, R5, #0
    CMP     R0, R1
    BLE     skip_x_incr
    SUB     R10,R10,R5
    LDR     R2,[SP,#4]   @ x
    ADD     R2,R2,R8
    STR     R2,[SP,#4]
skip_x_incr:

    @ if (e2 < dx)
    CMP     R0, R4
    BGE     skip_y_incr
    ADD     R10,R10,R4
    LDR     R2,[SP,#8]   @ y
    ADD     R2,R2,R9
    STR     R2,[SP,#8]
skip_y_incr:

    STR     R10,[SP,#36]
    B       line_loop

line_done:
    ADD     SP, SP, #40
    POP     {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,LR}
    BX      LR


@------------------------------------------------------------------------------
@ triangleFill(int x1,int y1,int x2,int y2,int x3,int y3) - stub
@------------------------------------------------------------------------------
triangleFill:
    BX      LR                     @ Return (Stub Implementation)

@------------------------------------------------------------------------------
@ circle(int x,int y,int r) - stub
@------------------------------------------------------------------------------

@ circle(int xc, int yc, int r)
@ R0=xc, R1=yc, R2=r
@ Midpoint circle algorithm, no multiplication.
@ Push all registers at start.

@ After pushing all regs (14 regs: R0-R12,LR = 56 bytes)
@ then SUB SP,SP,#32 for locals:
@ [SP,#0]:  xc
@ [SP,#4]:  yc
@ [SP,#8]:  r
@ [SP,#12]: x
@ [SP,#16]: y
@ [SP,#20]: d
@ 24 bytes used, 8 spare.

circle:
    PUSH {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,LR}
    SUB  SP, SP, #32

    @ Store xc,yc,r
    STR R0, [SP,#0]   @ xc
    STR R1, [SP,#4]   @ yc
    STR R2, [SP,#8]   @ r

    @ x=0
    MOV R0,#0
    STR R0,[SP,#12]

    @ y=r
    LDR R0,[SP,#8]
    STR R0,[SP,#16]

    @ d=1-r = (1-r)
    LDR R0,[SP,#8]
    RSBS R0,R0,#1    @ R0=1-r
    STR R0,[SP,#20]

    BL draw_circle_points

main_loop:
    @ while(x<y)
    LDR R0,[SP,#12]  @ x
    LDR R1,[SP,#16]  @ y
    CMP R0,R1
    BGE done_circle

    @ x=x+1
    ADD R0,R0,#1
    STR R0,[SP,#12]

    @ d<0?
    LDR R2,[SP,#20]  @ d
    CMP R2,#0
    BLT d_negative

    @ d>=0 case:
    @ y=y-1
    LDR R1,[SP,#16]
    SUB R1,R1,#1
    STR R1,[SP,#16]

    @ d += ((x-y)+(x-y))+1
    @ x in R0, y in R1 now
    SUB R3,R0,R1     @ diff=(x-y)
    ADD R4,R3,R3     @ two_diff=(diff+diff)
    ADD R2,R2,R4     @ d=d+two_diff
    ADD R2,R2,#1
    STR R2,[SP,#20]
    B update_points

d_negative:
    @ d<0:
    @ d += (x+x)+1
    LDR R0,[SP,#12] @ x
    ADD R3,R0,R0    @ two_x=(x+x)
    ADD R2,R2,R3
    ADD R2,R2,#1
    STR R2,[SP,#20]

update_points:
    BL draw_circle_points
    B main_loop

done_circle:
    ADD SP, SP, #32
    POP {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,LR}
    BX LR


@ draw_circle_points:
@ Push all registers again:
@ After this push, SP moves down another 56 bytes.
@ Parent's locals at parent's SP:
@ parent's SP = current SP +56 (because we just pushed 14 regs again)
@ xc=[parent SP,#0], yc=[parent SP,#4], x=[parent SP,#12], y=[parent SP,#16]

draw_circle_points:
    PUSH {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,LR}

    @ parent's SP = current SP +56
    ADD R0, SP, #56
    LDR R4,[R0,#0]    @ xc
    LDR R5,[R0,#4]    @ yc
    LDR R6,[R0,#12]   @ x
    LDR R7,[R0,#16]   @ y

    @ Draw the 8 points using pixel
    @ Before each pixel call, set R2=address of current_color
    @ pixel(x,y,color*), color* in R2

    @ pixel(xc+x, yc+y)
    LDR R2,=current_color
    ADD R0,R4,R6
    ADD R1,R5,R7
    BL pixel

    @ pixel(xc-x, yc+y)
    LDR R2,=current_color
    SUB R0,R4,R6
    ADD R1,R5,R7
    BL pixel

    @ pixel(xc+x, yc-y)
    LDR R2,=current_color
    ADD R0,R4,R6
    SUB R1,R5,R7
    BL pixel

    @ pixel(xc-x, yc-y)
    LDR R2,=current_color
    SUB R0,R4,R6
    SUB R1,R5,R7
    BL pixel

    @ pixel(xc+y, yc+x)
    LDR R2,=current_color
    ADD R0,R4,R7
    ADD R1,R5,R6
    BL pixel

    @ pixel(xc-y, yc+x)
    LDR R2,=current_color
    SUB R0,R4,R7
    ADD R1,R5,R6
    BL pixel

    @ pixel(xc+y, yc - x)
    LDR R2,=current_color
    ADD R0,R4,R7
    SUB R1,R5,R6
    BL pixel

    @ pixel(xc-y, yc - x)
    LDR R2,=current_color
    SUB R0,R4,R7
    SUB R1,R5,R6
    BL pixel

    POP {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,LR}
    BX LR
