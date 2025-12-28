.section .text

.global rotWord
.global subWord
.global convertHexKey
.global convertHexBlock16
.global is_hex_char
.global hex_char_to_nibble

// Declarar referencias externas
.extern Sbox
.extern buffer
.extern lastKey
.extern key_err_msg
.extern msg_last_key
.extern msg_ciphertext

rotWord:
    ldrb w1, [x0, #0]
    ldrb w2, [x0, #1]
    ldrb w3, [x0, #2]
    ldrb w4, [x0, #3]
    strb w2, [x0, #0]
    strb w3, [x0, #1]
    strb w4, [x0, #2]
    strb w1, [x0, #3]
    ret

subWord:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    str x20, [sp, #24]
    mov x19, x0
    ldr x20, =Sbox
    mov x1, #0
subword_loop:
    cmp x1, #4
    b.ge subword_done
    ldrb w2, [x19, x1]
    uxtw x2, w2
    ldrb w3, [x20, x2]
    strb w3, [x19, x1]
    add x1, x1, #1
    b subword_loop
subword_done:
    ldr x19, [sp, #16]
    ldr x20, [sp, #24]
    ldp x29, x30, [sp], #32
    ret

is_hex_char:
    cmp w4, #'0'
    b.lt not_hex
    cmp w4, #'9'
    b.le is_hex
    orr w4, w4, #0x20
    cmp w4, #'a'
    b.lt not_hex
    cmp w4, #'f'
    b.le is_hex
not_hex:
    mov w0, #0
    ret
is_hex:
    mov w0, #1
    ret

hex_char_to_nibble:
    cmp w4, #'0'
    b.lt hex_error
    cmp w4, #'9'
    b.le hex_digit
    orr w4, w4, #0x20
    cmp w4, #'a'
    b.lt hex_error
    cmp w4, #'f'
    b.gt hex_error
    sub w0, w4, #'a'
    add w0, w0, #10
    ret
hex_digit:
    sub w0, w4, #'0'
    ret
hex_error:
    mov w0, #0xFF
    ret

convertHexKey:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    str x19, [sp, #16]
    str x20, [sp, #24]
    str x21, [sp, #32]
    
    // Leer entrada
    mov x0, #0
    ldr x1, =buffer
    mov x2, #33
    mov x8, #63
    svc #0
    
    ldr x1, =buffer
    ldr x2, =lastKey
    mov x3, #0
    mov x11, #0
convert_hex_loop:
    cmp x3, #16
    b.ge convert_hex_done
skip_non_hex:
    ldrb w4, [x1, x11]
    cmp w4, #0
    b.eq convert_hex_done
    cmp w4, #10
    b.eq convert_hex_done
    
    // Verificar si es carácter hexadecimal
    cmp w4, #'0'
    b.lt not_hex_char
    cmp w4, #'9'
    b.le process_hex_pair
    orr w4, w4, #0x20
    cmp w4, #'a'
    b.lt not_hex_char
    cmp w4, #'f'
    b.gt not_hex_char
    b process_hex_pair
    
not_hex_char:
    add x11, x11, #1
    b skip_non_hex

process_hex_pair:
    // Primer nibble
    ldrb w4, [x1, x11]
    add x11, x11, #1
    bl hex_char_to_nibble
    cmp w0, #0xFF
    b.eq hex_error_convert
    lsl w5, w0, #4
    
    // Segundo nibble
    ldrb w4, [x1, x11]
    add x11, x11, #1
    bl hex_char_to_nibble
    cmp w0, #0xFF
    b.eq hex_error_convert
    orr w5, w5, w0
    strb w5, [x2, x3]
    add x3, x3, #1
    b convert_hex_loop

hex_error_convert:
    // Imprimir error
    mov x0, #1
    ldr x1, =key_err_msg
    mov x2, #33
    mov x8, #64
    svc #0

convert_hex_done:
    ldr x21, [sp, #32]
    ldr x20, [sp, #24]
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

convertHexBlock16:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    str x19, [sp, #16]
    str x20, [sp, #24]
    str x0, [sp, #32]  // Guardar destino
    
    // Leer entrada
    mov x0, #0
    ldr x1, =buffer
    mov x2, #65
    mov x8, #63
    svc #0
    
    ldr x19, [sp, #32]  // Destino
    ldr x20, =buffer     // Fuente
    mov x21, #0          // Índice destino
    mov x22, #0          // Índice fuente

hex_block_loop:
    cmp x21, #16
    b.ge hex_block_done
    
    ldrb w4, [x20, x22]
    cbz w4, hex_block_done
    cmp w4, #10
    b.eq hex_block_done
    cmp w4, #' '
    b.eq skip_char_block
    
    // Primer nibble
    bl hex_char_to_nibble
    cmp w0, #0xFF
    b.eq skip_char_block
    lsl w5, w0, #4
    
    // Avanzar para segundo nibble
    add x22, x22, #1
    ldrb w4, [x20, x22]
    cbz w4, hex_block_done
    cmp w4, #10
    b.eq hex_block_done
    
skip_spaces:
    cmp w4, #' '
    b.ne process_second
    add x22, x22, #1
    ldrb w4, [x20, x22]
    cbz w4, hex_block_done
    cmp w4, #10
    b.eq hex_block_done
    b skip_spaces

process_second:
    bl hex_char_to_nibble
    cmp w0, #0xFF
    b.eq skip_char_block
    orr w5, w5, w0
    strb w5, [x19, x21]
    add x21, x21, #1
    b next_char_block

skip_char_block:
    add x22, x22, #1
    b hex_block_loop

next_char_block:
    add x22, x22, #1
    b hex_block_loop

hex_block_done:
    ldr x0, [sp, #32]
    ldr x20, [sp, #24]
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #48
    ret



    