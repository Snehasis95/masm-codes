.model small
.stack 100h

.data
    str     db 50, ?, 50 dup('$')
    subst   db 50, ?, 50 dup('$')
    
    prompt1 db "Enter string: $"
    prompt2 db "Enter substring: $"
    
    msg1    db "Substring occurs in string $"
    msg2    db " times$"

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Input Main String
    lea ax, prompt1
    lea dx, str
    call input
    
    ; Input Substring
    lea ax, prompt2
    lea dx, subst
    call input
    
    lea dx, msg1
    mov ah, 09h
    int 21h
    
    ; Perform Check
    call check
    ; Result is now in AX
    
    call print_decimal
    
    lea dx, msg2
    mov ah, 09h
    int 21h

    mov ah, 4ch
    int 21h
main endp

; ------------------------------------------------
; CHECK PROCEDURE
; Counts occurrences of subst in str
; Output: Count in AX
; ------------------------------------------------
check proc
    push bx
    push cx
    push dx
    push si
    push di

    xor bx, bx          ; BX = Total Count = 0

    ; Check lengths
    xor cx, cx
    mov cl, str[1]      ; CL = Main Length
    cmp cl, 0
    je end_check        ; If empty, exit

    xor ax, ax
    mov al, subst[1]    ; AL = Sub Length
    cmp al, 0
    je end_check        ; If empty, exit

    cmp cl, al          ; If Main Len < Sub Len
    jb end_check        ; Cannot contain substring, exit

    ; Calculate Outer Loop Count: (StrLen - SubLen) + 1
    sub cl, al
    inc cl              ; CL = Number of positions to check

    lea si, str + 2     ; SI points to start of main string text

outer_loop:
    push cx             ; Save outer loop counter
    push si             ; Save current position in main string
    
    lea di, subst + 2   ; DI points to start of substring
    mov ch, 0
    mov cl, subst[1]    ; Inner loop count = Substring length

inner_loop:
    mov dh, [si]        ; Char from Main
    mov dl, [di]        ; Char from Sub
    
    cmp dh, dl
    jne mismatch        ; If chars don't match, break inner loop

    inc si
    inc di
    loop inner_loop

    ; If we fall through here, Inner Loop finished = MATCH FOUND
    inc bx              ; Increment Total Count

mismatch:
    pop si              ; Restore main string position
    pop cx              ; Restore outer loop counter
    
    inc si              ; Move to next character in main string
    loop outer_loop     ; Repeat

end_check:
    mov ax, bx          ; Move result (BX) to AX for printing
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret
check endp

; ------------------------------------------------
; INPUT PROCEDURE
; AX = Prompt Offset, DX = Buffer Offset
; ------------------------------------------------
input proc
    push ax
    push dx
    push cx

    push dx         ; Save Buffer Address
    
    mov dx, ax      ; Move Prompt to DX
    mov ah, 09h
    int 21h

    pop dx          ; Restore Buffer Address
    mov ah, 0ah
    int 21h

    call newline

    pop cx
    pop dx
    pop ax
    ret
input endp

; ------------------------------------------------
; PRINT DECIMAL
; Prints value in AX
; ------------------------------------------------
print_decimal proc
    push ax
    push bx
    push cx
    push dx

    ; Note: Do NOT XOR AH, AH here. We want the full 16-bit number from AX.
    
    mov bx, 10
    xor cx, cx

div_loop:
    xor dx, dx      ; Clear high word for div
    div bx          ; AX / 10, Remainder in DX
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