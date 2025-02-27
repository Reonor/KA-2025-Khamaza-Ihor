.model small
.stack 100h
.data
    a dw 1  
    b dw 10
.code
main    proc
    mov ax, @data
    mov ds,ax
    mov ax, a
    mov bx, b
    and ax,bx
    cmp ax,bx
    jne a_is_zero
    mov ax, 1
    int 21h
    a_is_zero:
    mov ax,0
    int 21h
main    endp
end main