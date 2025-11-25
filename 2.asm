.model small
.stack 100h

.data
	prompt1 db "Enter 20 numbers in ascending order (-128 to 127)$"
    prompt2 db "Enter number: $"

	buffer db 5, ?, 5 dup(?)

	sep db ", $"

	arr db 20 dup (?)

.code
main proc
    mov ax, @data
    mov ds, ax

	lea dx, prompt1
	mov ah, 09h
	int 21h
	call newline

	lea si, arr
	mov cx, 20
arrreadloop:
    lea dx, prompt2
    call input
	jc endmain
	mov [si], al
	inc si
	loop arrreadloop

	lea si, arr
	mov di, 4000h
	mov cx, 10
	mov dx, si
	add dx, 19

arrwriteloop:
	mov al, [si]
	mov [di], al
	inc si
	inc di
	push si
	mov si, dx
	mov al, [si]
	mov [di], al
	dec si
	inc di
	mov dx, si
	pop si
	loop arrwriteloop

	mov dx, 4000h
	call show

endmain:
    mov ah, 4ch
    int 21h
main endp



; takes array starting address through dx
; prints array

show proc
    push ax
    push cx
    push dx
    push si

	mov si, dx

    mov ax, 20
    push ax
    mov cx, 20

showloop:
    mov al, [si]
    call print_decimal

    lea dx, sep
    mov ah, 09h
    int 21h

    inc si
loop showloop

    mov ah, 02h
    mov dl, 08h
    int 21h
    mov dl, 08h
    int 21h
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    mov dl, 08h
    int 21h

    pop ax
    pop si
    pop dx
    pop cx
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
	push bx
	push cx
	push dx

	mov dl, 0Dh
	mov ah, 02h
	int 21h

	mov dl, 0Ah
	mov ah, 02h
	int 21h

	pop dx
	pop cx
	pop bx
	pop ax
	
	ret
newline endp

end main