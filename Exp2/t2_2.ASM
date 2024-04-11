STACK           SEGMENT     PARA STACK
STACK_AREA      DW          100 DUP(?)
STACK_BOTTOM    EQU         $ - STACK_AREA
STACK           ENDS

DATA            SEGMENT     PARA
DATA            ENDS

CODE            SEGMENT     PARA
                ASSUME      CS:CODE, DS:DATA, SS:STACK

; GET MACRO : get a byte from the keyboard (to AL)
GET             MACRO  
                MOV         AH, 1
                INT         21H
                ENDM

; GET_NUM PROCEDURE : get a number from the keyboard (to AX)
GET_NUM         PROC
                
                PUSH        SI
                PUSH        DX
                PUSH        BX

                MOV         SI, 0
                MOV         BX, 10
                
LP:             GET
                CMP         AL, 0DH     ; ENTER
                JE          GN_RT                
                CMP         AL, 30H     
                JB          LP          ; < '0'
                CMP         AL, 39H     
                JA          LP          ; > '9'

                SUB         AL, 30H
                XOR         AH, AH
                PUSH        AX
                MOV         AX, SI
                MUL         BX
                MOV         SI, AX
                POP         AX
                ADD         SI, AX
                LOOP        LP

GN_RT:          MOV         AX, SI                
                POP         BX
                POP         DX
                POP         SI
                RET 
GET_NUM         ENDP

; PRINT MACRO : print a byte (from dl) to the screen
PRINT           MACRO       
                MOV         AH, 2
                INT         21H
                ENDM

; PRINT_NUM PROCEDURE : print a number (AX) to the screen
PRINT_NUM       PROC
                
                PUSH        SI
                PUSH        DX
                PUSH        BX

                MOV         SI, 0
                MOV         BX, 10

LP1:            XOR         DX, DX
                DIV         BX
                PUSH        DX
                INC         SI
                CMP         AX, 0
                JNZ         LP1

LP2:            POP         DX
                XOR         DH, DH
                ADD         DL, 30H
                PRINT
                DEC         SI
                CMP         SI, 0
                JNZ         LP2

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

                CALL        GET_NUM
                MOV         BX, AX 
                CALL        GET_NUM
                MUL         BX
                CALL        PRINT_NUM

; EXIT
EXIT:           MOV         AX, 4C00H
                INT         21H
MAIN            ENDP
CODE            ENDS
                END         MAIN

