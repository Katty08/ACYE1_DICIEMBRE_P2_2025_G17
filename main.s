/* Programa AES-128 descifrado completo */
.section .data
.align 4

state:
    .space 16
    
key:
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
msg_state_matrix:
    .asciz "\n   Estado (matriz 4x4):\n   "
msg_after_invshift:
    .asciz "\n[->] Después de InvShiftRows:"
msg_after_invsub:
    .asciz "\n[->] Después de InvSubBytes:"
msg_after_addroundkey:
    .asciz "\n[->] Después de AddRoundKey:"
msg_after_invmix:
    .asciz "\n[->] Después de InvMixColumns:"
msg_round_num:
    .asciz "\n\n=== RONDA "
msg_round_end:
    .asciz " ==="
msg_subkey:
    .asciz "\n   Subclave utilizada: "

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
    
    // Convert
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
    
    // Convert
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
    
    // Mostrar subclaves expandidas
    bl print_expanded_keys
    
    /* ALGORITMO AES-128 DESCIFRADO */
    
    // Ronda inicial (10): AddRoundKey con W[40-43]
    adr x0, state
    adr x1, expanded_keys
    add x1, x1, #160      // offset 160 = W[40]
    bl add_round
    
    // Rondas intermedias (9 a 1)
    mov w19, #9
    
decrypt_loop:
    // Imprimir número de ronda
    mov x0, #1
    adr x1, msg_round_num
    mov x2, #14
    mov x8, #64
    svc #0
    
    mov w0, w19
    bl print_round_number
    
    mov x0, #1
    adr x1, msg_round_end
    mov x2, #4
    mov x8, #64
    svc #0
    
    // InvShiftRows
    adr x0, state
    bl inv_shift
    
    mov x0, #1
    adr x1, msg_after_invshift
    mov x2, #29
    mov x8, #64
    svc #0
    
    adr x0, state
    bl print_state_matrix
    
    // InvSubBytes
    adr x0, state
    bl inv_sub
    
    mov x0, #1
    adr x1, msg_after_invsub
    mov x2, #29
    mov x8, #64
    svc #0
    
    adr x0, state
    bl print_state_matrix
    
    // Mostrar subclave
    mov x0, #1
    adr x1, msg_subkey
    mov x2, #24
    mov x8, #64
    svc #0
    
    adr x1, expanded_keys
    mov w2, #16
    mul w2, w19, w2
    add x0, x1, x2
    mov w1, #16
    bl print_hex
    
    // AddRoundKey
    adr x0, state
    adr x1, expanded_keys
    mov w2, #16
    mul w2, w19, w2
    add x1, x1, x2
    bl add_round
    
    mov x0, #1
    adr x1, msg_after_addroundkey
    mov x2, #32
    mov x8, #64
    svc #0
    
    adr x0, state
    bl print_state_matrix
    
    // InvMixColumns
    adr x0, state
    bl inv_mix
    
    mov x0, #1
    adr x1, msg_after_invmix
    mov x2, #32
    mov x8, #64
    svc #0
    
    adr x0, state
    bl print_state_matrix
    
    // Siguiente ronda
    subs w19, w19, #1
    cmp w19, #0
    b.gt decrypt_loop
    
    // Ronda final (0): InvShift → InvSub → AddRoundKey (sin InvMix)
    adr x0, state
    bl inv_shift
    
    adr x0, state
    bl inv_sub
    
    adr x0, state
    adr x1, expanded_keys    // W[0-3] = offset 0
    bl add_round
    
    /* FIN ALGORITMO */
    
    // Show result message
    mov x0, #1
    adr x1, msg_result
    mov x2, #16
    mov x8, #64
    svc #0
    
    // Print state as hex
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

