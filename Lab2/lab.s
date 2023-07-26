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
    min dw 10 dup(0) ;save min value for every row
    max dw 10 dup(0)
    extern printf

section .text
    global main
    global print_matrix
    global autoprint_matrix
    global print_min



main:
    ;mov rdi, max
    ;call print_1
    ;call print_1
    call    count_min
    ;call    print_min
    ;call    autoprint_matrix

    call sort

    ;call print_newline
    ;call    print_min
    ;call    autoprint_matrix
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

swap: ;esi - The starting row index. || edi - The ending row index.
    push rsi
    push rdi
    push rax
    push rbx
    push rcx
    push rdx

    shl     esi, 1
    shl     edi, 1
    mov     eax, esi
    mov     ebx, edi
    mul     byte [cols]
    add     eax, matrix ; Add the matrix base address to get the starting row's memory address.
    xchg    eax, ebx
    mul     byte [cols]
    add     eax, matrix ; Add the matrix base address to get the starting row's memory address.
    movzx   ecx, byte [cols]
    .swap_min:
        add     esi, min
        add     edi, min
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

    pop rdx
    pop rcx
    pop rbx
    pop rax
    pop rdi
    pop rsi
    ret


sort:
    movzx   rax, byte [rows]    ; eax = gap
    .while_gap:
        shr     rax, 1      ; gap //= 2
        cmp     rax, 0      ; while gap > 0
        jle     .end_sort

        xor rdi, rdi ; rdi = i = 0      
        xor rsi, rsi
        add rsi, rax ; rsx = i + gap
        .process_gap:
            call    compare     ;esi, edi - raws index
            cmp     rdx, 0
            jge     .skip_swap
            call    swap    ; swap(max[i], max[i + gap])
        .skip_swap:
            inc     rdi         ; i++
            inc     rsi
            mov   cl, byte [rows]
            cmp     byte [rsi], cl ; i + gap < rows
            jl      .process_gap
        jmp     .while_gap
    .end_sort:
    ret


compare:
;esi, edi - raws index
;return rdx 1, if swap
    push rcx
    push rdx
    mov     rcx, min
    add     rcx, rsi
    movzx   rdx, word [rcx]
    mov     rcx, min
    add     rcx, rdi
    movzx   rcx, word [rcx]
    cmp     byte [asc], 1
    je      .asc
    jmp     .descending
    .asc:
        cmp     rcx, rdx    ; swap if max[j - gap] > max[j]
        jg      .need_swap
        jmp     .no_swap
    .descending:
        cmp     rcx, rdx   ; swap if max[j - gap] < max[j]
        jl      .need_swap
        jmp     .no_swap
    .need_swap:
        mov     rdx, 1
        jmp .comp_end
    .no_swap:
    mov     rdx, 0

    .comp_end:
    pop rdx
    pop rcx
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
    

    autoprint_matrix:
        push rdi
        push rdx
        push rcx

        mov rdi, matrix
        movzx rdx, byte[rows]
        movzx rcx, byte[cols]
        call    print_matrix

        pop rcx
        pop rdx
        pop rdi
        ret

    print_min:
        push rdi
        push rdx
        push rcx

        mov rdi, min
        mov rdx, 1
        movzx rcx, byte[rows]
        call    print_matrix

        pop rcx
        pop rdx
        pop rdi
        ret
