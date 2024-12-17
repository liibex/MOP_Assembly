#include <stdio.h>
#include <stdint.h>
#include "agra.h"  // Contains definition of pixcolor_t and function prototypes

// According to the original assembly logic, the packed color format is:
// bits [0:9]   = R (10 bits)
// bits [10:19] = G (10 bits)
// bits [20:29] = B (10 bits)
// bits [30:31] = OP (2 bits)
//
// We'll decode it using shifts and masks from a 32-bit value.

// Debug messages (unchanged from previous code)
static const char debug_msg_color[]       = "Current color set: R=%u, G=%u, B=%u, OP=%u\n";
static const char debug_msg_pixel[]       = "Pixel: Writing to offset=0x%08x, color=0x%08x\n";
static const char debug_msg_framebuffer[] = "FrameBuffer address: 0x%08x\n";
static const char debug_msg_coord[]       = "Pixel: Drawing at (x=%d, y=%d)\n";

static pixcolor_t current_color;  // Current drawing color

// Set the current drawing color from a pixcolor_t pointer
void setPixColor(pixcolor_t *color_op)
{
    current_color = *color_op;

    // Interpret pixcolor_t as a 32-bit integer
    uint32_t val = *(uint32_t *)&current_color;

    // Extract R, G, B, OP
    unsigned int R =  (val >> 0)  & 0x3FF;
    unsigned int G = (val >> 10) & 0x3FF;
    unsigned int B = (val >> 20) & 0x3FF;
    unsigned int OP = (val >> 30) & 0x3;

    printf(debug_msg_color, R, G, B, OP);
}

// Draw a pixel at (x, y) using the given pixcolor_t color
void pixel(int x, int y, pixcolor_t *color_op)
{
    // Print the coordinates for debugging
    printf(debug_msg_coord, x, y);

    // Get framebuffer info
    pixcolor_t *fb = FrameBufferGetAddress(); // returns pixcolor_t*
    printf(debug_msg_framebuffer, (unsigned int)(uintptr_t)fb);

    int width = FrameBufferGetWidth();
    int height = FrameBufferGetHeight();

    // Bounds checking
    if (x < 0 || y < 0 || x >= width || y >= height) {
        return; // Out of bounds
    }

    // Calculate offset:
    // offset = ((y * width) + x) * 4 bytes
    unsigned int Y = (unsigned int)y;
    unsigned int W = (unsigned int)width;
    unsigned int result = 0;
    while (Y > 0) {
        result += W;
        Y--;
    }
    unsigned int offset = (result + (unsigned int)x) * 4;

    // For debugging, interpret color as a 32-bit integer
    uint32_t val = *(uint32_t *)color_op;
    printf(debug_msg_pixel, offset, val);

    // Write the color into the framebuffer
    pixcolor_t *pixel_ptr = fb + ((y * width) + x);
    *pixel_ptr = *color_op;
}

// A standard Bresenham line algorithm implementation
// void line(int x1, int y1, int x2, int y2)
// {
//     pixcolor_t *col = &current_color;  // Use the current set color

//     int dx = abs(x2 - x1);
//     int sx = (x1 < x2) ? 1 : -1;
//     int dy = -abs(y2 - y1);
//     int sy = (y1 < y2) ? 1 : -1;
//     int err = dx + dy; // dx + (-dy) = dx - dy

//     while (1) {
//         pixel(x1, y1, col); // Draw the pixel at the current coordinates
//         if (x1 == x2 && y1 == y2) break;
//         int e2 = 2 * err;
//         if (e2 >= dy) { // Move horizontally
//             err += dy;
//             x1 += sx;
//         }
//         if (e2 <= dx) { // Move vertically
//             err += dx;
//             y1 += sy;
//         }
//     }
// }

