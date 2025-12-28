/****************************************************
 * main.s
 * AES-128 – Desencriptación (modo prueba)
 ****************************************************/

.section .rodata
ciphertext:
    .byte 0x69,0xC4,0xE0,0xD8,0x6A,0x7B,0x04,0x30
    .byte 0xD8,0xCD,0xB7,0x80,0x70,0xB4,0xC5,0x5A

key:
    .byte 0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07
    .byte 0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F

.section .bss
.align 4
state:
    .space 16

round_keys:
    .space 176

.section .text
.align 4
.global _start

.extern key_expansion
.extern add_round_key
.extern inv_shift_rows
.extern inv_sub_bytes
.extern print_state
.extern exit_program

_start:
    // copiar ciphertext → state
    ldr x0, =ciphertext
    ldr x1, =state
    mov x2, #16
copy_state:
    ldrb w3, [x0], #1
    strb w3, [x1], #1
    subs x2, x2, #1
    bne copy_state

    // key expansion
    ldr x0, =key
    ldr x1, =round_keys
    bl key_expansion

    // ronda 10
    ldr x0, =state
    ldr x1, =round_keys
    add x1, x1, #160
    bl add_round_key

    // rondas 9 → 1
    mov x20, #9
round_loop:
    ldr x0, =state
    bl inv_shift_rows

    ldr x0, =state
    bl inv_sub_bytes

    ldr x0, =state
    ldr x1, =round_keys
    mov x2, x20
    lsl x2, x2, #4
    add x1, x1, x2
    bl add_round_key

    subs x20, x20, #1
    bne round_loop

    // ronda final
    ldr x0, =state
    bl inv_shift_rows

    ldr x0, =state
    bl inv_sub_bytes

    ldr x0, =state
    ldr x1, =round_keys
    bl add_round_key

    // imprimir
    ldr x0, =state
    bl print_state

    bl exit_program
