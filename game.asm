.MODEL SMALL
.STACK 100h

.DATA
maze DB "####################",13,10
     DB "#   ##     ##      #",13,10
     DB "# ##  ## ##  ## ## #",13,10
     DB "#    ##      ##   E#",13,10
     DB "##  ##  ## ##  ## ##",13,10
     DB "#  ##      ##  ##  #",13,10
     DB "# ##   ## ## ## ## #",13,10
     DB "#     ##     ##    #",13,10
     DB "## ## ##  # ## ## ##",13,10
     DB "#    ##      ##    #",13,10
     DB "# ## ## # ## ## ## #",13,10
     DB "# ## ## # ##       #",13,10
     DB "####################",0

;FINAL CODE PEANLTY IMPLEMENTED
; ---- Players ----
player1X DW 3
player1Y DW 3
player2X DW 5
player2Y DW 5

NewX DW 0
NewY DW 0
MAZE_LINE DW 22

; ---- Counters ----
moveCount1 DW 0    
moveCount2 DW 0
plentyCount DW 0     ;  Penalty counter

moveLabel1 DB "P1 Moves: $"
moveLabel2 DB "         P2 Moves: $"
plentyLabel DB "         Collision Penalty: $"

; ---- Messages ----
WinMsgP1 DB 13,10,"Player 1 (@) wins!",13,10,'$'
WinMsgP2 DB 13,10,"Player 2 (*) wins!",13,10,'$'
PromptMsg DB "              Press R to replay",13,10,'$'

; ---- Final Score Labels ----
p1FinalLabel DB 13,10,"P1 Final Score (Moves + Penalty): $"
p2FinalLabel DB 13,10,"P2 Final Score (Moves + Penalty): $"

.CODE
MAIN PROC
    MOV AX,@DATA
    MOV DS,AX

StartGame:
    MOV moveCount1,0
    MOV moveCount2,0
    MOV plentyCount,0
    CALL DrawMaze
    CALL PlacePlayers
    CALL ShowMoveCount

GameLoop:
    MOV AH,01h
    INT 16h
    JZ GameLoop      ; wait for key

    MOV AH,00h
    INT 16h

    CMP AL,0
    JE CheckArrowKeys

    ; ---------- WASD for Player 2 ----------
    CMP AL,'W'
    JE P2Up
    CMP AL,'w'
    JE P2Up
    CMP AL,'S'
    JE P2Down
    CMP AL,'s'
    JE P2Down
    CMP AL,'A'
    JE P2Left
    CMP AL,'a'
    JE P2Left
    CMP AL,'D'
    JE P2Right
    CMP AL,'d'
    JE P2Right
    JMP GameLoop

; ---- Arrow keys (Player 1) ----
CheckArrowKeys:
    CMP AH,72
    JE P1Up
    CMP AH,80
    JE P1Down
    CMP AH,75
    JE P1Left
    CMP AH,77
    JE P1Right
    JMP GameLoop

; ---- Player 1 movement ----
P1Up:    MOV CX,player1Y
         MOV DX,player1X
         DEC CX
         JMP MoveP1
P1Down:  MOV CX,player1Y
         MOV DX,player1X
         INC CX
         JMP MoveP1
P1Left:  MOV CX,player1Y
         MOV DX,player1X
         DEC DX
         JMP MoveP1
P1Right: MOV CX,player1Y
         MOV DX,player1X
         INC DX
         JMP MoveP1

; ---- Player 2 movement ----
P2Up:    MOV CX,player2Y
         MOV DX,player2X
         DEC CX
         JMP MoveP2
P2Down:  MOV CX,player2Y
         MOV DX,player2X
         INC CX
         JMP MoveP2
P2Left:  MOV CX,player2Y
         MOV DX,player2X
         DEC DX
         JMP MoveP2
P2Right: MOV CX,player2Y
         MOV DX,player2X
         INC DX
         JMP MoveP2

; ----------------------------
; Move Player 1
MoveP1:
    MOV NewY,CX
    MOV NewX,DX
    CALL MovePlayer1
    JMP GameLoop

; Move Player 2
MoveP2:
    MOV NewY,CX
    MOV NewX,DX
    CALL MovePlayer2
    JMP GameLoop

; ------------------------
DrawMaze PROC
    MOV AH,06h
    MOV AL,0
    MOV BH,07h
    MOV CH,0
    MOV CL,0
    MOV DH,24
    MOV DL,79
    INT 10h

    MOV AH,02h
    MOV BH,0
    MOV DH,0
    MOV DL,0
    INT 10h

    MOV SI,OFFSET maze
PrintLoop:
    LODSB
    CMP AL,0
    JE DoneMaze
    MOV AH,0Eh
    INT 10h
    JMP PrintLoop
DoneMaze:
    RET
DrawMaze ENDP

; ------------------------
PlacePlayers PROC
    MOV AX,player1Y
    MOV BX,player1X
    CALL GotoXY
    MOV AH,0Eh
    MOV AL,'@'
    INT 10h

    MOV AX,player2Y
    MOV BX,player2X
    CALL GotoXY
    MOV AH,0Eh
    MOV AL,'*'
    INT 10h
    RET
PlacePlayers ENDP

; ------------------------
; --- Move Player 1 ---
MovePlayer1 PROC
    MOV AX,NewY
    MOV BX,22
    MUL BX
    ADD AX,NewX
    MOV SI,OFFSET maze
    ADD SI,AX
    MOV AL,[SI]

    CMP AL,'#'
    JE CantMove1
    CMP AL,'E'
    JE WinGameP1

    ; --- COLLISION CHECK ---
    MOV AX,NewX
    CMP AX,player2X
    JNE NotCollision1_X
    MOV AX,NewY
    CMP AX,player2Y
    JNE NotCollision1_X

    ;  Both players collide
    INC moveCount1
    INC moveCount2
    INC plentyCount
    CALL ShowMoveCount
    RET

