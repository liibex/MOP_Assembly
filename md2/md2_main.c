#include <stdlib.h>
#include <stdio.h>
#include "md2.h"

// matmul prototips
// int matmul( int h1, int w1, int *m1, int h2, int w2, int *m2, int *m3 );
// m3 -> resulting matrix

int main(int argc, char const *argv[]) {
    int h1, w1, h2, w2;
    int *m1, *m2, *m3;

    // Read h1, w1, m1
    scanf("%d", &h1);
    scanf("%d", &w1);

    m1 = (int*) malloc(h1 * w1 * sizeof(int));
    if (m1 == NULL) return 1;

    for (int i = 0; i < h1 * w1; i++) {
        scanf("%d", &m1[i]);
    }

    // Read h2, w2, m2
    scanf("%d", &h2);
    scanf("%d", &w2);

    m2 = (int*) malloc(h2 * w2 * sizeof(int));
    if (m2 == NULL) {
        free(m1);
        return 1;
    }

    for (int i = 0; i < h2 * w2; i++) {
        scanf("%d", &m2[i]);
    }

    // For matrix multiplication, the number of columns in the first matrix 
    // must be equal to the number of rows in the second matrix.
    // if (w1 != h2) {
    //     free(m1);
    //     free(m2);
    //     return 1;
    // }

    // Allocate memory for m3
    m3 = (int*) malloc(h1 * w2 * sizeof(int));
    if (m3 == NULL) {
        free(m1);
        free(m2);
        return 1;
    }

    // Call the assembly function matmul
    int res = matmul(h1, w1, m1, h2, w2, m2, m3);
    if (res != 0) {
        free(m1);
        free(m2);
        free(m3);
        return 1;
    }

    // Print result:
    // w3 h3
    // m3 
    printf("%d %d\n", h1, w2);
    for (int i = 0; i < h1; i++) {
        for (int j = 0; j < w2; j++) {
            printf("%d ", m3[i * w2 + j]);
        }
        printf("\n");
    }

    // Free allocated memory
    free(m1);
    free(m2);
    free(m3);

    return 0;
}
