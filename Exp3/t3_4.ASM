; STACK SEGMENT
STACK           SEGMENT     PARA STACK
STACK_AREA      DW          100 DUP(?)
STACK_BOTTOM    EQU         $ - STACK_AREA
STACK           ENDS

; DATA SEGMENT
DATA            SEGMENT     PARA
LEN             EQU         20
IN_BUF          DB          LEN-1
                DB          ?
STRING          DB          LEN DUP(?)

WORDS_LIST      DB          'abc', '$'
                DB          'rdefghi', '$'
                DB          'vsgsg', '$'
                DB          'fsf', '$'
                DB          'mbdhrno', '$'
                DB          'pfefe', '$'
                DB          20 DUP('$')
WORDS_OFFSET    DW          7 DUP(?)

CRLF            DB          0DH, 0AH, '$'
SPACE           DB          ' ', '$'
TAB             DB          9, '$'

TEST_STRING     DB          'TEST', '$'
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

; PRINT_REG MACRO
PRINT_REG       MACRO       REG
                PUSH        AX
                PUSH        DX
                MOV         DX, REG
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

; STRCMP SUB PROCEDURE  (AX = 0 if equal, 1 if greater, 0FFFFH if less)
STRCMP          PROC        NEAR
                PUSH        SI
                PUSH        DI
                PUSH        CX
                ; PRINT_REG   SI
                ; PRINT       SPACE
                ; PRINT_REG   DI
                ; PRINTLN     SPACE
                CLD
.LP:            LODSB
                CMP         AL, ES:[DI]
                JA          .GT
                JB          .LT
                CMP         AL, '$'
                JZ          .EQ
                INC         DI
                JMP         SHORT .LP
.GT:            MOV         AX, 1
                JMP         SHORT .END
.LT:            MOV         AX, 0FFFFH
                JMP         SHORT .END
.EQ:            XOR         AX, AX
.END:           POP         CX
                POP         DI
                POP         SI
                RET
STRCMP          ENDP

; SORT SUB PROCEDURE （CX = number of words)
SORT            PROC        NEAR
                PUSH        SI
                PUSH        DI
                PUSH        BX
                PUSH        DX

.LP1:    	    MOV         BX, 1
                PUSH        CX
            	DEC         CX
                MOV         SI, OFFSET WORDS_OFFSET
.LP2:    	    MOV         DI, WORD PTR [SI+2]
                PUSH        SI
                MOV         SI, WORD PTR [SI]
                CALL        STRCMP
                POP         SI
                CMP         AX, 0
                JGE         .LP2_END
                MOV         DX, WORD PTR [SI]
                XCHG        DX, WORD PTR [SI+2]
                MOV         WORD PTR [SI], DX
                MOV         BX, 0
.LP2_END:       ADD         SI, 2
                LOOP        .LP2

                ; PUSH        CX
                ; MOV         CX, 6
                ; CALL        PRINT_WORDS
                ; POP         CX
                
                POP         CX
                CMP         BX, 1
                JZ          .LP1_END
                ; PRINTLN     TEST_STRING
                JMP         SHORT .LP1

.LP1_END:       POP         DX
                POP         BX
                POP         DI
                POP         SI
                RET
SORT            ENDP

; PRINT_WORDS SUB PROCEDURE (CX = number of words)
PRINT_WORDS     PROC        NEAR
                PUSH        SI
                PUSH        BX
                MOV         SI, OFFSET WORDS_OFFSET
.LP3:           MOV         BX, [SI]
                PRINT_REG   BX
                PRINT       SPACE
                ADD         SI, 2
                LOOP        .LP3
                PRINT       CRLF
                POP         BX
                POP         SI
                RET
PRINT_WORDS     ENDP

; MAIN PROCEDURE
MAIN            PROC        FAR
                MOV         AX, STACK
                MOV         SS, AX
                MOV         SP, STACK_BOTTOM
                MOV         AX, DATA
                MOV         DS, AX
                MOV         ES, AX              ; DS = ES

                ; initialize WORDS_OFFSET
                MOV         SI, OFFSET WORDS_LIST
                MOV         DI, OFFSET WORDS_OFFSET
                MOV         CX, 6
LP1:            MOV         WORD PTR [DI], SI
                ADD         DI, 2
LP1_1:          CMP         BYTE PTR [SI], '$'
                JE          LP1_1_END
                INC         SI
                JMP         LP1_1
LP1_1_END:      INC         SI
                LOOP        LP1

                ; print the words
                MOV         CX, 6
                CALL        PRINT_WORDS

                ; sort the words
                MOV         CX, 6
                CALL        SORT

                ; print the words
                MOV         CX, 6
                CALL        PRINT_WORDS

                ; get a string
                CALL        GETS
                MOV         WORD PTR [WORDS_OFFSET+12], OFFSET STRING

                ; sort the words
                MOV         CX, 7
                CALL        SORT

                ; print the words
                MOV         CX, 7
                CALL        PRINT_WORDS

; EXIT
EXIT:           MOV         AX, 4C00H
                INT         21H
MAIN            ENDP
CODE            ENDS
                END         MAIN                
