section .data
    msg_n       db "Enter n (0-12): ", 0
    msg_fact    db "fact(n) = ", 0
    msg_calls   db 10, "calls = ", 0
    newline     db 10

section .bss
    ; memory: buffers and global counters
    input_buf resb 16
    out_buf   resb 16
    calls     resd 1
    n_val     resd 1

section .text
    global _start

_start:
    ; I/O: Input request
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_n
    mov edx, 17
    int 0x80

    ; I/O: Read n
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 16
    int 0x80
    call atoi
    mov [n_val], eax

    ; logic: Initialize global counter
    mov dword [calls], 0

    ; math: Call recursive factorial function
    mov eax, [n_val]
    call fact
    push eax            ; save result

    ; I/O: Print factorial result string
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_fact
    mov edx, 10
    int 0x80

    pop eax             ; restore result
    call itoa

    ; I/O: Print calls counter string
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_calls
    mov edx, 9
    int 0x80

    mov eax, [calls]
    call itoa

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

.exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; math: Recursive factorial function
; Input: EAX = n, Output: EAX = n!
fact:
    ; logic: Prologue
    push ebp
    mov ebp, esp
    
    inc dword [calls]   ; increment global call counter

    cmp eax, 1
    jbe .base_case       ; if n <= 1, return 1

    ; logic: Recursive step
    push eax            ; save current n on stack
    dec eax             ; n - 1
    call fact           ; fact(n - 1), result is in EAX
    pop ebx             ; restore original n into EBX
    
    mul ebx             ; EAX = EAX * EBX (result * n)
    jmp .epilogue

.base_case:
    mov eax, 1          ; 0! = 1, 1! = 1

.epilogue:
    mov esp, ebp
    pop ebp
    ret

; parse: atoi
atoi:
    push ebx
    push ecx
    xor eax, eax
    mov ecx, input_buf
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