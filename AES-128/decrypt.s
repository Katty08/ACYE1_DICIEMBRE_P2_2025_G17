.section .text
.global AES128_DecryptBlock

// Declarar referencias externas
.extern AddRoundKey
.extern InvSubBytes
.extern InvShiftRows
.extern InvMixColumns
.extern printKey
.extern printRoundNumber

// Constantes de mensajes
.extern msg_round_hdr
.extern msg_after_isr
.extern msg_after_isb
.extern msg_after_ark
.extern msg_after_imc
.extern msg_state_title

AES128_DecryptBlock:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    str x25, [sp, #64]
    mov x19, x0  // state
    mov x20, x1  // expandedKeys

    // Ronda inicial (10): AddRoundKey
    add x1, x20, #160
    mov x0, x19
    bl AddRoundKey
    
    // DEBUG: estado después AddRoundKey (ronda 10)
    mov x0, #1
    ldr x1, =msg_round_hdr
    mov x2, #11
    mov x8, #64
    svc #0
    
    mov w0, #10
    bl printRoundNumber
    
    mov x0, #1
    ldr x1, =msg_after_ark
    mov x2, #21
    mov x8, #64
    svc #0
    
    mov x0, #1
    ldr x1, =msg_state_title
    mov x2, #19
    mov x8, #64
    svc #0
    
    mov x0, x19
    bl printKey

    // Rondas 9 a 1
    mov w21, #9
round_loop:
    cmp w21, #0
    b.le final_round
    
    // DEBUG: inicio de ronda
    mov x0, #1
    ldr x1, =msg_round_hdr
    mov x2, #11
    mov x8, #64
    svc #0
    
    // GUARDAR w21 antes de llamar a funciones
    str w21, [sp, #76]  // Guardar en la pila
    mov w0, w21
    bl printRoundNumber
    ldr w21, [sp, #76]  // Restaurar después

    // 1. InvShiftRows
    mov x0, x19
    bl InvShiftRows
    
    // DEBUG: después InvShiftRows
    mov x0, #1
    ldr x1, =msg_after_isr
    mov x2, #22
    mov x8, #64
    svc #0
    
    mov x0, #1
    ldr x1, =msg_state_title
    mov x2, #19
    mov x8, #64
    svc #0
    
    str w21, [sp, #76]  // Guardar w21
    mov x0, x19
    bl printKey
    ldr w21, [sp, #76]  // Restaurar w21

    // 2. InvSubBytes
    mov x0, x19
    bl InvSubBytes
    
    // DEBUG: después InvSubBytes
    mov x0, #1
    ldr x1, =msg_after_isb
    mov x2, #21
    mov x8, #64
    svc #0
    
    mov x0, #1
    ldr x1, =msg_state_title
    mov x2, #19
    mov x8, #64
    svc #0
    
    str w21, [sp, #76]  // Guardar w21
    mov x0, x19
    bl printKey
    ldr w21, [sp, #76]  // Restaurar w21

    // 3. AddRoundKey (con clave de ronda actual)
    mov x0, x19
    uxtw x22, w21
    lsl x22, x22, #4
    add x1, x20, x22
    bl AddRoundKey
    
    // DEBUG: después AddRoundKey
    mov x0, #1
    ldr x1, =msg_after_ark
    mov x2, #21
    mov x8, #64
    svc #0
    
    mov x0, #1
    ldr x1, =msg_state_title
    mov x2, #19
    mov x8, #64
    svc #0
    
    str w21, [sp, #76]  // Guardar w21
    mov x0, x19
    bl printKey
    ldr w21, [sp, #76]  // Restaurar w21

    // 4. InvMixColumns (excepto última ronda)
    mov x0, x19
    bl InvMixColumns
    
    // DEBUG: después InvMixColumns
    mov x0, #1
    ldr x1, =msg_after_imc
    mov x2, #23
    mov x8, #64
    svc #0
    
    mov x0, #1
    ldr x1, =msg_state_title
    mov x2, #19
    mov x8, #64
    svc #0
    
    str w21, [sp, #76]  // Guardar w21
    mov x0, x19
    bl printKey
    ldr w21, [sp, #76]  // Restaurar w21

    sub w21, w21, #1
    b round_loop

final_round:
    // DEBUG: inicio ronda 0
    mov x0, #1
    ldr x1, =msg_round_hdr
    mov x2, #11
    mov x8, #64
    svc #0
    
    mov w0, #0
    bl printRoundNumber

    // Ronda final (0): NO InvMixColumns
    // 1. InvShiftRows
    mov x0, x19
    bl InvShiftRows
    
    // DEBUG: después InvShiftRows
    mov x0, #1
    ldr x1, =msg_after_isr
    mov x2, #22
    mov x8, #64
    svc #0
    
    mov x0, #1
    ldr x1, =msg_state_title
    mov x2, #19
    mov x8, #64
    svc #0
    
    mov x0, x19
    bl printKey

    // 2. InvSubBytes
    mov x0, x19
    bl InvSubBytes
    
    // DEBUG: después InvSubBytes
    mov x0, #1
    ldr x1, =msg_after_isb
    mov x2, #21
    mov x8, #64
    svc #0
    
    mov x0, #1
    ldr x1, =msg_state_title
    mov x2, #19
    mov x8, #64
    svc #0
    
    mov x0, x19
    bl printKey

    // 3. AddRoundKey (clave de ronda 0)
    mov x0, x19
    mov x1, x20
    bl AddRoundKey
    
    // DEBUG: después AddRoundKey
    mov x0, #1
    ldr x1, =msg_after_ark
    mov x2, #21
    mov x8, #64
    svc #0
    
    mov x0, #1
    ldr x1, =msg_state_title
    mov x2, #19
    mov x8, #64
    svc #0
    
    mov x0, x19
    bl printKey

    ldr x25, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret

    