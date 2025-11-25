.model small
.stack 100h

.data
    prompt db "Enter infix expression: $"
    expr db 50, ?, 50 dup(?)

    postf db 50, ?, 50 dup(?)
    pref db 50, ?, 50 dup(?)

    stk db 20 dup(?)
    sz dw 20
    top dw 0

    dbg db "Hello, is this looping?$"

    msg1 db "Infix:   $"
    msg2 db "Postfix: $"
    msg3 db "Prefix:  $"
    msg4 db "Result:  $"
    
    nan_msg db "NaN$"

.code
main proc
    mov ax, @data
    mov ds, ax

    lea ax, prompt
    lea dx, expr
    call input
    call newline

    lea dx, msg1
    mov ah, 09h
    int 21h
    lea ax, expr
    call show
    call newline

    lea ax, expr
    lea dx, postf
    call postfix
    
    lea dx, msg2
    mov ah, 09h
    int 21h
    lea ax, postf
    call show
    call newline

    lea ax, expr
    lea dx, pref
    call prefix
    
    lea dx, msg3
    mov ah, 09h
    int 21h
    lea ax, pref
    call show
    call newline
    
    lea dx, msg4
    mov ah, 09h
    int 21h

    lea dx, postf
    call eval
    
    call print_decimal

    mov ah, 4ch
    int 21h
main endp



; Returns result in al
eval proc
    push bx
    push cx
    push dx
    push si
    push di

    mov si, dx
    inc si
    xor cx, cx

    mov cl, [si]
    
    inc si

    push si
    add si, cx
    mov byte ptr [si], '$'
    pop si

    xor cx, cx
    mov di, 0

eval_scan_loop:
    mov al, [si]
    
    cmp al, '$'
    je eval_finish_trampoline

    cmp al, ' '
    je eval_space_found

    mov dl, al
    call isoperator
    jc eval_do_op

    cmp al, '0'
    jb eval_not_a_number_trampoline
    cmp al, '9'
    ja eval_not_a_number_trampoline

    sub al, '0'
    mov bl, al
    
    mov al, cl
    mov bh, 10
    mul bh
    add al, bl
    mov cl, al
    
    mov di, 1
    inc si
    jmp eval_scan_loop

eval_space_found:
    cmp di, 1
    jne eval_skip_space
    
    mov dl, cl
    call pushstk
    
    xor cx, cx
    mov di, 0

eval_skip_space:
    inc si
    jmp eval_scan_loop

eval_do_op:
    cmp di, 1
    jne eval_perform_math
    mov dl, cl
    call pushstk
    xor cx, cx
    mov di, 0

    jmp eval_perform_math
eval_finish_trampoline:
    jmp eval_finish
eval_not_a_number_trampoline:
    jmp eval_not_a_number

eval_perform_math:
    call popstk
    mov bl, dl
    
    call popstk
    mov al, dl

    mov dl, [si]
    
    cmp dl, '+'
    je op_add
    cmp dl, '-'
    je op_sub
    cmp dl, '*'
    je op_mul
    cmp dl, '/'
    je op_div
    cmp dl, '^'
    je op_pow
    jmp eval_scan_loop 

op_add:
    add al, bl
    jmp push_result
op_sub:
    sub al, bl
    jmp push_result
op_mul:
    mul bl
    jmp push_result
op_div:
    xor ah, ah
    div bl
    jmp push_result
op_pow:
    call power_calc
    jmp push_result

push_result:
    mov dl, al
    call pushstk
    inc si
    jmp eval_scan_loop

eval_finish:
    call popstk
    mov al, dl
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret

eval_not_a_number:
    lea dx, nan_msg
    mov ah, 09h
    int 21h
    mov ah, 4ch
    int 21h
eval endp



power_calc proc
    push cx
    push bx
    
    cmp bl, 0
    je pow_zero
    
    mov cl, bl
    dec cl
    mov bl, al
    
    cmp cl, 0
    je pow_done

