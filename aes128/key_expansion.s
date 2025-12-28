/****************************************************
 * key_expansion.s
 * Expansión de clave AES-128 (ENDIAN-SAFE)
 * Arquitectura: ARM64
 ****************************************************/

.section .text
.align 4
.global key_expansion

.extern sbox
.extern rcon

/****************************************************
 * key_expansion
 * x0 = key (16 bytes)
 * x1 = round_keys (176 bytes)
 ****************************************************/
key_expansion:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Copiar clave original
    mov x2, #16
copy_key:
    ldrb w3, [x0], #1
    strb w3, [x1], #1
    subs x2, x2, #1
    bne copy_key

    // i = 4 .. 43 (palabras)
    mov x4, #4

expand_loop:
    // temp[0..3] = W[i-1]
    sub x6, x1, #4
    ldrb w7, [x6]
    ldrb w8, [x6, #1]
    ldrb w9, [x6, #2]
    ldrb w10, [x6, #3]

    // if (i % 4 == 0)
    and x11, x4, #3
    cbnz x11, no_core

    // RotWord
    mov w12, w7
    mov w7, w8
    mov w8, w9
    mov w9, w10
    mov w10, w12

    // SubWord
    ldr x13, =sbox
    ldrb w7, [x13, w7, uxtw]
    ldrb w8, [x13, w8, uxtw]
    ldrb w9, [x13, w9, uxtw]
    ldrb w10,[x13, w10,uxtw]

    // Rcon
    ldr x14, =rcon
    lsr x15, x4, #2
    sub x15, x15, #1
    ldrb w15, [x14, x15]
    eor w7, w7, w15

no_core:
    // W[i] = W[i-4] XOR temp
    sub x16, x1, #16
    ldrb w17, [x16]
    ldrb w18, [x16, #1]
    ldrb w19, [x16, #2]
    ldrb w20, [x16, #3]

    eor w7, w7, w17
    eor w8, w8, w18
    eor w9, w9, w19
    eor w10, w10, w20

    // guardar W[i]
    strb w7, [x1], #1
    strb w8, [x1], #1
    strb w9, [x1], #1
    strb w10,[x1], #1

    add x4, x4, #1
    cmp x4, #44
    blt expand_loop

    ldp x29, x30, [sp], #16
    ret
