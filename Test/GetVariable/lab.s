; 1. Считать строку с переменной окружения
; 2. Вывести в консоль
bits	64

section	.data


var_not_found_msg:
	db 		"Environment variable not found", 0x0
var_not_found_msg_len:
	db 		31
buffer_len:
	db 		10

section .bss
buffer:
	resb	256