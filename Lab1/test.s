bits    64
section .data
    message db 'Hello, World!', 0Ah ; строка сообщения, символ перевода строки добавлен в конец

section .text
    global _start

_start:
    mov rax, 1          ; используем системный вызов write
    mov rdi, 1          ; выводим сообщение в стандартный вывод (файловый дескриптор 1)
    mov rsi, message    ; адрес строки сообщения
    mov rdx, 14         ; длина строки сообщения
    syscall             ; вызываем системный вызов

    mov rax, 60         ; используем системный вызов exit
    xor rdi, rdi        ; код возврата 0
    syscall             ; вызываем системный вызов
