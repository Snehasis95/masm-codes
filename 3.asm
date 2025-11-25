.model small
.stack 100h

.data
    buffer db 3, ?, 3 dup(?)
    prompt db "Enter a hex number (0 to FF):  $"
    msg db "Corresponding ASCII character: $"

    

.code

main proc
    mov ax, @data
    mov ds, ax

    lea dx, prompt
    call input

    push ax

    lea dx, msg
    mov ah, 09h
    int 21h

    pop ax
    mov dl, al
    mov ah, 02h
    int 21h

    mov ah, 4ch
    int 21h
main endp



; takes a string prompt through dx
; takes a hex number (0 to FF) as user input
; and gives the number at al
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

inputcontinue:
    mov ax, 0

    cmp cl, 0
    jnz inputloop
    stc
    jmp inputend

inputloop:
    mov dl, 16
    mul dl

    mov dl, buffer[si]
    cmp dl, 65
    js number
    cmp dl, 91
    jns lowercase

    sub dl, 'A'
    add dl, 10
    jmp inputloopadd

lowercase:
    sub dl, 'a'
    add dl, 10
    jmp inputloopadd

number:
    sub dl, '0'

inputloopadd:
    add al, dl
    inc si
loop inputloop

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