pow_loop:
    mul bl
    loop pow_loop
    jmp pow_done

pow_zero:
    mov al, 1

pow_done:
    pop bx
    pop cx
    ret
power_calc endp



print_decimal proc
	push ax
	push bx
	push cx
	push dx

	xor ah, ah
	mov bx, 10
	xor cx, cx

div_loop:
	xor dx, dx
	div bx
	push dx
	inc cx
	cmp ax, 0
	jne div_loop

print_digits:
	pop dx
	add dl, '0'
	mov ah, 02h
	int 21h
	loop print_digits

	pop dx
	pop cx
	pop bx
	pop ax
	ret
print_decimal endp




prefix proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov si, ax
    mov di, dx
    inc si
    inc di

    mov dx, ax
    call strrev

    push di

    mov bx, 0
    mov ch, 0
    mov cl, [si]
    inc si
    inc di

prefixloop:
    mov dl, [si]
    inc si

    call isoperator
    jc operatorhandling1

    cmp dl, ')'
    jz openbrackethandling1

    cmp dl, '('
    jz closebrackethandling1

    mov [di], dl
    inc di
    inc bx
    loop prefixloop
    jmp popstackloopoutside1

closebrackethandling1:
    mov dl, ' '
    mov[di], dl
    inc di
    inc bx

    call popstk
    jz popstackloopoutside1
    cmp dl, ')'
    jz closebrackethandlingdone1
    mov [di], dl
    inc di
    inc bx
    jmp closebrackethandling1

closebrackethandlingdone1:
    dec di
    dec bx
    loop prefixloop
    jmp popstackloopoutside1

openbrackethandling1:
    call pushstk
    loop prefixloop
    jmp popstackloopoutside1

operatorhandling1:
    call getpriority
    mov ah, al
    mov dh, dl

    mov dl, ' '
    mov[di], dl
    inc di
    inc bx

popstackloop1:
    call peekstk
    jz donepopping1

    cmp dh, '^'
    jz powchecking1

    call getpriority
    cmp al, ah
    jns donepopping1
    jmp dowhatevernext1

powchecking1:
    call getpriority
    cmp al, ah
    js donepopping1
    jmp dowhatevernext1

dowhatevernext1:
    call popstk
    mov [di], dl
    inc di
    inc bx
    jmp popstackloop1

donepopping1:
    mov dl, dh
    call pushstk
    loop prefixloop

popstackloopoutside1:
    mov dl, ' '
    mov[di], dl
    inc di
    inc bx

    call popstk
    jz donepoppingoutside1
    mov [di], dl
    inc di
    inc bx
    jmp popstackloopoutside1

donepoppingoutside1:
    pop di
    mov [di], bl

    pop di
    pop si
    pop dx
    call strrev
    pop cx
    pop bx
    pop ax
    ret
prefix endp



postfix proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov si, ax
    mov di, dx
    inc si
    inc di

    push di

    mov bx, 0
    mov ch, 0
    mov cl, [si]
    inc si
    inc di

postfixloop:
    mov dl, [si]
    inc si

    call isoperator
    jc operatorhandling

    cmp dl, '('
    jz openbrackethandling

    cmp dl, ')'
    jz closebrackethandling

    mov [di], dl
    inc di
    inc bx
    loop postfixloop
    jmp popstackloopoutside

closebrackethandling:
    mov dl, ' '
    mov[di], dl
    inc di
    inc bx

    call popstk
    jz popstackloopoutside
    cmp dl, '('
    jz closebrackethandlingdone
    mov [di], dl
    inc di
    inc bx
    jmp closebrackethandling

closebrackethandlingdone:
    dec di
    dec bx
    loop postfixloop
    jmp popstackloopoutside

openbrackethandling:
    call pushstk
    loop postfixloop
    jmp popstackloopoutside

operatorhandling:
    call getpriority
    mov ah, al
    mov dh, dl

    mov dl, ' '
    mov[di], dl
    inc di
    inc bx

