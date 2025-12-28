.section .text

.global AddRoundKey
.global InvSubBytes
.global InvShiftRows
.global xtime
.global gf_mul_const
.global InvMixColumns

// Declarar referencias externas
.extern InvSbox

AddRoundKey:
    mov x2, #0
1:  cmp x2, #16
    b.ge 2f
    ldrb w3, [x0, x2]
    ldrb w4, [x1, x2]
    eor w3, w3, w4
    strb w3, [x0, x2]
    add x2, x2, #1
    b 1b
2:  ret

InvSubBytes:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    ldr x1, =InvSbox
    mov x2, #0
1:  cmp x2, #16
    b.ge 2f
    ldrb w3, [x0, x2]
    uxtw x3, w3
    ldrb w4, [x1, x3]
    strb w4, [x0, x2]
    add x2, x2, #1
    b 1b
2:  ldp x29, x30, [sp], #16
    ret

InvShiftRows:
    // Row1: [1,5,9,13] -> [13,1,5,9]
    ldrb w1, [x0, #1]
    ldrb w2, [x0, #5]
    ldrb w3, [x0, #9]
    ldrb w4, [x0, #13]
    strb w4, [x0, #1]
    strb w1, [x0, #5]
    strb w2, [x0, #9]
    strb w3, [x0, #13]

    // Row2: [2,6,10,14] -> [10,14,2,6]
    ldrb w1, [x0, #2]
    ldrb w2, [x0, #6]
    ldrb w3, [x0, #10]
    ldrb w4, [x0, #14]
    strb w3, [x0, #2]
    strb w4, [x0, #6]
    strb w1, [x0, #10]
    strb w2, [x0, #14]

    // Row3: [3,7,11,15] -> [7,11,15,3]
    ldrb w1, [x0, #3]
    ldrb w2, [x0, #7]
    ldrb w3, [x0, #11]
    ldrb w4, [x0, #15]
    strb w2, [x0, #3]
    strb w3, [x0, #7]
    strb w4, [x0, #11]
    strb w1, [x0, #15]
    ret

xtime:
    and w1, w0, #0x80
    lsl w0, w0, #1
    and w0, w0, #0xFF
    cbz w1, 1f
    mov w2, #0x1B
    eor w0, w0, w2
1:  ret

gf_mul_const:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov w6, w1
    mov w7, w0
    
    bl xtime
    mov w3, w0
    mov w0, w3
    bl xtime
    mov w4, w0
    mov w0, w4
    bl xtime
    mov w5, w0

    cmp w6, #0x09
    b.eq mul_09
    cmp w6, #0x0B
    b.eq mul_0B
    cmp w6, #0x0D
    b.eq mul_0D
    // 0x0E
    eor w0, w5, w4
    eor w0, w0, w3
    b mul_done
mul_09:
    eor w0, w5, w7
    b mul_done
mul_0B:
    eor w0, w5, w3
    eor w0, w0, w7
    b mul_done
mul_0D:
    eor w0, w5, w4
    eor w0, w0, w7
mul_done:
    ldp x29, x30, [sp], #16
    ret

InvMixColumns:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    
    mov x19, x0
    mov x20, #0
    
col_loop:
    cmp x20, #4
    b.ge done
    
    mov x21, x20
    lsl x21, x21, #2
    
    ldrb w22, [x19, x21]
    add x23, x21, #1
    ldrb w24, [x19, x23]
    add x25, x21, #2
    ldrb w26, [x19, x25]
    add x27, x21, #3
    ldrb w28, [x19, x27]
    
    // t0 = 0E*s0 ^ 0B*s1 ^ 0D*s2 ^ 09*s3
    mov w0, w22
    mov w1, #0x0E
    bl gf_mul_const
    mov w9, w0
    
    mov w0, w24
    mov w1, #0x0B
    bl gf_mul_const
    eor w9, w9, w0
    
    mov w0, w26
    mov w1, #0x0D
    bl gf_mul_const
    eor w9, w9, w0
    
    mov w0, w28
    mov w1, #0x09
    bl gf_mul_const
    eor w9, w9, w0
    
    strb w9, [x19, x21]
    
    // t1 = 09*s0 ^ 0E*s1 ^ 0B*s2 ^ 0D*s3
    mov w0, w22
    mov w1, #0x09
    bl gf_mul_const
    mov w9, w0
    
    mov w0, w24
    mov w1, #0x0E
    bl gf_mul_const
    eor w9, w9, w0
    
    mov w0, w26
    mov w1, #0x0B
    bl gf_mul_const
    eor w9, w9, w0
    
    mov w0, w28
    mov w1, #0x0D
    bl gf_mul_const
    eor w9, w9, w0
    
    strb w9, [x19, x23]
    
    // t2 = 0D*s0 ^ 09*s1 ^ 0E*s2 ^ 0B*s3
    mov w0, w22
    mov w1, #0x0D
    bl gf_mul_const
    mov w9, w0
    
    mov w0, w24
    mov w1, #0x09
    bl gf_mul_const
    eor w9, w9, w0
    
    mov w0, w26
    mov w1, #0x0E
    bl gf_mul_const
    eor w9, w9, w0
    
    mov w0, w28
    mov w1, #0x0B
    bl gf_mul_const
    eor w9, w9, w0
    
    strb w9, [x19, x25]
    
    // t3 = 0B*s0 ^ 0D*s1 ^ 09*s2 ^ 0E*s3
    mov w0, w22
    mov w1, #0x0B
    bl gf_mul_const
    mov w9, w0
    
    mov w0, w24
    mov w1, #0x0D
    bl gf_mul_const
    eor w9, w9, w0
    
    mov w0, w26
    mov w1, #0x09
    bl gf_mul_const
    eor w9, w9, w0
    
    mov w0, w28
    mov w1, #0x0E
    bl gf_mul_const
    eor w9, w9, w0
    
    strb w9, [x19, x27]
    
    add x20, x20, #1
    b col_loop

done:
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret



    

    