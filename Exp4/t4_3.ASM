; STACK SEGMENT
STACK           SEGMENT     PARA STACK
STACK_AREA      DW          100 DUP(?)
STACK_BOTTOM    EQU         $ - STACK_AREA
STACK           ENDS

; DATA SEGMENT
DATA            SEGMENT     PARA
STRING1         DB          'wangjiajun', '$', 40 DUP(?)
LEN             EQU         20
IN_BUF          DB          LEN-1
                DB          ?
IN_STRING       DB          LEN DUP(?)

JMP_TABLE       DW          GETS, FIND, STRCMP, STRCPY, PUTS

IN_MSG          DB          ' a in ', '$'
GT_MSG          DB          '>', '$'
LT_MSG          DB          '<', '$'
EQ_MSG          DB          '=', '$'
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

; PUTS SUB PROCEDURE
; PARA:
; RET:
PUTS            PROC        NEAR
                PUSH        AX
                PUSH        DX
                MOV         DX, OFFSET STRING1
                MOV         AH, 9
                INT         21H
                PRINT       CRLF
                POP         DX
                POP         AX
                RET
PUTS            ENDP

; GETS SUB PROCEDURE
; PARA:
; RET: 
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
                MOV         SI, OFFSET IN_STRING
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

; STRLEN MACRO 
; PARA: DS:SI = OFFSET str
; RET: CX = length
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
; PARA: DS:SI = src, ES:DI = dst
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

; STRCMP SUB PROCEDURE
; PARA: DS:SI = str1, ES:DI = str2
; RET: AX = 0 if str1 == str2, -1 if str1 < str2, 1 if str1 > str2
STRCMP          PROC        NEAR
                PUSH        CX
                PUSH        DX
                PUSH        SI
                PUSH        DI

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

.END:           POP         DI
                POP         SI
                POP         DX
                POP         CX

                ; output part
                PRINT       IN_STRING
                CMP         AX, 0
                JE          .EQ_OUT
                JG          .GT_OUT
                JL          .LT_OUT
.GT_OUT:        PRINT       GT_MSG
                JMP         .END_OUT
.LT_OUT:        PRINT       LT_MSG
                JMP         .END_OUT
.EQ_OUT:        PRINT       EQ_MSG
.END_OUT:       PRINTLN     STRING1
                RET
STRCMP          ENDP

; FIND SUB PROCEDURE (AL = char to find, DI = offset of string)
; PARA: DI = offset of string
; RET: AX = number of char found
FIND            PROC        NEAR
                PUSH        BX
                PUSH        DX
                PUSH        SI
                PUSH        DI

                MOV         SI, DI
                STRLEN
                MOV         BL, 'a'
                MOV         DX, 0
.LPF:           PUSH        CX
                LODSB
                CMP         AL, BL
                JNE         .NEXT
                INC         DX
.NEXT:          POP         CX
                LOOP        .LPF                
                MOV         AX, DX

                POP         DI
                POP         SI
                POP         DX
                POP         BX

                ; output part
                CALL        PRINT_NUM
                PRINT       IN_MSG
                PRINTLN     STRING1       

                RET
FIND            ENDP

; MAIN PROCEDURE
MAIN            PROC        FAR
                MOV         AX, STACK
                MOV         SS, AX
                MOV         SP, STACK_BOTTOM
                MOV         AX, DATA
                MOV         DS, AX
                MOV         ES, AX              ; DS = ES

MAIN_LP:        MOV         AH, 01H
                INT         21H
                PRINT       CRLF
                CMP         AL, '0'
                JZ          EXIT
                JB          MAIN_LP
                CMP         AL, '5'
                JA          MAIN_LP
            
                XOR         AH, AH
                SUB         AX, '0'
                DEC         AX
                SHL         AX, 1
                MOV         BX, OFFSET JMP_TABLE
                ADD         BX, AX

                MOV         SI, OFFSET IN_STRING
                MOV         DI, OFFSET STRING1

                CALL        WORD PTR [BX]

NEXT_LP:        JMP         SHORT MAIN_LP

; EXIT
EXIT:           MOV         AX, 4C00H
                INT         21H
MAIN            ENDP
CODE            ENDS
                END         MAIN                
