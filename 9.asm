.model small
.stack 100h

.data
    buffer db 5, ?, 5 dup(?)
    mat1 db ?, ?, 255 dup(?)
    mat2 db ?, ?, 255 dup(?)

    msg1 db "Matrix A$"
    msg2 db "Matrix B$"
    prompt1 db "Enter number of rows: $"
    prompt2 db "Enter number of columns: $"

    prompt3 db "Enter element (row-wise): $"

    prompt4 db "Matrix operations", 0dh, 0ah, "  1: A+B", 0dh, 0ah, "  2: A-B", 0dh, 0ah, "  3: B-A", 0dh, 0ah, "  4: A.B", 0dh, 0ah, "  5: B.A", 0dh, 0ah, "Enter choice: $"

    mat3 db ?, ?, 255 dup(?)

    dbg db "Hello I was here", 0dh, 0ah, "$"

    addmsg db "A + B = C$"
    sub1msg db "A - B = C$"
    sub2msg db "B - A = C$"
    mul1msg db "A . B = C$"
    mul2msg db "B . A = C$"

    msg3 db "Matrix C$"

    adderr db "Matrices must be of same dimensions!$"
    mulerr db "First matrix must have as many columns as the second has rows!$"
    inverr db "Invalid choice!$"



.code

main proc
    mov ax, @data
    mov ds, ax

    lea dx, msg1
    mov ah, 09h
    int 21h
    call newline

    lea dx, prompt1
    call input
    jc exitmain1
    mov mat1[0], al

    lea dx, prompt2
    call input
    jc exitmain1
    mov mat1[1], al

    mov cl, mat1[0]
    mul cl
    mov cx, ax
    lea dx, prompt3
    mov si, 2

inputloop1:
    call input
    jc exitmain1
    mov mat1[si], al
    inc si
loop inputloop1

    call newline
    jmp noexitmain1

exitmain1:
    jmp exitmain

noexitmain1:
    lea dx, msg2
    mov ah, 09h
    int 21h
    call newline

    lea dx, prompt1
    call input
    jc exitmain2
    mov mat2[0], al

    lea dx, prompt2
    call input
    jc exitmain2
    mov mat2[1], al

    mov cl, mat2[0]
    mul cl
    mov cx, ax
    lea dx, prompt3
    mov si, 2

inputloop2:
    call input
    jc exitmain2
    mov mat2[si], al
    inc si
loop inputloop2

    call newline
    jmp noexitmain2

exitmain2:
    jmp exitmain

noexitmain2:
    lea dx, msg1
    mov ah, 09h
    int 21h
    call newline

    lea dx, mat1
    call show

    call newline
    lea dx, msg2
    mov ah, 09h
    int 21h

    call newline
    lea dx, mat2
    call show

forever:
    call newline
    lea dx, prompt4
    call input
    jc exitmain2

    lea dx, mat3

    cmp al, 1
    jnz sub1cmp

    lea ax, mat1
    lea bx, mat2
    call addm
    jc adderror

    push dx
    mov ah, 09h
    lea dx, addmsg
    int 21h
    call newline
    lea dx, msg3
    int 21h
    call newline
    pop dx
    call show
    jmp forever

adderror:
    lea dx, adderr
    mov ah, 09h
    int 21h
    jmp forever

sub1cmp:
    cmp al, 2
    jnz sub2cmp

    lea ax, mat1
    lea bx, mat2
    call subm
    jc adderror

    push dx
    mov ah, 09h
    lea dx, sub1msg
    int 21h
    call newline
    lea dx, msg3
    int 21h
    call newline
    pop dx
    call show
    jmp forever

sub2cmp:
    cmp al, 3
    jnz mul1cmp

    lea ax, mat2
    lea bx, mat1
    call subm
    jc adderror

    push dx
    mov ah, 09h
    lea dx, sub2msg
    int 21h
    call newline
    lea dx, msg3
    int 21h
    call newline
    pop dx
    call show
    jmp forever

mul1cmp:
    cmp al, 4
    jnz mul2cmp

    lea ax, mat1
    lea bx, mat2
    call mulm
    jc mulerror

    push dx
    mov ah, 09h
    lea dx, mul1msg
    int 21h
    call newline
    lea dx, msg3
    int 21h
    call newline
    pop dx
    call show
    jmp forever

mulerror:
    lea dx, mulerr
    mov ah, 09h
    int 21h
    jmp forever

mul2cmp:
    cmp al, 5
    jnz inverror

    lea ax, mat2
    lea bx, mat1
    call mulm
    jc mulerror

    push dx
    mov ah, 09h
    lea dx, mul2msg
    int 21h
    call newline
    lea dx, msg3
    int 21h
    call newline
    pop dx
    call show
    jmp forever

inverror:
    lea dx, inverr
    mov ah, 09h
    int 21h
    jmp forever

exitmain:
    mov ah, 4ch
    int 21h
main endp



; takes first matrix starting address through ax
; takes second matrix starting address through bx
; takes result matrix starting address through dx
; writes product to result matrix
; sets carry if invalid output

mulm proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov si, ax
    mov di, bx

    mov al, [si]
    mov bl, [di]
    inc si
    inc di

    mov ah, [si]
    mov bh, [di]
    inc si
    inc di

    cmp ah, bl
    jnz mulmerror

    push di
    mov di, dx
    mov [di], al
    inc di
    mov [di], bh
    inc di
    mov dx, di
    pop di

    mov cl, al
    mov ch, 0

