AS = nasm
LD = gcc

LDFLAGS = -no-pie
NASMFLAGS = -f elf64 -g
CFLAGS = -fPIE
SRCS = lab.s
OBJS = $(SRCS:.s=.o)
LIBS = -lm

EXE = lab

all: $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) $(LIBS) -o $@

.s.o:
	$(AS) $(NASMFLAGS) $< -o $@

.c.o:
	$(LD) $(CFLAGS) -c $< -o $@
