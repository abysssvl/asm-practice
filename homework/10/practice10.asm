section .data
    msg_input  db "Enter x: ", 0
    msg_bin    db "Binary: ", 0
    msg_pop    db 10, "Popcount: ", 0
    msg_mod    db 10, "Modified (set 0,3, clear 31): ", 0
    space      db " ", 0
    newline    db 10

section .bss
    ; memory: buffers
    input_buf resb 16
    out_buf   resb 16
    val_x     resd 1

section .text
    global _start

_start:
    ; I/O: Ask for x
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_input
    mov edx, 9
    int 0x80

    ; I/O: Read x
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 16
    int 0x80
    call atoi
    mov [val_x], eax

    ; I/O: Print "Binary: "
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_bin
    mov edx, 8
    int 0x80

    ; logic: Print 32-bit binary representation
    mov ebx, [val_x]    ; завантажуємо число в EBX
    mov ecx, 32         ; лічильник на 32 біти
.bin_loop:
    rol ebx, 1          ; виштовхуємо найстарший біт у прапор CF (Carry Flag)
    
    push ebx            ; зберігаємо EBX, бо він нам потрібен для циклу
    push ecx            ; зберігаємо лічильник

    jc .print_one       ; якщо в CF одиниця — йдемо на print_one
.print_zero:
    mov al, '0'
    jmp .do_print
.print_one:
    mov al, '1'
.do_print:
    mov [out_buf], al
    mov eax, 4
    mov ebx, 1
    mov ecx, out_buf
    mov edx, 1
    int 0x80

    pop ecx             ; відновлюємо лічильник
    pop ebx             ; відновлюємо EBX

    dec ecx
    jz .done_bin
    
    ; logic: друкуємо пробіл кожні 4 біти
    test ecx, 3
    jnz .bin_loop       ; якщо не кратне 4, йдемо далі
    
    push ebx
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    pop ecx
    pop ebx
    jmp .bin_loop

.done_bin:
    ; logic: Calculate Popcount
    mov eax, [val_x]
    xor ecx, ecx        ; counter
.pop_loop:
    test eax, eax
    jz .done_pop
    mov ebx, eax
    dec ebx
    and eax, ebx        ; очищує останню встановлену одиницю
    inc ecx
    jmp .pop_loop

.done_pop:
    push ecx            ; зберігаємо результат
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_pop
    mov edx, 11
    int 0x80
    pop eax
    call itoa

    ; logic: Bit manipulation (set 0,3, clear 31)
    mov eax, [val_x]
    or eax, 0x00000009  ; маска: (1<<0) | (1<<3)
    and eax, 0x7FFFFFFF ; маска: занурення 31-го біта
    
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_mod
    mov edx, 31
    int 0x80
    pop eax
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

; parse: atoi
atoi:
    xor eax, eax
    mov esi, ecx
.a_loop:
    movzx ebx, byte [esi]
    cmp bl, 10
    je .a_done
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp .a_loop
.a_done: ret

; I/O: itoa
itoa:
    test eax, eax
    jnz .i_start
    mov edi, out_buf
    mov byte [edi], '0'
    mov edx, 1
    jmp .i_write
.i_start:
    mov edi, out_buf
    add edi, 15
    mov byte [edi], 0
    mov ebx, 10
.i_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .i_loop
    mov edx, out_buf
    add edx, 15
    sub edx, edi
.i_write:
    mov ecx, edi
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret