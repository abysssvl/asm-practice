section .data
    msg_input db "Enter number: ", 0
    msg_len equ $ - msg_input
    newline db 0xA

section .bss
    input_buf resb 12    ; Буфер для чтения строки
    output_buf resb 12   ; Буфер для печати результата

section .text
    global _start

_start:
    ; I/O: печатаем приглашение к вводу
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_input
    mov edx, msg_len
    int 0x80

    ; I/O: читаем строку с клавиатуры
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 12
    int 0x80
    
    ; parse: EAX содержит количество байт, инициализируем регистры
    mov esi, input_buf
    xor eax, eax        ; Здесь будет итоговое число (AX)
    xor ebx, ebx        ; Очищаем вспомогательный регистр

.parse_loop:
    ; math: алгоритм String to Int
    mov bl, [esi]       ; Берем символ
    cmp bl, 0xA         ; Проверяем на символ новой строки (Enter)
    je .convert_back
    cmp bl, '0'         ; Проверка: это цифра?
    jb .convert_back
    cmp bl, '9'
    ja .convert_back

    sub bl, '0'         ; Конвертируем ASCII символ в цифру
    imul eax, 10        ; Умножаем текущее число на 10
    add eax, ebx        ; Прибавляем новую цифру
    
    inc esi             ; К следующему символу
    jmp .parse_loop

.convert_back:
    ; logic: Теперь число в AX. Конвертируем обратно в строку для вывода
    mov edi, output_buf
    add edi, 11         
    mov byte [edi], 0   
    mov ebx, 10

.loops:
    ; math: делим на 10, получаем остатки (цифры)
    xor edx, edx
    div ebx
    add dl, '0'         ; Конвертируем цифру обратно в ASCII
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .loops

.print_result:
    ; I/O: вывод результата
    mov edx, output_buf
    add edx, 11
    sub edx, edi
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    int 0x80

    ; I/O: перенос строки
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

.exit:
    ; I/O: завершение
    mov eax, 1
    xor ebx, ebx
    int 0x80