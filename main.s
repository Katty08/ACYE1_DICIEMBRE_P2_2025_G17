/* =========================================================
 * main.s
 * Persona 1 – Flujo general AES-128 (descifrado)
 * Arquitectura: ARMv7 (32 bits)
 * ========================================================= */

/* ===== Memoria NO inicializada ===== */
.section .bss
.align 4

state:
    .space 16              @ Estado AES (16 bytes)

/* ===== Memoria inicializada ===== */
.section .data
.align 4

round:
    .word 10               @ Contador de rondas (AES-128 = 10)


/* ===== Código ===== */
.section .text
.align 4
.global _start

/* ===== funciones externas ===== */
.extern key_expand         @ Persona 2
.extern inv_mix            @ Persona 3
.extern add_round          @ Persona 4


/* =========================================================
 * _start
 * ========================================================= */
_start:

    /* ===== Ronda inicial ===== */
    bl add_round


/* ===== Rondas intermedias (9 -> 1) ===== */
round_loop:
    ldr r0, =round         @ r0 = &round
    ldr r1, [r0]           @ r1 = round
    cmp r1, #1
    beq final_round        @ si round == 1 -> ronda final

    bl inv_mix             @ InvMixColumns
    bl add_round           @ AddRoundKey

    sub r1, r1, #1         @ round--
    str r1, [r0]
    b round_loop


/* ===== Ronda final ===== */
final_round:
    bl add_round           @ última AddRoundKey (sin InvMixColumns)


/* ===== Salida limpia ===== */
exit:
    mov r0, #0             @ código de salida
    mov r7, #1             @ syscall exit
    swi 0
