#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/fb.h>
#include "agra.h"

void save_as_bmp(const char *filename, uint32_t *buffer, int width, int height) {
    FILE *f;
    int filesize = 54 + 3 * width * height; // 54 bytes header, then RGB data

    unsigned char bmpfileheader[14] = {'B', 'M', 0, 0, 0, 0, 0, 0, 0, 0, 54, 0, 0, 0};
    unsigned char bmpinfoheader[40] = {40, 0, 0, 0, 0, 0, 0, 0, 1, 0, 24, 0};

    bmpfileheader[2] = (unsigned char)(filesize);
    bmpfileheader[3] = (unsigned char)(filesize >> 8);
    bmpfileheader[4] = (unsigned char)(filesize >> 16);
    bmpfileheader[5] = (unsigned char)(filesize >> 24);

    bmpinfoheader[4] = (unsigned char)(width);
    bmpinfoheader[5] = (unsigned char)(width >> 8);
    bmpinfoheader[6] = (unsigned char)(width >> 16);
    bmpinfoheader[7] = (unsigned char)(width >> 24);
    bmpinfoheader[8] = (unsigned char)(height);
    bmpinfoheader[9] = (unsigned char)(height >> 8);
    bmpinfoheader[10] = (unsigned char)(height >> 16);
    bmpinfoheader[11] = (unsigned char)(height >> 24);

    f = fopen(filename, "wb");
    if (!f) {
        perror("Error opening file");
        return;
    }

    fwrite(bmpfileheader, 1, 14, f);
    fwrite(bmpinfoheader, 1, 40, f);

    for (int y = height - 1; y >= 0; y--) { // BMP saves pixels bottom to top
        for (int x = 0; x < width; x++) {
            uint32_t pixel = buffer[y * width + x];
            unsigned char r = (pixel >> 16) & 0xFF;
            unsigned char g = (pixel >> 8) & 0xFF;
            unsigned char b = pixel & 0xFF;
            unsigned char color[3] = {b, g, r}; // BMP uses BGR format
            fwrite(color, 1, 3, f);
        }
    }

    fclose(f);
}

int main() {
    int fb_fd = open("/dev/fb0", O_RDONLY); // Open framebuffer for reading
    if (fb_fd == -1) {
        perror("Error opening framebuffer");
        return 1;
    }

    struct fb_var_screeninfo vinfo;
    if (ioctl(fb_fd, FBIOGET_VSCREENINFO, &vinfo)) {
        perror("Error reading variable information");
        close(fb_fd);
        return 1;
    }

    int width = vinfo.xres_virtual;
    int height = vinfo.yres_virtual;
    int screensize = width * height * vinfo.bits_per_pixel / 8;

    uint32_t *buffer = malloc(screensize);
    if (!buffer) {
        perror("Error allocating buffer");
        close(fb_fd);
        return 1;
    }

    read(fb_fd, buffer, screensize); // Read framebuffer

    save_as_bmp("output.bmp", buffer, width, height);

    free(buffer);
    close(fb_fd);
    return 0;
}
