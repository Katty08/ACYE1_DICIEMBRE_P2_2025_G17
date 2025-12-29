AS   = aarch64-linux-gnu-as
LD   = aarch64-linux-gnu-ld
QEMU = qemu-aarch64

TARGET = aes

OBJS = \
	main.o \
	io.o \
	key_expansion.o \
	add_round_key.o \
	inv_shift_rows.o \
	inv_sub_bytes.o \
	tables.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) -o $(TARGET) $(OBJS)

%.o: %.s
	$(AS) -g -o $@ $<

run: $(TARGET)
	$(QEMU) ./$(TARGET)

clean:
	rm -f *.o $(TARGET)