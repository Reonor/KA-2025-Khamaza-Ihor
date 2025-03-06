.model small
.stack 100h
.data
    array dw 10*20 DUP(0) ; Define array, initially filled with 0s

.code
main PROC
    mov ax, @data
    mov ds, ax            ; Initialize data segment

    mov ch, 0             ; Set loop counter for rows (X)
    mov cl, 0             ; Set loop counter for columns (Y)

myloop:
    mov al, cl            ; Y
    mov bl, ch            ; BL = X
    add bl, 5             ; X + 5
    xor bh, bh            ; BH = 0 // so that we can use BX as a 16-bit register
    mul bl                ; AX = (X + 5) * Y
    mov bx, ax            ; BX = AX

    ; Find the address of the element in the word array
    ; First, find the address of the row
    mov ax, 20
    mul ch                ; AX = X * 20

    ; Now add the column stored in CL
    mov dh, 0
    mov dl, cl
    add ax, dx

    ; Now multiply by 2 to get the offset in the array
    shl ax, 1

    ; Exchange AX and BX so that BX contains the address of the element and AX contains the value
    xchg ax, bx
    ; now store the result from BX into the array
    mov [array + bx], ax

    inc cl
    cmp cl, 20
    jne myloop

    mov cl, 0
    inc ch
    cmp ch, 10
    jne myloop

mov ax, 4C00h  ; Terminate program
main    endp
end main