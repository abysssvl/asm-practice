section .data
    msg_n db "Enter n (5-50): ", 0
    msg_min db 10, "Min: ", 0
    msg_max db 10, "Max: ", 0
    msg_idx db " at index ", 0
    space db " ", 0
    newline db 10

section .bss
    ; memory: array and buffers
    array resd 50
    input_buf resb 10
    out_buf resb 12
    n_val resd 1

section .text
    global _start

_start:
    ; I/O: Ask for n
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_n
    mov edx, 16
    int 0x80

    ; I/O: Read n
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 10
    int 0x80
    call atoi
    mov [n_val], eax

    ; logic: Fill array using formula (i * 3 + 7)
    xor ecx, ecx        ; i = 0
.fill_loop:
    cmp ecx, [n_val]
    je .print_array
    
    ; math: generate value
    mov eax, ecx
    imul eax, 3
    add eax, 7
    
    ; memory: store in array [base + ecx*4]
    mov [array + ecx*4], eax
    
    inc ecx
    jmp .fill_loop

.print_array:
    ; I/O: Print all elements
    xor esi, esi        ; index
.p_loop:
    cmp esi, [n_val]
    je .find_min_max
    
    mov eax, [array + esi*4]
    call itoa
    
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    
    inc esi
    jmp .p_loop

.find_min_max:
    ; logic: Search min/max
    mov eax, [array]    ; current max
    mov ebx, [array]    ; current min
    xor ecx, ecx        ; current index
    xor edx, edx        ; max index
    xor ebp, ebp        ; min index

.search_loop:
    inc ecx
    cmp ecx, [n_val]
    je .print_results
    
    mov esi, [array + ecx*4]
    
    ; logic: compare for max
    cmp esi, eax
    jle .check_min
    mov eax, esi
    mov edx, ecx
    
.check_min:
    ; logic: compare for min
    cmp esi, ebx
    jge .search_loop
    mov ebx, esi
    mov ebp, ecx
    jmp .search_loop

.print_results:
    ; logic: print min and its index
    push eax            ; save max
    push edx            ; save max index
    
    mov eax, 4
    mov ecx, msg_min
    mov edx, 6
    int 0x80
    
    mov eax, ebx        ; min value
    call itoa
    
    mov eax, 4
    mov ecx, msg_idx
    mov edx, 10
    int 0x80
    
    mov eax, ebp        ; min index
    call itoa

    ; logic: print max and its index
    pop edx             ; restore max index
    pop ebx             ; restore max value
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_max
    mov edx, 6
    int 0x80
    
    mov eax, ebx        ; max value
    call itoa
    
    mov eax, 4
    mov ecx, msg_idx
    mov edx, 10
    int 0x80
    
    mov eax, edx        ; max index
    call itoa
    
    mov eax, 4
    mov ecx, newline
    mov edx, 1
    int 0x80

.exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; parse: string to int
atoi:
    xor eax, eax
    mov esi, ecx
.loop:
    movzx ebx, byte [esi]
    cmp bl, 10
    je .done
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp .loop
.done: ret

; I/O: int to string
itoa:
    mov edi, out_buf
    add edi, 11
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
    
    mov ecx, edi
    mov edx, out_buf
    add edx, 11
    sub edx, edi
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret