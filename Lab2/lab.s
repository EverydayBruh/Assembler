BITS 64

section .data
asc     db 1
rows	db 10
cols	db 9
matrix:
	dw 233, 142, 101, 148, 96, 194, 8, 92, 135
    dw 222, 93, 20, 104, 41, 200, 227, 26, 254
    dw 170, 25, 137, 201, 225, 245, 183, 244, 1
    dw 23, 119, 62, 78, 193, 245, 59, 226, 190
    dw 216, 149, 235, 104, 135, 32, 137, 135, 153
    dw 62, 40, 36, 42, 180, 132, 68, 160, 226
    dw 86, 161, 56, 251, 113, 36, 0, 243, 60
    dw 64, 60, 187, 31, 249, 79, 94, 189, 107
    dw 144, 21, 235, 24, 99, 73, 208, 30, 26
    dw 163, 25, 237, 43, 204, 137, 98, 116, 69

section .data
    min dw 10 dup(0)
    max dw 10 dup(0)
    extern printf

section .text
    global main

section .text
    global print_matrix



main:
    ;mov rdi, max
    ;call print_1
    ;call print_1
    call    count_min
    ; mov rdi, matrix
    ; movzx rdx, byte[rows]
    ; movzx rcx, byte[cols]
    ; call    print_matrix
    mov rdi, min
    mov rdx, 1
    movzx rcx, byte[rows]
    call    print_matrix
    ;call    sort
    ;call    print_newline
    ;call    print_matrix
    retn

count_min:
    mov     rsi, matrix
    mov     rdi, min
    movzx   rdx, byte [rows]
    .iterate_rows:
        mov     bx, 0x7FFF   ; Initialize ebx (minimum value) to the maximum 16-bit signed value
        movzx   rcx, byte [cols]
        .iterate_cols:
            mov   ax, word [rsi]
            cmp     ax, bx
            jge     .skip_update
            mov     bx, ax
            .skip_update:
            add     rsi, 2
            loop    .iterate_cols
        mov     word [rdi], bx
        add     rdi, 2
        dec     rdx             ; Decrement the row counter
        jnz     .iterate_rows 
    ret

swap:
    mov     eax, esi
    mov     ebx, edi
    ;imul    eax, eax, byte [cols] ; Multiply esi by 2 to get the element size in bytes
    ;imul    ebx, ebx, byte [cols] ; Multiply edi by 2 to get the element size in bytes
    add     eax, matrix
    add     ebx, matrix
    movzx   ecx, byte [cols]
    shl     ecx, 1   
    .swap_max:
        add     esi, max
        add     edi, max
        movzx   edx, word [edi]
        xchg    dx, word [esi]
        mov     word [edi], dx
    .iterate_cols:
        movzx   edx, word [eax]
        xchg    dx, word [ebx]
        mov     word [eax], dx
        add     eax, 2
        add     ebx, 2
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
    format_string db "%d ", 0
    newline db "%c", 0

section .text

print_1:
    push rax
    push rdi
    push rbx
    push rsi
    push rcx

    mov rbx, rsp    
    and rsp, -16

    movzx rsi, word [rdi]
    mov rdi, format_string
    xor rax, rax    ; Clear RAX (RAX = 0) to indicate that there are no floating-point arguments
    call printf
    
    mov rsp, rbx
    
    pop rcx
    pop rsi
    pop rbx
    pop rdi
    pop rax
    ret


print_newline:
    push rax
    push rdi 
    push rbx
    push rsi
    push rcx
   
    mov rbx, rsp    
    and rsp, -16

    mov rdi, newline
    xor rax, rax   
    mov rsi, 10
    call printf

    mov rsp, rbx

    pop rcx
    pop rsi
    pop rbx
    pop rdi
    pop rax
    ret







print_matrix: ; rdi - matrix, rdx - rows, rcx - cols
    
    push rax
    push rdi
    push rsi
    push rbx
    
    mov rax, rdx
    mov rbx, rcx

    print_matrix_outer_loop:
        print_matrix_inner_loop:
            ; Print the current element
            call print_1
            
            ; Move to the next element in the same row
            add rdi, 2
            ; Check if the row has ended
            sub rbx, 1
            jnz print_matrix_inner_loop

    ; Reset rbx to the original cols value
    mov rbx, rcx
    
    ; Move to the next row
    call print_newline
    sub rax, 1
    jnz print_matrix_inner_loop

    ; Print a newline to move to the next line after printing the entire matrix
    
    pop rbx
    pop rsi
    pop rdi
    pop rax
    ret
    
