; STACK SEGMENT
STACK           SEGMENT     PARA STACK
STACK_AREA      DW          100 DUP(?)
STACK_BOTTOM    EQU         $ - STACK_AREA
STACK           ENDS

; DATA SEGMENT
DATA            SEGMENT     PARA
STRING1         DB          40 DUP(?)
LEN             EQU         20
IN_BUF          DB          LEN-1
                DB          ?
STRING2         DB          LEN DUP(?)

CRLF            DB          0DH, 0AH, '$'
SPACE           DB          ' ', '$'
TAB             DB          9, '$'
DATA            ENDS

; CODE SEGMENT
CODE            SEGMENT     PARA
                ASSUME      CS:CODE, DS:DATA, SS:STACK, ES:DATA

; PRINT MACRO
PRINT           MACRO       MSG
                PUSH        AX
                PUSH        DX
                MOV         DX, OFFSET MSG
                MOV         AH, 9
                INT         21H
                POP         DX
                POP         AX
                ENDM

; PRINTLN MACRO
PRINTLN         MACRO       MSG
                PRINT       MSG
                PRINT       CRLF
                ENDM

; GETS SUB PROCEDURE (AX = OFFSET IN_BUF)
GETS            PROC        NEAR
                PUSH        SI
                ; PUSH        AX
                PUSH        CX
                PUSH        DX
                
                ; MOV         DX, OFFSET IN_BUF
                MOV         DX, AX
                MOV         AH, 0AH
                INT         21H

                MOV         CL, IN_BUF+1
                XOR         CH, CH
                MOV         SI, OFFSET STRING2
                ADD         SI, CX
                MOV         BYTE PTR [SI], '$'
                PRINT       CRLF            ; i don't know why this is needed
                                            ; but without it, the program doesn't work
                POP         DX
                POP         CX
                ; POP         AX
                POP         SI
                RET
GETS            ENDP

; STRLEN MACRO
STRLEN          MACRO
                LOCAL       SL_START, SL_END
                PUSH        SI
                PUSH        AX
                MOV         CX, 0
SL_START:       LODSB
                CMP         AL, '$'
                JE          SL_END      ; AL = '$'
                CMP         AL, 0
                JE          SL_END      ; AL = 0
                CMP         AL, 0DH
                JE          SL_END      ; AL = 0DH
                INC         CX
                JMP         SL_START
SL_END:         POP         AX
                POP         SI
                ENDM

; STRCPY SUB PROCEDURE
STRCPY          PROC        NEAR            ; DS:SI = src, ES:DI = dst
                PUSH        CX
                
                STRLEN
                CMP         SI, DI
                JAE         .FORWARD

.BACKWORD:      STD
                ADD         SI, CX
                ADD         DI, CX
                INC         CX              ; this is aim to move the str with the terminator
                ; DEC         SI
                ; DEC         DI
                REP         MOVSB
                CLD
                JMP         .MMEND

.FORWARD:       CLD
                INC         CX              ; this is aim to move the str with the terminator
                REP         MOVSB

.MMEND:         POP         CX
                RET
STRCPY          ENDP 

; STRCAT SUB PROCEDURE
STRCAT          PROC        NEAR            ; DS:SI = src, ES:DI = dst
                PUSH        CX

                PUSH        SI
                MOV         SI, DI
                STRLEN
                POP         SI
                ADD         DI, CX
                CALL        STRCPY
                
                POP         CX
                RET
STRCAT          ENDP

; MAIN PROCEDURE
MAIN            PROC        FAR
                MOV         AX, STACK
                MOV         SS, AX
                MOV         SP, STACK_BOTTOM
                MOV         AX, DATA
                MOV         DS, AX
                MOV         ES, AX              ; DS = ES

                ; GENERATE STRING1
                MOV         SI, OFFSET STRING1
                MOV         BYTE PTR [SI], '2'
                MOV         BYTE PTR [SI+1], '1'
                MOV         BYTE PTR [SI+2], '3'
                MOV         BYTE PTR [SI+3], '7'
                MOV         BYTE PTR [SI+4], '1'
                MOV         BYTE PTR [SI+5], '2'
                MOV         BYTE PTR [SI+6], '4'
                MOV         BYTE PTR [SI+7], '8'
                MOV         BYTE PTR [SI+8], '$'

                ; GETS(IN_BUF)
                MOV         AX, OFFSET IN_BUF
                CALL        GETS

                ; STRCAT(STRING2, STRING1)
                MOV         SI, OFFSET STRING2
                MOV         DI, OFFSET STRING1
                CALL        STRCAT

                ; PRINTLN(STRING1)
                PRINTLN     STRING1

; EXIT
EXIT:           MOV         AX, 4C00H
                INT         21H
MAIN            ENDP
CODE            ENDS
                END         MAIN                
