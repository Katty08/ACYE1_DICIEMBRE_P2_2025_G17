.section .text
.align 4
.global inv_mix

/*
 * inv_mix
 * Implementación de InvMixColumns para AES-128
 * Arquitectura: ARMv7 (32 bits)
 *
 * Entradas:
 *   r0 = puntero a la matriz de estado (16 bytes)
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
    push {r1-r10, lr}

    mov  r6, #0              @ offset de columna (0,4,8,12)

inv_mix_col_loop:
    cmp  r6, #16
    beq  inv_mix_done

    add  r1, r0, r6          @ r1 = &state[columna]

    @ Cargar columna actual s0..s3
    ldrb r2, [r1, #0]        @ s0
    ldrb r3, [r1, #1]        @ s1
    ldrb r4, [r1, #2]        @ s2
    ldrb r5, [r1, #3]        @ s3

    @ === s0' = 0E·s0 ⊕ 0B·s1 ⊕ 0D·s2 ⊕ 09·s3 ===
    mov  r0, r2
    bl   gf_mul14
    mov  r7, r0              @ 0E·s0

    mov  r0, r3
    bl   gf_mul11
    eor  r7, r7, r0          @ ⊕ 0B·s1

    mov  r0, r4
    bl   gf_mul13
    eor  r7, r7, r0          @ ⊕ 0D·s2

    mov  r0, r5
    bl   gf_mul9
    eor  r7, r7, r0          @ ⊕ 09·s3  -> s0'

    @ === s1' = 09·s0 ⊕ 0E·s1 ⊕ 0B·s2 ⊕ 0D·s3 ===
    mov  r0, r2
    bl   gf_mul9
    mov  r8, r0              @ 09·s0

    mov  r0, r3
    bl   gf_mul14
    eor  r8, r8, r0          @ ⊕ 0E·s1

    mov  r0, r4
    bl   gf_mul11
    eor  r8, r8, r0          @ ⊕ 0B·s2

    mov  r0, r5
    bl   gf_mul13
    eor  r8, r8, r0          @ ⊕ 0D·s3  -> s1'

    @ === s2' = 0D·s0 ⊕ 09·s1 ⊕ 0E·s2 ⊕ 0B·s3 ===
    mov  r0, r2
    bl   gf_mul13
    mov  r9, r0              @ 0D·s0

    mov  r0, r3
    bl   gf_mul9
    eor  r9, r9, r0          @ ⊕ 09·s1

    mov  r0, r4
    bl   gf_mul14
    eor  r9, r9, r0          @ ⊕ 0E·s2

    mov  r0, r5
    bl   gf_mul11
    eor  r9, r9, r0          @ ⊕ 0B·s3  -> s2'

    @ === s3' = 0B·s0 ⊕ 0D·s1 ⊕ 09·s2 ⊕ 0E·s3 ===
    mov  r0, r2
    bl   gf_mul11
    mov  r10, r0             @ 0B·s0

    mov  r0, r3
    bl   gf_mul13
    eor  r10, r10, r0        @ ⊕ 0D·s1

    mov  r0, r4
    bl   gf_mul9
    eor  r10, r10, r0        @ ⊕ 09·s2

    mov  r0, r5
    bl   gf_mul14
    eor  r10, r10, r0        @ ⊕ 0E·s3  -> s3'

    @ Guardar columna transformada
    strb r7,  [r1, #0]
    strb r8,  [r1, #1]
    strb r9,  [r1, #2]
    strb r10, [r1, #3]

    add  r6, r6, #4          @ siguiente columna
    b    inv_mix_col_loop

inv_mix_done:
    pop  {r1-r10, lr}
    bx   lr


/* =======================
 * Operaciones en GF(2^8)
 * ======================= */

@ gf_mul2: multiplica por 0x02 en GF(2^8)
@ Entrada: r0 = byte
@ Salida:  r0 = 0x02 · byte
gf_mul2:
    mov  r1, r0
    and  r1, r1, #0x80      @ ¿bit más alto?
    lsl  r0, r0, #1         @ x << 1
    tst  r1, #0x80
    beq  gf_mul2_no_red
    eor  r0, r0, #0x1B      @ reducción módulo x^8 + x^4 + x^3 + x + 1
gf_mul2_no_red:
    and  r0, r0, #0xFF
    bx   lr


@ gf_mul9:  0x09 = 8x ⊕ x
gf_mul9:
    push {r1-r3, lr}
    mov  r1, r0             @ x
    bl   gf_mul2            @ 2x
    mov  r2, r0             @ 2x
    bl   gf_mul2            @ 4x
    mov  r3, r0             @ 4x
    bl   gf_mul2            @ 8x
    eor  r0, r0, r1         @ 8x ⊕ x
    pop  {r1-r3, lr}
    bx   lr


@ gf_mul11: 0x0B = 8x ⊕ 2x ⊕ x
gf_mul11:
    push {r1-r3, lr}
    mov  r1, r0             @ x
    bl   gf_mul2            @ 2x
    mov  r2, r0             @ 2x
    bl   gf_mul2            @ 4x
    bl   gf_mul2            @ 8x
    eor  r0, r0, r2         @ 8x ⊕ 2x
    eor  r0, r0, r1         @ (8x ⊕ 2x) ⊕ x
    pop  {r1-r3, lr}
    bx   lr


@ gf_mul13: 0x0D = 8x ⊕ 4x ⊕ x
gf_mul13:
    push {r1-r3, lr}
    mov  r1, r0             @ x
    bl   gf_mul2            @ 2x
    mov  r2, r0             @ 2x
    bl   gf_mul2            @ 4x
    mov  r3, r0             @ 4x
    bl   gf_mul2            @ 8x
    eor  r0, r0, r3         @ 8x ⊕ 4x
    eor  r0, r0, r1         @ (8x ⊕ 4x) ⊕ x
    pop  {r1-r3, lr}
    bx   lr


@ gf_mul14: 0x0E = 8x ⊕ 4x ⊕ 2x
gf_mul14:
    push {r1-r3, lr}
    mov  r1, r0             @ x
    bl   gf_mul2            @ 2x
    mov  r2, r0             @ 2x
    bl   gf_mul2            @ 4x
    mov  r3, r0             @ 4x
    bl   gf_mul2            @ 8x
    eor  r0, r0, r3         @ 8x ⊕ 4x
    eor  r0, r0, r2         @ (8x ⊕ 4x) ⊕ 2x
    pop  {r1-r3, lr}
    bx   lr
