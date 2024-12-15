# Target executable name
TARGET = agra

# Object files needed for linking
OBJ = agra_main.o agra.o framebuffer.o

# Compilation flags for ARM assembly and C
ASFLAGS = -mcpu=xscale -alh=$*.lis -L
CFLAGS = -O0 -Wall -g
LDFLAGS = -g

# Cross-compiler tools for ARM architecture
CC = arm-linux-gnueabi-gcc
AS = arm-linux-gnueabi-as

# Header files to track dependencies
allhfiles = $(wildcard *.h)

# Directory containing test files
TESTDIR = test_data

.PHONY: all clean test

# Build the executable
all: $(TARGET)

# Link the object files to create the final executable
$(TARGET): $(OBJ)
	$(CC) $(LDFLAGS) -o $@ $^

# Compile the main C file with header dependency
agra_main.o: agra_main.c $(allhfiles)
	$(CC) $(CFLAGS) -o $@ -c $<

# Compile the framebuffer file
framebuffer.o: framebuffer.c $(allhfiles)
	$(CC) $(CFLAGS) -o $@ -c $<

# Assemble the assembly file for ARM architecture
agra.o: agra.s
	$(AS) $(ASFLAGS) -o $@ $<

# Test using qemu-arm to emulate ARM architecture
test: all
	@echo "Running tests..."
	@qemu-arm -L /usr/arm-linux-gnueabi ./$(TARGET)
	@echo "All tests completed."

# Clean object files and the target executable
clean:
	rm -f *.o $(TARGET) *.lis result.txt
