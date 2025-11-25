.model small
.stack 100h

.data

    stk db 20 dup(?)
    sz dw 20
    top dw 0

    prompt1 db "Stack operation: 0-Exit 1-Push 2-Pop", 0dh, 0ah, "Enter choice: $"

    controlBuffer db 2, ?, 2 dup(?)

    prompt2 db "   Enter new element: $"

    inputBuffer db 2, ?, 2 dup(?)

    msg1 db "   Element pushed into stack$"
    msg2 db "   Element popped: $"
    errmsg db "INVALID$"

    errmsg1 db "   Stack is full$"
    errmsg2 db "   Stack is empty$"


.code

main proc
    mov ax, @data
    mov ds, ax

forever:
    call newline

    lea ax, prompt1
    lea dx, controlBuffer
    call input

    mov al, controlBuffer[2]
    cmp al, '0'
    jnz checkOne
    jmp exit

checkOne:
    cmp al, '1'
    jnz checkTwo
    
    lea ax, prompt2
    lea dx, inputBuffer
    call input

    mov dl, inputBuffer[2]
    call pushstk

    jz pushError
    
    lea dx, msg1
    mov ah, 09h
    int 21h
    jmp checkOneFinish

pushError:
    lea dx, errmsg1
    mov ah, 09h
    int 21h

checkOneFinish:
    call newline
    jmp forever

checkTwo:
    cmp al, '2'
    jnz error

    call popstk

    jz popError

    mov cl, dl

    lea dx, msg2
    mov ah, 09h
    int 21h

    mov dl, cl
    mov ah, 02h
    int 21h
    jmp checkTwoFinish

popError:
    lea dx, errmsg2
    mov ah, 09h
    int 21h

checkTwoFinish:
    call newline
    jmp forever

error:
    lea dx, errmsg
    mov ah, 09h
    int 21h
    call newline

jmp forever

exit:
    mov ah, 4ch
    int 21h
main endp



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
