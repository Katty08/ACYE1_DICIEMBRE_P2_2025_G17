.section .text
.align 4
.global inv_mix

/*
 * inv_mix
 * Implementación de InvMixColumns para AES-128
 * Arquitectura: ARM64
 *
 * Entradas:
 *   x0 = puntero a la matriz de estado (16 bytes)
 *
 * La matriz de estado está en orden column-major:
 *   [  0,  4,  8, 12 ]  -> fila 0
 *   [  1,  5,  9, 13 ]  -> fila 1
 *   [  2,  6, 10, 14 ]  -> fila 2
 *   [  3,  7, 11, 15 ]  -> fila 3
 *
 * Para cada columna C = [s0,s1,s2,s3]^T se aplica:
 *   s0' = 0E·s0 ⊕ 0B·s1 ⊕ 0D·s2 ⊕ 09·s3
 *   s1' = 09·s0 ⊕ 0E·s1 ⊕ 0B·s2 ⊕ 0D·s3
 *   s2' = 0D·s0 ⊕ 09·s1 ⊕ 0E·s2 ⊕ 0B·s3
 *   s3' = 0B·s0 ⊕ 0D·s1 ⊕ 09·s2 ⊕ 0E·s3
 */

inv_mix:
    stp x19, x20, [sp, #-80]!
    stp x21, x22, [sp, #16]
    stp x23, x24, [sp, #32]
    stp x25, x26, [sp, #48]
    stp x27, x30, [sp, #64]

    mov  w19, #0              // offset de columna (0,4,8,12)

inv_mix_col_loop:
    cmp  w19, #16
    b.eq inv_mix_done

    add  x1, x0, x19         // x1 = &state[columna]

    // Cargar columna actual s0..s3
    ldrb w2, [x1, #0]        // s0
    ldrb w3, [x1, #1]        // s1
    ldrb w4, [x1, #2]        // s2
    ldrb w5, [x1, #3]        // s3

    // === s0' = 0E·s0 ⊕ 0B·s1 ⊕ 0D·s2 ⊕ 09·s3 ===
    mov  w0, w2
    bl   gf_mul14
    mov  w20, w0             // 0E·s0

    mov  w0, w3
    bl   gf_mul11
    eor  w20, w20, w0        // ⊕ 0B·s1

    mov  w0, w4
    bl   gf_mul13
    eor  w20, w20, w0        // ⊕ 0D·s2

    mov  w0, w5
    bl   gf_mul9
    eor  w20, w20, w0        // ⊕ 09·s3  -> s0'

    // === s1' = 09·s0 ⊕ 0E·s1 ⊕ 0B·s2 ⊕ 0D·s3 ===
    mov  w0, w2
    bl   gf_mul9
    mov  w21, w0             // 09·s0

    mov  w0, w3
    bl   gf_mul14
    eor  w21, w21, w0        // ⊕ 0E·s1

    mov  w0, w4
    bl   gf_mul11
    eor  w21, w21, w0        // ⊕ 0B·s2

    mov  w0, w5
    bl   gf_mul13
    eor  w21, w21, w0        // ⊕ 0D·s3  -> s1'

    // === s2' = 0D·s0 ⊕ 09·s1 ⊕ 0E·s2 ⊕ 0B·s3 ===
    mov  w0, w2
    bl   gf_mul13
    mov  w22, w0             // 0D·s0

    mov  w0, w3
    bl   gf_mul9
    eor  w22, w22, w0        // ⊕ 09·s1

    mov  w0, w4
    bl   gf_mul14
    eor  w22, w22, w0        // ⊕ 0E·s2

    mov  w0, w5
    bl   gf_mul11
    eor  w22, w22, w0        // ⊕ 0B·s3  -> s2'

    // === s3' = 0B·s0 ⊕ 0D·s1 ⊕ 09·s2 ⊕ 0E·s3 ===
    mov  w0, w2
    bl   gf_mul11
    mov  w23, w0             // 0B·s0

    mov  w0, w3
    bl   gf_mul13
    eor  w23, w23, w0        // ⊕ 0D·s1

    mov  w0, w4
    bl   gf_mul9
    eor  w23, w23, w0        // ⊕ 09·s2

    mov  w0, w5
    bl   gf_mul14
    eor  w23, w23, w0        // ⊕ 0E·s3  -> s3'

    // Guardar columna transformada
    strb w20, [x1, #0]
    strb w21, [x1, #1]
    strb w22, [x1, #2]
    strb w23, [x1, #3]

    add  w19, w19, #4        // siguiente columna
    b    inv_mix_col_loop

inv_mix_done:
    ldp x27, x30, [sp, #64]
    ldp x25, x26, [sp, #48]
    ldp x23, x24, [sp, #32]
    ldp x21, x22, [sp, #16]
    ldp x19, x20, [sp], #80
    ret


/* =======================
 * Operaciones en GF(2^8)
 * ======================= */

// gf_mul2: multiplica por 0x02 en GF(2^8)
// Entrada: w0 = byte
// Salida:  w0 = 0x02 · byte
gf_mul2:
    mov  w1, w0
    and  w1, w1, #0x80      // ¿bit más alto?
    lsl  w0, w0, #1         // x << 1
    tst  w1, #0x80
    b.eq gf_mul2_no_red
    mov  w2, #0x1B          // cargar constante en registro
    eor  w0, w0, w2         // reducción módulo x^8 + x^4 + x^3 + x + 1
gf_mul2_no_red:
    and  w0, w0, #0xFF
    ret


// gf_mul9:  0x09 = 8x ⊕ x
gf_mul9:
    stp x19, x20, [sp, #-32]!
    stp x21, x30, [sp, #16]
    mov  w19, w0            // x
    bl   gf_mul2            // 2x
    mov  w20, w0            // 2x
    bl   gf_mul2            // 4x
    mov  w21, w0            // 4x
    bl   gf_mul2            // 8x
    eor  w0, w0, w19        // 8x ⊕ x
    ldp x21, x30, [sp, #16]
    ldp x19, x20, [sp], #32
    ret


// gf_mul11: 0x0B = 8x ⊕ 2x ⊕ x
gf_mul11:
    stp x19, x20, [sp, #-32]!
    stp x21, x30, [sp, #16]
    mov  w19, w0            // x
    bl   gf_mul2            // 2x
    mov  w20, w0            // 2x
    bl   gf_mul2            // 4x
    bl   gf_mul2            // 8x
    eor  w0, w0, w20        // 8x ⊕ 2x
    eor  w0, w0, w19        // (8x ⊕ 2x) ⊕ x
    ldp x21, x30, [sp, #16]
    ldp x19, x20, [sp], #32
    ret


// gf_mul13: 0x0D = 8x ⊕ 4x ⊕ x
gf_mul13:
    stp x19, x20, [sp, #-32]!
    stp x21, x30, [sp, #16]
    mov  w19, w0            // x
    bl   gf_mul2            // 2x
    mov  w20, w0            // 2x
    bl   gf_mul2            // 4x
    mov  w21, w0            // 4x
    bl   gf_mul2            // 8x
    eor  w0, w0, w21        // 8x ⊕ 4x
    eor  w0, w0, w19        // (8x ⊕ 4x) ⊕ x
    ldp x21, x30, [sp, #16]
    ldp x19, x20, [sp], #32
    ret


// gf_mul14: 0x0E = 8x ⊕ 4x ⊕ 2x
gf_mul14:
    stp x19, x20, [sp, #-32]!
    stp x21, x30, [sp, #16]
    mov  w19, w0            // x
    bl   gf_mul2            // 2x
    mov  w20, w0            // 2x
    bl   gf_mul2            // 4x
    mov  w21, w0            // 4x
    bl   gf_mul2            // 8x
    eor  w0, w0, w21        // 8x ⊕ 4x
    eor  w0, w0, w20        // (8x ⊕ 4x) ⊕ 2x
    ldp x21, x30, [sp, #16]
    ldp x19, x20, [sp], #32
    ret
