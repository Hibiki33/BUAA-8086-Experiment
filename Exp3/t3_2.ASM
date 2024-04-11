; STACK SEGMENT
STACK           SEGMENT     PARA STACK
STACK_AREA      DW          100 DUP(?)
STACK_BOTTOM    EQU         $ - STACK_AREA
STACK           ENDS

; DATA SEGMENT
DATA            SEGMENT     PARA
STRING1         DB          '@1jLP4&', '$'
LEN             EQU         20
IN_BUF          DB          LEN-1
                DB          ?
STRING2         DB          LEN DUP(?)

CRLF            DB          0DH, 0AH, '$'
SPACE           DB          ' ', '$'
TAB             DB          9, '$'

GT_CH           DB          '>', '$'
LT_CH           DB          '<', '$'
EQ_CH           DB          '=', '$'
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

; STRCMP SUB PROCEDURE  (AX = 0 if equal, 1 if greater, 0FFFFH if less)
STRCMP          PROC        NEAR
                CLD
.LP:            LODSB
                CMP         AL, ES:[DI]
                JA          .GT
                JB          .LT
                CMP         AL, 0
                JZ          .EQ
                INC         DI
                JMP         SHORT .LP
.GT:            MOV         AX, 1
                JMP         SHORT .END
.LT:            MOV         AX, 0FFFFH
                JMP         SHORT .END
.EQ:            XOR         AX, AX
.END:           RET
STRCMP          ENDP

; GETS SUB PROCEDURE
GETS            PROC        NEAR
                PUSH        SI
                PUSH        AX
                PUSH        CX
                PUSH        DX
                
                MOV         DX, OFFSET IN_BUF
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
                POP         AX
                POP         SI
                RET
GETS            ENDP

; MAIN PROCEDURE
MAIN            PROC        FAR
                MOV         AX, STACK
                MOV         SS, AX
                MOV         SP, STACK_BOTTOM
                MOV         AX, DATA
                MOV         DS, AX
                MOV         ES, AX              ; DS = ES

                CALL        GETS
                CALL        STRCMP
                CMP         AX, 0
                PRINT       STRING1
                JE          L3
                JL          L2
L1:             PRINT       GT_CH         
                JMP         SHORT L4
L2:             PRINT       LT_CH
                JMP         SHORT L4
L3:             PRINT       EQ_CH
L4:             PRINTLN     STRING2

; EXIT
EXIT:           MOV         AX, 4C00H
                INT         21H
MAIN            ENDP
CODE            ENDS
                END         MAIN                
