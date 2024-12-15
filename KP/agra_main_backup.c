#include "agra.h"
#include <stdio.h>

int main() {
    pixcolor_t color;

    printf("Clearing the frame buffer...\n");
    for (int y = 0; y < FrameBufferGetHeight(); y++) {
        for (int x = 0; x < FrameBufferGetWidth(); x++) {
            color.r = 0;
            color.g = 0;
            color.b = 0;
            color.op = 0;
            pixel(x, y, &color);
        }
    }
    FrameShow();

    printf("Drawing a white pixel at (25, 2)...\n");
    color.r = 0x03FF;
    color.g = 0x03FF;
    color.b = 0x03FF;
    color.op = 0;
    printf("Packed value in R7: 0x%08X\n", *((uint32_t*)&color));
    setPixColor(&color);
    pixel(25, 2, &color);
    FrameShow();

    return 0;
}
