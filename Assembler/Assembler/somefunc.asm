bits 64

section .data
;a dd 2
;b dw 2
;c dw 1
;d dw 2
;e dd 4
a dd 2147480000
b dw -32000
c dw -32000
d dw 32000
e dd 2147480000

div_by_zero_msg db 'Error: Division by zero',0
div_by_zero_msg_len equ $-div_by_zero_msg
msg db "%ld", 10, 0 ;форматная строка для вывода числа в десятичном формате


section .text
global _start

_start:
    ;вычисление числителя
    movsx rax, word[b] ;rax = b
    movsx rdx, word[c] ;rdx = c
    add rax, rdx ;rax = b + c
    movsx rcx, dword[a];
    imul  rcx;rax = a * (b + c)
    movsx rbx, dword[e] ;rbx = e
    movsx rcx, dword[a];
    add rbx, rcx ;rbx = e + a
    movsx rdx, word[d] ;rdx = d
    imul rdx, rbx ;rdx = d * (e + a)
    me:
    sub rax, rdx ;rax = a * (b + c) - d * (e + a)

    ;вычисление знаменателя
    movsx rdx, word[c] ;rdx = c
    imul rdx, rdx ;rdx = c * c
    movsx rcx, word[b] ;rcx = b
    imul rcx, rdx ;rcx = c * c * b
    movsx rdx, word[d] ;rdx = d
    imul rdx, rdx ;rdx = d * d
    sub rdx, rcx ;rdx = d * d - c * c * b

    ;проверка знаменателя на ноль
    cmp rdx, 0
    je divide_by_zero_error

    ;вычисление результатa
    
    mov rbx, rdx
    me2:
    cqo
    idiv rbx ;rax = (a * (b + c) - d * (e + a)) / (d * d - c * c * b)
    me3:
    
    end:
    mov rax, 1 ;устанавливаем номер системного вызова для exit
    mov rbx, 0 ;устанавливаем код возврата 0
    int 0x80 ;вызываем системный вызов exit

    

divide_by_zero_error:
    ;вывод сообщения об ошибке деления на ноль
    mov rax, 1 ;устанавливаем номер системного вызова для write
    mov rcx, div_by_zero_msg ;устанавливаем адрес сообщения
    mov rdx, div_by_zero_msg_len ;устанавливаем длину сообщения
    int 0x80 ;вызываем системный вызов write

    ;выход из программы с ошибкой
    mov rax, 1 ;устанавливаем номер системного вызова для exit
    mov rbx, 1 ;устанавливаем код возврата 1
    int 0x80 ;вызываем системный вызов exit