NotCollision1_X:
    ; --- Normal Move ---
    MOV AX,player1Y
    MOV BX,player1X
    CALL GotoXY
    MOV AH,0Eh
    MOV AL,' '
    INT 10h

    MOV AX,NewY
    MOV BX,NewX
    CALL GotoXY
    MOV AH,0Eh
    MOV AL,'@'
    INT 10h

    MOV AX,NewX
    MOV player1X,AX
    MOV AX,NewY
    MOV player1Y,AX
    INC moveCount1
    CALL ShowMoveCount

CantMove1:
    RET

WinGameP1:
    CALL ShowWinScreenP1
    JMP HandleReplay
MovePlayer1 ENDP

; ------------------------
; --- Move Player 2 ---
MovePlayer2 PROC
    MOV AX,NewY
    MOV BX,22
    MUL BX
    ADD AX,NewX
    MOV SI,OFFSET maze
    ADD SI,AX
    MOV AL,[SI]

    CMP AL,'#'
    JE CantMove2
    CMP AL,'E'
    JE WinGameP2

    ; --- COLLISION CHECK ---
    MOV AX,NewX
    CMP AX,player1X
    JNE NotCollision2_X
    MOV AX,NewY
    CMP AX,player1Y
    JNE NotCollision2_X

    ;  Both players collide
    INC moveCount1
    INC moveCount2
    INC plentyCount
    CALL ShowMoveCount
    RET

NotCollision2_X:
    ; --- Normal Move ---
    MOV AX,player2Y
    MOV BX,player2X
    CALL GotoXY
    MOV AH,0Eh
    MOV AL,' '
    INT 10h

    MOV AX,NewY
    MOV BX,NewX
    CALL GotoXY
    MOV AH,0Eh
    MOV AL,'*'
    INT 10h

    MOV AX,NewX
    MOV player2X,AX
    MOV AX,NewY
    MOV player2Y,AX
    INC moveCount2
    CALL ShowMoveCount

CantMove2:
    RET

WinGameP2:
    CALL ShowWinScreenP2
    JMP HandleReplay
MovePlayer2 ENDP

; ------------------------
ShowWinScreenP1 PROC
    CALL ClearScreen
    MOV DX,OFFSET WinMsgP1
    MOV AH,09h
    INT 21h
    JMP CommonWin
ShowWinScreenP1 ENDP

ShowWinScreenP2 PROC
    CALL ClearScreen
    MOV DX,OFFSET WinMsgP2
    MOV AH,09h
    INT 21h
    JMP CommonWin
ShowWinScreenP2 ENDP

; ------------------------
CommonWin:
    MOV DX,OFFSET PromptMsg
    MOV AH,09h
    INT 21h
    CALL ShowMoveCount

    ; ---- Show Final Scores ----
    MOV AH,09h
    LEA DX,p1FinalLabel
    INT 21h
    MOV AX,moveCount1
    ADD AX,plentyCount
    CALL PrintNumber

    MOV AH,09h
    LEA DX,p2FinalLabel
    INT 21h
    MOV AX,moveCount2
    ADD AX,plentyCount
    CALL PrintNumber

    RET

; ------------------------
ClearScreen PROC
    MOV AH,06h
    MOV AL,0
    MOV BH,07h
    MOV CH,0
    MOV CL,0
    MOV DH,24
    MOV DL,79
    INT 10h
    RET
ClearScreen ENDP

; ------------------------
HandleReplay:
    MOV AH,0
    INT 16h
    CMP AL,'R'
    JE RestartGame
    CMP AL,'r'
    JE RestartGame
    CMP AL,'E'
    JE ExitGame
    CMP AL,'e'
    JE ExitGame
    JMP HandleReplay

RestartGame:
    MOV player1X,3
    MOV player1Y,3
    MOV player2X,5
    MOV player2Y,5
    MOV moveCount1,0
    MOV moveCount2,0
    MOV plentyCount,0
    JMP StartGame

ExitGame:
    MOV AH,4Ch
    INT 21h

; ------------------------
GotoXY PROC
    MOV DH,AL
    MOV DL,BL
    MOV BH,0
    MOV AH,02h
    INT 10h
    RET
GotoXY ENDP

; ------------------------
ShowMoveCount PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    ; ---- Player 1 ----
    MOV AH,02h
    MOV BH,0
    MOV DH,23
    MOV DL,0
    INT 10h
    MOV AH,09h
    LEA DX,moveLabel1
    INT 21h
    MOV AX,moveCount1
    CALL PrintNumber

    ; ---- Player 2 ----
    MOV AH,02h
    MOV BH,0
    MOV DH,23
    MOV DL,40
    INT 10h
    MOV AH,09h
    LEA DX,moveLabel2
    INT 21h
    MOV AX,moveCount2
    CALL PrintNumber

    ; ---- Penalty Counter ----
    MOV AH,02h
    MOV BH,0
    MOV DH,24
    MOV DL,0
    INT 10h
    MOV AH,09h
    LEA DX,plentyLabel
    INT 21h
    MOV AX,plentyCount
    CALL PrintNumber

    POP DX
    POP CX
    POP BX
    POP AX
    RET
ShowMoveCount ENDP

; ------------------------
PrintNumber PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV CX,0
    MOV BX,10
ConvertLoop:
    XOR DX,DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX,0
    JNE ConvertLoop
PrintLoop1:
    POP DX
    ADD DL,'0'
    MOV AH,02h
    INT 21h
    LOOP PrintLoop1
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PrintNumber ENDP

END MAIN
