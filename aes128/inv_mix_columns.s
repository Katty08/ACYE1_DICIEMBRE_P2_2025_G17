/****************************************************
 * inv_mix_columns.s
 * AES InvMixColumns
 * Arquitectura: ARM64
 ****************************************************/

.section .text
.align 4
.global inv_mix_columns

.extern gf_mul_9
.extern gf_mul_11
.extern gf_mul_13
.extern gf_mul_14

inv_mix_columns:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    sub sp, sp, #16        // buffer temporal
    mov x1, sp

    mov x2, #0             // columna 0..3

column_loop:
    // x3 = col * 4
    lsl x3, x2, #2

    // base = state + col*4
    add x10, x0, x3

    // cargar columna
    ldrb w4, [x10]         // s0
    ldrb w5, [x10, #1]     // s1
    ldrb w6, [x10, #2]     // s2
    ldrb w7, [x10, #3]     // s3

    // t0 = 14*s0 ^ 11*s1 ^ 13*s2 ^ 9*s3
    mov w0, w4
    bl gf_mul_14
    mov w8, w0

    mov w0, w5
    bl gf_mul_11
    eor w8, w8, w0

    mov w0, w6
    bl gf_mul_13
    eor w8, w8, w0

    mov w0, w7
    bl gf_mul_9
    eor w8, w8, w0

    add x11, x1, x3
    strb w8, [x11]

    // t1 = 9*s0 ^ 14*s1 ^ 11*s2 ^ 13*s3
    mov w0, w4
    bl gf_mul_9
    mov w8, w0

    mov w0, w5
    bl gf_mul_14
    eor w8, w8, w0

    mov w0, w6
    bl gf_mul_11
    eor w8, w8, w0

    mov w0, w7
    bl gf_mul_13
    eor w8, w8, w0

    strb w8, [x11, #1]

    // t2 = 13*s0 ^ 9*s1 ^ 14*s2 ^ 11*s3
    mov w0, w4
    bl gf_mul_13
    mov w8, w0

    mov w0, w5
    bl gf_mul_9
    eor w8, w8, w0

    mov w0, w6
    bl gf_mul_14
    eor w8, w8, w0

    mov w0, w7
    bl gf_mul_11
    eor w8, w8, w0

    strb w8, [x11, #2]

    // t3 = 11*s0 ^ 13*s1 ^ 9*s2 ^ 14*s3
    mov w0, w4
    bl gf_mul_11
    mov w8, w0

    mov w0, w5
    bl gf_mul_13
    eor w8, w8, w0

    mov w0, w6
    bl gf_mul_9
    eor w8, w8, w0

    mov w0, w7
    bl gf_mul_14
    eor w8, w8, w0

    strb w8, [x11, #3]

    add x2, x2, #1
    cmp x2, #4
    blt column_loop

    // copiar buffer temporal a state
    mov x2, #16
    mov x3, #0
copy_back:
    ldrb w4, [x1, x3]
    strb w4, [x0, x3]
    add x3, x3, #1
    subs x2, x2, #1
    bne copy_back

    add sp, sp, #16
    ldp x29, x30, [sp], #16
    ret
