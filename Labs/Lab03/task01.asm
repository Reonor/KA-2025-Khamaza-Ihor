.model small
.stack 100h
.code
main    proc
    mov ax, 200
    mov dx, 100
    mov bx,ax
    mov cx,dx
    mov dx,bx
    mov ax,cx
    int 21h
main    endp
end main