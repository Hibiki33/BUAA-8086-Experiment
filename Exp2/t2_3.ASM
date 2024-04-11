STACK           SEGMENT     PARA STACK
STACK_AREA      DW          100 DUP(?)
STACK_BOTTOM    EQU         $ - STACK_AREA
STACK           ENDS

DATA            SEGMENT     PARA
OP1             DD          21371248H
OP2             DD          12345678h
RESULT          DD          2 DUP(0)
DIVIDENT        DW          4 DUP(0)
DEC_STR         DB          19 DUP(0), '$'
NEW_LINE        DB          0DH, 0AH, '$'
DATA            ENDS

CODE            SEGMENT     PARA
                ASSUME      CS:CODE, DS:DATA, SS:STACK

PRINT_HEX_RES   PROC   
                PUSH        AX
                PUSH        BX
                PUSH        CX
                PUSH        DX
                PUSH        SI

                LEA         SI, RESULT+7
                MOV         CX, 8       

HEX_LP:         MOV         AL, [SI]    
                MOV         AH, AL       
                AND         AL, 0FH    
                SHR         AH, 1
                SHR         AH, 1
                SHR         AH, 1
                SHR         AH, 1       
                MOV         BL, AL      
                MOV         AL, AH   
                CALL        PRINT_HEX   
                MOV         AL, BL      
                CALL        PRINT_HEX  

                DEC         SI       
                LOOP        HEX_LP

                POP         SI
                POP         DX
                POP         CX
                POP         BX
                POP         AX
                RET

PRINT_HEX:      CMP         AL, 9
                JA          LETTER
                ADD         AL, 30H      ; 0-9
                JMP         PRINT_CHAR

LETTER:         ADD         AL, 37H      ; A-F

PRINT_CHAR:     MOV         AH, 2
                MOV         DL, AL
                INT         21H
                RET

PRINT_HEX_RES   ENDP

PRINT_DEC_RES   PROC        
    
                PUSH        AX
                PUSH        BX
                PUSH        CX
                PUSH        DX
                PUSH        SI
                PUSH        DI

                MOV         BX, 10
                MOV         CX, 19
                MOV         SI, OFFSET DEC_STR+18
DEC_DIV_LP:     PUSH        CX
                MOV         CX, 4
                MOV         DI, OFFSET DIVIDENT+6
                XOR         DX, DX
DEC_DIV_LP2:    MOV         AX, [DI]
                DIV         BX
                MOV         [DI], AX
                DEC         DI
                DEC         DI
                LOOP        DEC_DIV_LP2                
                OR          DL, 30H
                MOV         [SI], DL
                DEC         SI
                POP         CX
                LOOP        DEC_DIV_LP

                MOV         DX, OFFSET DEC_STR
                MOV         AH, 09H
                INT         21H

                POP         DI
                POP         SI
                POP         DX
                POP         CX
                POP         BX
                POP         AX
                RET
PRINT_DEC_RES   ENDP               
                
MAIN            PROC        FAR                

START:          MOV         AX, STACK
                MOV         SS, AX
                MOV         SP, STACK_BOTTOM
                MOV         AX, DATA
                MOV         DS, AX

                ; 加载OP1的低16位
                MOV         AX, WORD PTR OP1
                ; 加载OP2的低16位
                MOV         BX, WORD PTR OP2
                ; 乘法
                MUL         BX
                ; 存储结果的低32位
                MOV         WORD PTR RESULT, AX
                MOV         WORD PTR RESULT+2, DX

                ; 加载OP1的高16位
                MOV         AX, WORD PTR OP1+2
                ; 与OP2的低16位相乘
                MUL         BX
                ; 将结果加到RESULT的高32位
                ADD         WORD PTR RESULT+2, AX
                ADC         WORD PTR RESULT+4, DX

                ; 加载OP2的高16位
                MOV         BX, WORD PTR OP2+2
                ; 加载OP1的低16位
                MOV         AX, WORD PTR OP1
                ; 乘法
                MUL         BX
                ; 将结果加到RESULT的高32位
                ADD         WORD PTR RESULT+2, AX
                ADC         WORD PTR RESULT+4, DX

                ; 加载OP1的高16位
                MOV         AX, WORD PTR OP1+2
                ; 与OP2的高16位相乘
                MUL         BX
                ; 将结果加到RESULT的最高32位
                ADD         WORD PTR RESULT+4, AX
                ADC         WORD PTR RESULT+6, DX
                
                ; print in hex
                CALL        PRINT_HEX_RES
                 
                ; new line 
                MOV         DX, OFFSET NEW_LINE
                MOV         AH, 09H
                INT         21H

                ; print in dec
                MOV         DI, OFFSET DIVIDENT
                MOV         SI, OFFSET RESULT
                MOV         CX, 4
DEC_PRE_LP:     MOV         AX, [SI]
                MOV         [DI], AX
                INC         DI 
                INC         DI
                INC         SI
                INC         SI
                LOOP        DEC_PRE_LP
                CALL        PRINT_DEC_RES   

; EXIT
EXIT:           MOV         AX, 4C00H
                INT         21H
MAIN            ENDP
CODE            ENDS
                END         MAIN

