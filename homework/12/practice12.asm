section .data
    prompt_text db "Enter text: ", 0
    prompt_pat  db "Enter pattern: ", 0
    msg_first   db "First index: ", 0
    msg_count   db 10, "Total count: ", 0
    newline     db 10
    minus_sign  db "-"

section .bss
    ; memory: buffers
    text_buf  resb 256
    pat_buf   resb 64
    out_buf   resb 16
    t_len     resd 1
    p_len     resd 1
    first_idx resd 1
    total_cnt resd 1

section .text
    global _start

_start:
    ; I/O: Ввід тексту
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_text
    mov edx, 12
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, text_buf
    mov edx, 255
    int 0x80
    mov ecx, text_buf
    call strip_newline
    mov [t_len], eax

    ; I/O: Ввід шаблону
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_pat
    mov edx, 15
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, pat_buf
    mov edx, 63
    int 0x80
    mov ecx, pat_buf
    call strip_newline
    mov [p_len], eax

    ; logic: Ініціалізація
    mov dword [first_idx], -1
    mov dword [total_cnt], 0

    ; Перевірка на порожній шаблон
    mov eax, [p_len]
    test eax, eax
    jz .print_results

    ; logic: Пошук підрядка (Наївний алгоритм)
    xor esi, esi            ; i = індекс у тексті
.outer_loop:
    ; Перевірка межі: i + p_len <= t_len
    mov eax, esi
    add eax, [p_len]
    cmp eax, [t_len]
    jg .print_results

    ; Порівняння: text[esi] з pattern
    xor edi, edi            ; j = індекс у шаблоні
.inner_loop:
    cmp edi, [p_len]
    je .match_found

    mov al, [text_buf + esi + edi]
    mov bl, [pat_buf + edi]
    cmp al, bl
    jne .no_match

    inc edi
    jmp .inner_loop

.match_found:
    inc dword [total_cnt]
    cmp dword [first_idx], -1
    jne .not_the_first
    mov [first_idx], esi
.not_the_first:
    add esi, [p_len]        ; Пропускаємо знайдений підрядок (без перекриття)
    jmp .outer_loop

.no_match:
    inc esi                 ; Зсув на 1 символ
    jmp .outer_loop

.print_results:
    ; I/O: Вивід результатів
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_first
    mov edx, 13
    int 0x80

    mov eax, [first_idx]
    call itoa_signed

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_count
    mov edx, 13
    int 0x80

    mov eax, [total_cnt]
    call itoa_unsigned

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

.exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Підпрограми ---

strip_newline:
    ; Видаляє \n та повертає довжину в EAX
    xor eax, eax
.loop:
    mov dl, [ecx + eax]
    cmp dl, 10
    je .found
    cmp dl, 13
    je .found
    cmp dl, 0
    je .done
    inc eax
    jmp .loop
.found:
    mov byte [ecx + eax], 0
.done:
    ret

itoa_signed:
    test eax, eax
    jns itoa_unsigned
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, minus_sign
    mov edx, 1
    int 0x80
    pop eax
    neg eax
    ; Продовжуємо в itoa_unsigned

itoa_unsigned:
    pushad
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
    popad
    ret