.model small
.stack 100h

.data
    sum_low dw 0
    sum_high dw 0
    input_buffer db 255          ; Max input length
                 db 0            ; Actual length (set by DOS)
                 db 255 dup(0)   ; Input storage
    number_array dw 10000 dup(?) ; Array for numbers (16-bit)
    count        dw 0            ; Number of elements

    ; Messages
    msg_median   db 0Dh, 0Ah, 'Median: $'
    msg_avg      db 0Dh, 0Ah, 'Average: $'
    msg_no_input db 0Dh, 0Ah, 'No numbers entered.$'
    num_str      db 6 dup('$')   ; Buffer for number strings
    minus_32768  db '-32768$'    ; Special case for minimum value

.code
main proc
    mov ax, @data
    mov ds, ax
    mov es, ax

    call read_input
    call bubble_sort
    call print_median
    call print_average

    mov ax, 4C00h    ; Exit program
    int 21h
main endp

; ========================================================
; READ INPUT (Skip invalid entries)
; ========================================================
read_input proc
    mov ah, 0Ah      ; DOS: Buffered input
    lea dx, input_buffer
    int 21h

    ; Null-terminate the input string
    lea si, input_buffer + 2
    xor cx, cx
    mov cl, [input_buffer + 1] ; Actual length
    add si, cx
    mov byte ptr [si], 0       ; Replace CR with null

    lea si, input_buffer + 2   ; Start parsing here

parse_loop:
    call skip_whitespace
    cmp byte ptr [si], 0
    je done_reading

    call parse_number
    jnc valid_number
    ; Skip invalid character
    inc si
    jmp parse_loop

valid_number:
    ; Store valid number
    mov bx, [count]
    shl bx, 1
    mov [number_array + bx], ax
    inc word ptr [count]
    jmp parse_loop

done_reading:
    ret
read_input endp

; ========================================================
; SKIP WHITESPACE
; ========================================================
skip_whitespace proc
skip_loop:
    mov al, [si]
    cmp al, ' '
    je increment
    cmp al, 9       ; Tab
    je increment
    ret
increment:
    inc si
    jmp skip_loop
skip_whitespace endp

; ========================================================
; PARSE NUMBER (Returns CF=1 if invalid)
; ========================================================
parse_number proc
    xor ax, ax
    xor bx, bx
    mov di, 0       ; Sign flag (0 = positive)

    ; Check for '-'
    mov bl, [si]
    cmp bl, '-'
    jne check_digit
    mov di, 1       ; Negative flag
    inc si          ; Skip '-'
    mov bl, [si]    ; Peek next character

check_digit:        ; Validate post '-' character
    cmp bl, '0'
    jb invalid
    cmp bl, '9'
    ja invalid

parse_digits:
    mov cx, 10      ; Base 10 multiplier
    xor ax, ax      ; Initialize number

read_loop:
    mov bl, [si]
    cmp bl, '0'
    jb done_digits
    cmp bl, '9'
    ja done_digits
    sub bl, '0'     ; Convert ASCII to digit

    ; Check for overflow
    imul cx         ; DX:AX = AX * 10
    cmp dx, 0       ; Check high word
    jne overflow
    add ax, bx
    jo overflow     ; Check signed overflow

    ; Check maximum value based on sign
    cmp di, 0
    je check_pos_max
    ; Negative: max 32768
    cmp ax, 32768
    ja overflow
    jmp continue
check_pos_max:
    cmp ax, 32767
    ja overflow

continue:
    inc si
    jmp read_loop

overflow:
    ; Clamp to max/min
    cmp di, 0
    je clamp_pos
    mov ax, 32768   ; -32768 after negation
    jmp clamp_done
clamp_pos:
    mov ax, 32767
clamp_done:
    ; Skip remaining digits
consume_loop:
    inc si
    mov bl, [si]
    cmp bl, '0'
    jb done_digits
    cmp bl, '9'
    ja done_digits
    jmp consume_loop

done_digits:
    cmp di, 0       ; Apply sign
    je apply_sign
    neg ax

apply_sign:
    clc             ; Valid number
    ret

invalid:           ; Handle invalid input
    stc
    ret
parse_number endp

; ========================================================
; BUBBLE SORT (Signed comparison)
; ========================================================
bubble_sort proc
    mov cx, [count]
    dec cx
    jle done_sort  ; No elements or one element

outer_loop:
    mov dx, 0      ; Flag to check swaps
    mov si, 0      ; Index

    mov ax, [count]
    dec ax
    shl ax, 1      ; ax = (count-1)*2

