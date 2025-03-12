.model small
.stack 100h

.data
    num1 dw 5
    num2 dw 10

.code
main:
    mov ax, @data
    mov ds, ax

    mov ax, num1
    mov bx, num2

    mul bx            ; AX = AX * BX, результат у AX

    mov ah, 4Ch
    int 21h

end main
