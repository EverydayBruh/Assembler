bits 64
section .data
    matrix db 1, 4, 6, 4, 1, 4, 16, 24, 16, 4, 6, 24, 36, 24, 6, 4, 16, 24, 16, 4, 1, 4, 6, 4, 1

section .text
    global blur

flag:
    ret
flag2:
    ret
flag3:
    ret


blur:
    ; Parameters:
    ; [rdi] - img
    ; [rsi] - blur_img
    ; [rdx] - width
    ; [rcx] - height
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov [rsp+56], r12

    mov r11, rdi
    mov r12, rsi

    xor r8, r8          ; r8 = row
    .row_loop:
        xor r9, r9      ; r9 = col
        .col_loop:
            ;shift = (col + row*width)*3;
            mov rax, r8
            imul rax, rdx
            add rax, r9
            imul rax, 3
            
            mov [rsp], rdx
            mov [rsp+8], rcx
            mov [rsp+16], r8
            mov [rsp+24], r9
            mov [rsp+32], r11
            mov [rsp+40], r12

            
            mov rdi, r11
            add rdi, rax    ; [rdi] - img_pixel
            mov rsi, r12
            add rsi, rax    ; [rsi] - blur_pixel
                            ; [rdx] - width

            
            
            cmp r8, 2
            jl .copy
            sub rcx, 2
            cmp r8, rcx
            jge .copy

            cmp r9, 2
            jl .copy
            mov rcx, rdx
            sub rcx, 2
            cmp r9, rcx
            jge .copy

            xor r10, r10
            .color_loop:
                mov rdx, [rsp]
                mov [rsp+48], r10
                call blur_pixel
                mov r10, [rsp+48]
                inc rdi
                inc rsi
                inc r10
                cmp r10, 2
                jle .color_loop
            jmp .skip_copy

            .copy:
                mov al, byte [rdi]
                mov byte[rsi], al
                mov al, byte [rdi+1]
                mov byte[rsi+1], al
                mov al, byte [rdi+2]
                mov byte[rsi+2], al

            .skip_copy:

            mov r12, [rsp+40]
            mov r11, [rsp+32]
            mov r9, [rsp+24]
            mov r8, [rsp+16]
            mov rcx, [rsp+8]
            mov rdx, [rsp]

            call flag2
            inc r9
            call flag3
            cmp r9, rdx
            jl .col_loop

        inc r8
        cmp r8, rcx
        jl .row_loop
    mov r12, [rsp+56]
    leave
    ret


blur_pixel:
    ; Parameters:
    ; [rdi] - img_pixel
    ; [rsi] - blur_pixel
    ; [rdx] - width
    push rbp
    mov rbp, rsp
    sub rsp, 16
    ;  Save rbx, rbp, r12, r13, r14, r15
    mov [rsp], r12
    mov [rsp+8], r13

    xor rax, rax            ; Clear rax (sum)

    ; Loop through matrix rows
    xor r8, r8
    .small_row_loop:
        ; Loop through matrix columns
        xor r9, r9
        .small_col_loop:
            mov r10, r9
            add r10, -2
            imul r10, 3                  ;r10 = (col - 2)*3
            mov r11, r8
            add r11, -2
            imul r11, rdx
            imul r11, 3                  ;r11 = (row - 2)*width*3
            add r10, r11                ;r10 = (col - 2)*3 + (row - 2)*width*3
            movzx r12, byte [rdi + r10]  ;*(img_pixel + (col - 2)*3 + (row - 2)*width*3);
            mov r10, r8
            imul r10, 5
            add r10, r9
            movzx r13, byte [matrix + r10]
            imul r12, r13
            add rax, r12  ; Accumulate sum
            inc r9
        cmp r9, 5
        jl .small_col_loop

    inc r8
    cmp r8, 5
    jl .small_row_loop

    ; Normalize and store the result
    mov rcx, 256
    call flag
    cqo
    div rcx
    mov byte [rsi], al

    mov r12, [rsp]
    mov r13, [rsp+8]
    leave
    ret


