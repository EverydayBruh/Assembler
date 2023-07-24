.code
processMatrix proc

	; Function prologue
	push rbp
	mov rbp, rsp

	; Parameters:
	; [rbp+16] contains the matrix pointer (int* matrix)
	; [rbp+20] contains the number of rows (int rows)
	; [rbp+24] contains the number of columns (int cols)

	; Your matrix processing code goes here.

	; Load the matrix pointer into rsi (second parameter)
	mov rsi, [rbp+16]

	; Load the number of rows into rdx (third parameter)
	mov rdx, [rbp+20]

	; Load the number of columns into rcx (fourth parameter)
	mov rcx, [rbp+24]

	; Loop through the matrix and multiply all the elements by 2
	processMatrixLoop:
		mov eax, [rsi]        ; Load the current element (4 bytes) into the lower 32 bits of rax
		shl eax, 1           ; Multiply the current element by 2 (shift left by 1 bit)
		mov [rsi], eax        ; Store the updated element back into the matrix
		add rsi, 4           ; Move the matrix pointer to the next element (assuming the matrix is an int* array)
		loop processMatrixLoop ; Loop until all elements are processed

	; Function epilogue
	pop rbp
	ret

processMatrix endp
end
