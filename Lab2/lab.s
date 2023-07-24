BITS 64

section .data
asc     db 1
rows	db 10
cols	db 9
matrix:
	db 233, 142, 101, 148, 96, 194, 8, 92, 135
    db 222, 93, 20, 104, 41, 200, 227, 26, 254
    db 170, 25, 137, 201, 225, 245, 183, 244, 1
    db 23, 119, 62, 78, 193, 245, 59, 226, 190
    db 216, 149, 235, 104, 135, 32, 137, 135, 153
    db 62, 40, 36, 42, 180, 132, 68, 160, 226
    db 86, 161, 56, 251, 113, 36, 0, 243, 60
    db 64, 60, 187, 31, 249, 79, 94, 189, 107
    db 144, 21, 235, 24, 99, 73, 208, 30, 26
    db 163, 25, 237, 43, 204, 137, 98, 116, 69

section .data
    max db 10 dup(0)
    extern printf

section .text
    global main




main:
    mov rdi, 1
    mov rsi, 1
    mov rax, 1
    call print_1
    ;call print_matrix
    call    count_max
    call    sort
    retn

count_max:
    mov     esi, matrix
    mov     edi, max
    movzx   ecx, byte [rows]
    .iterate_rows:
        xor     ebx, ebx
        push    rcx
        movzx   ecx, byte [cols]
        .iterate_cols:
            movzx   eax, byte [esi]
            cmp     eax, ebx
            jle     .skip_update
            mov     ebx, eax
            .skip_update:
            inc     esi
            loop    .iterate_cols
        pop     rcx
        mov     byte [edi], bl
        inc     edi
        loop    .iterate_rows
    ret

swap:
    mov     eax, esi
    mov     ebx, edi
    mul     byte [cols]
    add     eax, matrix
    xchg    eax, ebx
    mul     byte [cols]
    add     eax, matrix
    movzx   ecx, byte [cols]
    .swap_max:
        add     esi, max
        add     edi, max
        movzx   edx, byte [edi]
        xchg    dl, byte [esi]
        mov     byte [edi], dl
    .iterate_cols:
        movzx   edx, byte [eax]
        xchg    dl, byte [ebx]
        mov     byte [eax], dl
        inc     eax
        inc     ebx
        loop    .iterate_cols
    ret

sort:
    movzx   eax, byte [rows]    ; eax = gap
    .while_gap:
        shr     eax, 1      ; gap //= 2
        cmp     eax, 0      ; while gap > 0
        jle     .end_sort
        mov     ebx, eax    ; ebx = i in gap..rows
        .process_gap:
            mov     ecx, ebx    ; ecx = j = i
            .swap_gaps:
                cmp     ecx, eax    ; break if j < gap
                jl      .break
                call    compare     ; compare max[j - gap] ? max[j]
                cmp     ebp, 0
                je      .break
                call    perform_swap    ; swap(max[j - gap], max[j])
                sub     ecx, eax        ; j -= gap
                jmp     .swap_gaps
            .break:
            inc     ebx ; i++
            cmp     bl, byte [rows]
            jl      .process_gap
        jmp .while_gap
    .end_sort:
    ret

compare:
    mov     esi, max
    add     esi, ecx
    movzx   edi, byte [esi]
    sub     esi, eax
    movzx   esi, byte [esi]
    cmp     byte [asc], 1
    je      .asc
    jmp     .descending
    .asc:
        cmp     esi, edi    ; swap if max[j - gap] > max[j]
        jg      .need_swap
        jmp     .no_swap
    .descending:
        cmp     esi, edi    ; swap if max[j - gap] < max[j]
        jl      .need_swap
        jmp     .no_swap
    .need_swap:
        mov     rbp, 1
        ret
    .no_swap:
    mov     rbp, 0
    ret

perform_swap:
    push    rax
    push    rbx
    push    rcx
    mov     ebp, ecx
    sub     ebp, eax
    mov     esi, ebp
    mov     edi, ecx
    call    swap        ; swap(ecx, ecx - eax)
    pop     rcx
    pop     rbx
    pop     rax
    ret

_exit_normal:
    ; Exit program normally
    mov     rdi, 0
    jmp     _exit

_exit_error:
    ; Exit program with error code 1
    mov     rdi, 1
    jmp     _exit

_exit:
    mov     rax, 60     ; Syscall for exit
    syscall


section .text
    global print_matrix
    extern putchar

print_matrix:
    push rsi              ; Preserve rsi and rdi registers
    push rdi

    mov     rsi, matrix   ; Load address of the matrix into rsi
    movzx   rcx, byte [rows] ; Load the number of rows into rcx
    movzx   rdx, byte [cols] ; Load the number of columns into rdx

print_matrix_loop:
    ; Print each element of the matrix
    movzx   rdi, byte [rsi] ; Load the current element to be printed into rdi

    ; Print the current element (rdi) as a decimal value
    call    print_1        ; Use putchar function to print a character

    ; Print a space after each element (except the last one in a row)
    dec     rdx            ; Decrease the column counter
    jz      print_newline  ; If it's the last column, jump to print_newline
    mov     rax, ' '       ; space character
    call    putchar        ; Use putchar function to print a character
    jmp     print_next_element


print_next_element:
    add     rsi, 1         ; Move to the next element in the matrix

    ; Check if we have printed all rows
    dec     rcx            ; Decrease the row counter
    jnz     print_matrix_loop

    pop rdi               ; Restore rdi and rsi registers
    pop rsi
    ret

putchar:
    ; Putchar function to print a character (syscall wrapper)
    mov     rax, 1        ; syscall number for sys_write (stdout)
    mov     rdi, 1        ; file descriptor 1 (stdout)
    mov     rdx, 1        ; number of bytes to write (1 byte)
    syscall
    ret


section .data
    format_string db "%d ", 0
    newline db "%c", 0

section .text

print_1:
    movzx rsi, byte [rdi]

    ; Call printf to print the first element
    mov rdi, format_string
    xor rax, rax    ; Clear RAX (RAX = 0) to indicate that there are no floating-point arguments
    call printf
    
    push rax
    call print_newline
    
    pop rax
    ret


print_newline:
    push rbp
    mov rbp, rsp
    push rdi
    push rsi
    push rax

    mov rdi, newline
    xor rax, rax   
    mov rsi, 10
    call printf

    pop rax
    pop rsi
    pop rdi
    mov rsp, rbp
    pop rbp
    ret







