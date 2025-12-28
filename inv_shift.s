/* =========================================
 * inv_shift.s
 * InvShiftRows – AES-128
 * Arquitectura: ARM64
 * ========================================= */

.section .text
.align 4
.global inv_shift

/* -----------------------------------------
 * inv_shift
 * x0 = puntero al estado (16 bytes)
 * ----------------------------------------- */
inv_shift:
    stp x19, x20, [sp, #-48]!
    stp x21, x22, [sp, #16]
    stp x30, xzr, [sp, #32]

    /* ===== Fila 1 (column-major: índices 1,5,9,13): rotar derecha 1 ===== */
    ldrb w19, [x0, #13]
    ldrb w20, [x0, #1]
    ldrb w21, [x0, #5]
    ldrb w22, [x0, #9]

    strb w19, [x0, #1]
    strb w20, [x0, #5]
    strb w21, [x0, #9]
    strb w22, [x0, #13]

    /* ===== Fila 2 (column-major: índices 2,6,10,14): rotar derecha 2 ===== */
    ldrb w19, [x0, #10]
    ldrb w20, [x0, #14]
    ldrb w21, [x0, #2]
    ldrb w22, [x0, #6]

    strb w19, [x0, #2]
    strb w20, [x0, #6]
    strb w21, [x0, #10]
    strb w22, [x0, #14]

    /* ===== Fila 3 (column-major: índices 3,7,11,15): rotar derecha 3 ===== */
    ldrb w19, [x0, #7]
    ldrb w20, [x0, #11]
    ldrb w21, [x0, #15]
    ldrb w22, [x0, #3]

    strb w19, [x0, #3]
    strb w20, [x0, #7]
    strb w21, [x0, #11]
    strb w22, [x0, #15]

    ldp x30, xzr, [sp, #32]
    ldp x21, x22, [sp, #16]
    ldp x19, x20, [sp], #48
    ret
