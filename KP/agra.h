#ifndef AGRA_H
#define AGRA_H

#include <stdint.h>

// Krāsas tips punktam
typedef struct {
    unsigned int r  : 10; // Sarkanais komponents (10 biti)
    unsigned int g  : 10; // Zaļais komponents (10 biti)
    unsigned int b  : 10; // Zilais komponents (10 biti)
    unsigned int op : 2;  // Operācija (2 biti)
} pixcolor_t;

// Operāciju iespējas pikseļiem ar fona (FrameBuffer) krāsu
typedef enum {
    PIXEL_COPY = 0, // Kopēt pikseļa krāsu pāri fonam
    PIXEL_AND  = 1, // AND operācija ar fona krāsu
    PIXEL_OR   = 2, // OR operācija ar fona krāsu
    PIXEL_XOR  = 3  // XOR operācija ar fona krāsu
} pixop_t;

// Funkcijas prototipi
void setPixColor(pixcolor_t *color_op);                  // Iestatīt pašreizējo krāsu
void pixel(int x, int y, pixcolor_t *color_op);          // Zīmēt pikseli
void line(int x1, int y1, int x2, int y2);               // Zīmēt līniju starp punktiem
void triangleFill(int x1, int y1, int x2, int y2, int x3, int y3); // Aizpildīt trijstūri
void circle(int x, int y, int radius);                  // Zīmēt riņķa līniju

// FrameBuffer funkcijas
pixcolor_t* FrameBufferGetAddress(); // Atgriež bufera sākuma adresi
int FrameBufferGetWidth();           // Atgriež bufera platumu
int FrameBufferGetHeight();          // Atgriež bufera augstumu
int FrameShow();                     // Izvada bufera saturu uz "displeja"

#endif // AGRA_H
