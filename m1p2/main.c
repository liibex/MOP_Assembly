#include <stdio.h>
#include <stdlib.h>
#include "m1p2.h"  // Include the header file for m1p2

int main() {
    int N;

    // Read an integer from standard input
    // printf("Enter a positive integer: ");
    if (scanf("%d", &N) != 1 || N <= 0) {
        // fprintf(stderr, "Invalid input. Please enter a positive integer.\n");
        return 1;
    }

    // Call the assembly function m1p2 with the integer N
    m1p2(N);

    return 0;
}