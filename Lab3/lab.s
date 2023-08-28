bits	64

section	.data


input_msg:
	db 		"Filename: ", 0x0
input_msg_len:
	db 		11
buffer_len:
	db 		10
vowels:
    db "AEIOU", 0       
flag:
	db	0 

section .bss
buffer:
	resb	256
fd:
	resq 	1

section	.text
	global	_start
	extern	get_env_value






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
    mov rdi, rsp
    
    xor rsi, rsi ; Initialize rsi to 0 for the index

	mov 	byte[buffer + rax - 1], 0x0 ; Null-terminate the input stored in the buffer.
	
	create_file:    ; Label used to create the file.
		mov 	rax, 2
		mov 	rdi, buffer
	    mov 	rsi, 1101o  ; File flags (O_WRONLY | O_CREAT | O_APPEND).
	    mov 	rdx, 0666o  ; FIle premission
		syscall

	mov 	[fd], rax       ; Store the file descriptor in the 'fd' variable.
	mov 	byte[flag], 0   ; Clear the 'flag' variable. 0 - no world, 1 - save, 2 - delete

	while_line:
        ; Read a line from the buffer.
		mov 	rax, 0
		mov 	rdi, 0
		mov 	rsi, buffer
		movzx 	rdx, byte[buffer_len]
		syscall
        ; Check end of file
		cmp 	rax, 0
		je 		fin

		mov 	r10, rax    ; line length in r10.
		xor 	rcx, rcx    ; Loop counter RCX
		xor 	r15, r15 	; to_write
		while_read_line:
            ; Check if end of the line has been reached.
			cmp 	rcx, r10
			je 		while_read_line_end

            ; Check if the current character is a space, tab, or newline 
			cmp 	byte[buffer + rcx], 0x20
			je 		not_a_word
			cmp 	byte[buffer + rcx], 0x9
			je 		not_a_word
			cmp 	byte[buffer + rcx], 0xA
			je 		meet_new_line
            

            


            mov 	bl, byte[buffer + rcx] 

            ; Check if it's the first symbol of the line.
            cmp 	byte[flag], 0
            jne 		not_first_symb
				; Process firs symbol
				mov 	ah, bl
				call is_vowel ; rax = 2 of vowel, 1 otherwise
				mov byte [flag], al

			not_first_symb:
            ; Check if the word need to be saved
            cmp 	byte[flag], 1
            je 	save_symb

            ; If the current word not need to be saved, skip it.
            inc 	rcx
            jmp 	while_read_line
            
            
            save_symb:
                mov 	byte[buffer + r15], bl
                inc 	r15
                inc 	rcx
                jmp		while_read_line

			not_a_word:
                ; Check if we printed word and add a space.
				cmp		byte[flag], 2
				je 		not_first
					mov 	byte[buffer + r15], 0x20
					inc 	r15
				not_first:
				mov 	byte[flag], 0   ; Clear the 'flag' variable to mark the end of word
				inc 	rcx
				jmp 	while_read_line

			meet_new_line:
                ; Clear the 'flag' variable to mark the end of word
				mov 	byte[flag], 0
				inc 	rcx
				mov 	byte[buffer + r15], 0xA
				inc		r15
				jmp 	while_read_line


		while_read_line_end:
        ; Write the processed line to the file.
		mov 	rax, 1
		mov 	rdi, [fd] 
		mov 	rsi, buffer
		mov 	rdx, r15
		syscall 

		dec 	r15                     ; Decrease r15 to remove the newline character from the end.
		cmp 	byte[buffer + r15], 0xA ; Check if the last character of the line is a newline.
		jne 	while_line
		mov 	byte[flag], 0
		jmp 	while_line

fin:
	mov 	rax, 3             ; 'close' syscall
    mov 	rdi, [fd]          
    syscall                    
	mov		eax, 60
	mov		edi, 0
	syscall                    ;exit the program.



; Function to check if the current symbol is a vowel
; Input:
;   ah: ASCII character to check
; Output:
;   al: 2 if the character is a vowel, 1 otherwise
is_vowel:
    push rdx                 ; Save rdx register on the stack
    push rsi                 ; Save rsi register on the stack

    and ah, 0xDF             ; Convert to uppercase (set the 6th bit).

    ; Check if the character is a vowel 
    mov rsi, vowels              
    check_vowel_loop:
        lodsb                    ; Load the next character from the vowels string into al.
        cmp al, 0                ; Check if the end of the string is reached (null terminator).
        je not_found_vowel       ; If so, end the loop.

        cmp al, ah     ; Compare the current vowel with the input character.
        je found_vowel           ;

        jmp check_vowel_loop     ; Continue the loop to check the next vowel.

    found_vowel:
        mov al, 2               ; Set al to 2 to indicate a vowel.
        jmp check_vowel_end
	not_found_vowel:
		mov al, 1               
        jmp check_vowel_end

    check_vowel_end:
        pop rsi                  ; Restore rsi register from the stack
        pop rdx                  ; Restore rdx register from the stack
    ret                      ; Return from the function.


