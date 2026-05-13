section .data
    prompt db "Enter height h (5-25): ", 0
    prompt_len equ $ - prompt
    newline_char db 10

section .bss
    ; memory: buffers for logic
    input_buf resb 10
    line_buf  resb 128
    h_val     resd 1

section .text
    global _start

_start:
    ; I/O: друк запиту висоти
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; I/O: читання h
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 10
    int 0x80

    ; parse: конвертація рядка в число (h)
    call atoi
    mov [h_val], eax

    ; logic: головний цикл малювання ялинки (ESI = i від 0 до h-1)
    xor esi, esi

.main_loop:
    mov eax, [h_val]
    cmp esi, eax
    jge .exit

    ; math: розрахунок кількості пробілів та зірочок
    ; spaces = h - i - 1
    ; stars  = 2 * i + 1
    
    mov edi, line_buf   ; EDI вказує на початок буфера рядка

    ; loops: цикл для пробілів
    mov ecx, [h_val]
    sub ecx, esi
    dec ecx             ; ECX = h - i - 1
    jz .skip_spaces
.space_loop:
    mov byte [edi], ' '
    inc edi
    loop .space_loop

.skip_spaces:
    ; loops: цикл для зірочок
    mov ecx, esi
    shl ecx, 1          ; ECX = 2 * i
    inc ecx             ; ECX = 2 * i + 1
.star_loop:
    mov byte [edi], '*'
    inc edi
    loop .star_loop

    ; memory: додаємо символ нового рядка в кінець буфера
    mov al, [newline_char]
    mov [edi], al
    inc edi

    ; logic: розрахунок довжини сформованого рядка
    mov edx, edi
    sub edx, line_buf   ; EDX = довжина рядка
    mov ecx, line_buf
    call print_line

    inc esi
    jmp .main_loop

.exit:
    ; I/O: завершення програми
    mov eax, 1
    xor ebx, ebx
    int 0x80

; підпрограма print_line(ecx=buf, edx=len)
print_line:
    push eax
    push ebx
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    int 0x80
    pop ebx
    pop eax
    ret

; parse: atoi (ASCII to Integer)
atoi:
    xor eax, eax
    mov ecx, input_buf
.atoi_loop:
    movzx ebx, byte [ecx]
    cmp bl, 10          ; перевірка на Enter
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
    ret