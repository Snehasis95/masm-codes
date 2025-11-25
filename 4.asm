.model small
.stack 100h

.data
    msg1 db "Enter first number: $"
    msgOp db "Enter operator (+, -, *, /): $"
    msg2 db "Enter second number: $"
    msgRes db "Result: $"
    errormsg db "Invalid operator or Div by 0", "$"
    
    num1 dw 0
    num2 dw 0
    charOp db ? 

.code

main proc
    mov ax, @data
    mov ds, ax

    lea dx, msg1
    mov ah, 09h
    int 21h
    
    call scan_num
    mov num1, cx

    lea dx, msgOp
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    mov charOp, al
    call newline

    lea dx, msg2
    mov ah, 09h
    int 21h

    call scan_num
    mov num2, cx
    call newline

    lea dx, msgRes
    mov ah, 09h
    int 21h
    
    mov al, charOp
    mov bx, num1
    mov cx, num2

    cmp al, '+'
    je do_add
    cmp al, '-'
    je do_sub
    cmp al, '*'
    je do_mul
    cmp al, '/'
    je do_div
    jmp error

do_add:
    add bx, cx
    mov ax, bx
    call print_decimal
    jmp exit_prog

do_sub:
    sub bx, cx
    mov ax, bx
    call print_decimal
    jmp exit_prog

do_mul:
    mov ax, bx
    mul cx
    call print_decimal
    jmp exit_prog

do_div:
    cmp cx, 0
    je error

    mov ax, bx
    xor dx, dx
    div cx

    push dx
    call print_decimal
    pop dx

    cmp dx, 0
    je exit_prog

    push dx
    mov ah, 02h
    mov dl, '.'
    int 21h
    pop dx

    mov bx, 5
    mov si, num2

print_float_loop:
    cmp bx, 0
    je exit_prog
    cmp dx, 0
    je exit_prog

    mov ax, dx
    xor dx, dx
    mov cx, 10
    mul cx
    
    div si
    
    push dx
    call print_decimal
    pop dx
    
    dec bx
    jmp print_float_loop


error:
    lea dx, errormsg
    mov ah, 09h
    int 21h

exit_prog:
    mov ah, 4ch
    int 21h
main endp



; Returns the integer value in CX.
scan_num proc
    push ax
    push bx
    push dx

    xor cx, cx
    
next_digit:
    mov ah, 01h
    int 21h

    cmp al, 13
    je stop_scan
    
    sub al, '0'
    xor ah, ah
    mov bx, ax

    mov ax, cx
    mov dx, 10
    mul dx
    add ax, bx
    mov cx, ax
    
    jmp next_digit

stop_scan:
    pop dx
    pop bx
    pop ax
    ret
scan_num endp



print_decimal proc
    push ax
    push bx
    push cx
    push dx

    xor cx, cx
    mov bx, 10

digit_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne digit_loop

print_loop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_decimal endp



newline proc
    push ax
    push dx
    mov dl, 0Dh
    mov ah, 02h
    int 21h
    mov dl, 0Ah
    mov ah, 02h
    int 21h
    pop dx
    pop ax
    ret
newline endp

end main