; =========================================================
; Practice 14
; Selection sort + median
; NASM i386 / Debian Linux
; Only int 0x80
; =========================================================

section .data

; =========================
; I/O
; =========================

msg_n          db "Enter n: "
len_msg_n      equ $ - msg_n

msg_nums       db "Enter numbers:", 10
len_msg_nums   equ $ - msg_nums

msg_before     db 10, "Array before sort:", 10
len_before     equ $ - msg_before

msg_after      db 10, "Array after sort:", 10
len_after      equ $ - msg_after

msg_median     db 10, "Median: "
len_median     equ $ - msg_median

space          db " "
newline        db 10

section .bss

; =========================
; memory
; =========================

buffer         resb 1
array          resd 100
num_buffer     resb 16

n              resd 1
median         resd 1

section .text
global _start

; =========================================================
; START
; =========================================================

_start:

; =========================
; I/O
; =========================

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_n
    mov edx, len_msg_n
    int 0x80

; =========================
; input n
; =========================

    call read_int
    mov [n], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_nums
    mov edx, len_msg_nums
    int 0x80

; =========================
; loops - input array
; =========================

    xor esi, esi

input_loop:

    mov eax, [n]
    cmp esi, eax
    jge input_done

    call read_int
    mov [array + esi*4], eax

    inc esi
    jmp input_loop

input_done:

; =========================
; output before sorting
; =========================

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_before
    mov edx, len_before
    int 0x80

    call print_array

; =========================================================
; selection sort
; =========================================================

; =========================
; logic + loops
; =========================

    xor esi, esi

outer_loop:

    mov eax, [n]
    dec eax

    cmp esi, eax
    jge sort_done

    mov ebx, esi
    mov edi, esi
    inc edi

inner_loop:

    mov eax, [n]
    cmp edi, eax
    jge do_swap

    mov eax, [array + edi*4]
    mov edx, [array + ebx*4]

    cmp eax, edx
    jge next_inner

    mov ebx, edi

next_inner:

    inc edi
    jmp inner_loop

; =========================
; swap two dd
; =========================

do_swap:

    cmp ebx, esi
    je next_outer

    mov eax, [array + esi*4]
    mov edx, [array + ebx*4]

    mov [array + esi*4], edx
    mov [array + ebx*4], eax

next_outer:

    inc esi
    jmp outer_loop

sort_done:

; =========================
; output after sorting
; =========================

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_after
    mov edx, len_after
    int 0x80

    call print_array

; =========================================================
; median
; =========================================================

; =========================
; math
; =========================

    mov eax, [n]
    dec eax
    shr eax, 1

    mov eax, [array + eax*4]
    mov [median], eax

; =========================
; output median
; =========================

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_median
    mov edx, len_median
    int 0x80

    mov eax, [median]
    call print_int

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

; =========================
; exit
; =========================

    mov eax, 1
    xor ebx, ebx
    int 0x80

; =========================================================
; read_int
; eax = integer
; =========================================================

read_int:

; =========================
; parse
; =========================

    xor edi, edi

read_char:

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 1
    int 0x80

    mov al, [buffer]

    cmp al, 10
    je read_done

    cmp al, 13
    je read_done

    sub al, '0'

    movzx ebx, al

    mov eax, edi
    imul eax, 10
    add eax, ebx

    mov edi, eax

    jmp read_char

read_done:

    mov eax, edi
    ret

; =========================================================
; print_array
; =========================================================

print_array:

; =========================
; loops
; =========================

    xor esi, esi

print_loop:

    mov eax, [n]
    cmp esi, eax
    jge print_done

    mov eax, [array + esi*4]
    call print_int

    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

    inc esi
    jmp print_loop

print_done:

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ret

; =========================================================
; print_int
; eax = integer
; =========================================================

print_int:

; =========================
; math
; =========================

    mov edi, num_buffer
    add edi, 15

    mov byte [edi], 0

    mov ebx, 10

convert_loop:

    xor edx, edx
    div ebx

    add dl, '0'

    dec edi
    mov [edi], dl

    test eax, eax
    jnz convert_loop

; =========================
; I/O
; =========================

    mov eax, 4
    mov ebx, 1
    mov ecx, edi

    mov edx, num_buffer
    add edx, 15
    sub edx, edi

    int 0x80

    ret