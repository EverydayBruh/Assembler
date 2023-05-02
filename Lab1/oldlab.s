bits    64

section .data 
a DWORD 1000
b WORD -1
c1 WORD 2
d WORD -3
e DWORD 5


section .code
addition proc a:DWORD, b:WORD, c1:WORD, d:WORD, e:DWORD

    movsx rax, word ptr b; eax = b
    movsx edx, word ptr c1;
    add eax, edx ; eax = b + c
    imul eax, a ; eax = a * (b + c)   -dq
    mov ebx, e ; ebx = e
    add ebx, a ; ebx = e + a
    movsx edx, word ptr d; ; edx = d
    imul ebx, edx; ebx = d * (e + a)        -dq
    sub eax, ebx; eax = a * (b + c) - d * (e + a)

    imul edx, edx ; edx = d * d
    movsx ecx, word ptr c1 ; ecx = c
    imul ecx, ecx ; ecx = c * c
    movsx ebx, word ptr b
    imul ecx, ebx ; ecx = c * c * b
    sub edx, ecx ; edx = d * d - c * c * b
    mov ebx, edx; 
    cmp ebx, 0 ;
    je error

    cdq ; 
    idiv ebx ; eax = (a * (b + c) - d * (e + a)) / (d * d - c * c * b)
    ret


    error: ;
        mov eax, 0 ; 
        ret
addition endp
end