void line(int x1, int y1, int x2, int y2)
{
    // Use the globally set current_color
    pixcolor_t *col = &current_color;

    // Compute dx and sx without abs() or multiplication
    int dx = x2 - x1;
    int sx = 1;
    if (dx < 0) {
        dx = -dx;   // dx = |x2 - x1|
        sx = -1;
    }

    // Compute dy and sy without abs() or multiplication
    int dy = y2 - y1;
    int sy = 1;
    if (dy < 0) {
        dy = -dy;   // dy = |y2 - y1|
        sy = -1;
    }

    // Bresenham's algorithm uses dy and dx. 
    // Original form: err = dx + dy (with one as negative)
    // The standard algorithm sets err = dx + dy when one is negated:
    // In the standard Bresenham:
    //   dx = abs(x2-x1)
    //   dy = -abs(y2-y1)
    // We'll emulate that by making dy negative if we follow original logic:
    // But to keep things simple:
    //   We know from standard Bresenham:
    //   err = dx + dy if dy is negative or dx + (-dy).
    // Instead of rearranging, we can follow the standard approach:
    // Bresenham line variant: 
    // We choose the variant from the previous working code:
    //   dx = abs(x2-x1)
    //   dy = -abs(y2-y1)
    // Then err = dx + dy
    //
    // We already have dx = |x2 - x1|
    // Let's make dy negative:
    dy = -dy; // now dy = -|y2 - y1|
    
    // Now err = dx + dy
    int err = dx + dy;  // dy is negative, so effectively err = dx - |dy|

    // Start drawing the line
    while (1) {
        pixel(x1, y1, col);

        // If we've reached the end, break
        if (x1 == x2 && y1 == y2) {
            break;
        }

        // double error without multiplication: e2 = err + err;
        int e2 = err + err;

        // Check if we should move horizontally
        if (e2 >= dy) { // Remember dy is negative, so e2>=dy means we adjust x
            err += dy;  // err = err + dy (dy negative reduces err)
            x1 += sx;
        }

        // Check if we should move vertically
        if (e2 <= dx) { // move vertically
            err += dx;  // err = err + dx
            y1 += sy;
        }
    }
}




// ------------------------------------------------------------------------------
//  triangleFill(int x1,int y1,int x2,int y2,int x3,int y3) - corrected
// ------------------------------------------------------------------------------

