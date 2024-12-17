#include "agra.h"
#include <stdio.h>

int main() {
    // Initialize the frame buffer
    pixcolor_t color;

    // Clear the frame buffer (fill with black)
    printf("Clearing the frame buffer (filling with black)...\n");
    for (int y = 0; y < FrameBufferGetHeight(); y++) {
        for (int x = 0; x < FrameBufferGetWidth(); x++) {
            color.r = 0;
            color.g = 0;
            color.b = 0;
            color.op = PIXEL_COPY;
            pixel(x, y, &color);
        }
    }
    printf("Frame buffer cleared.\n");
    FrameShow();

    // Draw a white pixel at (25, 2)
    printf("Drawing a white pixel at (25, 2)...\n");
    color.r = 0x03FF;
    color.g = 0x03FF;
    color.b = 0x03FF;
    color.op = PIXEL_COPY;
    setPixColor(&color);
    pixel(25, 2, &color);
    printf("White pixel drawn at (25, 2).\n");
    FrameShow();

    // Draw a blue line from (0, 0) to (39, 19)
    printf("Drawing a blue line from (0, 0) to (39, 19)...\n");
    color.r = 0;
    color.g = 0;
    color.b = 0x03FF;
    setPixColor(&color);
    line(0, 0, 39, 19);
    line(0, 0, 2, 2);
    line(16, 16, 8, 8);
    // line(4, 4, 2, 4);
    printf("Blue line drawn from (0, 0) to (39, 19).\n");
    FrameShow();

    // // Draw a green-filled triangle at (20, 13), (28, 19), (38, 6)
    // printf("Drawing a green-filled triangle with vertices at (20, 13), (28, 19), (38, 6)...\n");
    // color.r = 0;
    // color.g = 0x03FF;
    // color.b = 0;
    // setPixColor(&color);
    // triangleFill(20, 13, 28, 19, 38, 6);
    // printf("Green-filled triangle drawn.\n");
    // FrameShow();

    // // Draw a red circle with center (20, 10) and radius 7
    // printf("Drawing a red circle with center (20, 10) and radius 7...\n");
    // color.r = 0x03FF;
    // color.g = 0;
    // color.b = 0;
    // setPixColor(&color);
    // circle(20, 10, 7);
    // printf("Red circle drawn.\n");
    // FrameShow();

    return 0;
}
