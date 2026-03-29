section .data
    prompt db "Enter number: ", 0
    prompt_len equ $ - prompt
    newline db 10

section .bss
    ; memory: buffers for string conversion
    input_buf resb 16
    output_buf resb 16

section .text
    global _start

_start:
    ; I/O: друкуємо запрошення до вводу
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; I/O: читаємо вхідний рядок
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 16
    int 0x80

    ; parse: конвертуємо рядок у число (atoi)
    mov esi, input_buf
    xor eax, eax
    xor ebx, ebx
.atoi_loop:
    mov bl, [esi]
    cmp bl, 10          ; перевірка на Enter (newline)
    je .process_start
    cmp bl, '0'
    jb .process_start
    cmp bl, '9'
    ja .process_start
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp .atoi_loop

.process_start:
    ; math: ініціалізація суми та довжини
    xor ecx, ecx        ; ECX буде зберігати суму цифр
    xor ebp, ebp        ; EBP буде лічильником довжини (len)
    mov ebx, 10         ; дільник

.loops:
    ; logic: цикл while x > 0
    test eax, eax
    jz .done_math

    ; math: ділення для отримання цифр
    xor edx, edx        ; обов'язково обнуляємо EDX перед div
    div ebx             ; EAX = частка, EDX = залишок (остання цифра)

    add ecx, edx        ; додаємо цифру до суми
    inc ebp             ; збільшуємо довжину
    jmp .loops

.done_math:
    ; logic: зберігаємо результати та готуємо вивід
    push ebp            ; зберігаємо довжину в стек
    push ecx            ; зберігаємо суму в стек

    ; I/O: виводимо суму цифр
    pop eax             
    call print_number

    ; I/O: виводимо довжину числа
    pop eax             
    call print_number

.exit:
    ; I/O: вихід з програми
    mov eax, 1
    xor ebx, ebx
    int 0x80

; Підпрограма для друку числа з EAX (itoa + write)
print_number:
    ; logic: перевірка на нуль
    test eax, eax
    jnz .itoa_prep
    mov edi, output_buf
    mov byte [edi], '0'
    mov edx, 1
    jmp .write_out

.itoa_prep:
    mov edi, output_buf
    add edi, 15         ; починаємо з кінця буфера
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

    ; обчислюємо довжину для sys_write
    mov edx, output_buf
    add edx, 15
    sub edx, edi

.write_out:
    mov ecx, edi
    mov eax, 4          
    mov ebx, 1          
    int 0x80

    ; I/O: друкуємо символ нового рядка
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret