; Programa PROJETO

; ZONA I: Definicao de constantes
FIM_TEXTO       EQU     '@'
LIMITE		EQU 	'#'
IO_READ         EQU     FFFFh
IO_WRITE	EQU 	FFFEh
IO_STATUS       EQU     FFFDh
IO_CONTROLO	EQU	FFFCh
SP_INICIAL      EQU     FDFFh
INT_MASK_ADDR   EQU     FFFAh
INT_MASK        EQU     0000000000000001b

sup_esquerdo    EQU     0001h ;(0a linha, 1a coluna (00,00))
sup_direito     EQU     0051h ;(0a linha, 79a coluna (00,79))
inf_esquerdo    EQU     1701h ;(23a linha, 1a coluna(23,00))
inf_direito     EQU     1751h ;(23a linha, 79a coluna(23,79))

pos_canhao_i    EQU     0402h ;(04a linha, 02a coluna(04,02))


; ZONA II: definicao de variaveis

        	ORIG    8000h
VarTexto1       STR     'Prepare-se', FIM_TEXTO
VarTexto2       STR     'Prima	o botao IE', FIM_TEXTO
int0            WORD    0

; ZONA III:  Interrupções

                ORIG    FE00h   
INT_0           WORD    Subir


; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas

                ORIG    0000h
                JMP     Inicio

; EscCar: Rotina que efectua a escrita de um caracter para o ecra.
;       O caracter pode ser visualizado na janela de texto.
;               Entradas: pilha - caracter a escrever
;               Saidas: ---
;                       Efeitos: alteracao do registo R1
;                       alteracao da posicao de memoria M[IO]

EscCar:         PUSH    R1
                PUSH    R2
                MOV     R2, M[SP+5]
                MOV     M[IO_CONTROLO], R2
                MOV     R1, M[SP+4]
                MOV     M[IO_WRITE], R1
                POP     R2
                POP     R1
                RETN    2

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
                RET

Subir:          INC M[int0]
                RTI

Sobe_nave:      PUSH    R1
                MOV     R3,5
                MOV     R1, pos_canhao_i
                SUB     R1, 0100h
                PUSH    R1
                CALL    EscreveNave
                POP     R1
                POP     R1
                RET

EscreveLimites: PUSH 	R1
		MOV	R1, M[SP+4]               ;limite inferior
CicloLim:	CMP     R1, M[SP+3]               ;limite superior
		BR.P 	FimEscLim
                PUSH    R1
		PUSH 	'#'
		CALL 	EscCar
		INC 	R1
		BR      CicloLim
FimEscLim:	POP	R1
		RETN    3



; EscString: Rotina que efectua a escrita de uma cadeia de caracter, terminada
;          pelo caracter FIM_TEXTO. Pode-se definir como terminador qualquer
;          caracter ASCII.
;               Entradas: R2 - apontador para o inicio da cadeia de caracteres
;               Saidas: ---
;               Efeitos: ---

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



; Programa Principal:

Inicio:         MOV     R7, SP_INICIAL
                MOV     SP, R7
                MOV R7, INT_MASK
                MOV M[INT_MASK_ADDR], R7
                ENI

                MOV     R1, FFFFh
                MOV     M[FFFCh], R1

                PUSH    sup_esquerdo
                PUSH    sup_direito
		CALL	EscreveLimites

                PUSH    inf_esquerdo
                PUSH    inf_direito
                CALL    EscreveLimites

                PUSH    pos_canhao_i
		CALL	EscreveNave
Movimentos:     CMP     M[int0],R0
                CALL.NZ Sobe_nave
                BR      Movimentos
Fim:	        BR      Fim
