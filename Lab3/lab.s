bits	64

section	.data


input_msg:
	db 		"Filename: ", 0x0
input_msg_len:
	db 		11
file_exist_msg:
	db 		"File already exists. Rewrite? (y/n)", 0x0
file_exist_msg_len:
	db 		36
buffer_len:
	db 		10

section .bss
buffer:
	resb	256
symb:
	resb 	1
fd:
	resq 	1

section	.text
	global	_start

;rdi - addr

_start:
	mov 	rax, 1
	mov 	rdi, 1
	mov 	rsi, input_msg
	movzx 	rdx, byte[input_msg_len]
	syscall ; Invokes the system call to print the input_msg.
	mov 	rax, 0
	mov 	rdi, 0
	mov 	rsi, buffer
	movzx 	rdx, byte[buffer_len]
	syscall ; Invokes the system call to read user input and store it in the buffer.
	mov 	byte[buffer + rax - 1], 0x0 ; Null-terminate the input stored in the buffer.
	mov 	rax, 2
	mov 	rdi, buffer
    mov 	rsi, 0000o  ; File flags (O_WRONLY | O_CREAT | O_TRUNC).
    mov 	rdx, 0666o  
	syscall  ; Invokes the system call to open the file.

	cmp 	rax, 0
	jl		create_file ; Jump to the label create_file if the file doesn't exist.
		
        ; If the file exists, prompt the user to rewrite it.
        mov 	rax, 1
		mov 	rdi, 1
		mov 	rsi, file_exist_msg
		movzx 	rdx, byte[file_exist_msg_len]
		syscall
		mov 	rax, 0
		mov 	rdi, 0
		mov 	rsi, rsp
		movzx 	rdx, byte[buffer_len]
		syscall
		cmp 	byte[rsp], 'y'
		jne 	fin
	create_file:    ; Label used to create the file.
		mov 	rax, 2
		mov 	rdi, buffer
	    mov 	rsi, 1101o  ; File flags (O_WRONLY | O_CREAT | O_APPEND).
	    mov 	rdx, 0666o  ; FIle premission
		syscall

	mov 	[fd], rax       ; Store the file descriptor in the 'fd' variable.
	mov 	byte[symb], 0   ; Clear the 'symb' variable to mark the absence of a symbol.

	while_line:
        ; Read a line from the buffer.
		mov 	rax, 0
		mov 	rdi, 0
		mov 	rsi, buffer
		movzx 	rdx, byte[buffer_len]
		syscall
        ; Check if the return value of the 'read' syscall is 0 (end of file).
		cmp 	rax, 0
		je 		fin

		mov 	r10, rax    ; Store the number of characters read (line length) in r10.
		xor 	rcx, rcx    ; Loop counter RCX
		xor 	r15, r15 	; to_write
		while_read_line:
            ; Check if the end of the line has been reached.
			cmp 	rcx, r10
			je 		while_read_line_end

            ; Check if the current character is a space, tab, or newline 
			cmp 	byte[buffer + rcx], 0x20
			je 		not_a_word
			cmp 	byte[buffer + rcx], 0x9
			je 		not_a_word
			cmp 	byte[buffer + rcx], 0xA
			je 		meet_new_line

            mov 	al, byte[buffer + rcx] ; Process a character (write to the output buffer).
            ; Check if it's the first symbol of the line.
            cmp 	byte[symb], 0
            je 		first_symb
            ; Check if the current character matches the last symbol written.
            cmp 	byte[symb], al
            jne 	useful_symb
            ; If the current character matches the last symbol written, skip it.
            inc 	rcx
            jmp 	while_read_line
            first_symb:
                ; Save the first symbol encountered in the 'symb' variable.
                mov 	byte[symb], al
            
            useful_symb:
                ; Write the current character to the output buffer.
                mov 	byte[buffer + r15], al
                inc 	r15
                inc 	rcx
                jmp		while_read_line

			not_a_word:
                ; Check if this is not the first character and add a space.
				cmp		byte[symb], 0
				je 		not_first
					mov 	byte[buffer + r15], 0x20
					inc 	r15
				not_first:
				mov 	byte[symb], 0   ; Clear the 'symb' variable to mark the absence of a symbol.
				inc 	rcx
				jmp 	while_read_line

			meet_new_line:
                ; Clear the 'symb' variable to mark the absence of a symbol.
				mov 	byte[symb], 0
				inc 	rcx
				inc		r15
				jmp 	while_read_line


		while_read_line_end:
        ; Write the processed line to the file.
		mov 	rax, 1
		mov 	rdi, [fd] ; File descriptor stored in 'fd'.
		mov 	rsi, buffer
		mov 	rdx, r15
		syscall ; Invokes the system call to write the line to the file.

		dec 	r15                     ; Decrease r15 to remove the newline character from the end.
		cmp 	byte[buffer + r15], 0xA ; Check if the last character of the line is a newline.
		jne 	while_line
		mov 	byte[symb], 0
		jmp 	while_line

fin:
	mov 	rax, 3             ; 'close' syscall
    mov 	rdi, [fd]          ; file descriptor  
    syscall                    ; Invokes the system call to close the file.
	mov		eax, 60
	mov		edi, 0
	syscall                    ; Invokes the system call to exit the program.

