/* =========================================================
 * main.s
 * AES-128 – Descifrado
 * Persona 1 – Flujo general del algoritmo
 * Arquitectura: ARM64
 * ========================================================= */

.section .bss
.align 4

state:
    .space 16


.section .data
.align 4

/* Subclaves AES-128 (NIST, 176 bytes) */
round_keys:
    .byte 0x2b,0x7e,0x15,0x16,0x28,0xae,0xd2,0xa6,0xab,0xf7,0x15,0x88,0x09,0xcf,0x4f,0x3c
    .byte 0xa0,0xfa,0xfe,0x17,0x88,0x54,0x2c,0xb1,0x23,0xa3,0x39,0x39,0x2a,0x6c,0x76,0x05
    /* … continúa hasta 176 bytes … */

/* Texto cifrado (NIST) */
ciphertext:
    .byte 0x69,0xc4,0xe0,0xd8
    .byte 0x6a,0x7b,0x04,0x30
    .byte 0xd8,0xcd,0xb7,0x80
    .byte 0x70,0xb4,0xc5,0x5a

round:
    .word 10


.section .text
.align 4
.global _start

.extern inv_shift
.extern inv_sub
.extern inv_mix
.extern add_round


_start:

    /* Copiar ciphertext a state */
    adrp x0, ciphertext
    add  x0, x0, :lo12:ciphertext
    adrp x1, state
    add  x1, x1, :lo12:state
    mov w2, #16

copy_state:
    ldrb w3, [x0], #1
    strb w3, [x1], #1
    subs w2, w2, #1
    b.ne copy_state


    /* Subclave final */
    adrp x1, round_keys
    add  x1, x1, :lo12:round_keys
    add  x1, x1, #160


    /* Ronda inicial */
    adrp x0, state
    add  x0, x0, :lo12:state
    bl add_round


round_loop:
    adrp x4, round
    add  x4, x4, :lo12:round
    ldr w5, [x4]
    cmp w5, #1
    b.eq final_round

    adrp x0, state
    add  x0, x0, :lo12:state
    bl inv_shift

    adrp x0, state
    add  x0, x0, :lo12:state
    bl inv_sub

    sub x1, x1, #16

    adrp x0, state
    add  x0, x0, :lo12:state
    bl add_round

    adrp x0, state
    add  x0, x0, :lo12:state
    bl inv_mix

    sub w5, w5, #1
    str w5, [x4]
    b round_loop


final_round:
    adrp x0, state
    add  x0, x0, :lo12:state
    bl inv_shift

    adrp x0, state
    adrp x0, state
    add  x0, x0, :lo12:state
    bl inv_sub

    sub x1, x1, #16

    adrp x0, state
    add  x0, x0, :lo12:state
    bl add_round

    /*  DETENER EJECUCIÓN PARA DEBUG */
    b .


exit:
    mov x0, #0
    mov x8, #93
    svc #0
