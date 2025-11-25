.MODEL SMALL
.STACK 100h

.DATA
    ; --- Messages ---
    msg_n       DB 10,13, "Enter number of elements (N): $"
    msg_arr     DB 10,13, "Enter sorted numbers: $"
    msg_target  DB 10,13, "Enter target to search: $"
    msg_found   DB 10,13, "Found at Index: $"
    msg_not     DB 10,13, "Element not found!$"
    
    ; --- Variables ---
    arr         DW 50 DUP(0)  ; Array to hold up to 50 integers (Words)
    count       DW 0          ; Number of elements (N)
    target      DW 0          ; The number to find
    
    ; --- Binary Search Indices ---
    lowIdx      DW 0
    highIdx     DW 0
    midIdx      DW 0

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; 1. Input N (Count)
    LEA DX, msg_n
    MOV AH, 09h
    INT 21h
    CALL SCAN_NUM       ; Read input into CX
    MOV count, CX       ; Store in variable

    ; 2. Input Array Elements
    LEA DX, msg_arr
    MOV AH, 09h
    INT 21h
    
    MOV CX, count       ; Set loop counter to N
    MOV SI, 0           ; Array Index (Byte Offset)
    
InputLoop:
    PUSH CX             ; Save Loop Counter
    
    ; Print a newline and some spacing for clarity
    MOV AH, 02h
    MOV DL, 10
    INT 21h
    
    CALL SCAN_NUM       ; Read number into CX
    MOV arr[SI], CX     ; Store in Array
    ADD SI, 2           ; Move to next Word (2 bytes)
    
    POP CX              ; Restore Loop Counter
    LOOP InputLoop

    ; 3. Input Target
    LEA DX, msg_target
    MOV AH, 09h
    INT 21h
    CALL SCAN_NUM
    MOV target, CX

    ; ==========================================
    ; BINARY SEARCH LOGIC STARTS HERE
    ; ==========================================
    
    ; Initialize: low = 0, high = N - 1
    MOV lowIdx, 0
    
    MOV AX, count
    DEC AX              ; High = Count - 1
    MOV highIdx, AX

SearchLoop:
    ; Check if Low > High (Exit Condition)
    MOV AX, lowIdx
    CMP AX, highIdx
    JG NotFound         ; If Low > High, element doesn't exist

    ; Calculate Mid = (Low + High) / 2
    MOV AX, lowIdx
    ADD AX, highIdx
    SHR AX, 1           ; Shift Right by 1 = Divide by 2
    MOV midIdx, AX

    ; Calculate Array Offset: Offset = Mid * 2 (Since DW is 2 bytes)
    MOV SI, midIdx
    ADD SI, SI          ; SI = Mid * 2
    
    ; Compare arr[mid] with target
    MOV BX, arr[SI]
    CMP BX, target
    JE  FoundIt         ; Equal? Found!
    JL  GoRight         ; Array[Mid] < Target? Look in right half
    JG  GoLeft          ; Array[Mid] > Target? Look in left half

GoRight:
    ; Low = Mid + 1
    MOV AX, midIdx
    INC AX
    MOV lowIdx, AX
    JMP SearchLoop

GoLeft:
    ; High = Mid - 1
    MOV AX, midIdx
    DEC AX
    MOV highIdx, AX
    JMP SearchLoop

    ; ==========================================
    ; OUTPUT SECTION
    ; ==========================================

FoundIt:
    LEA DX, msg_found
    MOV AH, 09h
    INT 21h
    
    MOV AX, midIdx      ; Load the index found
    CALL PRINT_NUM      ; Print it
    JMP ExitProg

NotFound:
    LEA DX, msg_not
    MOV AH, 09h
    INT 21h

ExitProg:
    MOV AH, 4Ch
    INT 21h

MAIN ENDP

; ==========================================
; PROCEDURE: SCAN_NUM
; Inputs a decimal number from keyboard into CX
; ==========================================
SCAN_NUM PROC
    PUSH AX
    PUSH BX
    PUSH DX

    MOV CX, 0       ; Result accumulator
    MOV BX, 10      ; Multiplier (base 10)

ScanStart:
    MOV AH, 01h     ; Read char
    INT 21h
    
    CMP AL, 13      ; Check for Enter key
    JE ScanDone
    CMP AL, ' '     ; Check for Space
    JE ScanDone
    
    SUB AL, '0'     ; Convert ASCII to Integer
    MOV AH, 0       ; Clear upper half of AX
    
    PUSH AX         ; Save the digit
    MOV AX, CX      ; Move current total to AX
    MUL BX          ; AX = Total * 10
    MOV CX, AX      ; Move back to CX
    POP AX          ; Restore digit
    ADD CX, AX      ; CX = (Total * 10) + Digit
    
    JMP ScanStart

ScanDone:
    POP DX
    POP BX
    POP AX
    RET
SCAN_NUM ENDP

; ==========================================
; PROCEDURE: PRINT_NUM
; Prints value in AX as decimal digits
; ==========================================
PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, 0       ; Counter for digits
    MOV BX, 10      ; Divisor

SplitDigits:
    MOV DX, 0       ; Clear DX for division
    DIV BX          ; AX / 10 -> AX=Quotient, DX=Remainder
    PUSH DX         ; Save remainder (digit) on stack
    INC CX          ; Increase count
    CMP AX, 0       ; Is quotient 0?
    JNE SplitDigits

PrintDigits:
    POP DX          ; Get digit back
    ADD DL, '0'     ; Convert to ASCII
    MOV AH, 02h
    INT 21h
    LOOP PrintDigits

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUM ENDP

END MAIN