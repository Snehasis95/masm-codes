.model small
.stack 100h

.data
	msg db "Current time: $"




.code

main proc
	mov ax, @data
	mov ds, ax

infloop:
	call showtime
jmp infloop

	mov ah, 4ch
	int 21h
main endp




showtime proc
	push ax
	push cx
	push dx

	lea dx, msg
	mov ah, 09h
	int 21h

	mov ah, 02h
	int 1ah

	mov al, ch
	call print_bcd

	mov dl, ':'
	mov ah, 02h
	int 21h

	mov al, cl
	call print_bcd

	mov dl, ':'
	mov ah, 02h
	int 21h

	mov al, dh
	call print_bcd

	mov dl, 0dh
	mov ah, 02h
	int 21h

	pop dx
	pop cx
	pop ax
	ret
showtime endp





print_bcd proc
	push cx
	push dx
	push ax

	mov dl, al
	and dl, 0f0h
	mov cl, 4
	shr dl, cl
	add dl, '0'
	mov ah, 02h
	int 21h

    pop ax
    push ax

	mov dl, al
	and dl, 0fh
	add dl, '0'
	mov ah, 02h
	int 21h

	pop ax
	pop dx
	pop cx
	ret
print_bcd endp

end main