inner_loop:
    mov bx, [number_array + si]
    cmp bx, [number_array + si + 2]
    jle no_swap
    ; Swap elements
    mov di, [number_array + si + 2]
    mov [number_array + si + 2], bx
    mov [number_array + si], di
    mov dx, 1      ; Set swap flag

no_swap:
    add si, 2
    cmp si, ax      ; Compare to (count-1)*2
    jl inner_loop

    test dx, dx
    jz done_sort    ; No swaps, exit
    loop outer_loop

done_sort:
    ret
bubble_sort endp

; ========================================================
; PRINT MEDIAN (Handles rounding for even counts)
; ========================================================
print_median proc
    mov dx, offset msg_median
    call print_string

    mov cx, [count]
    test cx, cx
    jz no_numbers

    mov ax, cx
    shr ax, 1       ; ax = count / 2
    jnc even_count

    ; Odd count: middle element
    shl ax, 1
    mov si, ax
    mov ax, [number_array + si]
    jmp print_median_val

even_count:
    ; Even count: average of two middle elements (with rounding)
    dec ax
    shl ax, 1
    mov si, ax
    mov ax, [number_array + si]
    add ax, [number_array + si + 2]
    cwd             ; Sign extend to dx:ax
    mov cx, 2
    idiv cx         ; ax = quotient, dx = remainder

    cmp dx, 0
    je print_median_val  ; Exact, no adjustment
    test dx, dx
    js negative_remainder
    inc ax          ; Positive remainder (round up)
    jmp print_median_val
negative_remainder:
    dec ax          ; Negative remainder (round down)

print_median_val:
    call print_number
    ret

no_numbers:
    mov dx, offset msg_no_input
    call print_string
    ret
print_median endp

; ========================================================
; PRINT AVERAGE (Handles no input)
; ========================================================
print_average proc
    mov dx, offset msg_avg
    call print_string

    mov cx, [count]
    jcxz no_numbers_avg

    ; Initialize 32-bit sum (DI:SI)
    xor si, si        ; Low word
    xor di, di        ; High word

    mov bx, 0         ; Index for number_array

sum_loop:
    mov ax, [number_array + bx]  ; Load 16-bit number
    cwd                          ; Sign extend to DX:AX (32-bit)
    add si, ax                   ; Add low word to SI
    adc di, dx                   ; Add high word with carry to DI
    add bx, 2
    loop sum_loop

    ; Add count/2 for rounding (32-bit)
    mov ax, [count]
    cwd                          ; Sign extend count to DX:AX
    mov bx, ax
    sar bx, 1                    ; BX = count/2 (signed)
    mov ax, bx
    cwd                          ; Sign extend BX to DX:AX
    add si, ax                   ; Add low word of count/2
    adc di, dx                   ; Add high word with carry

    ; Prepare for 32-bit division (DX:AX = DI:SI)
    mov ax, si
    mov dx, di
    mov cx, [count]              ; Divisor (count)
    idiv cx                      ; AX = quotient (average)

    ; Print the result
    call print_number
    ret

no_numbers_avg:
    mov dx, offset msg_no_input
    call print_string
    ret
print_average endp

; ========================================================
; PRINT NUMBER (Handles -32768 correctly)
; ========================================================
print_number proc
    ; Save all registers manually (replaces PUSHA)
    push di
    push si
    push bp
    push bx
    push dx
    push cx
    push ax

    cmp ax, 8000h   ; Check for -32768
    je special_case
    cmp ax, 0
    jge positive

    ; Handle negatives
    mov dl, '-'
    mov ah, 02h
    int 21h
    neg ax

positive:
    mov cx, 0
    mov bx, 10
    test ax, ax
    jnz next_digit
    push '0'
    inc cx
    jmp print_digits

next_digit:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz next_digit

print_digits:
    pop dx
    mov ah, 02h
    int 21h
    loop print_digits

    ; Restore registers manually (replaces POPA)
    pop ax
    pop cx
    pop dx
    pop bx
    pop bp
    pop si
    pop di
    ret

special_case:
    mov dx, offset minus_32768
    mov ah, 09h
    int 21h
    ; Restore registers
    pop ax
    pop cx
    pop dx
    pop bx
    pop bp
    pop si
    pop di
    ret
print_number endp

; ========================================================
; PRINT STRING (DX points to string)
; ========================================================
print_string proc
    mov ah, 09h
    int 21h
    ret
print_string endp

end main