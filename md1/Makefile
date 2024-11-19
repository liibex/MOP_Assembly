# Target executable name
TARGET = md1

# Object files needed for linking
OBJ = $(TARGET)_main.o $(TARGET).o

# Compilation flags
ASFLAGS = -mcpu=xscale -alh=$*.lis -L
CFLAGS = -O0 -Wall
LDFLAGS = -g

# Cross-compiler tools for ARM architecture
CC = arm-linux-gnueabi-gcc
AS = arm-linux-gnueabi-as

# Header files to track dependencies
allhfiles = $(wildcard *.h)

.PHONY: all clean test

# Build the executable
all: $(TARGET)

# Link the object files to create the final executable
$(TARGET): $(OBJ)
	$(CC) $(LDFLAGS) -o $@ $^

# Compile the main C file with header dependency
$(TARGET)_main.o: $(TARGET)_main.c $(allhfiles)
	$(CC) -g $(CFLAGS) -o $@ -c $<

# Assemble the assembly file for ARM architecture
$(TARGET).o: $(TARGET).s
	$(AS) -g $(ASFLAGS) -o $@ $<

# Test using qemu-arm to emulate ARM architecture
# test: all
# 	qemu-arm -L /usr/arm-linux-gnueabi ./$(TARGET) 10

# Test function to run multiple test cases
test: all
	@echo "Running tests..."
	@$(MAKE) -s test_case INPUT=10 EXPECTED=55
	@$(MAKE) -s test_case INPUT=0 EXPECTED=0
	@$(MAKE) -s test_case INPUT=1 EXPECTED=1
	@$(MAKE) -s test_case INPUT=100 EXPECTED=5050
	@$(MAKE) -s test_case INPUT=65535 EXPECTED=2147450880
	@$(MAKE) -s test_case INPUT=65536 EXPECTED=0
	@$(MAKE) -s test_case INPUT= EXPECTED=0
	@$(MAKE) -s test_case INPUT=-1 EXPECTED=0
	@$(MAKE) -s test_case INPUT=e EXPECTED=0
	@echo "All tests completed."

# Test individual cases by checking the output
test_case:
	@echo "Testing input $(INPUT)..."
	@ACTUAL=`qemu-arm -L /usr/arm-linux-gnueabi ./$(TARGET) $(INPUT)`; \
	if [ "$$ACTUAL" = "$(EXPECTED)" ]; then \
		echo "PASS: Input $(INPUT), Expected $(EXPECTED), Got $$ACTUAL"; \
	else \
		echo "FAIL: Input $(INPUT), Expected $(EXPECTED), Got $$ACTUAL"; \
		exit 1; \
	fi

# Clean object files and the target executable
clean:
	rm -f *.o $(TARGET)
