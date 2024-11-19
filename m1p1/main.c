#include <stdio.h>
#include <stdlib.h>
#include "m1p1.h"

int main() {
    char buffer[256]; // Define a buffer with a fixed size
    if (fgets(buffer, sizeof(buffer), stdin) == NULL) {
        return 1;
    }

    // Call the assembly function to convert the string to title case
    m1p1(buffer);

    // Print the result
    printf("%s", buffer);

    return 0;
}