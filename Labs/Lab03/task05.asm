.model small
.stack 100h
.code
main    proc
    mov ax, 200
    mov dx, 100
    xor dx,ax 
    xor ax,dx ;running xor for result of an xor and for one of it's compenents returns the other component
    xor dx,ax ;and again
    int 21h
main    endp
end main