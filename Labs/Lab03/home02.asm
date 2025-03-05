.model small
.stack 100h
.data
    a DW 120       ; Початкове значення змінної a
    b DW 130        ; Початкове значення змінної b
    c DW 150       ; Початкове значення змінної c

.code
main proc
    MOV AX, @data  ; Завантаження сегменту даних
    MOV DS, AX

    ; Перевірка умови (a > b)
    MOV AX, a
    CMP AX, b
    JLE else   ; Якщо a <= b, перейти в else

    ; Перевірка умови (b < c)
    MOV BX, b
    CMP BX, c
    JGE else   ; Якщо b >= c, перейти в else

    ; if умова виконується, тепер перевіримо (a > 100)
    CMP AX, 100
    JLE end_if      ; Якщо a <= 100, не виконуємо b = b + 10

    ADD BX, 10      ; b = b + 10
    MOV b, BX

end_if:
    JMP end_p ; Пропустити else блок

else:
    ; else: Присвоїти a = 200, b = 100
    MOV a, 200
    MOV b, 100

end_p:
    MOV AX, 4C00h   ; Завершення програми
    INT 21h
main endp
end main