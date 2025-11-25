.model small
.stack 100h

.data
    msgCmd  db "Enter Operation (STRLEN, STRCMP, STRREV): $"
    msgStr  db "Enter String: $"
    msgStr1 db "Enter String 1: $"
    msgStr2 db "Enter String 2: $"
    errCmd  db "Error: Invalid Command$"
    
    ; Buffer structure for DOS 0Ah Input
    ; Byte 0: Max Len, Byte 1: Actual Len, Byte 2+: String
    buffer  db 50, ?, 50 dup(?)

    func db 50 dup('$')  
    str1 db 50 dup('$')
    str2 db 50 dup('$')

.code

main proc
    mov ax, @data
    mov ds, ax

    lea dx, msgCmd
    mov ah, 09h
    int 21h

    ; Get Command
    call input
    lea di, func
    call copy_buffer
    call newline

    ; Command Parsing
    cmp func[0], 'S'
    jne invalid_cmd
    cmp func[1], 'T'
    jne invalid_cmd
    cmp func[2], 'R'
    jne invalid_cmd

    mov al, func[3]
    
    cmp al, 'C'
    je get_two_strings

    cmp al, 'L'
    je get_one_string

    cmp al, 'R'
    je get_one_string

    jmp invalid_cmd

get_one_string:
    lea dx, msgStr
    mov ah, 09h
    int 21h

    call input
    lea di, str1
    call copy_buffer
    call newline
    
    jmp execute

get_two_strings:
    lea dx, msgStr1
    mov ah, 09h
    int 21h

    call input
    lea di, str1
    call copy_buffer
    call newline

    lea dx, msgStr2
    mov ah, 09h
    int 21h

    call input
    lea di, str2
    call copy_buffer
    call newline

    jmp execute

execute:
    call run
    jmp exit_prog

invalid_cmd:
    lea dx, errCmd
    mov ah, 09h
    int 21h

exit_prog:
    mov ah, 4ch
    int 21h
main endp

; ---------------- Procedures ----------------

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


copy_buffer proc
    push ax
    push bx
    push cx
    push si
    push di

    xor cx, cx
    mov cl, buffer[1] ; Get length read
    lea si, buffer + 2
    
    cmp cx, 0
    je copy_done

copy_loop:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    loop copy_loop

copy_done:
    mov byte ptr [di], '$' ; Null terminate

    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret
copy_buffer endp


run proc
lencheck:
    mov al, func[3]
    cmp al, 'L'
    jnz cmpcheck
    call strlen
    ret

cmpcheck:
    mov al, func[3]
    cmp al, 'C'
    jnz revcheck
    call strcmp
    ret

revcheck:
    mov al, func[3]
    cmp al, 'R'
    jnz error_run
    call strrev
    ret

error_run:
    lea dx, errCmd
    mov ah, 09h
    int 21h
    ret
run endp


strlen proc
    push ax
    push dx
    push si

    mov si, 0
strlenloop:
    mov al, str1[si]
    cmp al, '$'
    jz strlenbreak
    inc si
    jmp strlenloop

strlenbreak:
    lea dx, func
    mov ah, 09h
    int 21h

    mov dl, '('
    mov ah, 02h
    int 21h
    mov dl, '"'
    int 21h
    lea dx, str1
    mov ah, 09h
    int 21h
    mov dl, '"'
    mov ah, 02h
    int 21h
    mov dl, ')'
    int 21h
    mov dl, '='
    int 21h

    mov ax, si
    call print_decimal

    pop si
    pop dx
    pop ax
    ret
strlen endp


strcmp proc
    push ax
    push dx
    push si
    mov si, 0

strcmploop:
    mov ah, str1[si]
    mov al, str2[si]

    cmp ah, '$'
    jz lastcomp
    cmp al, '$'
    jz morethan

    inc si
    cmp ah, al
    jz strcmploop
    jb lessthan      ; Changed js to jb (Jump Below) for unsigned char comparison
    jmp morethan

lastcomp:
    cmp al, '$'
    jnz lessthan
    
    call print_str1_quote
    mov dl, '='
    mov ah, 02h
    int 21h
    call print_str2_quote
    jmp strcmpend

lessthan:
    call print_str1_quote
    mov dl, '<'
    mov ah, 02h
    int 21h
    call print_str2_quote
    jmp strcmpend

morethan:
    call print_str1_quote
    mov dl, '>'
    mov ah, 02h
    int 21h
    call print_str2_quote

strcmpend:
    pop si
    pop dx
    pop ax
    ret
strcmp endp


; Renamed from print_str1 to match the call in strcmp
print_str1_quote proc
    mov dl, '"'
    mov ah, 02h
    int 21h
    lea dx, str1
    mov ah, 09h
    int 21h
    mov dl, '"'
    mov ah, 02h
    int 21h
    ret
print_str1_quote endp


; Renamed from print_str2 to match the call in strcmp
print_str2_quote proc
    mov dl, '"'
    mov ah, 02h
    int 21h
    lea dx, str2
    mov ah, 09h
    int 21h
    mov dl, '"'
    mov ah, 02h
    int 21h
    ret
print_str2_quote endp


strrev proc
    push ax
    push dx
    push si
    push di

    lea dx, func
    mov ah, 09h
    int 21h
    mov dl, '('
    mov ah, 02h
    int 21h
    mov dl, '"'
    int 21h
    lea dx, str1
    mov ah, 09h
    int 21h
    mov dl, '"'
    mov ah, 02h
    int 21h
    mov dl, ')'
    int 21h
    mov dl, '='
    int 21h

    mov si, 0
strlenloop2:
    mov al, str1[si]
    cmp al, '$'
    jz strlenbreak2
    inc si
    jmp strlenloop2

strlenbreak2:
    ; Check for empty string to avoid crash
    cmp si, 0
    je revloopbreak
    
    mov di, 0
    dec si
    
strrevloop:
    mov al, str1[si]
    mov ah, str1[di]
    mov str1[di], al
    mov str1[si], ah
    dec si
    inc di
    cmp si, di
    jz revloopbreak
    js revloopbreak
    jmp strrevloop

revloopbreak:    
    mov dl, '"'
    mov ah, 02h
    int 21h
    lea dx, str1
    mov ah, 09h
    int 21h
    mov dl, '"'
    mov ah, 02h
    int 21h

    pop di
    pop si
    pop dx
    pop ax
    ret
strrev endp


print_decimal proc
    push ax
    push bx
    push cx
    push dx

    ; Removed 'xor ah, ah' here. 
    ; The input number is in the full AX register.
    
    mov bx, 10
    xor cx, cx

div_loop:
    xor dx, dx    ; Clear DX before division
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
    mov ah, 02h
    mov dl, 0Dh
    int 21h
    mov dl, 0Ah
    int 21h
    pop dx
    pop ax
    ret
newline endp

end main