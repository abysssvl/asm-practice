section .data
    msg_n db "Enter n (10-100): ", 0
    msg_val db "Enter value: ", 0
    msg_target db "Enter target: ", 0
    msg_first db "First index: ", 0
    msg_count db 10, "Count: ", 0
    msg_indices db 10, "All indices: ", 0
    space db " ", 0
    newline db 10
    not_found_msg db "-1", 0

section .bss
    ; memory: array storage and buffers
    array resd 100
    found_indices resd 100
    input_buf resb 16
    out_buf resb 16
    n_val resd 1
    target resd 1
    count resd 1
    first_idx resd 1

section .text
    global _start

_start:
    ; I/O: Get array size
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_n
    mov edx, 18
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 16
    int 0x80
    call atoi
    mov [n_val], eax

    ; logic: Fill array from user input
    xor esi, esi        ; i = 0
.input_loop:
    cmp esi, [n_val]
    je .get_target
    
    push esi            ; save index
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_val
    mov edx, 13
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 16
    int 0x80
    call atoi
    pop esi             ; restore index
    
    mov [array + esi*4], eax
    inc esi
    jmp .input_loop

.get_target:
    ; I/O: Get target value
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_target
    mov edx, 14
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 16
    int 0x80
    call atoi
    mov [target], eax

    ; logic: Linear search
    mov dword [first_idx], -1
    mov dword [count], 0
    xor esi, esi        ; index i = 0
    xor edi, edi        ; found count j = 0

.search_loop:
    cmp esi, [n_val]
    je .print_results
    
    mov eax, [array + esi*4]
    cmp eax, [target]
    jne .next_iter

    ; match found
    inc dword [count]
    mov [found_indices + edi*4], esi
    inc edi
    
    ; check if it is the first match
    cmp dword [first_idx], -1
    jne .next_iter
    mov [first_idx], esi

.next_iter:
    inc esi
    jmp .search_loop

.print_results:
    ; I/O: Print first index
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_first
    mov edx, 13
    int 0x80

    mov eax, [first_idx]
    cmp eax, -1
    je .print_minus_one
    call itoa
    jmp .print_total_count

.print_minus_one:
    mov eax, 4
    mov ebx, 1
    mov ecx, not_found_msg
    mov edx, 2
    int 0x80

.print_total_count:
    ; I/O: Print count
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_count
    mov edx, 8
    int 0x80
    mov eax, [count]
    call itoa

    ; I/O: Print all indices
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_indices
    mov edx, 13
    int 0x80

    xor esi, esi
.print_idx_loop:
    cmp esi, [count]
    je .finish
    
    mov eax, [found_indices + esi*4]
    call itoa
    
    push esi
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    pop esi
    
    inc esi
    jmp .print_idx_loop

.finish:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80

; parse: atoi
atoi:
    xor eax, eax
    mov esi, ecx
.atoi_loop:
    movzx ebx, byte [esi]
    cmp bl, 10
    je .atoi_done
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp .atoi_loop
.atoi_done: ret

; I/O: itoa
itoa:
    test eax, eax
    jnz .itoa_real
    mov edi, out_buf
    mov byte [edi], '0'
    mov edx, 1
    jmp .itoa_write
.itoa_real:
    mov edi, out_buf
    add edi, 15
    mov byte [edi], 0
    mov ebx, 10
.itoa_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .itoa_loop
    mov edx, out_buf
    add edx, 15
    sub edx, edi
.itoa_write:
    mov ecx, edi
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret