#include "agra.h"
#include <stdio.h>
#include <stdlib.h>

// Define the frame buffer dimensions
#define FRAME_WIDTH 40
#define FRAME_HEIGHT 20

// Frame buffer: a 2D array of pixels
static pixcolor_t FrameBuffer[FRAME_HEIGHT][FRAME_WIDTH];

// Get the address of the frame buffer
pixcolor_t* FrameBufferGetAddress() {
    return &FrameBuffer[0][0];
}

// Get the width of the frame buffer
int FrameBufferGetWidth() {
    return FRAME_WIDTH;
}

// Get the height of the frame buffer
int FrameBufferGetHeight() {
    return FRAME_HEIGHT;
}

// Show the frame buffer contents as ASCII art
int FrameShow() {
//     for (int y = 0; y < FRAME_HEIGHT; y++) {
//         for (int x = 0; x < FRAME_WIDTH; x++) {
//             FrameBuffer[y][x].r = 0x03FF;
//             FrameBuffer[y][x].g = 0;
//             FrameBuffer[y][x].b = 0;
//         }
//     }
// }

    for (int y = 0; y < FRAME_HEIGHT; y++) {
        for (int x = 0; x < FRAME_WIDTH; x++) {
            pixcolor_t pixel = FrameBuffer[y][x];

            // Determine the symbol based on the pixel's color
            if (pixel.r == 0 && pixel.g == 0 && pixel.b == 0) {
                putchar(' '); // Black (empty space)
            } else if (pixel.r > pixel.g && pixel.r > pixel.b) {
                putchar('R'); // Dominant red
            } else if (pixel.g > pixel.r && pixel.g > pixel.b) {
                putchar('G'); // Dominant green
            } else if (pixel.b > pixel.r && pixel.b > pixel.g) {
                putchar('B'); // Dominant blue
            } else if (pixel.g == pixel.b && pixel.g > pixel.r) {
                putchar('C'); // Cyan
            } else if (pixel.r == pixel.b && pixel.r > pixel.g) {
                putchar('M'); // Magenta
            } else if (pixel.r == pixel.g && pixel.r > pixel.b) {
                putchar('Y'); // Yellow
            } else {
                putchar('*'); // White or undefined
            }
        }
        putchar('\n');
    }
    return 0; // Success
}
