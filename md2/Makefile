# Target executable name
TARGET = md2

# Object files needed for linking
OBJ = $(TARGET)_main.o $(TARGET).o

# Compilation flags for ARM assembly and C
ASFLAGS = -mcpu=xscale -alh=$*.lis -L
CFLAGS = -O0 -Wall
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
$(TARGET)_main.o: $(TARGET)_main.c $(allhfiles)
	$(CC) -g $(CFLAGS) -o $@ -c $<

# Assemble the assembly file for ARM architecture
$(TARGET).o: $(TARGET).s
	$(AS) -g $(ASFLAGS) -o $@ $<

# Test using qemu-arm to emulate ARM architecture
test: all
	@echo "Running tests..."
	@$(MAKE) -s test_case INFILE=$(TESTDIR)/infile1.txt OUTFILE=$(TESTDIR)/outfile1.txt EXPECT=0
	@$(MAKE) -s test_case INFILE=$(TESTDIR)/infile2.txt OUTFILE=$(TESTDIR)/outfile2.txt EXPECT=0
	@$(MAKE) -s test_case INFILE=$(TESTDIR)/infile3.txt OUTFILE=$(TESTDIR)/outfile3.txt EXPECT=0
	@$(MAKE) -s test_case INFILE=$(TESTDIR)/infile4.txt OUTFILE=$(TESTDIR)/outfile4.txt EXPECT=1
	@$(MAKE) -s test_case INFILE=$(TESTDIR)/infile5.txt OUTFILE=$(TESTDIR)/outfile5.txt EXPECT=0
	@$(MAKE) -s test_case INFILE=$(TESTDIR)/infile6.txt OUTFILE=$(TESTDIR)/outfile6.txt EXPECT=1
	@$(MAKE) -s test_case INFILE=$(TESTDIR)/infile7.txt OUTFILE=$(TESTDIR)/outfile7.txt EXPECT=1
	@$(MAKE) -s test_case INFILE=$(TESTDIR)/infile8.txt OUTFILE=$(TESTDIR)/outfile8.txt EXPECT=1
	@$(MAKE) -s test_case INFILE=$(TESTDIR)/infile9.txt OUTFILE=$(TESTDIR)/outfile9.txt EXPECT=1
	@echo "All tests completed."

# Test individual cases by checking the output and the exit status
test_case:
	@echo "Testing with input file: $(INFILE) (expected result: $(EXPECT))..."
	@qemu-arm -L /usr/arm-linux-gnueabi ./$(TARGET) < $(INFILE) > result.txt; \
	EXIT_STATUS=$$?; \
	if [ "$$EXIT_STATUS" -eq "$(EXPECT)" ]; then \
		if [ "$(EXPECT)" -eq "0" ]; then \
			diff -q result.txt $(OUTFILE) && echo "PASS" || (echo "FAIL" && exit 1); \
		else \
			echo "PASS"; \
		fi \
	else \
		echo "FAIL"; \
		exit 1; \
	fi

# Clean object files and the target executable
clean:
	rm -f *.o $(TARGET) *.lis result.txt