// Helper function to swap two integers
static void swap_int(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

// Helper function to draw a horizontal line from (x1, y) to (x2, y)
static void draw_horizontal_line(int x1, int x2, int y) {
    if (x1 > x2) {
        swap_int(&x1, &x2);
    }
    for (int x = x1; x <= x2; x++) {
        pixel(x, y, &current_color);
    }
}

// Fill a flat-bottom triangle using an error-based incremental approach
static void fill_flat_bottom_triangle(int x1, int y1, int x2, int y2, int x3, int y3) {
    // Calculate the differences
    int dx1 = x3 - x1;
    int dy1 = y3 - y1;

    int dx2 = x3 - x2;
    int dy2 = y3 - y2;

    // Initialize starting points
    int curx1 = x1;
    int curx2 = x2;

    // Determine the step direction for each edge
    int stepx1 = (dx1 >= 0) ? 1 : -1;
    int stepx2 = (dx2 >= 0) ? 1 : -1;

    // Calculate absolute differences
    int abs_dx1 = (dx1 >= 0) ? dx1 : -dx1;
    int abs_dx2 = (dx2 >= 0) ? dx2 : -dx2;

    // Initialize error terms
    int error1 = 0;
    int error2 = 0;

    // Iterate over each scanline from y1 to y3
    for (int y = y1; y <= y3; y++) {
        draw_horizontal_line(curx1, curx2, y);

        error1 += abs_dx1;
        error2 += abs_dx2;

        // Adjust curx1 based on error1
        if (error1 >= dy1 && dy1 != 0) {
            curx1 += stepx1;
            error1 -= dy1;
        }

        // Adjust curx2 based on error2
        if (error2 >= dy2 && dy2 != 0) {
            curx2 += stepx2;
            error2 -= dy2;
        }
    }
}

// Fill a flat-top triangle using an error-based incremental approach
static void fill_flat_top_triangle(int x1, int y1, int x2, int y2, int x3, int y3) {
    // Calculate the differences
    int dx1 = x3 - x1;
    int dy1 = y3 - y1;

    int dx2 = x3 - x2;
    int dy2 = y3 - y2;

    // Initialize starting points
    int curx1 = x3;
    int curx2 = x3;

    // Determine the step direction for each edge
    int stepx1 = (dx1 >= 0) ? 1 : -1;
    int stepx2 = (dx2 >= 0) ? 1 : -1;

    // Calculate absolute differences
    int abs_dx1 = (dx1 >= 0) ? dx1 : -dx1;
    int abs_dx2 = (dx2 >= 0) ? dx2 : -dx2;

    // Initialize error terms
    int error1 = 0;
    int error2 = 0;

    // Iterate over each scanline from y3 to y1
    for (int y = y3; y >= y1; y--) {
        draw_horizontal_line(curx1, curx2, y);

        error1 += abs_dx1;
        error2 += abs_dx2;

        // Adjust curx1 based on error1
        if (error1 >= dy1 && dy1 != 0) {
            curx1 += stepx1;
            error1 -= dy1;
        }

        // Adjust curx2 based on error2
        if (error2 >= dy2 && dy2 != 0) {
            curx2 += stepx2;
            error2 -= dy2;
        }
    }
}

// Fill a general triangle by splitting it into flat-bottom and flat-top triangles
void triangleFill(int x1, int y1, int x2, int y2, int x3, int y3) {
    // Sort the vertices by y-coordinate ascending (y1 <= y2 <= y3)
    if (y1 > y2) { swap_int(&y1, &y2); swap_int(&x1, &x2); }
    if (y1 > y3) { swap_int(&y1, &y3); swap_int(&x1, &x3); }
    if (y2 > y3) { swap_int(&y2, &y3); swap_int(&x2, &x3); }

    // After sorting: (x1,y1) top, (x2,y2) middle, (x3,y3) bottom

    if (y2 == y3) {
        // Flat-bottom triangle
        fill_flat_bottom_triangle(x1, y1, x2, y2, x3, y3);
    }
    else if (y1 == y2) {
        // Flat-top triangle
        fill_flat_top_triangle(x1, y1, x2, y2, x3, y3);
    }
    else {
        // General triangle - split into a flat-bottom and flat-top triangle

        // Compute the new vertex (x4, y4) where y4 == y2
        // Using integer arithmetic to avoid multiplication

        // Compute the differences
        int dx_total = x3 - x1;
        int dy_total = y3 - y1;

        int dy_split = y2 - y1;

        // Initialize variables for error-based stepping
        int error = 0;
        int x4 = x1;

        // Perform dy_split steps to compute x4 incrementally
        for(int i = 0; i < dy_split; i++) {
            error += dx_total;
            if (dy_total > 0 && error >= dy_total) {
                x4 += 1;
                error -= dy_total;
            }
            else if (dy_total < 0 && error <= dy_total) {
                x4 -= 1;
                error -= dy_total;
            }
            // If dy_total is 0, stepx remains 0
        }

        // Now, split the triangle into two flat triangles
        // Flat-bottom: (x1, y1), (x2, y2), (x4, y2)
        fill_flat_bottom_triangle(x1, y1, x2, y2, x4, y2);

        // Flat-top: (x2, y2), (x4, y2), (x3, y3)
        fill_flat_top_triangle(x2, y2, x4, y2, x3, y3);
    }
}







// ------------------------------------------------------------------------------
//  circle(int x,int y,int r) - stub
// ------------------------------------------------------------------------------

extern pixcolor_t current_color;
extern void pixel(int x, int y, pixcolor_t *color_op);

void circle(int xc, int yc, int r)
{
    int x = 0;
    int y = r;
    int d = 1 - r;  // decision variable d = 1 - r initially

    // A helper macro to draw all eight symmetrical points
    #define DRAW_CIRCLE_POINTS(X, Y) \
        pixel((xc + (X)), (yc + (Y)), &current_color); \
        pixel((xc - (X)), (yc + (Y)), &current_color); \
        pixel((xc + (X)), (yc - (Y)), &current_color); \
        pixel((xc - (X)), (yc - (Y)), &current_color); \
        pixel((xc + (Y)), (yc + (X)), &current_color); \
        pixel((xc - (Y)), (yc + (X)), &current_color); \
        pixel((xc + (Y)), (yc - (X)), &current_color); \
        pixel((xc - (Y)), (yc - (X)), &current_color);

    // Draw initial points
    DRAW_CIRCLE_POINTS(x, y)

    while (x < y)
    {
        x = x + 1;  // increment x

        if (d < 0)
        {
            // d += 2*x + 1; without MUL
            int two_x = x + x;
            d = d + two_x + 1;
        }
        else
        {
            // d += 2*(x - y) + 1;
            // Without multiplication:
            // 2*(x-y) is (x-y)+(x-y)
            int diff = x - y;
            int two_diff = diff + diff;
            y = y - 1;  // decrement y
            d = d + two_diff + 1;
        }

        DRAW_CIRCLE_POINTS(x, y)
    }

    #undef DRAW_CIRCLE_POINTS
}

