# Makefile para proyecto AES

# Compilador y enlazador
AS = aarch64-linux-gnu-as
LD = aarch64-linux-gnu-ld

# Archivos fuente
SRCS = constants.s utils.s keys.s inverse.s functions.s decrypt.s main.s
OBJS = $(SRCS:.s=.o)
TARGET = proyecto

# Reglas
all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) -o $@ $^

%.o: %.s
	$(AS) -o $@ $<

# Limpiar
clean:
	rm -f $(OBJS) $(TARGET)

# Ejecutar con QEMU
run: $(TARGET)
	qemu-aarch64 ./$(TARGET)

.PHONY: all clean run