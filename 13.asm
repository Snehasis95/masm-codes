.model small
.stack 100h



.data
    prompt db "Press any key. Press Enter to exit.$"

    msg1 db "Frequency of key presses: $"
    msg2 db "Total keypresses: $"
    msg3 db "Vowels:           $"
    msg4 db "Consonants:       $"
    msg5 db "Last $"
    msg6 db " keys pressed: $"

    count db 0, 0, 0

    chars db 10, 0, 10 dup(?)

    freq db 255 dup(0)

    space db "Spc$"
    bksp db "Bksp$"

    dbg db "Debug statement reached$"



.code

main proc
    mov ax, @data
    mov ds, ax

forever:
    mov ax, 0600h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h

    mov ah, 02h
    mov bh, 00h
    mov dx, 0000h
    int 10h

    call displayfrequency
    call newline
    call newline

    call displaycount
    call newline

    call displaybuffer
    call newline
    call newline

    mov ah, 09h
    lea dx, prompt
    int 21h

    mov ah, 01h
    int 21h
    cmp al, 0dh
    jz endmain1
    jmp endmain2
endmain1:
    jmp endmain
endmain2:

    mov ah, 0
    mov si, ax
    lea dx, freq
    add si, dx
    mov dl, [si]
    inc dl
    mov [si], dl

    cmp al, 65
    js checkcontinue1
    jmp checkcontinue2
checkcontinue1:
    jmp checkcontinue
checkcontinue2:
    cmp al, 91
    jns checklowercase

    cmp al, 'A'
    jz incvowel
    cmp al, 'E'
    jz incvowel
    cmp al, 'I'
    jz incvowel
    cmp al, 'O'
    jz incvowel
    cmp al, 'U'
    jz incvowel

    mov dl, count[2]
    inc dl
    mov count[2], dl
    jmp checkcontinue

incvowel:
    mov dl, count[1]
    inc dl
    mov count[1], dl
    jmp checkcontinue

checklowercase:
    cmp al, 97
    js checkcontinue
    cmp al, 123
    jns checkcontinue

    cmp al, 'a'
    jz incvowel
    cmp al, 'e'
    jz incvowel
    cmp al, 'i'
    jz incvowel
    cmp al, 'o'
    jz incvowel
    cmp al, 'u'
    jz incvowel
    
    mov dl, count[2]
    inc dl
    mov count[2], dl

checkcontinue:
    mov dl, count[0]
    inc dl
    mov count[0], dl

    lea dx, chars
    mov si, dx
    mov ch, [si]
    inc si
    mov cl, [si]
    cmp cl, ch
    jnz charsnotfull

    mov ch, 0
    dec cx
    inc si
    inc si
    
charsloop:
    mov dl, [si]
    dec si
    mov [si], dl
    inc si
    inc si
    loop charsloop

    dec si
    mov [si], al
    jmp charscontinue

charsnotfull:
    mov ch, 0
    inc cx
    mov [si], cl
    add si, cx
    mov [si], al

charscontinue:
    jmp forever

endmain:
    mov ah, 4ch
    int 21h
main endp



displaybuffer proc
    push ax
    push dx
    push cx
    push si

    lea dx, msg5
    mov ah, 09h
    int 21h

    lea dx, chars
    mov si, dx

    mov al, [si]
    call print_decimal

    inc si
    mov cl, [si]
    mov ch, 0

    lea dx, msg6
    mov ah, 09h
    int 21h

    cmp cl, 0
    jz displaybufferloopbreak

    inc si

displaybufferloop:
    mov dl, [si]
    mov ah, 02h
    int 21h
    inc si
    loop displaybufferloop

displaybufferloopbreak:
    pop si
    pop cx
    pop dx
    pop ax
    ret
displaybuffer endp



displaycount proc
    push ax
    push dx
    push si

    lea dx, count
    mov si, dx

    lea dx, msg2
    mov ah, 09h
    int 21h

    mov al, [si]
    call print_decimal
    call newline
    inc si

    lea dx, msg3
    mov ah, 09h
    int 21h

    mov al, [si]
    call print_decimal
    call newline
    inc si

    lea dx, msg4
    mov ah, 09h
    int 21h

    mov al, [si]
    call print_decimal
    call newline

    pop si
    pop dx
    pop ax
    ret
displaycount endp



displayfrequency proc
    push ax
    push dx
    push si

    lea dx, freq
    mov si, dx
    mov cx, 255

displayloop:
    mov al, [si]
    cmp al, 0
    jz displayloopcontinue

    push ax

    mov dl, 255
    sub dl, cl

    mov ah, 02h
    int 21h

    mov dl, ':'
    int 21h

    mov dl, ' '
    int 21h

    pop ax
    call print_decimal

    mov ah, 02h
    mov dl, 09h
    int 21h

displayloopcontinue:
    inc si
    loop displayloop

    pop si
    pop dx
    pop ax
    ret
displayfrequency endp



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

end main