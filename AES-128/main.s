.section .text

.global _start

// Declarar referencias externas
.extern msg_last_key
.extern msg_ciphertext
.extern msg_cipher_state
.extern msg_plain_title
.extern cipherState
.extern expandedKeys
.extern convertHexKey
.extern inverseKeyExpansion
.extern printAllKeys
.extern convertHexBlock16
.extern printKey
.extern AES128_DecryptBlock

_start:
    // Pedir última clave
    mov x0, #1
    ldr x1, =msg_last_key
    mov x2, #36
    mov x8, #64
    svc #0
    
    bl convertHexKey
    bl inverseKeyExpansion
    bl printAllKeys

    // Pedir ciphertext
    mov x0, #1
    ldr x1, =msg_ciphertext
    mov x2, #45
    mov x8, #64
    svc #0
    
    ldr x0, =cipherState
    bl convertHexBlock16

    // Mostrar ciphertext
    mov x0, #1
    ldr x1, =msg_cipher_state
    mov x2, #31
    mov x8, #64
    svc #0
    
    ldr x0, =cipherState
    bl printKey

    // Desencriptar
    ldr x0, =cipherState
    ldr x1, =expandedKeys
    bl AES128_DecryptBlock

    // Mostrar plaintext
    mov x0, #1
    ldr x1, =msg_plain_title
    mov x2, #22
    mov x8, #64
    svc #0
    
    ldr x0, =cipherState
    bl printKey

    // Salir
    mov x0, #0
    mov x8, #93
    svc #0



