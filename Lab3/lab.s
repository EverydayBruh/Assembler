bits	64

section	.data


input_msg:
	db 		"Filename: ", 0x0
input_msg_len:
	db 		11
var_not_found_msg:
	db 		"Environment variable not found", 0x0
var_not_found_msg_len:
	db 		31
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

;rdi - addr

section .data
    ; Environment variable name to look for
    env_var_name db "file_name", 0
    ; Buffer to store the value of the environment variable
    buffer_size equ 256

section .bss
    ; Variable to store the address of the environment variables
    environ resq 1


find_env_var:
    ; Load the current environment variable address into rdx
    mov rdx, qword [rdi + rsi*8]

    ; Check if we reached the end of the environment variables (null pointer)
    test rdx, rdx
    jz not_found

    ; Compare the current environment variable with the one we are looking for
    call compare_env_var_name
    cmp rax, 0 ;(rax = 0 if equal)
    jz found

    ; Move to the next environment variable
    inc rsi
    jmp find_env_var

not_found:
    ; Code to handle the case when the environment variable is not found
    ; (e.g., set default value or exit the program).

found:
    ; rdx now points to the environment variable we found.
    ; We need to extract the value part (string after the equals sign).

    ; Find the length of the environment variable string
    call string_length
    ; Rax now contains the length of the environment variable string

    ; Load the address of the value part (rdx + length of the name + 1)
    add rdx, rax, 1

    ; Move the value part to the buffer
    mov rsi, buffer
    mov rcx, rax
    rep movsb

    ; Null-terminate the buffer
    mov byte [rsi + rax], 0

    ; The value of the environment variable is now stored in the buffer.

    ; Exit the program (optional)
    ; call exit_program

    ; Your code continues here...

get_environ:
    ; Function to get the address of the environment variables
    mov rax, 0x3c ; __NR_getpid for x86-64 Linux
    xor edi, edi  ; Set edi to 0 (current process ID)
    syscall
    ret

compare_env_var_name:
    ; Function to compare the environment variable name with the name we are looking for
    ; Input:
    ; rdx - Pointer to the current environment variable
    ; Output:
    ; rax - 0 if the strings are equal, non-zero otherwise

    ; Initialize rax to 0 (equality flag)
    xor rax, rax

    ; Compare strings byte by byte until we reach a null terminator
    ; or until we find a mismatch
    xor rcx, rcx ; Counter for the loop
.loop:
    mov al, [rdx + rcx] ; Load a byte from the current environment variable
    mov bl, [env_var_name + rcx] ; Load a byte from the target environment variable name
    cmp al, bl ; Compare the two bytes
    jne .done ; If they are not equal, exit the loop
    test al, al ; Check if we reached the end of the current environment variable
    jz .done ; If yes, the strings are equal
    inc rcx ; Move to the next byte
    jmp .loop

.done:
    ret

string_length:
    ; Function to calculate the length of a null-terminated string
    ; Input:
    ; rdx - Pointer to the string
    ; Output:
    ; rax - Length of the string (excluding the null terminator)

    xor rax, rax ; Initialize rax to 0 (length counter)

.loop:
    cmp byte [rdx + rax], 0 ; Check if the current byte is null (end of string)
    jz .done ; If yes, we reached the end of the string
    inc rax ; Move to the next byte
    jmp .loop

.done:
    ret



_start:
	; mov 	rax, 1
	; mov 	rdi, 1
	; mov 	rsi, input_msg
	; movzx 	rdx, byte[input_msg_len]
	; syscall ; Invokes the system call to print the input_msg.
	; mov 	rax, 0
	; mov 	rdi, 0
	; mov 	rsi, buffer
	; movzx 	rdx, byte[buffer_len]
	; syscall ; Invokes the system call to read user input and store it in the buffer.
    mov rdi, rsp
    call get_environ

    ; Loop through the environment variables
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
            

            


            mov 	bl, byte[buffer + rcx] ; Process a character (write to the output buffer).

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
                ; Write the current character to the output buffer.
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
		mov 	rdi, [fd] ; File descriptor stored in 'fd'.
		mov 	rsi, buffer
		mov 	rdx, r15
		syscall ; Invokes the system call to write the line to the file.

		dec 	r15                     ; Decrease r15 to remove the newline character from the end.
		cmp 	byte[buffer + r15], 0xA ; Check if the last character of the line is a newline.
		jne 	while_line
		mov 	byte[flag], 0
		jmp 	while_line

fin:
	mov 	rax, 3             ; 'close' syscall
    mov 	rdi, [fd]          ; file descriptor  
    syscall                    ; Invokes the system call to close the file.
	mov		eax, 60
	mov		edi, 0
	syscall                    ; Invokes the system call to exit the program.



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


