.model small
.stack 100h

.data
    inputFileName    db "input.txt",0
    outputFileName   db "output.txt",0

    buffer db 512 dup(?)      ; for reading file text

    primeMsg db "Prime numbers written to output.txt",13,10,'$'

.code

main proc
    mov ax, @data
    mov ds, ax

    ; ─────── OPEN INPUT FILE ───────
    mov ah, 3Dh
    mov al, 0          ; read-only
    mov dx, offset inputFileName
    int 21h
    jc file_error
    mov bx, ax         ; input file handle

    ; ─────── CREATE OUTPUT FILE ───────
    mov ah, 3Ch
    mov cx, 0
    mov dx, offset outputFileName
    int 21h
    jc file_error
    mov si, ax         ; output file handle (in SI)

    ; ─────── READ FILE CONTENT ───────
read_data:
    mov ah, 3Fh
    mov cx, 512
    mov dx, offset buffer
    int 21h
    or ax, ax
    jz done           ; EOF

    mov di, offset buffer

parse_loop:
    ; Skip spaces and newlines
skip_spaces:
    cmp byte ptr [di], 0
    je read_data
    cmp byte ptr [di], ' '
    je inc_di
    cmp byte ptr [di], 13
    je inc_di
    cmp byte ptr [di], 10
    je inc_di
    jmp get_number
inc_di:
    inc di
    jmp skip_spaces

get_number:
    xor ax, ax        ; AX = number
digit_read:
    cmp byte ptr [di], '0'
    jl check_prime
    cmp byte ptr [di], '9'
    jg check_prime
    mov bl, [di]
    sub bl, '0'
    mov bh, 0
    mov cx, 10
    mul cx
    add ax, bx
    inc di
    jmp digit_read

check_prime:
    mov dx, ax       ; keep number in DX
    cmp dx, 2
    jl parse_loop
    mov cx, 2
prime_test:
    mov ax, dx
    xor si, si
    div cx
    cmp si, 0
    je not_prime
    inc cx
    mov ax, cx
    mul ax
    cmp ax, dx
    jbe prime_test

; ─────── WRITE PRIME TO OUTPUT ───────
write_prime:
    mov ax, dx
    call write_number
    jmp parse_loop

not_prime:
    jmp parse_loop

done:
    ; Close files
    mov ah, 3Eh
    mov bx, si
    int 21h
    mov ah, 3Eh
    mov bx, si
    int 21h

    ; Print message
    mov ah, 09h
    mov dx, offset primeMsg
    int 21h

    mov ah, 4Ch
    int 21h

file_error:
    mov ah, 09h
    mov dx, offset primeMsg
    int 21h
    mov ah, 4Ch
    int 21h
main endp


;-----------------------------------------
; write_number: AX contains number
; writes AX as ASCII and adds space
;-----------------------------------------
write_number proc
    push ax
    push bx
    push cx
    push dx

    mov bx, 10
    xor cx, cx
div_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne div_loop

print_loop:
    pop dx
    add dl, '0'
    mov ah, 40h
    mov bx, si
    mov cx, 1
    int 21h
    loop print_loop

    ; write a space
    mov dl, ' '
    mov ah, 40h
    mov bx, si
    mov cx, 1
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
write_number endp

end main
