.model small
.stack 100h

.data
	buffer db 20, ?, 20 dup(?)
	prompt db "Enter message: $"
	msg1 db "Original message:    $"
	msg2 db "Transformed message: $"




.code

main proc
	mov ax, @data
	mov ds, ax

	lea dx, prompt
	call show
	call input
	call newline

	lea dx, msg1
	call show
	call output
	call newline

	call parse

	lea dx, msg2
	call show
	call output

	mov ah, 4ch
	int 21h
main endp




input proc
	push ax
	push dx

	mov ah, 0ah
	lea dx, buffer
	int 21h

	pop dx
	pop ax
	ret
input endp




output proc
	push ax
	push cx
	push dx
	push si

	mov cl, buffer[1]
	xor ch, ch
	mov si, 2

outputloop:
	mov dl, buffer[si]
	mov ah, 02h
	int 21h
	inc si
loop outputloop

	pop si
	pop dx
	pop cx
	pop ax
	ret
output endp




parse proc
	push ax
	push cx
	push dx
	push si

	mov cl, buffer[1]
	xor ch, ch
	mov si, 2

parseloop:
	mov dl, buffer[si]

	cmp dl, 'A'
	js parsecontinue
	mov dh, 'Z'
	cmp dh, dl
	js parseelseif
	sub dl, 'A'
	add dl, 'a'
	mov buffer[si], dl
	jmp parsecontinue

parseelseif:
	cmp dl, 'a'
        js parsecontinue
	mov dh, 'z'
        cmp dh, dl
        js parsecontinue
        sub dl, 'a'
        add dl, 'A'
        mov buffer[si], dl

parsecontinue:
	inc si
loop parseloop

	pop si
	pop dx
	pop cx
	pop ax
	ret
parse endp




show proc
	push ax
	mov ah, 09h
	int 21h
	pop ax
	ret
show endp




newline proc
	push ax
	push dx

	mov ah, 02h
	mov dl, 0dh
	int 21h
	mov dl, 0ah
	int 21h

	pop dx
	pop ax
	ret
newline endp

end main

