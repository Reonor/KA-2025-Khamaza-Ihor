.model small
.stack 100h
.data
    array dw 20 DUP(0) ; Define an array of 15 words, initially filled with 0s
.code
    main PROC
        mov ax, @data
        mov ds, ax ; Initialize data segment

        ; Prepare our loop
        mov bx, 0  ; Initial position in the array
        mov cx, 0  ; Loop counter
        mov ax, 20  ; First element of the array

    array_loop:
        ; Use ax and dx as temporary registers to hold the last two Fibonacci numbers
        mov [array + bx], ax ; Store F(n) in the array
        add bx, 2            ; Move to the next position in the array (words)
        dec ax               ; Next number in the sequence
        inc cx
        cmp cx, 20
        jne array_loop       ; Repeat if cx != 20

        mov ax, 4C00h
        int 21h              ; Terminate program

    main ENDP
END main
