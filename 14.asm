.model small
.stack 100h

.data
    prompt_filename   db 'Enter the filename: $'
    msg_error         db 0dh, 0ah, 'Error: File not found or could not be opened.$'
    msg_chars         db 0dh, 0ah, 'Characters: $'
    msg_words         db 0dh, 0ah, 'Words     : $'
    msg_lines         db 0dh, 0ah, 'Lines     : $'

    filename_buffer   label byte
    max_len           db 255
    actual_len        db ?
    filename          db 255 dup(0)

    file_handle       dw ?
    read_buffer       db 512 dup(?)

    char_count        dw 0
    word_count        dw 0
    line_count        dw 0

    in_word_flag      db 0

.code
main proc
    mov ax, @data
    mov ds, ax

    lea dx, prompt_filename
    mov ah, 09h
    int 21h

    lea dx, filename_buffer
    mov ah, 0ah
    int 21h

    mov bh, 0
    mov bl, actual_len
    mov filename[bx], 0

    lea dx, filename
    mov al, 0
    mov ah, 3dh
    int 21h

    jc label1
    mov file_handle, ax
    jmp read_loop

label1:
    jmp file_open_error

read_loop:
    mov bx, file_handle
    lea dx, read_buffer
    mov cx, 512
    mov ah, 3fh
    int 21h

    cmp ax, 0
    je end_of_file

    mov cx, ax
    mov si, 0

process_char:
    mov al, read_buffer[si]

    inc char_count

    cmp al, 0ah
    jne not_a_newline
    inc line_count

not_a_newline:
    cmp al, ' '
    je is_delimiter
    cmp al, 09h
    je is_delimiter
    cmp al, 0dh
    je is_delimiter
    cmp al, 0ah
    je is_delimiter
    jmp not_a_delimiter

is_delimiter:
    cmp in_word_flag, 1
    jne end_char_loop
    inc word_count
    mov in_word_flag, 0
    jmp end_char_loop

not_a_delimiter:
    mov in_word_flag, 1

end_char_loop:
    inc si
    loop process_char

    jmp read_loop

end_of_file:
    cmp in_word_flag, 1
    jne no_final_word
    inc word_count

no_final_word:
    cmp char_count, 0
    je close_file
    cmp line_count, 0
    jne close_file
    mov line_count, 1

close_file:
    mov bx, file_handle
    mov ah, 3eh
    int 21h

    lea dx, msg_chars
    mov ah, 09h
    int 21h
    mov ax, char_count
    call print_num

    lea dx, msg_words
    mov ah, 09h
    int 21h
    mov ax, word_count
    call print_num

    lea dx, msg_lines
    mov ah, 09h
    int 21h
    mov ax, line_count
    call print_num

    jmp exit_program

file_open_error:
    lea dx, msg_error
    mov ah, 09h
    int 21h

exit_program:
    mov ah, 4ch
    int 21h

main endp

print_num proc
    mov cx, 0
    mov bx, 10

convert_loop:
    mov dx, 0
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne convert_loop

print_loop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_loop

    ret
print_num endp

end main