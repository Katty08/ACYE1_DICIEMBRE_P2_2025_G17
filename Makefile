# =========================================
# Makefile - AES-128 ARMv7
# =========================================

AS = as
LD = ld

OBJS = main.o key_expand.o inv_mix.o add_round.o inv_shift.o inv_sub.o

all: aes

aes: $(OBJS)
	$(LD) -o aes $(OBJS)

%.o: %.s
	$(AS) -o $@ $<

clean:
	rm -f *.o aes
