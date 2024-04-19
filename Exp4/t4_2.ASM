; STACK SEGMENT
STACK           SEGMENT     PARA STACK
STACK_AREA      DW          100 DUP(?)
STACK_BOTTOM    EQU         $ - STACK_AREA
STACK           ENDS

; DATA SEGMENT
DATA            SEGMENT     PARA
N               DW          6

CRLF            DB          0DH, 0AH, '$'
SPACE           DB          ' ', '$'
TAB             DB          9, '$'
DATA            ENDS

; CODE SEGMENT
CODE            SEGMENT     PARA
                ASSUME      CS:CODE, DS:DATA, SS:STACK

; MAIN PROCEDURE
MAIN            PROC        FAR
                MOV         AX, STACK
                MOV         SS, AX
                MOV         SP, STACK_BOTTOM
                MOV         AX, DATA
                MOV         DS, AX

                MOV         AX, N
                PUSH        AX
                CALL        FACTORIAL   ; FACTORIAL(N)
                CALL        PRINT_NUM   ; PRINT_NUM(AX)

                ; PRINT CRLF
                MOV         DX, OFFSET CRLF
                MOV         AH, 9
                INT         21H            

; EXIT
EXIT:           MOV         AX, 4C00H
                INT         21H
MAIN            ENDP

; FACTORIAL SUB PROCEDURE (STACK)
FACTORIAL       PROC        NEAR
                PUSH        BP
                MOV         BP, SP
                PUSH        DX
                PUSH        BX
                
                MOV         BX, [BP+4]
                CMP         BX, 0
                JNZ         FACTORIAL_IN
                MOV         AX, 1
                JMP         SHORT FACTORIAL_EXIT
FACTORIAL_IN:   PUSH        BX
                DEC         BX
                PUSH        BX
                CALL        FACTORIAL
                POP         BX
                MUL         BX

FACTORIAL_EXIT: POP         BX
                POP         DX
                POP         BP
                RET         2
FACTORIAL       ENDP

; PRINT_NUM SUB PROCEDURE (AX)
PRINT_NUM       PROC        NEAR
                PUSH        AX
                PUSH        BX
                PUSH        CX
                PUSH        DX

                MOV         CX, 0
                MOV         BX, 10
.CAL_LP:        MOV         DX, 0
                DIV         BX
                PUSH        DX
                INC         CX
                CMP         AX, 0
                JNZ         .CAL_LP

.OUTPUT_LP:     POP         DX
                ADD         DL, 30H
                MOV         AH, 2
                INT         21H
                LOOP        .OUTPUT_LP

                POP         DX
                POP         CX
                POP         BX
                POP         AX
                RET
PRINT_NUM       ENDP

CODE            ENDS
                END         MAIN                

