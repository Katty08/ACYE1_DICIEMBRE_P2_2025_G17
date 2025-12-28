/****************************************************
 * inv_sub_bytes.s
 * AES InvSubBytes
 * Arquitectura: ARM64
 ****************************************************/

.section .text
.align 4
.global inv_sub_bytes

.extern inv_sbox

/****************************************************
 * inv_sub_bytes
 * x0 = puntero a state (16 bytes)
 ****************************************************/
inv_sub_bytes:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr x1, =inv_sbox     // tabla inv_sbox
    mov x2, #16           // 16 bytes del estado

loop_inv_sub:
    ldrb w3, [x0]         // byte actual del state
    uxtw x3, w3           // extender a 64 bits para indexar
    ldrb w4, [x1, x3]     // inv_sbox[state[i]]
    strb w4, [x0], #1     // guardar y avanzar

    subs x2, x2, #1
    bne loop_inv_sub

    ldp x29, x30, [sp], #16
    ret
