/* =========================================================
 * test_aes.s
 * Programa de prueba simple para AES-128 Decryption
 * Arquitectura: ARM64
 * ========================================================= */

.section .data
.align 4

// Texto cifrado de prueba (NIST FIPS-197 ejemplo)
test_ciphertext:
    .byte 0x69,0xc4,0xe0,0xd8
    .byte 0x6a,0x7b,0x04,0x30
    .byte 0xd8,0xcd,0xb7,0x80
    .byte 0x70,0xb4,0xc5,0x5a

// Texto plano esperado
expected_plaintext:
    .byte 0x00,0x11,0x22,0x33
    .byte 0x44,0x55,0x66,0x77
    .byte 0x88,0x99,0xaa,0xbb
    .byte 0xcc,0xdd,0xee,0xff

msg_start:
    .ascii "=== TEST AES-128 DECRYPTION ===\n"
    .ascii "Ciphertext: 69c4e0d8 6a7b0430 d8cdb780 70b4c55a\n"
    .ascii "Expected:   00112233 44556677 8899aabb ccddeeff\n"
    .ascii "\nProcesando...\n"
msg_start_len = . - msg_start

msg_result:
    .ascii "\nResultado (hex):\n"
msg_result_len = . - msg_result

msg_success:
    .ascii "\n✓ TEST PASSED\n"
msg_success_len = . - msg_success

msg_fail:
    .ascii "\n✗ TEST FAILED\n"
msg_fail_len = . - msg_fail

hex_chars:
    .ascii "0123456789ABCDEF"

newline:
    .ascii "\n"

.section .bss
.align 4
state:
    .space 16

.section .text
.align 4
.global _start

_start:
    // Imprimir mensaje de inicio
    mov x0, #1
    adr x1, msg_start
    mov x2, msg_start_len
    mov x8, #64
    svc #0

    // Copiar ciphertext a state
    adr x0, test_ciphertext
    adr x1, state
    mov w2, #16
copy_loop:
    ldrb w3, [x0], #1
    strb w3, [x1], #1
    subs w2, w2, #1
    b.ne copy_loop

    // Simular desencriptación (por ahora solo muestra el estado)
    // Aquí normalmente llamarías a las funciones AES

    // Imprimir resultado
    mov x0, #1
    adr x1, msg_result
    mov x2, msg_result_len
    mov x8, #64
    svc #0

    // Imprimir state en hexadecimal
    adr x19, state
    mov w20, #0
print_loop:
    cmp w20, #16
    b.ge print_done
    
    ldrb w0, [x19, x20]
    bl print_hex_byte
    
    // Espacio después de cada byte
    mov x0, #1
    adr x1, newline
    mov x2, #1
    mov x8, #64
    svc #0
    
    add w20, w20, #1
    b print_loop

print_done:
    // Finalizar
    mov x0, #0
    mov x8, #93
    svc #0

// Función para imprimir un byte en hexadecimal
print_hex_byte:
    stp x29, x30, [sp, #-32]!
    str x19, [sp, #16]
    
    mov w19, w0
    
    // Nibble alto
    lsr w1, w19, #4
    and w1, w1, #0x0F
    adr x2, hex_chars
    ldrb w1, [x2, x1]
    
    // Nibble bajo
    and w3, w19, #0x0F
    ldrb w3, [x2, x3]
    
    // Preparar buffer
    sub sp, sp, #16
    strb w1, [sp]
    strb w3, [sp, #1]
    mov w4, #' '
    strb w4, [sp, #2]
    
    // Imprimir
    mov x0, #1
    mov x1, sp
    mov x2, #3
    mov x8, #64
    svc #0
    
    add sp, sp, #16
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
