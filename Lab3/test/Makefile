AS = nasm
LD = ld

ASFLAGS = -g -f elf64
LDFLAGS = -static

#SRCS = lab1.s env.s
SRCS = lab.s
OBJS = $(SRCS:.s=.o)

EXE = lab

all: $(SRCS) $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@ 

.s.o:
	$(AS) $(ASFLAGS) $< -o $@ 
