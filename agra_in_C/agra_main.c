#include "agra.h"
#include <stdio.h>

int main() {
    // Initialize the frame buffer
    pixcolor_t color;

    // Clear the frame buffer (fill with black)
    // printf("Clearing the frame buffer (filling with black)...\n");
    for (int y = 0; y < FrameBufferGetHeight(); y++) {
        for (int x = 0; x < FrameBufferGetWidth(); x++) {
            color.r = 0;
            color.g = 0;
            color.b = 0;
            color.op = PIXEL_COPY;
            pixel(x, y, &color);
        }
    }
    // printf("Frame buffer cleared.\n");

    color.r = 0x03FF;
    color.g = 0x03FF;
    color.b = 0x03FF;
    color.op = PIXEL_COPY;
    setPixColor(&color);
    pixel(25, 2, &color);

    color.r = 0;
    color.g = 0;
    color.b = 0x03FF;
    setPixColor(&color);
    line(0, 0, 39, 19);

    color.r = 0;
    color.g = 0x03FF;
    color.b = 0;
    setPixColor(&color);
    triangleFill(20, 13, 28, 19, 38, 6);

    color.r = 0x03FF;
    color.g = 0;
    color.b = 0;
    setPixColor(&color);
    circle(20, 10, 7);

    FrameShow();

    return 0;
}
