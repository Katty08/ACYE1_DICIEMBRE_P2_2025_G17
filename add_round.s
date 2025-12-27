/* =========================================
 * add_round.s
 * AddRoundKey - AES-128
 * r0 = &state
 * r1 = &round_key
 * ========================================= */

.section .text
.align 4
.global add_round

add_round:
    push {r4, r5, r6, lr}   @ preservar registros

    mov r4, #0              @ contador i = 0

loop_add:
    cmp r4, #16
    beq end_add

    ldrb r5, [r0, r4]       @ r5 = state[i]
    ldrb r6, [r1, r4]       @ r6 = key[i]
    eor  r5, r5, r6         @ state[i] ^= key[i]
    strb r5, [r0, r4]       @ guardar resultado

    add r4, r4, #1
    b loop_add

end_add:
    pop {r4, r5, r6, lr}
    bx lr
