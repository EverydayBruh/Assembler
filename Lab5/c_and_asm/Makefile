CC = gcc
CFLAGS = -Wall -Wextra -std=c99
ASM = nasm
ASMFLAGS = -f elf64
LDFLAGS = -lm -no-pie -lc

TARGET = lab
SOURCES = lab.c
ASM_SOURCES = copy.s
OBJECTS = $(SOURCES:.c=.o)
ASM_OBJECTS = $(ASM_SOURCES:.s=.o)

all: $(TARGET)

$(TARGET): $(OBJECTS) $(ASM_OBJECTS)
	$(CC) $(CFLAGS) -o $@ $(OBJECTS) $(ASM_OBJECTS) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $<

%.o: %.s
	$(ASM) $(ASMFLAGS) $< -o $@

clean:
	rm -f $(TARGET) $(OBJECTS) $(ASM_OBJECTS)
