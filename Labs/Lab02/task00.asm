.model small
.stack 100h
.code
main    proc
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx
    mov ax, 100
    mov bx, 50
    add ax, bx
    loop:
    inc cx
    cmp cx, 40
    jne loop
    mov ax, 4c00h           ; exit program
    int 21h                 ; call dos interrupt
    sub bx, cx
main    endp
end main