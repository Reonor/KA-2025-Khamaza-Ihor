model small
.stack 100h
.data
    newline db 0Dh, 0Ah, '$'  ; Newline for formatting
    limit db 5               ; Upper limit (modifiable, between 0 and 9)
.code
main proc
    mov ax, @data   ; Initialize data segment
    mov ds, ax
    
    mov cl, limit   ; Load limit value
    inc cl          ; Adjust for correct loop count
    mov dl, '0'     ; Start from ASCII '0'

print_loop:
    mov ah, 02h     ; DOS function to print character
    int 21h         ; Print current number
    
    inc dl          ; Move to next number (ASCII increment)
    loop print_loop ; Repeat until CX=0

    ; Print newline
    mov dx, offset newline
    mov ah, 09h     ; DOS function to print string
    int 21h
    
    mov ah, 4Ch     ; DOS terminate function
    int 21h         ; Exit program

main endp
end main