.section .text

.global inverseKeyExpansion
.global printAllKeys

// Declarar referencias externas
.extern lastKey
.extern expandedKeys
.extern Rcon
.extern tempWord
.extern msg_inverse_title
.extern msg_round_key
.extern msg_colon
.extern msg_original_key
.extern rotWord
.extern subWord
.extern printKey
.extern printRoundNumber

inverseKeyExpansion:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    
    ldr x19, =lastKey
    ldr x20, =expandedKeys
    ldr x21, =Rcon
    
    // Copiar última clave a posición de ronda 10
    mov x22, #0
copy_loop:
    cmp x22, #16
    b.ge copy_done
    ldrb w23, [x19, x22]
    add x24, x22, #160
    strb w23, [x20, x24]
    add x22, x22, #1
    b copy_loop
copy_done:

    // Calcular claves anteriores
    mov x22, #43
main_loop:
    cmp x22, #3
    b.le loop_done
    
    // Dirección de W[i]
    mov x23, #4
    mul x24, x22, x23
    add x24, x20, x24
    
    // Verificar si i es múltiplo de 4
    and x25, x22, #3
    cbnz x25, not_multiple
    
    // i múltiplo de 4
    sub x25, x22, #1
    mul x25, x25, x23
    add x25, x20, x25
    
    // Copiar a tempWord
    ldr x26, =tempWord
    ldrb w0, [x25, #0]
    strb w0, [x26, #0]
    ldrb w0, [x25, #1]
    strb w0, [x26, #1]
    ldrb w0, [x25, #2]
    strb w0, [x26, #2]
    ldrb w0, [x25, #3]
    strb w0, [x26, #3]
    
    // Aplicar RotWord y SubWord
    mov x0, x26
    bl rotWord
    mov x0, x26
    bl subWord
    
    // XOR con Rcon[i/4 - 1]
    lsr x25, x22, #2
    sub x25, x25, #1
    mov x23, #4
    mul x25, x25, x23
    add x25, x21, x25
    
    ldrb w0, [x26, #0]
    ldrb w1, [x25, #0]
    eor w0, w0, w1
    strb w0, [x26, #0]
    
    // W[i-4] = W[i] XOR tempWord
    sub x25, x22, #4
    mov x23, #4
    mul x25, x25, x23
    add x25, x20, x25
    
    ldrb w0, [x24, #0]
    ldrb w1, [x26, #0]
    eor w0, w0, w1
    strb w0, [x25, #0]
    
    ldrb w0, [x24, #1]
    ldrb w1, [x26, #1]
    eor w0, w0, w1
    strb w0, [x25, #1]
    
    ldrb w0, [x24, #2]
    ldrb w1, [x26, #2]
    eor w0, w0, w1
    strb w0, [x25, #2]
    
    ldrb w0, [x24, #3]
    ldrb w1, [x26, #3]
    eor w0, w0, w1
    strb w0, [x25, #3]
    
    b next_iteration
    
not_multiple:
    // i no múltiplo de 4
    sub x25, x22, #4
    mov x23, #4
    mul x25, x25, x23
    add x25, x20, x25
    
    sub x26, x22, #1
    mul x26, x26, x23
    add x26, x20, x26
    
    ldrb w0, [x24, #0]
    ldrb w1, [x26, #0]
    eor w0, w0, w1
    strb w0, [x25, #0]
    
    ldrb w0, [x24, #1]
    ldrb w1, [x26, #1]
    eor w0, w0, w1
    strb w0, [x25, #1]
    
    ldrb w0, [x24, #2]
    ldrb w1, [x26, #2]
    eor w0, w0, w1
    strb w0, [x25, #2]
    
    ldrb w0, [x24, #3]
    ldrb w1, [x26, #3]
    eor w0, w0, w1
    strb w0, [x25, #3]

next_iteration:
    sub x22, x22, #1
    b main_loop

loop_done:
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret

printAllKeys:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    str x20, [sp, #24]
    
    // Título
    mov x0, #1
    ldr x1, =msg_inverse_title
    mov x2, #28
    mov x8, #64
    svc #0
    
    ldr x19, =expandedKeys
    mov x20, #10
    
key_loop:
    cmp x20, #0
    b.lt original_key
    
    // "Clave Ronda X:"
    mov x0, #1
    ldr x1, =msg_round_key
    mov x2, #13
    mov x8, #64
    svc #0
    
    mov w0, w20
    bl printRoundNumber
    
    mov x0, #1
    ldr x1, =msg_colon
    mov x2, #2
    mov x8, #64
    svc #0
    
    // Imprimir clave
    mov x21, #16
    mul x21, x20, x21
    add x0, x19, x21
    bl printKey
    
    sub x20, x20, #1
    b key_loop

original_key:
    // "CLAVE ORIGINAL (Ronda 0) "
    mov x0, #1
    ldr x1, =msg_original_key
    mov x2, #25
    mov x8, #64
    svc #0
    
    mov x0, #1
    ldr x1, =newline
    mov x2, #1
    mov x8, #64
    svc #0
    
    mov x0, x19
    bl printKey
    
    ldr x19, [sp, #16]
    ldr x20, [sp, #24]
    ldp x29, x30, [sp], #32
    ret



    