mulmloop:
    push si
    push di
    push cx
    
    mov cl, bh
    mov ch, 0

    mulinner:
        push ax
        push cx
        push si
        push di
        push dx

        mov dx, 0
        mov cl, ah
        mov ch, 0

        mulinnermost:
            mov al, [si]
            mov ah, [di]
            mul ah
            add dx, ax
            inc si
            push bx
            mov bl, bh
            mov bh, 0
            add di, bx
            pop bx
        loop mulinnermost

        pop di
        mov [di], dl
        mov dx, di
        inc dx

        pop di
        pop si
        pop cx
        pop ax

        inc di
    loop mulinner

    pop cx
    pop di
    pop si

    push ax
    mov al, ah
    mov ah, 0
    add si, ax
    pop ax
loop mulmloop

    clc
    jmp mulmend

mulmerror:
    stc

mulmend:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
mulm endp



; takes first matrix starting address through ax
; takes second matrix starting address through bx
; takes result matrix starting address through dx
; writes difference to result matrix
; sets carry if invalid output

subm proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov si, ax
    mov di, bx

    mov al, [si]
    mov bl, [di]
    inc si
    inc di

    mov ah, [si]
    mov bh, [di]
    inc si
    inc di

    cmp al, bl
    jnz submerror
    cmp ah, bh
    jnz submerror

    mov bx, di
    mov di, dx
    mov [di], al
    inc di
    mov [di], ah
    inc di
    mov dx, di
    mov di, bx
    

    mul ah
    mov cx, ax

submloop:
    mov al, [si]
    mov ah, [di]
    sub al, ah
    mov bx, di
    mov di, dx
    mov [di], al
    inc di
    mov dx, di
    mov di, bx
    inc si
    inc di
loop submloop

    clc
    jmp submend

submerror:
    stc

submend:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
subm endp



; takes first matrix starting address through ax
; takes second matrix starting address through bx
; takes result matrix starting address through dx
; writes sum to result matrix
; sets carry if invalid output

addm proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov si, ax
    mov di, bx

    mov al, [si]
    mov bl, [di]
    inc si
    inc di

    mov ah, [si]
    mov bh, [di]
    inc si
    inc di

    cmp al, bl
    jnz addmerror
    cmp ah, bh
    jnz addmerror

    mov bx, di
    mov di, dx
    mov [di], al
    inc di
    mov [di], ah
    inc di
    mov dx, di
    mov di, bx
    

    mul ah
    mov cx, ax

addmloop:
    mov al, [si]
    mov ah, [di]
    add al, ah
    mov bx, di
    mov di, dx
    mov [di], al
    inc di
    mov dx, di
    mov di, bx
    inc si
    inc di
loop addmloop

    clc
    jmp addmend

addmerror:
    stc

addmend:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
addm endp



; takes matrix starting address through dx
; prints the matrix

show proc
    push ax
    push bx
    push cx
    push dx
    push si

    mov si, dx
    mov cl, [si]
    mov ch, 0

    inc si
    mov bl, [si]
    mov bh, 0
    push bx

    inc si

outershowloop:
    pop bx
    push bx
    push cx
    mov cx, bx

    mov ah, 02h
    mov dl, '['
    int 21h
    mov dl, ' '
    int 21h

    innershowloop:
        mov al, [si]
        call print_decimal
        inc si

        mov dl, 9
        mov ah, 02h
        int 21h
    loop innershowloop

    mov ah, 02h
    mov dl, 08h
    int 21h
    int 21h
    int 21h
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ']'
    int 21h

    mov bx, cx
    pop cx
    call newline
loop outershowloop

    pop bx

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
show endp


; takes a string prompt through dx
; takes a decimal number (-128 to 127) as user input
; and gives an 8-bit number (2's complement) at al
; sets carry flag if input is empty

input proc
    push cx
    push dx
    push si
    push ax
    
    mov ah, 09h
    int 21h

    lea dx, buffer
    mov ah, 0ah
    int 21h

    call newline

    mov dh, 0
    mov cl, buffer[1]
    mov ch, 0
    mov si, 2

    mov al, buffer[si]
    cmp al, '-'

    jnz inputcontinue

    mov dh, 1
    inc si
    dec cl

inputcontinue:
    mov ax, 0

    cmp cl, 0
    jnz inputloop
    stc
    jmp inputend

inputloop:
    mov dl, 10
    mul dl

    mov dl, buffer[si]
    sub dl, '0'
    add al, dl
    inc si
loop inputloop

    cmp dh, 1
    jnz inputpositive
    xor al, 255
    add al, 1

inputpositive:
    clc

inputend:
    mov dl, al
    pop ax
    mov al, dl
    pop si
    pop dx
    pop cx
    ret
input endp



; takes an 8-bit number (-128 to 127) through al
; prints it as a decimal number (2's complement)

print_decimal proc
	push ax
	push bx
	push cx
	push dx

    mov ah, al
    and ah, 128
    jz printcontinue

    push ax
    mov dl, '-'
    mov ah, 02h
    int 21h
    pop ax

    xor al, 255
    add al, 1

printcontinue:
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