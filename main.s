/* Programa AES-128 descifrado completo */
.section .data
.align 4

state:
    .space 16
    
key:
    .space 16

temp_buffer:
    .space 16

expanded_keys:
    .space 176

input_buffer:
    .space 128

hex_buffer:
    .space 3

msg_title:
    .asciz "=== AES-128 DECRYPT ===\n"
msg_cipher:
    .asciz "Ciphertext (hex): "
msg_key:
    .asciz "Key (hex): "
msg_expand:
    .asciz "\n[*] Expandiendo clave...\n"
msg_decrypt:
    .asciz "[*] Descifrando...\n"
msg_result:
    .asciz "\n[+] Plaintext: "
msg_nl:
    .asciz "\n"

// Vectores de prueba FIPS-197 (Appendix B)
// Plaintext: "Two One Nine Two" -> 54 77 6F 20 4F 6E 65 20 4E 69 6E 65 20 54 77 6F
// Ciphertext: 29 C3 50 5F 57 14 20 F6 40 22 99 B3 1A 02 D7 3A
// Key: "Thats my Kung Fu" -> 54 68 61 74 73 20 6D 79 20 4B 75 6E 67 20 46 75
test_plain_ref:
    .byte 0x54,0x77,0x6F,0x20,0x4F,0x6E,0x65,0x20
    .byte 0x4E,0x69,0x6E,0x65,0x20,0x54,0x77,0x6F
test_cipher_ref:
    .byte 0x29,0xC3,0x50,0x5F,0x57,0x14,0x20,0xF6
    .byte 0x40,0x22,0x99,0xB3,0x1A,0x02,0xD7,0x3A
test_key_ref:
    .byte 0x54,0x68,0x61,0x74,0x73,0x20,0x6D,0x79
    .byte 0x20,0x4B,0x75,0x6E,0x67,0x20,0x46,0x75

msg_test_ok:
    .asciz "[SELF-TEST] OK (FIPS-197 B)\n"
msg_test_fail:
    .asciz "[SELF-TEST] FAIL (FIPS-197 B)\n"

.section .text
.align 4
.global _start

/* Funciones externas */
.extern key_expand
.extern inv_shift
.extern inv_sub
.extern add_round
.extern inv_mix

_start:
    // Self-test de descifrado con vector FIPS-197
    bl self_test

    // Title
    mov x0, #1
    adr x1, msg_title
    mov x2, #24
    mov x8, #64
    svc #0
    
    // Prompt ciphertext
    mov x0, #1
    adr x1, msg_cipher
    mov x2, #18
    mov x8, #64
    svc #0
    
    // Read
    mov x0, #0
    adr x1, input_buffer
    mov x2, #100
    mov x8, #63
    svc #0
    
    // Convert ciphertext hex to bytes
    adr x0, input_buffer
    adr x1, state
    mov w2, #16
    bl hex_to_bytes
    
    // Prompt key
    mov x0, #1
    adr x1, msg_key
    mov x2, #11
    mov x8, #64
    svc #0
    
    // Read
    mov x0, #0
    adr x1, input_buffer
    mov x2, #100
    mov x8, #63
    svc #0
    
    // Convert key hex to bytes
    adr x0, input_buffer
    adr x1, key
    mov w2, #16
    bl hex_to_bytes
    
    // Expandir clave
    mov x0, #1
    adr x1, msg_expand
    mov x2, #26
    mov x8, #64
    svc #0
    
    adr x0, key
    adr x1, expanded_keys
    bl key_expand
    
    // Mensaje descifrado
    mov x0, #1
    adr x1, msg_decrypt
    mov x2, #19
    mov x8, #64
    svc #0
    
    // Ejecutar núcleo de descifrado sobre state/expanded_keys
    bl aes_decrypt_core
    
    // Show result message
    mov x0, #1
    adr x1, msg_result
    mov x2, #13
    mov x8, #64
    svc #0
    
    // Print state as hex (sin conversión)
    adr x0, state
    mov w1, #16
    bl print_hex
    
    // Newline
    mov x0, #1
    adr x1, msg_nl
    mov x2, #1
    mov x8, #64
    svc #0
    
    // Exit
    mov x0, #0
    mov x8, #93
    svc #0