popstackloop:
    call peekstk
    jz donepopping

    cmp dh, '^'
    jz powchecking

    call getpriority
    cmp ah, al
    js donepopping
    jmp dowhatevernext

powchecking:
    call getpriority
    cmp ah, al
    jns donepopping
    jmp dowhatevernext

dowhatevernext:
    call popstk
    mov [di], dl
    inc di
    inc bx
    jmp popstackloop

donepopping:
    mov dl, dh
    call pushstk
    loop postfixloop

popstackloopoutside:
    mov dl, ' '
    mov[di], dl
    inc di
    inc bx

    call popstk
    jz donepoppingoutside
    mov [di], dl
    inc di
    inc bx
    jmp popstackloopoutside

donepoppingoutside:
    pop di
    mov [di], bl

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
postfix endp



getpriority proc
    cmp dl, '+'
    jnz getprioritysub
    mov al, 3
    ret

getprioritysub:
    cmp dl, '-'
    jnz getprioritymul
    mov al, 3
    ret

getprioritymul:
    cmp dl, '*'
    jnz getprioritydiv
    mov al, 2
    ret

getprioritydiv:
    cmp dl, '/'
    jnz getprioritypow
    mov al, 2
    ret

getprioritypow:
    cmp dl, '^'
    jnz getpriorityerr
    mov al, 1
    ret

getpriorityerr:
    mov al, 127
    ret
getpriority endp



isoperator proc
    cmp dl, '+'
    jz isoperatortrue
    cmp dl, '-'
    jz isoperatortrue
    cmp dl, '*'
    jz isoperatortrue
    cmp dl, '/'
    jz isoperatortrue
    cmp dl, '^'
    jz isoperatortrue
    clc
    ret

isoperatortrue:
    stc
    ret
isoperator endp



peekstk proc
    push ax
    push bx
    push si

    mov ax, top
    cmp ax, 0
    jz peekFinish

    mov si, top
    dec si
    mov dl, stk[si]

peekFinish:
    cmp ax, 0
    pop si
    pop bx
    pop ax
    ret
peekstk endp



popstk proc
    push ax
    push bx
    push si
    
    mov ax, top
    cmp ax, 0
    jz popFinish

    mov si, top
    dec si
    mov dl, stk[si]
    mov top, si

popFinish:
    cmp ax, 0
    pop si
    pop bx
    pop ax
    ret
popstk endp



pushstk proc
    push ax
    push bx
    push dx
    push si

    mov ax, top
    mov bx, sz

    cmp ax, bx
    jz pushFinish

    mov si, top
    mov stk[si], dl
    inc si
    mov top, si

pushFinish:
    pop si
    pop dx
    pop bx
    pop ax
    ret
pushstk endp



input proc
    push ax
    push dx

    mov dx, ax
    mov ah, 09h
    int 21h

    pop dx
    mov ah, 0ah
    int 21h

    call newline

    pop ax
    ret
input endp



show proc
    push ax
    push cx
    push dx
    push si

    mov si, ax
    inc si
    mov cl, [si]
    mov ch, 0
    inc si

showloop:
    mov dl, [si]
    cmp dl, '$'
    jz showdone

    mov ah, 02h
    int 21h
    inc si
    loop showloop

showdone:
    pop si
    pop dx
    pop cx
    pop ax
    ret
show endp



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

strrev proc
    push cx
    push dx
    push si
    push di

    mov si, dx
    inc si    
    mov cl, [si]
    mov dl, [si]
    inc si
    mov dh, 0
    mov ch, 0
    add dx, si
    dec dx
    mov di, dx

    shr cx, 1

strrevloop:
    mov dl, [si]
    mov dh, [di]
    mov [di], dl
    mov [si], dh
    inc si
    dec di
    loop strrevloop

    pop di
    pop si
    pop dx
    pop cx
    ret
strrev endp

debug proc
    push ax
    push dx
    lea dx, dbg
    mov ah, 09h
    int 21h
    pop dx
    pop ax
    ret
debug endp

end