bits 64

section .data

section .text
global _start

_start:
   int 0x80 ;вызываем системный вызов exit

