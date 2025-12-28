/****************************************************
 * io.s
 * Entrada / Salida - AES ARM64
 ****************************************************/

.section .data
newline:
    .byte 0x0A

hex_table:
    .ascii "0123456789ABCDEF"

.section .bss
.align 4
input_buffer:
    .space 64

output_buffer:
    .space 2

.section .text
.global read_hex_block
.global print_state
.global exit_program

/****************************************************
 * read_hex_block
 * x0 = destino (16 bytes)
 ****************************************************/
read_hex_block:
    // prólogo
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x19, x0                 // destino

    // ===== READ stdin =====
    mov x0, #0                  // stdin
    ldr x1, =input_buffer
    mov x2, #64                 // leer lo que haya
    mov x8, #63                 // sys_read
    svc #0

    // x0 = bytes leídos
    // si son menos de 32, no hay entrada válida
    cmp x0, #32
    blt read_fail

    // ===== convertir HEX -> bytes =====
    ldr x1, =input_buffer
    mov x2, #16                 // 16 bytes
    mov x3, #0

convert_loop:
    ldrb w4, [x1], #1
    bl hex_to_nibble
    lsl w5, w0, #4

    ldrb w4, [x1], #1
    bl hex_to_nibble
    orr w5, w5, w0

    strb w5, [x19], #1

    add x3, x3, #1
    cmp x3, x2
    bne convert_loop

    // epílogo
    ldp x29, x30, [sp], #16
    ret

read_fail:
    // salida limpia si no hubo datos suficientes
    mov x0, #1                  // stdout
    ldr x1, =newline
    mov x2, #1
    mov x8, #64                 // sys_write
    svc #0

    ldp x29, x30, [sp], #16
    ret

/****************************************************
 * hex_to_nibble
 * w4 = ASCII
 * retorna w0 = 0..15
 ****************************************************/
hex_to_nibble:
    cmp w4, #'0'
    blt hex_error
    cmp w4, #'9'
    ble is_digit

    cmp w4, #'A'
    blt hex_error
    cmp w4, #'F'
    ble is_upper

    cmp w4, #'a'
    blt hex_error
    cmp w4, #'f'
    ble is_lower

hex_error:
    mov w0, #0
    ret

is_digit:
    sub w0, w4, #'0'
    ret

is_upper:
    sub w0, w4, #'A'
    add w0, w0, #10
    ret

is_lower:
    sub w0, w4, #'a'
    add w0, w0, #10
    ret

/****************************************************
 * print_state
 * x0 = buffer (16 bytes)
 ****************************************************/
print_state:
    // prólogo
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x19, x0
    mov x20, #16

print_loop:
    ldrb w1, [x19], #1

    // nibble alto
    lsr w2, w1, #4
    uxtw x2, w2
    ldr x3, =hex_table
    ldrb w2, [x3, x2]

    // nibble bajo
    and w4, w1, #0x0F
    uxtw x4, w4
    ldrb w4, [x3, x4]

    ldr x5, =output_buffer
    strb w2, [x5]
    strb w4, [x5, #1]

    mov x0, #1                  // stdout
    mov x1, x5
    mov x2, #2
    mov x8, #64                 // sys_write
    svc #0

    subs x20, x20, #1
    bne print_loop

    // salto de línea
    mov x0, #1
    ldr x1, =newline
    mov x2, #1
    mov x8, #64
    svc #0

    // epílogo
    ldp x29, x30, [sp], #16
    ret

/****************************************************
 * exit_program
 ****************************************************/
exit_program:
    mov x0, #0
    mov x8, #93                 // sys_exit
    svc #0
