/* Matriz de constantes inversas de MixColumns (InvMixColumns)
 *   [0E 0B 0D 09]
 *   [09 0E 0B 0D]
 *   [0D 09 0E 0B]
 *   [0B 0D 09 0E]
 */
.section .data
.align 4
inv_mix_mat:
    .byte 0x0E,0x0B,0x0D,0x09
    .byte 0x09,0x0E,0x0B,0x0D
    .byte 0x0D,0x09,0x0E,0x0B
    .byte 0x0B,0x0D,0x09,0x0E

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
 */

inv_mix:
    stp x19, x20, [sp, #-80]!
    stp x21, x22, [sp, #16]
    stp x23, x24, [sp, #32]
    stp x25, x26, [sp, #48]
    stp x27, x30, [sp, #64]

    mov  x27, x0             // Guardar puntero original al estado

    // Cargar puntero a matriz de constantes inversas
    adrp x25, inv_mix_mat
    add  x25, x25, :lo12:inv_mix_mat

    mov  w19, #0             // índice de columna (0, 4, 8, 12)

inv_mix_col_loop:
    cmp  w19, #16
    b.eq inv_mix_done

    // Para column-major: columna N está en bytes consecutivos N*4 a N*4+3
    // Cargar columna actual s0..s3
    add x1, x27, x19
    ldrb w2, [x1, #0]        // s0
    ldrb w3, [x1, #1]        // s1
    ldrb w4, [x1, #2]        // s2
    ldrb w5, [x1, #3]        // s3

    // Guardar s0..s3 en buffer temporal en la pila para indexarlos
    sub  sp, sp, #16
    strb w2, [sp, #0]
    strb w3, [sp, #1]
    strb w4, [sp, #2]
    strb w5, [sp, #3]

    // ===== Fila 0: usar primera fila de la matriz =====
    // s0' = m00*s0 ⊕ m01*s1 ⊕ m02*s2 ⊕ m03*s3
    // m0j = inv_mix_mat[0*4 + j]
    ldrb w1, [x25, #0]
    ldrb w0, [sp, #0]
    bl   gf_mul_const
    mov  w20, w0

    ldrb w1, [x25, #1]
    ldrb w0, [sp, #1]
    bl   gf_mul_const
    eor  w20, w20, w0

    ldrb w1, [x25, #2]
    ldrb w0, [sp, #2]
    bl   gf_mul_const
    eor  w20, w20, w0

    ldrb w1, [x25, #3]
    ldrb w0, [sp, #3]
    bl   gf_mul_const
    eor  w20, w20, w0      // s0'

    // ===== Fila 1: segunda fila de la matriz =====
    // s1' = m10*s0 ⊕ m11*s1 ⊕ m12*s2 ⊕ m13*s3
    ldrb w1, [x25, #4]
    ldrb w0, [sp, #0]
    bl   gf_mul_const
    mov  w21, w0

    ldrb w1, [x25, #5]
    ldrb w0, [sp, #1]
    bl   gf_mul_const
    eor  w21, w21, w0

    ldrb w1, [x25, #6]
    ldrb w0, [sp, #2]
    bl   gf_mul_const
    eor  w21, w21, w0

    ldrb w1, [x25, #7]
    ldrb w0, [sp, #3]
    bl   gf_mul_const
    eor  w21, w21, w0      // s1'

    // ===== Fila 2: tercera fila de la matriz =====
    // s2' = m20*s0 ⊕ m21*s1 ⊕ m22*s2 ⊕ m23*s3
    ldrb w1, [x25, #8]
    ldrb w0, [sp, #0]
    bl   gf_mul_const
    mov  w22, w0

    ldrb w1, [x25, #9]
    ldrb w0, [sp, #1]
    bl   gf_mul_const
    eor  w22, w22, w0

    ldrb w1, [x25, #10]
    ldrb w0, [sp, #2]
    bl   gf_mul_const
    eor  w22, w22, w0

    ldrb w1, [x25, #11]
    ldrb w0, [sp, #3]
    bl   gf_mul_const
    eor  w22, w22, w0      // s2'

    // ===== Fila 3: cuarta fila de la matriz =====
    // s3' = m30*s0 ⊕ m31*s1 ⊕ m32*s2 ⊕ m33*s3
    ldrb w1, [x25, #12]
    ldrb w0, [sp, #0]
    bl   gf_mul_const
    mov  w23, w0

    ldrb w1, [x25, #13]
    ldrb w0, [sp, #1]
    bl   gf_mul_const
    eor  w23, w23, w0

    ldrb w1, [x25, #14]
    ldrb w0, [sp, #2]
    bl   gf_mul_const
    eor  w23, w23, w0

    ldrb w1, [x25, #15]
    ldrb w0, [sp, #3]
    bl   gf_mul_const
    eor  w23, w23, w0      // s3'

    // Liberar buffer temporal
    add  sp, sp, #16

    // Guardar columna transformada (column-major: consecutivos)
    add  x1, x27, x19
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

/* Multiplicación por constante en GF(2^8) para los valores
 * usados en la matriz inversa: 0x09, 0x0B, 0x0D, 0x0E.
 * Entrada: w0 = byte, w1 = constante
 * Salida:  w0 = w0 * w1 en GF(2^8)
 */
gf_mul_const:
    cmp w1, #0x09
    beq gmc_9
    cmp w1, #0x0B
    beq gmc_11
    cmp w1, #0x0D
    beq gmc_13
    // Cualquier otro valor esperado (0x0E) usa gf_mul14
    b   gf_mul14

gmc_9:
    b   gf_mul9

gmc_11:
    b   gf_mul11

gmc_13:
    b   gf_mul13


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
