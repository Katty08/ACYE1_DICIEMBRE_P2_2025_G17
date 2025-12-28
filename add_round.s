/* =========================================
 * add_round.s
 * AddRoundKey - AES-128
 * x0 = &state
 * x1 = &round_key
 * ========================================= */

.section .text
.align 4
.global add_round

add_round:
    stp x19, x20, [sp, #-32]!
    stp x21, x30, [sp, #16]

    mov w19, #0             // contador i = 0

loop_add:
    cmp w19, #16
    b.eq end_add

    ldrb w20, [x0, x19]     // w20 = state[i]
    ldrb w21, [x1, x19]     // w21 = key[i]
    eor  w20, w20, w21      // state[i] ^= key[i]
    strb w20, [x0, x19]     // guardar resultado

    add w19, w19, #1
    b loop_add

end_add:
    ldp x21, x30, [sp, #16]
    ldp x19, x20, [sp], #32
    ret
