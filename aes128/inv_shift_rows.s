/****************************************************
 * inv_shift_rows.s
 * AES InvShiftRows
 * Arquitectura: ARM64
 ****************************************************/

.section .text
.align 4
.global inv_shift_rows

/****************************************************
 * inv_shift_rows
 * x0 = puntero a state (16 bytes)
 ****************************************************/
inv_shift_rows:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Copiar state a stack (16 bytes)
    sub sp, sp, #16
    mov x1, sp
    mov x2, #16

copy_loop:
    ldrb w3, [x0], #1
    strb w3, [x1], #1
    subs x2, x2, #1
    bne copy_loop

    // Restaurar punteros
    sub x0, x0, #16
    mov x1, sp

    // Fila 0 (sin cambio)
    ldrb w2, [x1, #0]
    strb w2, [x0, #0]
    ldrb w2, [x1, #4]
    strb w2, [x0, #4]
    ldrb w2, [x1, #8]
    strb w2, [x0, #8]
    ldrb w2, [x1, #12]
    strb w2, [x0, #12]

    // Fila 1 (rotar 1 derecha)
    ldrb w2, [x1, #13]
    strb w2, [x0, #1]
    ldrb w2, [x1, #1]
    strb w2, [x0, #5]
    ldrb w2, [x1, #5]
    strb w2, [x0, #9]
    ldrb w2, [x1, #9]
    strb w2, [x0, #13]

    // Fila 2 (rotar 2 derecha)
    ldrb w2, [x1, #10]
    strb w2, [x0, #2]
    ldrb w2, [x1, #14]
    strb w2, [x0, #6]
    ldrb w2, [x1, #2]
    strb w2, [x0, #10]
    ldrb w2, [x1, #6]
    strb w2, [x0, #14]

    // Fila 3 (rotar 3 derecha)
    ldrb w2, [x1, #7]
    strb w2, [x0, #3]
    ldrb w2, [x1, #11]
    strb w2, [x0, #7]
    ldrb w2, [x1, #15]
    strb w2, [x0, #11]
    ldrb w2, [x1, #3]
    strb w2, [x0, #15]

    // Liberar stack
    add sp, sp, #16

    ldp x29, x30, [sp], #16
    ret