/* Núcleo del descifrado AES-128 (usa state y expanded_keys globales) */
aes_decrypt_core:
    // Ronda inicial: AddRoundKey(10) con W[40-43]
    adr x0, state
    adr x1, expanded_keys
    add x1, x1, #160      // offset 160 = W[40]
    bl add_round
    
    // Rondas 9 a 1: InvShift → InvSub → AddRoundKey → InvMix
    mov w19, #9
decrypt_loop:
    cmp w19, #0
    b.le final_round
    
    // InvShiftRows
    adr x0, state
    bl inv_shift
    
    // InvSubBytes
    adr x0, state
    bl inv_sub
    
    // AddRoundKey
    adr x0, state
    adr x1, expanded_keys
    mov w2, #16
    mul w2, w19, w2
    add x1, x1, x2
    bl add_round
    
    // InvMixColumns
    adr x0, state
    bl inv_mix
    
    // Siguiente ronda
    subs w19, w19, #1
    b decrypt_loop
    
    // Ronda final (0): InvShift → InvSub → AddRoundKey
final_round:
    adr x0, state
    bl inv_shift
    
    adr x0, state
    bl inv_sub
    
    adr x0, state
    adr x1, expanded_keys    // W[0-3] = offset 0
    bl add_round
    
    ret

/* Self-test: descifra el vector FIPS-197 B y comprueba el resultado */
self_test:
    stp x19, x20, [sp, #-64]!
    stp x21, x22, [sp, #16]
    stp x23, x24, [sp, #32]
    stp x29, x30, [sp, #48]

    // Copiar ciphertext de prueba a state
    adr x19, test_cipher_ref
    adr x20, state
    mov w21, #16
st_copy_ct:
    ldrb w22, [x19], #1
    strb w22, [x20], #1
    subs w21, w21, #1
    b.ne st_copy_ct

    // Copiar key de prueba a key
    adr x19, test_key_ref
    adr x20, key
    mov w21, #16
st_copy_k:
    ldrb w22, [x19], #1
    strb w22, [x20], #1
    subs w21, w21, #1
    b.ne st_copy_k

    // Expandir clave de prueba
    adr x0, key
    adr x1, expanded_keys
    bl key_expand

    // Ejecutar descifrado sobre state
    bl aes_decrypt_core

    // Comparar state con plaintext de referencia
    adr x19, state
    adr x20, test_plain_ref
    mov w21, #16
    mov w22, #0          // flag: 0 = iguales, 1 = distintos
st_cmp_loop:
    ldrb w23, [x19], #1
    ldrb w24, [x20], #1
    cmp  w23, w24
    b.eq st_cmp_next
    mov  w22, #1
st_cmp_next:
    subs w21, w21, #1
    b.ne st_cmp_loop

    // Imprimir resultado
    mov x0, #1
    cmp w22, #0
    b.ne st_fail
    adr x1, msg_test_ok
    b st_print
st_fail:
    adr x1, msg_test_fail
st_print:
    // calcular longitud rápida (recorre hasta 0)
    mov x2, #0
st_len_loop:
    ldrb w23, [x1, x2]
    cbz  w23, st_len_done
    add  x2, x2, #1
    b    st_len_loop
st_len_done:
    mov x8, #64
    svc #0

    ldp x29, x30, [sp, #48]
    ldp x21, x22, [sp, #16]
    ldp x23, x24, [sp, #32]
    ldp x19, x20, [sp], #64
    ret

/* Convert column-major to row-major */
col_to_row:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]
    
    mov x19, x0              // state pointer
    sub sp, sp, #16          // temp buffer
    mov x20, sp
    
    // Copy to temp
    mov w21, #0
ctr_copy:
    ldrb w1, [x19, x21]
    strb w1, [x20, x21]
    add w21, w21, #1
    cmp w21, #16
    b.lt ctr_copy
    
    // Convert: col-major[i] -> row-major[row*4 + col]
    // where row = i % 4, col = i / 4
    mov w21, #0
ctr_loop:
    cmp w21, #16
    b.ge ctr_done
    
    // row = i % 4
    and w1, w21, #3
    // col = i / 4
    lsr w2, w21, #2
    // new_index = row * 4 + col
    lsl w1, w1, #2
    add w1, w1, w2
    
    ldrb w3, [x20, x21]
    strb w3, [x19, x1]
    
    add w21, w21, #1
    b ctr_loop
    
ctr_done:
    add sp, sp, #16
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

/* Convert row-major to column-major */
row_to_col:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]
    
    mov x19, x0              // dest pointer
    mov x20, x1              // src pointer
    
    // Convert: row-major[i] -> col-major[col*4 + row]
    // where row = i / 4, col = i % 4
    mov w21, #0
rtc_loop:
    cmp w21, #16
    b.ge rtc_done
    
    // row = i / 4
    lsr w1, w21, #2
    // col = i % 4
    and w2, w21, #3
    // new_index = col * 4 + row
    lsl w2, w2, #2
    add w2, w2, w1
    
    ldrb w3, [x20, x21]
    strb w3, [x19, x2]
    
    add w21, w21, #1
    b rtc_loop
    
rtc_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

/* Hex to bytes */
hex_to_bytes:
    stp x29, x30, [sp, #-64]!
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    
    mov x19, x0      // input
    mov x20, x1      // output
    mov w21, #0      // count
    mov w22, #0      // index
    
h2b_loop:
    cmp w21, w2
    b.ge h2b_done
    
    // First nibble
h2b_skip1:
    ldrb w0, [x19, x22]
    add w22, w22, #1
    cmp w0, #10
    b.eq h2b_done
    cmp w0, #13
    b.eq h2b_skip1
    cmp w0, #32
    b.eq h2b_skip1
    cmp w0, #0
    b.eq h2b_done
    
    bl hex_val
    lsl w4, w0, #4
    
    // Second nibble  
h2b_skip2:
    ldrb w0, [x19, x22]
    add w22, w22, #1
    cmp w0, #10
    b.eq h2b_done
    cmp w0, #13
    b.eq h2b_skip2
    cmp w0, #32
    b.eq h2b_skip2
    cmp w0, #0
    b.eq h2b_done
    
    bl hex_val
    orr w4, w4, w0
    
    // Store
    strb w4, [x20, x21]
    add w21, w21, #1
    b h2b_loop
    
h2b_done:
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

hex_val:
    cmp w0, #'a'
    b.lt hv_upper
    sub w0, w0, #87
    ret
hv_upper:
    cmp w0, #'A'
    b.lt hv_digit
    sub w0, w0, #55
    ret
hv_digit:
    sub w0, w0, #48
    ret

/* Print hex */
print_hex:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    
    mov x19, x0      // pointer
    mov w20, w1      // count
    
    adr x21, hex_buffer
    
ph_loop:
    cbz w20, ph_done
    
    ldrb w0, [x19], #1
    
    // High nibble
    lsr w2, w0, #4
    and w2, w2, #0xF
    cmp w2, #10
    b.lt ph_h_dig
    add w2, w2, #55
    b ph_h_ok
ph_h_dig:
    add w2, w2, #48
ph_h_ok:
    strb w2, [x21]
    
    // Low nibble
    and w2, w0, #0xF
    cmp w2, #10
    b.lt ph_l_dig
    add w2, w2, #55
    b ph_l_ok
ph_l_dig:
    add w2, w2, #48
ph_l_ok:
    strb w2, [x21, #1]
    
    // Write
    mov x0, #1
    mov x1, x21
    mov x2, #2
    mov x8, #64
    svc #0
    
    sub w20, w20, #1
    b ph_loop
    
ph_done:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret
