/* =========================================================
 * main.s
 * AES-128 – Descifrado
 * Persona 1 – Flujo general del algoritmo
 * Arquitectura: ARMv7 (32 bits)
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
    ldr r0, =ciphertext
    ldr r1, =state
    mov r2, #16

copy_state:
    ldrb r3, [r0], #1
    strb r3, [r1], #1
    subs r2, r2, #1
    bne copy_state


    /* Subclave final */
    ldr r1, =round_keys
    add r1, r1, #160


    /* Ronda inicial */
    ldr r0, =state
    bl add_round


round_loop:
    ldr r4, =round
    ldr r5, [r4]
    cmp r5, #1
    beq final_round

    ldr r0, =state
    bl inv_shift

    ldr r0, =state
    bl inv_sub

    sub r1, r1, #16

    ldr r0, =state
    bl add_round

    ldr r0, =state
    bl inv_mix

    sub r5, r5, #1
    str r5, [r4]
    b round_loop


final_round:
    ldr r0, =state
    bl inv_shift

    ldr r0, =state
    bl inv_sub

    sub r1, r1, #16

    ldr r0, =state
    bl add_round

    /*  DETENER EJECUCIÓN PARA DEBUG */
    b .


exit:
    mov r0, #0
    mov r7, #1
    swi 0
