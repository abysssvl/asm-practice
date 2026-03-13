section .data
    ; memory: reserve space for newline
    newline db 0xA

section .bss
    ; memory: buffer for storing digits (max 7 chars for 999999 + null)
    buffer resb 8

section .text
    global _start

_start:
    ; math: input number 0...999999 (example: 123456)
    ; we use EAX because AX is part of it
    mov eax, 123456     
    
    ; logic: point to the end of the buffer
    mov edi, buffer
    add edi, 7          ; move to the last byte
    mov byte [edi], 0   ; null terminator (optional for sys_write)
    
    ; math/logic: handle zero case
    cmp eax, 0
    jne .parse_init
    dec edi
    mov byte [edi], '0'
    jmp .print_result

.parse_init:
    mov ebx, 10         ; divisor for math

.loops:
    ; math: divide EAX by 10
    xor edx, edx        ; clear remainder
    div ebx             ; EAX = quotient, EDX = remainder
    
    ; math: convert remainder to ASCII
    add dl, '0'
    dec edi             ; move buffer pointer back
    mov [edi], dl       ; store digit
    
    ; logic: check if quotient is zero
    test eax, eax
    jnz .loops          ; if not zero, continue loops

.print_result:
    ; I/O: sys_write (EAX=4)
    ; first, calculate length
    mov edx, buffer
    add edx, 7
    sub edx, edi        ; EDX now contains string length
    
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, edi        ; pointer to start of string
    int 0x80            ; kernel call

    ; I/O: print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

.exit:
    ; I/O: sys_exit (EAX=1)
    mov eax, 1
    xor ebx, ebx        ; exit code 0
    int 0x80