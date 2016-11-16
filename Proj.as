;				~~~
;		«««THE ULTIMATE UNTITLED PROJECTO»»»
;				~~~
; ZONA I:  CONSTANTES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FIM_TEXTO       EQU     '@'
LIMITE		EQU 	'#'
ESPACO		EQU	' '
IO_READ         EQU     FFFFh
IO_WRITE	EQU 	FFFEh
IO_STATUS       EQU     FFFDh
IO_CONTROLO	EQU	FFFCh
SP_INICIAL      EQU     F0FFh
INT_MASK_ADDR   EQU     FFFAh
INT_MASK        EQU     0000000000001111b
sup_esquerdo    EQU     0001h ;(0a linha, 1a coluna (00,00))
sup_direito     EQU     0051h ;(0a linha, 79a coluna (00,79))
inf_esquerdo    EQU     1701h ;(23a linha, 1a coluna(23,00))
inf_direito     EQU     1751h ;(23a linha, 79a coluna(23,79))
pos_canhao_i    EQU     0402h ;(04a linha, 02a coluna(04,02))

; ZONA II:  VARIAVEIS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        	ORIG    8000h
VarTexto1       STR     'Prepare-se', FIM_TEXTO
VarTexto2       STR     'Prima	o botao IE', FIM_TEXTO
Int0            WORD    0
Int1            WORD    0
Int2            WORD    0
Int3            WORD    0
Canhao_pos	WORD	0
Canhao_int	WORD    0

; ZONA III:  INTERRUPCOES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                ORIG    FE00h
INT_0           WORD    Descer
INT_1           WORD    Subir
INT_2           WORD    Esquerda
INT_3           WORD    Direita


; ZONA IV:  CODIGO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas

                ORIG    0000h
                JMP     Inicio

;  ZONA IV.I: ROTINAS DE INTERRUPCAO -------------------------------------------
Descer:         INC M[Int0]
                MOV R1,0100h
                MOV M[Canhao_int], R1
                RTI

Subir:          INC M[Int1]
                MOV R1,0100h
                NEG R1
                MOV M[Canhao_int], R1
                RTI

Esquerda:       INC M[Int2]
                MOV R1,0001h
                NEG R1
                MOV M[Canhao_int], R1
                RTI

Direita:        INC M[Int3]
                MOV R1,0001h
                MOV M[Canhao_int], R1
                RTI


;  ZONA IV.II: ROTINAS DE ESCRITA ----------------------------------------------
;  EscCar:	Efectua a escrita de um caracter para o ecra.
;		O caracter pode ser visualizado na janela de texto.
;			Entradas: pilha - caracter a escrever, posicao
; 			Saidas: ---
;			Efeitos: alteracao do M[IO_WRITE] e M[IO_CONTROLO]
EscCar:         PUSH    R1
                PUSH    R2
                MOV     R2, M[SP+5]
                MOV     M[IO_CONTROLO], R2
                MOV     R1, M[SP+4]
                MOV     M[IO_WRITE], R1
                POP     R2
                POP     R1
                RETN    2

;  EscString:	Rotina que efectua a escrita de uma cadeia de caracter,
;		terminada pelo caracter FIM_TEXTO. Pode-se definir como
;		terminador qualquer caracter ASCII.
;			Entradas: R2 - apontador para o inicio da cadeia de car
;			Saidas: ---
;			Efeitos: ---
EscString:      PUSH    R1
                PUSH    R2
Ciclo:          MOV     R1, M[R2]
                CMP     R1, FIM_TEXTO
                BR.Z    FimEsc
                PUSH    R1
                CALL    EscCar
                INC     R2
                BR      Ciclo
FimEsc:         POP     R2
                POP     R1
                RET

EscreveNave:    PUSH	R1
                MOV	R1,M[SP+3]
                PUSH    R1
                PUSH	'>'
                CALL	EscCar
                SUB	R1,1
                PUSH    R1
		PUSH	')'
		CALL	EscCar
		SUB	R1,0100h
                PUSH    R1
		PUSH	'\'
		CALL	EscCar
		ADD	R1,0200H
                PUSH    R1
		PUSH	'/'
		CALL	EscCar
		POP	R1
                RETN	1

ApagaNave:	PUSH	R1
                MOV	R1,M[Canhao_pos]
                PUSH    R1
                PUSH	ESPACO
                CALL	EscCar
                SUB	R1,1
                PUSH    R1
		PUSH	ESPACO
		CALL	EscCar
		SUB	R1,0100h
                PUSH    R1
		PUSH	ESPACO
		CALL	EscCar
		ADD	R1,0200H
                PUSH    R1
		PUSH	ESPACO
		CALL	EscCar
		POP	R1
                RET

EscreveLimite:	PUSH 	R1
		MOV	R1, M[SP+4]               ;limite inferior
CicloLim:	CMP     R1, M[SP+3]               ;limite superior
		BR.P 	FimEscLim
                PUSH    R1
		PUSH 	LIMITE
		CALL 	EscCar
		INC 	R1
		BR      CicloLim
FimEscLim:	POP	R1
		RETN    2

;  ZONA IV.III ROTINAS DA NAVE -------------------------------------------------
Nave:		CMP     M[Int0],R0
                CALL.NZ MoveNave
                CMP     M[Int1],R0
                CALL.NZ MoveNave
                CMP     M[Int2],R0
                CALL.NZ MoveNave
                CMP     M[Int3],R0
                CALL.NZ MoveNave
                BR      Nave

MoveNave:	PUSH    R1
                PUSH    R3
                MOV     M[Int0], R0
                MOV     M[Int1], R0
                MOV     M[Int2], R0
                MOV     M[Int3], R0
                CALL    ApagaNave
                MOV     R1, M[Canhao_pos]
                ADD     R1, M[Canhao_int]
                CMP     R1, 0201h               ;Choca com o limite superior?
                BR.P    ChocaSuperior
                SUB     R1, M[Canhao_int]
ChocaSuperior:	CMP	R1, 1600h
                BR.N    ChocaEsquerda
                SUB     R1, M[Canhao_int]
ChocaEsquerda:  MOV     R3,R0
                MVBL    R3,R1
                CMP     R3,0001h
                BR.P    DentroMapa
                SUB     R1, M[Canhao_int]
DentroMapa:     PUSH    R1
                CALL    EscreveNave
                MOV     M[Canhao_pos], R1
                POP     R1
                POP     R3
                RET

;  ZONA IV.IV ROTINAS DE LIMITES -----------------------------------------------
EscreveLimites:	PUSH    sup_esquerdo
		PUSH    sup_direito
		CALL	EscreveLimite
		PUSH    inf_esquerdo
		PUSH    inf_direito
		CALL    EscreveLimite
		RET

;  ZONA IV.V ROTINA PRINCIPAL --------------------------------------------------
Inicio:         MOV     R7, SP_INICIAL
                MOV     SP, R7
                MOV	R7, INT_MASK
                MOV	M[INT_MASK_ADDR], R7
                MOV     R1, FFFFh
                MOV     M[FFFCh], R1
		ENI
		CALL    EscreveLimites
		MOV	R1, pos_canhao_i
		MOV	M[Canhao_pos], R1
                PUSH    M[Canhao_pos]
		CALL	EscreveNave
		CALL	Nave
Fim:	        BR      Fim
