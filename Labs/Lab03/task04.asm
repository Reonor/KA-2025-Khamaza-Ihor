.model small
.stack 100h
.code
main    proc
    mov dx, 64
    xor dx, dx ;xor makes it so no matter what the number is, all the bits are set to 0. if bit is 1, then for 1 and 1 xor is 0, if bit is 0, for 0 and 0, xor is 0
    int 21h
main    endp
end main