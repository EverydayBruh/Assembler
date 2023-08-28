    bits	64

    section	.data

    
    max_steps:
        dd	100000
    neg_one:
        dd -1.0
    pos_one:
        dd 1.0   
    one_six_neg:
        dd -0.16666667
    printf_float_spec:
        db 	"%f", 0xA, 0x0
    overflow_message:
        db 	"Required precision can't be reached", 0xA, 0x0
    printf_res_libm_spec:
        db 	"Libm: f(%f) = %f", 0xA, 0x0
    printf_x_spec:
        db 	"X = ", 0x0
    printf_prec_spec:
        db 	"Prec = ", 0x0
    printf_file_error:
        db	"Can't open file", 0xA, 0x0
    printf_res_my_spec:
        db 	"My: f(%f) = %f", 0xA, 0x0
    scanf_float_spec:
        db 	"%f", 0x0
    file_mode:
        db 	"w", 0x0
    fprintf_spec:
        db	"Step %d: res = %f, member = %f", 0xA, 0x0
        
    section .bss 
        symb 	resb 1 
        res 	resd 1
        x 	resd 1
        prec 	resd 1
        fdesc	resq 1
        
    section	.text 
        global	main
        extern 	printf
        extern 	exit
        extern	scanf
        extern	sqrtf
        extern  logf
        extern	fopen
        extern	fprintf
        extern	fclose
        extern	fabsf


    main:
        push 	rbp      ; Prologue: Save the previous base pointer
        mov	rbp, rsp
        sub	rsp, 32
        mov	[rbp - 8], rbx
        mov	rdi, [rsi + 8]
        mov	rsi, file_mode
        call	fopen

        cmp	rax, 0
        jne	file_opened

        xor	rax, rax
        mov	rdi, printf_file_error
        call	printf
        jmp	fin

    my_ln:      ;xmm0 = x
                ;xmm1 = prec
        push rbp                 ; Prologue: Save the previous base pointer
        mov rbp, rsp             ; Set the new base pointer
        sub rsp, 0x50            ; Allocate space on the stack for local variables
        mov [rbp - 8], rbx       ; Save rbx register value

        
        movss xmm3, xmm0     
        mulss xmm3, xmm0       
        mulss xmm3, xmm0      ; xmm3 = x^3

        movss xmm2, [one_six_neg] ; Load the constant -1.0 / 6 into xmm2

        mulss xmm3, xmm2      ; xmm1 = x^3 * -(1.0 / 6)

        movss xmm9, xmm3        ; step = -(1.0 /6) * pow(x, 3);
        movss xmm10, xmm0        ; Store x in xmm10 (res)     
        mov   rcx, 1           ; rcx = n
        while_ln_begin:
            cmp ecx, dword[max_steps] ; Compare loop counter to max_steps
            jge ln_soverflow         ; Jump to ln_soverflow if the condition is true
            
            ; Save registers and local variables on the stack
            mov	[rbp - 16], rcx
            movdqu	[rbp - 32], xmm0
            movdqu	[rbp - 48], xmm1
            movdqu	[rbp - 64], xmm9
            movdqu	[rbp - 80], xmm10

            ; Print step and res using fprintf
            mov	rax, 2
            mov	rdi, qword[fdesc]
            mov	rsi, fprintf_spec
            mov	rdx, rcx
            cvtss2sd xmm0, xmm10    ; Convert xmm10 to double precision
            cvtss2sd xmm1, xmm9     ; Convert xmm9 to double precision
            call fprintf

            ; Restore registers and local variables from the stack
            mov	rcx, [rbp - 16]
            movdqu	xmm0, [rbp - 32]
            movdqu	xmm1, [rbp - 48]
            movdqu	xmm9, [rbp - 64]
            movdqu	xmm10, [rbp - 80]

            ; Update res, step, and loop counter
            addss	xmm10, xmm9 	;res += step

            ;step*=(-1)*(1 - 1.0/(2*(n))) * (2*n - 1.0) / (2*n + 1.0) * x*x;
            ;*=(-1)
            movss xmm2, [neg_one]
            mulss xmm9, xmm2

            ;*(1 - 1.0/2*n)
            movss xmm2, dword [pos_one]
            inc	rcx
            mov	rax, rcx	
            sal	rax, 1		;n*2
            cvtsi2ss xmm8, rax  
            movss xmm3, dword [neg_one]
            divss	xmm3, xmm8	;-1.0/2*n
            addss xmm2, xmm3    ;(1 - 1.0/2*n)
            mulss xmm9, xmm2

            ;*(2*n - 1.0)
            cvtsi2ss xmm8, rax 
            movss xmm3, dword [neg_one]
            addss xmm8, xmm3
            mulss xmm9, xmm8

            ;/ (2*n + 1.0)
            cvtsi2ss xmm8, rax 
            movss xmm3, dword [pos_one]
            addss xmm8, xmm3
            divss xmm9, xmm8

            ;step *= x^2
            mulss	xmm9, xmm0 	
            mulss	xmm9, xmm0 	


            ; Save registers and local variables on the stack again
            mov	[rbp - 16], rcx
            movdqu	[rbp - 32], xmm0
            movdqu	[rbp - 48], xmm1
            movdqu	[rbp - 64], xmm9
            movdqu	[rbp - 80], xmm10
        
            ; Calculate the absolute value of step
            movss	xmm0, xmm9	; = step
            call	fabsf		;xmm12 = |step|
            movss	xmm12, xmm0

            ; Restore registers and local variables from the stack
            mov	rcx, [rbp - 16]
            movdqu	xmm0, [rbp - 32]
            movdqu	xmm1, [rbp - 48]
            movdqu	xmm9, [rbp - 64]
            movdqu	xmm10, [rbp - 80]

            ; Compare |step| with prec
            ucomiss	xmm12, xmm1
            jbe 	ln_success   ; Jump to ln_success if |step| <= prec
            jmp	while_ln_begin
    ln_soverflow:	
        xor	rax, rax
        mov	rdi, overflow_message
        call	printf
        
    ln_success:	
        movss	xmm0, xmm10
        leave   ; Epilogue: Restore stack and base pointer
        ret
        
    
        
    file_opened:	
        mov	qword[fdesc], rax   ; Store the file descriptor
        
        ; Print "X = "
        xor	rax, rax
        mov	rdi, printf_x_spec
        call	printf

        ; Read the value of x from the user
        xor	rax, rax
        mov	rdi, scanf_float_spec
        mov 	rsi, x
        call	scanf

        ; Print "Prec = "
        xor	rax, rax
        mov	rdi, printf_prec_spec
        call	printf
        
        ; Print "Prec = "
        xor	rax, rax
        mov	rdi, scanf_float_spec
        mov 	rsi, prec
        call	scanf	

        movss	xmm0, dword[x]
        movss	xmm1, dword[prec]
        call	my_ln 
        
        ; Print the result of my_ln
        mov	eax, 2
        mov	rdi, printf_res_my_spec
        cvtss2sd xmm1, xmm0		
        cvtss2sd xmm0, dword[x]
        call	printf	

        mov	rdi, qword[fdesc]
        call	fclose

        ; res = log( x + sqrt(1 + x*x));
        movss   xmm0, [pos_one]
        movss   xmm1, dword[x]
        mulss   xmm1, xmm1
        addss   xmm0, xmm1
        call	sqrtf
        
        movss xmm1, dword[x]
        addss xmm0, xmm1
        call logf

        mov	eax, 2
        mov	rdi, printf_res_libm_spec
        cvtss2sd xmm1, xmm0		
        cvtss2sd xmm0, dword[x]
        call	printf
    fin:
        mov	rbx, [rbp - 8]  
        leave               
        ret
