; STACK SEGMENT
STACK           SEGMENT     PARA STACK
STACK_AREA      DW          100 DUP(?)
STACK_BOTTOM    EQU         $ - STACK_AREA
STACK           ENDS

; DATA SEGMENT
DATA            SEGMENT     PARA

                DB          16 DUP('x')
STRING1         DB          'WangJiajun', '$'

                DB          8 DUP('x')
STRING2         DB          'WangJiajun', '$'

STRING3         DB          'WangJiajun', '$'
                DB          8 DUP('x')

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

; MEMMOVE SUB PROCEDURE
MEMMOVE         PROC        NEAR            ; DS:SI = src, ES:DI = dst
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

.MMEND:         RET
MEMMOVE         ENDP 

; MAIN PROCEDURE
MAIN            PROC        FAR
                MOV         AX, STACK
                MOV         SS, AX
                MOV         SP, STACK_BOTTOM
                MOV         AX, DATA
                MOV         DS, AX
                MOV         ES, AX              ; DS = ES

; STEP-1
                PRINTLN     STRING1
                MOV         SI, OFFSET STRING1
                MOV         DI, OFFSET STRING1-16
                CALL        MEMMOVE
                PRINT       STRING1
                PRINT       SPACE
                PRINTLN     STRING1-16

; STEP-2
                PRINTLN     STRING1
                MOV         SI, OFFSET STRING2
                MOV         DI, OFFSET STRING2-8
                CALL        MEMMOVE
                PRINT       STRING2
                PRINT       SPACE
                PRINTLN     STRING2-8

; STEP-3 
                PRINTLN     STRING1
                MOV         SI, OFFSET STRING3
                MOV         DI, OFFSET STRING3+6
                CALL        MEMMOVE
                PRINT       STRING3
                PRINT       SPACE
                PRINTLN     STRING3+6

; EXIT
EXIT:           MOV         AX, 4C00H
                INT         21H
MAIN            ENDP
CODE            ENDS
                END         MAIN                
