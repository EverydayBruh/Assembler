BITS 64

section .data
asc     db 1
rows	db 10
cols	db 9
matrix:
	db 0xe9, 0x8e, 0x65, 0x94, 0x60, 0xc2, 0x08, 0x5c, 0x87
	db 0xde, 0x5d, 0x14, 0x68, 0x29, 0xc8, 0xe3, 0x1a, 0xfe
	db 0xaa, 0x19, 0x89, 0xc9, 0xe1, 0xf5, 0xb7, 0xf4, 0x01
	db 0x17, 0x77, 0x3e, 0x4e, 0xc1, 0xf5, 0x3b, 0xe2, 0xbe
	db 0xd8, 0x95, 0xeb, 0x68, 0x87, 0x20, 0x89, 0x87, 0x99
	db 0x3e, 0x28, 0x24, 0x2a, 0xb4, 0x84, 0x44, 0xa0, 0xe2
	db 0x56, 0xa1, 0x38, 0xfb, 0x71, 0x24, 0x00, 0xf3, 0x3c
	db 0x40, 0x3c, 0xbb, 0x1f, 0xf9, 0x4f, 0x5e, 0xbd, 0x6b
	db 0x90, 0x15, 0xeb, 0x18, 0x63, 0x49, 0xd0, 0x1e, 0x1a
	db 0xa3, 0x19, 0xed, 0x2b, 0xcc, 0x89, 0x62, 0x74, 0x45

section .data
max db 10 dup(0)

section .text
global main


_start:
    call main
    .end:
    jmp     _exit_normal


main:
    call print_1
    call    count_max
    call    sort
    ret

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

section .data
    newline db 10         ; Newline character (ASCII code 10)

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
    call    putchar        ; Use putchar function to print a character

    ; Print a space after each element (except the last one in a row)
    dec     rdx            ; Decrease the column counter
    jz      print_newline  ; If it's the last column, jump to print_newline
    mov     rax, ' '       ; space character
    call    putchar        ; Use putchar function to print a character
    jmp     print_next_element

print_newline:
    ; Print a newline character after each row
    mov     rax, newline   ; Load the newline character
    call    putchar        ; Use putchar function to print a character

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


section .text

print_1:
    ; Write character to stdout (file descriptor 1)
    mov rax, 1              ; System call number for sys_write
    mov rdi, 1              ; File descriptor 1 (stdout)
    mov rsi, matrix            ; Pointer to the character to print
    mov rdx, 1              ; Number of bytes to write (1 for a single character)
    syscall              ; Make the system call

    ret








