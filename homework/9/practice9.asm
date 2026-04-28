section .data
    msg_n db "Enter n (100-1000): ", 0
    hash db "#", 0
    colon db ": ", 0
    open_p db " (", 0
    close_p db ")", 10, 0
    newline db 10
    seed dd 123456789    

section .bss
    
    freq resd 10
    n_val resd 1
    input_buf resb 16
    out_buf resb 16

section .text
    global _start

_start:
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_n
    mov edx, 20
    int 0x80

   
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 16
    int 0x80
    call atoi
    mov [n_val], eax

    
    mov ecx, [n_val]
.gen_loop:
    push ecx
    
    ; math: LCG formula x = (1103515245*x + 12345) mod 2^31
    mov eax, [seed]
    mov ebx, 1103515245
    mul ebx
    add eax, 12345
    and eax, 0x7FFFFFFF  
    mov [seed], eax      
    
  
    xor edx, edx
    mov ebx, 10
    div ebx              
    
    inc dword [freq + edx*4] 
    
    pop ecx
    loop .gen_loop

    
    xor esi, esi         
.print_histo:
    cmp esi, 10
    je .exit

    
    mov eax, esi
    call itoa_no_newline
    
    mov eax, 4
    mov ebx, 1
    mov ecx, colon
    mov edx, 2
    int 0x80

    
    mov edi, [freq + esi*4]
    push edi            
    
    
    shr edi, 2           

.draw_hashes:
    test edi, edi
    jz .print_count
    
    push edi
    mov eax, 4
    mov ebx, 1
    mov ecx, hash
    mov edx, 1
    int 0x80
    pop edi
    dec edi
    jmp .draw_hashes

.print_count:
    mov eax, 4
    mov ebx, 1
    mov ecx, open_p
    mov edx, 2
    int 0x80

    pop eax              
    call itoa_no_newline

    mov eax, 4
    mov ebx, 1
    mov ecx, close_p
    mov edx, 3
    int 0x80

    inc esi
    jmp .print_histo

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

; I/O: itoa_no_newline
itoa_no_newline:
    push esi
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
    
    mov ecx, edi
    mov edx, out_buf
    add edx, 15
    sub edx, edi
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop esi
    ret