section .data
    msg_n       db "Enter n (5-200): ", 0
    msg_val     db "Value: ", 0
    msg_orig    db "Original: ", 0
    msg_rev     db 10, "Reversed: ", 0
    msg_pal_y   db 10, "PALINDROME: YES", 10, 0
    msg_pal_n   db 10, "PALINDROME: NO", 10, 0
    space       db " ", 0
    newline     db 10

section .bss
    ; memory: buffers for original and reversed arrays
    arr_orig resd 200
    arr_rev  resd 200
    input_buf resb 16
    out_buf  resb 16
    n_val    resd 1
    is_palin resd 1

section .text
    global _start

_start:
    ; I/O: Input n
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_n
    mov edx, 17
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 16
    int 0x80
    call atoi
    mov [n_val], eax

    ; logic: Input array
    xor esi, esi            ; index = 0
.input_loop:
    cmp esi, [n_val]
    jge .do_reverse

    push esi
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_val
    mov edx, 7
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 16
    int 0x80
    call atoi
    pop esi

    mov [arr_orig + esi*4], eax
    inc esi
    jmp .input_loop

.do_reverse:
    ; memory & loops: Reverse array
    mov ecx, [n_val]
    test ecx, ecx
    jz .print_orig

    xor esi, esi            ; source index (starts from 0)
    mov edi, ecx
    dec edi                 ; dest index (starts from n-1)

.rev_loop:
    mov eax, [arr_orig + esi*4]
    mov [arr_rev + edi*4], eax
    inc esi
    dec edi
    loop .rev_loop

    ; logic: Check Palindrome
    mov dword [is_palin], 1 ; assume YES
    mov ecx, [n_val]
    shr ecx, 1              ; loop n/2 times
    jz .print_orig

    xor esi, esi
    mov edi, [n_val]
    dec edi
.pal_loop:
    mov eax, [arr_orig + esi*4]
    cmp eax, [arr_orig + edi*4]
    je .pal_next
    mov dword [is_palin], 0 ; mismatch -> NO
    jmp .print_orig
.pal_next:
    inc esi
    dec edi
    loop .pal_loop

.print_orig:
    ; I/O: Print Original Array
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_orig
    mov edx, 10
    int 0x80

    mov ecx, [n_val]
    mov esi, arr_orig
    call print_array

    ; I/O: Print Reversed Array
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_rev
    mov edx, 11
    int 0x80

    mov ecx, [n_val]
    mov esi, arr_rev
    call print_array

    ; I/O: Print Palindrome Status
    cmp dword [is_palin], 1
    je .pal_yes

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_pal_n
    mov edx, 16
    int 0x80
    jmp .exit

.pal_yes:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_pal_y
    mov edx, 17
    int 0x80

.exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Subroutines ---

; print_array(ecx=count, esi=array_ptr)
print_array:
    push ebp
    mov ebp, esp
    pushad
    
    test ecx, ecx
    jz .pa_end

    mov edi, 0              ; index
.pa_loop:
    mov eax, [esi + edi*4]
    call itoa
    
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    pop ecx

    inc edi
    loop .pa_loop

.pa_end:
    popad
    pop ebp
    ret

; parse: atoi
atoi:
    push ebx
    push ecx
    xor eax, eax
.atoi_loop:
    movzx ebx, byte [ecx]
    cmp bl, 10
    je .atoi_done
    cmp bl, '0'
    jb .atoi_done
    cmp bl, '9'
    ja .atoi_done
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc ecx
    jmp .atoi_loop
.atoi_done:
    pop ecx
    pop ebx
    ret

; I/O: itoa
itoa:
    pushad
    mov edi, out_buf
    add edi, 15
    mov byte [edi], 0
    mov ebx, 10
    
    test eax, eax
    jnz .itoa_loop
    mov byte [edi-1], '0'
    dec edi
    jmp .itoa_write

.itoa_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .itoa_loop

.itoa_write:
    mov ecx, edi
    mov edx, out_buf
    add edx, 15
    sub edx, edi
    mov eax, 4
    mov ebx, 1
    int 0x80
    popad
    ret