/* Imprimir un byte en hexadecimal */
print_hex_byte:
    stp x29, x30, [sp, #-32]!
    
    sub sp, sp, #16
    mov x1, sp
    
    // High nibble
    lsr w2, w0, #4
    and w2, w2, #0xF
    cmp w2, #10
    b.lt phb_h_dig
    add w2, w2, #55
    b phb_h_ok
phb_h_dig:
    add w2, w2, #48
phb_h_ok:
    strb w2, [x1]
    
    // Low nibble
    and w2, w0, #0xF
    cmp w2, #10
    b.lt phb_l_dig
    add w2, w2, #55
    b phb_l_ok
phb_l_dig:
    add w2, w2, #48
phb_l_ok:
    strb w2, [x1, #1]
    
    // Space
    mov w2, #' '
    strb w2, [x1, #2]
    
    // Print
    mov x0, #1
    mov x2, #3
    mov x8, #64
    svc #0
    
    add sp, sp, #16
    ldp x29, x30, [sp], #32
    ret

/* Imprimir matriz de estado 4x4 */
print_state_matrix:
    stp x29, x30, [sp, #-48]!
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]
    
    mov x19, x0      // pointer to state
    
    mov x0, #1
    adr x1, msg_state_matrix
    mov x2, #28
    mov x8, #64
    svc #0
    
    mov x20, #0      // row counter
psm_row_loop:
    cmp x20, #4
    b.ge psm_done
    
    mov x21, #0      // column counter
psm_col_loop:
    cmp x21, #4
    b.ge psm_row_end
    
    // Calculate offset: column*4 + row
    mov x2, #4
    mul x2, x21, x2
    add x2, x2, x20
    ldrb w0, [x19, x2]
    bl print_hex_byte
    
    add x21, x21, #1
    b psm_col_loop
    
psm_row_end:
    mov x0, #1
    adr x1, msg_nl
    mov x2, #1
    mov x8, #64
    svc #0
    
    cmp x20, #3
    b.ge psm_skip_indent
    
    // Print indent for next row
    sub sp, sp, #16
    mov x0, sp
    mov w1, #' '
    strb w1, [x0]
    strb w1, [x0, #1]
    strb w1, [x0, #2]
    mov x0, #1
    mov x1, sp
    mov x2, #3
    mov x8, #64
    svc #0
    add sp, sp, #16
    
psm_skip_indent:
    add x20, x20, #1
    b psm_row_loop
    
psm_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

/* Imprimir número de ronda */
print_round_number:
    stp x29, x30, [sp, #-16]!
    
    sub sp, sp, #16
    cmp w0, #10
    b.lt prn_single
    
    mov w1, #'1'
    strb w1, [sp]
    mov w1, #'0'
    strb w1, [sp, #1]
    mov x0, #1
    mov x1, sp
    mov x2, #2
    mov x8, #64
    svc #0
    b prn_done
    
prn_single:
    add w0, w0, #'0'
    strb w0, [sp]
    mov x0, #1
    mov x1, sp
    mov x2, #1
    mov x8, #64
    svc #0
    
prn_done:
    add sp, sp, #16
    ldp x29, x30, [sp], #16
    ret

/* Imprimir subclaves expandidas */
print_expanded_keys:
    stp x29, x30, [sp, #-32]!
    str x19, [sp, #16]
    str x20, [sp, #24]
    
    mov x0, #1
    sub sp, sp, #64
    adr x1, msg_nl
    mov x2, #1
    strb w2, [sp]
    mov x1, sp
    mov x8, #64
    svc #0
    
    mov w1, #'='
    mov x2, #0
pek_eq_loop:
    cmp x2, #40
    b.ge pek_eq_done
    strb w1, [sp, x2]
    add x2, x2, #1
    b pek_eq_loop
pek_eq_done:
    mov x0, #1
    mov x1, sp
    mov x2, #40
    mov x8, #64
    svc #0
    add sp, sp, #64
    
    sub sp, sp, #128
    adr x1, msg_nl
    ldrb w2, [x1]
    strb w2, [sp]
    mov w2, #'S'
    strb w2, [sp, #1]
    mov w2, #'U'
    strb w2, [sp, #2]
    mov w2, #'B'
    strb w2, [sp, #3]
    mov w2, #'C'
    strb w2, [sp, #4]
    mov w2, #'L'
    strb w2, [sp, #5]
    mov w2, #'A'
    strb w2, [sp, #6]
    mov w2, #'V'
    strb w2, [sp, #7]
    mov w2, #'E'
    strb w2, [sp, #8]
    mov w2, #'S'
    strb w2, [sp, #9]
    mov w2, #' '
    strb w2, [sp, #10]
    mov w2, #'E'
    strb w2, [sp, #11]
    mov w2, #'X'
    strb w2, [sp, #12]
    mov w2, #'P'
    strb w2, [sp, #13]
    mov w2, #'A'
    strb w2, [sp, #14]
    mov w2, #'N'
    strb w2, [sp, #15]
    mov w2, #'D'
    strb w2, [sp, #16]
    mov w2, #'I'
    strb w2, [sp, #17]
    mov w2, #'D'
    strb w2, [sp, #18]
    mov w2, #'A'
    strb w2, [sp, #19]
    mov w2, #'S'
    strb w2, [sp, #20]
    adr x1, msg_nl
    ldrb w2, [x1]
    strb w2, [sp, #21]
    mov x0, #1
    mov x1, sp
    mov x2, #22
    mov x8, #64
    svc #0
    add sp, sp, #128
    
    adr x19, expanded_keys
    mov x20, #0
    
pek_loop:
    cmp x20, #11
    b.ge pek_done
    
    sub sp, sp, #32
    adr x1, msg_nl
    ldrb w2, [x1]
    strb w2, [sp]
    mov w2, #'R'
    strb w2, [sp, #1]
    mov w2, #'o'
    strb w2, [sp, #2]
    mov w2, #'n'
    strb w2, [sp, #3]
    mov w2, #'d'
    strb w2, [sp, #4]
    mov w2, #'a'
    strb w2, [sp, #5]
    mov w2, #' '
    strb w2, [sp, #6]
    
    mov w2, w20
    cmp w2, #10
    b.lt pek_single_digit
    mov w2, #'1'
    strb w2, [sp, #7]
    mov w2, #'0'
    strb w2, [sp, #8]
    mov w2, #':'
    strb w2, [sp, #9]
    mov w2, #' '
    strb w2, [sp, #10]
    mov x0, #1
    mov x1, sp
    mov x2, #11
    mov x8, #64
    svc #0
    b pek_print_key
    
pek_single_digit:
    add w2, w2, #'0'
    strb w2, [sp, #7]
    mov w2, #':'
    strb w2, [sp, #8]
    mov w2, #' '
    strb w2, [sp, #9]
    mov x0, #1
    mov x1, sp
    mov x2, #10
    mov x8, #64
    svc #0
    
pek_print_key:
    add sp, sp, #32
    
    mov x21, #16
    mul x21, x20, x21
    add x0, x19, x21
    mov w1, #16
    bl print_hex
    
    add x20, x20, #1
    b pek_loop
    
pek_done:
    sub sp, sp, #64
    mov w1, #'='
    mov x2, #0
pek_eq2_loop:
    cmp x2, #40
    b.ge pek_eq2_done
    strb w1, [sp, x2]
    add x2, x2, #1
    b pek_eq2_loop
pek_eq2_done:
    mov x0, #1
    mov x1, sp
    mov x2, #40
    mov x8, #64
    svc #0
    
    adr x1, msg_nl
    ldrb w2, [x1]
    strb w2, [sp]
    mov x0, #1
    mov x1, sp
    mov x2, #1
    mov x8, #64
    svc #0
    add sp, sp, #64
    
    ldr x20, [sp, #24]
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret