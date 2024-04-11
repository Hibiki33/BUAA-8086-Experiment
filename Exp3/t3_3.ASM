; STACK SEGMENT
STACK           SEGMENT     PARA STACK
STACK_AREA      DW          100 DUP(?)
STACK_BOTTOM    EQU         $ - STACK_AREA
STACK           ENDS

; DATA SEGMENT
DATA            SEGMENT     PARA
LEN             EQU         64
IN_BUF          DB          LEN-1
                DB          ?
STRING          DB          LEN DUP(?)

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
                MOV         SI, OFFSET STRING
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

; FIND SUB PROCEDURE (AL = char to find, SI = offset of string, CX = length of string)
FIND            PROC        NEAR
                PUSH        BX
                PUSH        DX
                PUSH        DI
                MOV         BL, AL
                MOV         DX, 0
.LP:            PUSH        CX
                LODSB
                CMP         AL, BL
                JNE         .NEXT
                INC         DX
.NEXT:          POP         CX
                LOOP        .LP                
                MOV         AX, DX
                POP         DI
                POP         DX
                POP         BX
                RET
FIND            ENDP

; PRINT_NUM PROCEDURE : print a number (AX) to the screen
PRINT_NUM       PROC        NEAR       
                PUSH        SI
                PUSH        DX
                PUSH        BX

                MOV         SI, 0
                MOV         BX, 10

.LP1:           XOR         DX, DX
                DIV         BX
                PUSH        DX
                INC         SI
                CMP         AX, 0
                JNZ         .LP1

.LP2:           POP         DX
                XOR         DH, DH
                ADD         DL, 30H
                MOV         AH, 2
                INT         21H
                DEC         SI
                CMP         SI, 0
                JNZ         .LP2

PN_RT:          POP         BX
                POP         DX
                POP         SI
                RET
PRINT_NUM       ENDP

; MAIN PROCEDURE
MAIN            PROC        FAR
                MOV         AX, STACK
                MOV         SS, AX
                MOV         SP, STACK_BOTTOM
                MOV         AX, DATA
                MOV         DS, AX
                MOV         ES, AX              ; DS = ES

                CALL        GETS
                MOV         SI, OFFSET STRING
                MOV         CL, IN_BUF+1
                XOR         CH, CH
                MOV         AL, 'a'
                CALL        FIND
                CALL        PRINT_NUM

; EXIT
EXIT:           MOV         AX, 4C00H
                INT         21H
MAIN            ENDP
CODE            ENDS
                END         MAIN                
