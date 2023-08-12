section .data
    matrix db 1, 4, 6, 4, 1, 4, 16, 24, 16, 4, 6, 24, 36, 24, 6, 4, 16, 24, 16, 4, 1, 4, 6, 4, 1

section .text
    global blur
    extern fmin

blurpixel:
    ; Parameters:
    ; [rdi] - img_pixel
    ; [rsi] - blur_pixel
    ; [rdx] - width

    xorps xmm0, xmm0         ; Clear xmm0 (sum)
    mov rcx, rdi             ; Save img_pixel for addressing
    sub rcx, 3*5             ; Point to the start of the image area

    ; Loop through matrix rows
    xor r8, r8
    .row_loop:
        mov rax, rcx

        ; Loop through matrix columns
        xor r9, r9
        .col_loop:
            movzx r10b, byte [rax + r9]
            movzx r11b, byte [r8 + r9]
            imul r10d, r11d
            add eax, r10d   ; Accumulate sum
            inc r9
        cmp r9, 5
        jl .col_loop

        add rcx, rdx*3      ; Move to next row
        add r8, rdx*3
        inc r8
    cmp r8, 5*rdx
    jl .row_loop

    ; Normalize and store the result
    movaps xmm1, xmm0
    movaps xmm2, xmm0
    shufps xmm2, xmm2, 0x55
    addps xmm1, xmm2
    movaps xmm2, xmm0
    shufps xmm2, xmm2, 0xAA
    addps xmm1, xmm2
    movaps xmm2, xmm0
    shufps xmm2, xmm2, 0xFF
    addps xmm1, xmm2
    divps xmm1, [rel float256]
    cvtps2dq xmm1, xmm1
    packuswb xmm1, xmm1
    movd [rsi], xmm1

    ret

blur:
    ; Parameters:
    ; [rdi] - img
    ; [rsi] - blur_img
    ; [rdx] - width
    ; [rcx] - height

    xor r8, r8          ; r8 = row
    .row_loop:
        xor r9, r9      ; r9 = col
        .col_loop:
            mov rax, r8
            imul rax, rdx
            add rax, r9
            add rax, rbp    ; rax = shift

            push rax
            push rax
            push rdx
            call blurpixel
            pop rdx
            pop rax

            add r9, 1
            cmp r9, rdx
            jl .col_loop

        add r8, 1
        cmp r8, rcx
        jl .row_loop

    ret

section .data
    float256 dd 256.0

section .bss
    resb 16    ; For alignment
