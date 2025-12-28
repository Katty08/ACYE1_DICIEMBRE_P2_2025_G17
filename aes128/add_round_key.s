/****************************************************
 * add_round_key.s
 * AES AddRoundKey
 * Arquitectura: ARM64
 ****************************************************/

.section .text
.align 4
.global add_round_key

/****************************************************
 * add_round_key
 * x0 = puntero a state (16 bytes)
 * x1 = puntero a round_key (16 bytes)
 ****************************************************/
add_round_key:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x2, #16          // contador de bytes

xor_loop:
    ldrb w3, [x0]        // state[i]
    ldrb w4, [x1]        // round_key[i]
    eor w3, w3, w4
    strb w3, [x0], #1

    add x1, x1, #1
    subs x2, x2, #1
    bne xor_loop

    ldp x29, x30, [sp], #16
    ret
