/* =========================================
 * inv_shift.s
 * InvShiftRows – AES-128
 * Arquitectura: ARMv7
 * ========================================= */

.section .text
.align 4
.global inv_shift

/* -----------------------------------------
 * inv_shift
 * r0 = puntero al estado (16 bytes)
 * ----------------------------------------- */
inv_shift:
    push {r4-r7, lr}

    /* ===== Fila 1 (rotar derecha 1) ===== */
    ldrb r1, [r0, #13]
    ldrb r2, [r0, #9]
    ldrb r3, [r0, #5]
    ldrb r4, [r0, #1]

    strb r1, [r0, #1]
    strb r2, [r0, #5]
    strb r3, [r0, #9]
    strb r4, [r0, #13]

    /* ===== Fila 2 (rotar derecha 2) ===== */
    ldrb r1, [r0, #10]
    ldrb r2, [r0, #14]
    ldrb r3, [r0, #2]
    ldrb r4, [r0, #6]

    strb r1, [r0, #2]
    strb r2, [r0, #6]
    strb r3, [r0, #10]
    strb r4, [r0, #14]

    /* ===== Fila 3 (rotar derecha 3) ===== */
    ldrb r1, [r0, #7]
    ldrb r2, [r0, #11]
    ldrb r3, [r0, #15]
    ldrb r4, [r0, #3]

    strb r1, [r0, #3]
    strb r2, [r0, #7]
    strb r3, [r0, #11]
    strb r4, [r0, #15]

    pop {r4-r7, lr}
    bx lr
