section .data
    msg_a db "Enter a: ", 0
    msg_b db "Enter b: ", 0
    s_prefix db "SIGNED: ", 0
    u_prefix db "UNSIGNED: ", 0
    m_s_prefix db "max_signed: ", 0
    m_u_prefix db "max_unsigned: ", 0
    lt db "a < b", 10, 0
    eq db "a = b", 10, 0
    gt db "a > b", 10, 0
    newline db 10

section .bss
    ; memory: buffers
    buf_a resb 16
    buf_b resb 16
    out_buf resb 16
    val_a resd 1
    val_b resd 1

section .text
    global _start

_start:
    ; I/O: Input A
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_a
    mov edx, 9
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buf_a
    mov edx, 16
    int 0x80
    call atoi
    mov [val_a], eax

    ; I/O: Input B
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_b
    mov edx, 9
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buf_b
    mov edx, 16
    int 0x80
    call atoi
    mov [val_b], eax

    ; logic: Signed Comparison
    mov eax, 4
    mov ebx, 1
    mov ecx, s_prefix
    mov edx, 8
    int 0x80

    mov eax, [val_a]
    mov ebx, [val_b]
    cmp eax, ebx
    jl .s_lt
    je .s_eq
    jg .s_gt

.s_lt:
    mov ecx, lt
    jmp .s_print
.s_eq:
    mov ecx, eq
    jmp .s_print
.s_gt:
    mov ecx, gt
.s_print:
    mov edx, 6
    mov eax, 4
    mov ebx, 1
    int 0x80

    ; logic: Unsigned Comparison
    mov eax, 4
    mov ebx, 1
    mov ecx, u_prefix
    mov edx, 10
    int 0x80

    mov eax, [val_a]
    mov ebx, [val_b]
    cmp eax, ebx
    jb .u_lt
    je .u_eq
    ja .u_gt

.u_lt:
    mov ecx, lt
    jmp .u_print
.u_eq:
    mov ecx, eq
    jmp .u_print
.u_gt:
    mov ecx, gt
.u_print:
    mov edx, 6
    mov eax, 4
    mov ebx, 1
    int 0x80

    ; math: Max Signed
    mov eax, 4
    mov ebx, 1
    mov ecx, m_s_prefix
    mov edx, 12
    int 0x80

    mov eax, [val_a]
    mov ebx, [val_b]
    cmp eax, ebx
    jg .print_max_s
    mov eax, ebx
.print_max_s:
    call itoa_signed

    ; math: Max Unsigned
    mov eax, 4
    mov ebx, 1
    mov ecx, m_u_prefix
    mov edx, 14
    int 0x80

    mov eax, [val_a]
    mov ebx, [val_b]
    cmp eax, ebx
    ja .print_max_u
    mov eax, ebx
.print_max_u:
    call itoa_unsigned

.exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; parse: atoi handles negative numbers
atoi:
    xor eax, eax
    xor ebx, ebx
    xor edx, edx
    mov esi, ecx
    cmp byte [esi], '-'
    jne .loop
    inc esi
    mov edx, 1 ; flag for negative
.loop:
    mov bl, [esi]
    cmp bl, 10
    je .finish
    cmp bl, '0'
    jb .finish
    cmp bl, '9'
    ja .finish
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp .loop
.finish:
    test edx, edx
    jz .ret
    neg eax
.ret:
    ret

; I/O: itoa signed
itoa_signed:
    test eax, eax
    jns itoa_unsigned
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, .minus
    mov edx, 1
    int 0x80
    pop eax
    neg eax
    jmp itoa_unsigned
    section .data
        .minus db '-'
    section .text

; I/O: itoa unsigned
itoa_unsigned:
    mov edi, out_buf
    add edi, 15
    mov byte [edi], 0
    mov ebx, 10
.loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .loop
    
    mov ecx, edi
    mov edx, out_buf
    add edx, 15
    sub edx, edi
    mov eax, 4
    mov ebx, 1
    int 0x80
    
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret