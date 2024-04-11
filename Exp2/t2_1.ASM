STACK           SEGMENT     PARA STACK
STACK_AREA      DW          100 DUP(?)
STACK_BOTTOM    EQU         $ - STACK_AREA
STACK           ENDS

DATA            SEGMENT     PARA
TABLE_LEN       DW          16
TABLE           DW          2137h, 1248h, 400, 10, 20, 0, 1, 8
                DW          41h, 40, 42h, 50, 60, 0ffffh, 2, 2000h
RESULT          DB          5 DUP(?), 20H, '$'
NEW_LINE        DB          0dh, 0ah, '$'
DATA            ENDS

CODE            SEGMENT     PARA
                ASSUME      CS:CODE, DS:DATA, SS:STACK

; PRINT MACRO
PRINT           MACRO       MSG
                MOV         DX, OFFSET MSG
                MOV         AH, 9
                INT         21H
                ENDM

; PRINT_TABLE MACRO
PRINT_TABLE     MACRO   
                LOCAL       LP, SUB_LP

                MOV         CX, TABLE_LEN
                MOV         SI, OFFSET TABLE
                
LP:             PUSH        CX
                MOV         CX, 5
                MOV         DI, OFFSET RESULT + 4
                MOV         AX, [SI]
                MOV         BX, 10

SUB_LP:         XOR         DX, DX
                DIV         BX
                OR          DL, 30H
                MOV         [DI], DL
                DEC         DI
                LOOP        SUB_LP

                PRINT       RESULT
                INC         SI
                INC         SI
                POP         CX
                LOOP        LP
                ENDM                  

; MAIN PROCEDURE
MAIN            PROC        FAR
                MOV         AX, STACK
                MOV         SS, AX
                MOV         SP, STACK_BOTTOM
                MOV         AX, DATA
                MOV         DS, AX

; PART1
                PRINT_TABLE
                PRINT       NEW_LINE

; PART2
                MOV         CX, TABLE_LEN
                DEC         CX
BUBBLE_LP:      MOV         BX, 1
                MOV         SI, OFFSET TABLE
                PUSH        CX

BUBBLE_SUB_LP:  MOV         AX, [SI]
                CMP         AX, [SI + 2]
                JBE         BUBBLE_SKIP
                XCHG        AX, [SI + 2]
                MOV         [SI], AX
                MOV         BX, 0
BUBBLE_SKIP:    ADD         SI, 2
                LOOP        BUBBLE_SUB_LP

                POP         CX
                DEC         CX
                CMP         BX, 1
                JZ          BUBBLE_FIN                          
                JMP         SHORT BUBBLE_LP
BUBBLE_FIN:

; PART3
                PRINT_TABLE
                PRINT       NEW_LINE

; EXIT
EXIT:           MOV         AX, 4C00H
                INT         21H
MAIN            ENDP
CODE            ENDS
                END         MAIN
