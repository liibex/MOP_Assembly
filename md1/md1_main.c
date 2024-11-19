#include <stdio.h>
#include <stdlib.h>
#include "md1.h"

int main(int argc, char *argv[]) {
    if (argc != 2) {
        // printf("Usage: %s <n>\n", argv[0]);
        printf("%u\n", 0);
        return 1;
    }

    unsigned int n = atoi(argv[1]);  // input to integer
    unsigned int result = asum(n);   // Assembler asum

    printf("%u\n", result);          // Print result
    return 0;
}