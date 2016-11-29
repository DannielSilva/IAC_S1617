;									~~~
;			<<< Joao Daniel Silva 86445, Francisco Sousa, 86416 >>>
;									~~~
; ZONA I:  CONSTANTES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FIM_TEXTO		EQU		'@'
LIMITE			EQU		'#'
ESPACO			EQU		' '
NAVECAR1		EQU		'>'
NAVECAR2		EQU		')'
NAVECAR3		EQU		'\'
NAVECAR4		EQU		'/'
BALA			EQU		'-'
INT_MASK		EQU		1100000000011111b
SP_INICIAL		EQU		F0FFh
LCD_WRITE		EQU		FFF5h
TEMP_DURACAO		EQU		FFF6h
TEMP_CONTROLO		EQU		FFF7h
INT_MASK_ADDR		EQU		FFFAh
IO_CONTROLO		EQU		FFFCh
IO_STATUS		EQU		FFFDh
IO_WRITE		EQU		FFFEh
IO_READ			EQU		FFFFh
sup_esquerdo		EQU		0000h	;(0a linha, 0a coluna (00,00))
sup_direito		EQU		004Eh	;(0a linha, 78a coluna (00,78))
inf_esquerdo		EQU		1700h	;(23a linha, 0a coluna(23,00))
inf_direito		EQU		174Eh	;(23a linha, 78a coluna(23,78))
pos_canhao_i		EQU		0401h	;(04a linha, 01a coluna(04,01))
pos_VarText1		EQU		0B23h	;(12a linha, 35a coluna)
pos_VarText2		EQU		0D20h	;(14a linha, 32a coluna)

; ZONA II:  VARIAVEIS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				ORIG	8000h
IntNav			WORD	1
IntTiro			WORD	0
IntE			WORD	0
IntTemp			WORD	0
Canhao_pos		WORD	0
Canhao_int		WORD	0
NoTiros			WORD	0
VarTexto1		STR	'Prepare-se', FIM_TEXTO
VarTexto2		STR	'Prima o botao IE', FIM_TEXTO
EspacoVar1		STR	'          ', FIM_TEXTO
EspacoVar2		STR	'                ', FIM_TEXTO
Tiro			TAB	5

; ZONA III:  INTERRUPCOES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			ORIG	FE00h
INT_0			WORD	Descer
INT_1			WORD	Subir
INT_2			WORD	Esquerda
INT_3			WORD	Direita
INT_4			WORD	Disparar
			ORIG	FE0Eh
INT_E			WORD	Comecar
INT_F			WORD	Temporizar

; ZONA IV:  CODIGO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;		conjunto de instrucoes Assembly, ordenadas de forma a realizar
;		as funcoes pretendidas
			ORIG	0000h
			JMP		Inicio

;  ZONA IV.I: ROTINAS DE INTERRUPCAO -------------------------------------------
;_|_|_|  _|      _|  _|_|_|_|_|  _|_|_|_|  _|_|_|    _|_|_|    _|    _|  _|_|_|
;  _|    _|_|    _|      _|      _|        _|    _|  _|    _|  _|    _|  _|    _|
;  _|    _|  _|  _|      _|      _|_|_|    _|_|_|    _|_|_|    _|    _|  _|_|_|
;  _|    _|    _|_|      _|      _|        _|    _|  _|    _|  _|    _|  _|
;_|_|_|  _|      _|      _|      _|_|_|_|  _|    _|  _|    _|    _|_|    _|
Descer:			INC	M[IntNav]
			MOV	R1,0100h
			MOV	M[Canhao_int], R1
			RTI

Subir:			INC	M[IntNav]
			MOV	R1,0100h
			NEG	R1
			MOV	M[Canhao_int], R1
			RTI

Esquerda:		INC	M[IntNav]
			MOV	R1,0001h
			NEG	R1
			MOV	M[Canhao_int], R1
			RTI

Direita:		INC	M[IntNav]
			MOV	R1,0001h
			MOV	M[Canhao_int], R1
			RTI

Disparar:		INC	M[IntTiro]
			RTI

Comecar:		INC	M[IntE]
			RTI

Temporizar:		INC	M[IntTemp]
			RTI

;  ZONA IV.II: ROTINAS DE ESCRITA ----------------------------------------------
; _|_|_|_|    _|_|_|    _|_|_|  _|_|_|    _|_|_|  _|_|_|_|_|    _|_|
; _|        _|        _|        _|    _|    _|        _|      _|    _|
; _|_|_|      _|_|    _|        _|_|_|      _|        _|      _|_|_|_|
; _|              _|  _|        _|    _|    _|        _|      _|    _|
; _|_|_|_|  _|_|_|      _|_|_|  _|    _|  _|_|_|      _|      _|    _|
;  EscCar:	Evoca a rotina EscCar para escrever a nave na janela de texto,
;			com os carateres que a constituem. O canhao e' escrito primeiro
;			e a posicao dos restantes componentes da nave sao
;			dependentes da posicao dele
;				Entradas: pilha - posicao do canhao
;				Saidas: ---
;				Efeitos: ---
EscCar:			PUSH	R1
				PUSH	R2
				MOV		R2, M[SP+5]
				MOV		M[IO_CONTROLO], R2
				MOV		R1, M[SP+4]
				MOV		M[IO_WRITE], R1
				POP		R2
				POP		R1
				RETN	2

; EscString:Rotina que efectua a escrita de uma cadeia de caracter, terminada
;			pelo caracter FIM_TEXTO.
;				Entradas: R2 - apontador para o inicio da cadeia de caracteres
;				Saidas: ---
;				Efeitos: ---
EscString:		PUSH	R1
				PUSH	R2
				PUSH	R3
				MOV		R2, M[SP+6]
				MOV		R3, M[SP+5]
CicloEscStr:	MOV		R1, M[R2]	;Carater de uma cadeia
				CMP		R1, FIM_TEXTO
				BR.Z	FimEscStr
				PUSH	R3		;posicao de escrita
				PUSH	R1		;carater a ser escrito
				CALL	EscCar
				INC		R2
				INC		R3
				BR		CicloEscStr
FimEscStr:		POP		R3
				POP		R2
				POP		R1
				RETN	2

;  EscreveNave:	Evoca a rotina EscCar para escrever a nave na janela de texto
;			Entradas: pilha - posicao do canhao
;			Saidas: ---
;			Efeitos:
EscreveNave:	PUSH	R1
		MOV	R1, M[SP+3]
		PUSH	R1
		PUSH	NAVECAR1
		CALL	EscCar
		SUB	R1,1
		PUSH	R1
		PUSH	NAVECAR2
		CALL	EscCar
		SUB	R1,0100h
		PUSH	R1
		PUSH	NAVECAR3
		CALL	EscCar
		ADD	R1,0200H
		PUSH	R1
		PUSH	NAVECAR4
		CALL	EscCar
		POP	R1
		RETN	1

;ApagaNave:	Evoca a rotina EscCar para apagar a nave da janela
;		de texto
;			Entradas: pilha - posicao do canhao
;			Saidas: ---
;			Efeitos:
ApagaNave:	PUSH	R1
		MOV	R1, M[Canhao_pos]
		PUSH	R1
		PUSH	ESPACO
		CALL	EscCar
		SUB	R1,1
		PUSH	R1
		PUSH	ESPACO
		CALL	EscCar
		SUB	R1,0100h
		PUSH	R1
		PUSH	ESPACO
		CALL	EscCar
		ADD	R1,0200h
		PUSH	R1
		PUSH	ESPACO
		CALL	EscCar
		POP	R1
		RET

;EscreveLimite:	Evoca a rotina EscCar para escrever uma linha de limite
;			Entradas: pilha - coordenada do inicio e fim do limite
;			Saidas: ---
;			Efeitos: ---
EscreveLimite:	PUSH	R1
				MOV		R1, M[SP+4]			;limite inferior
CicloLim:		CMP		R1, M[SP+3]			;limite superior
				BR.P	FimEscLim
				PUSH	R1
				PUSH	LIMITE
				CALL	EscCar
				INC		R1
				BR		CicloLim
FimEscLim:		POP		R1
				RETN	2

;  ZONA IV.III ROTINAS DA NAVE -------------------------------------------------
; _|      _|    _|_|    _|      _|  _|_|_|_|
; _|_|    _|  _|    _|  _|      _|  _|
; _|  _|  _|  _|_|_|_|  _|      _|  _|_|_|
; _|    _|_|  _|    _|    _|  _|    _|
; _|      _|  _|    _|      _|      _|_|_|_|
;  Nave:	Apaga a nave, verifica se a proxima posicao da nave coincide com
;			limite e, se sim, volta a escrever na posicao anterior.
;			Se nao, evoca a rotina EscreveNave para escrever a nave
;			na nova posicao.
;				Entradas: pilha - coordenada no inicio e do limite para
;				onde escrever o limite
;				Saidas: ---
;				Efeitos: alteracao do conteudo de M[Canhao_pos]
Nave:			PUSH	R1
				PUSH	R3
				MOV		M[IntNav], R0			;Reinicia a flag do mov da nave
				CALL	ApagaNave
				MOV		R1, M[Canhao_pos]
				ADD		R1, M[Canhao_int]		;Mete em R1 a posi nova da nave
				CMP		R1, 0200h				;Choca com o limite superior?
				BR.P	ChocaInferior
				SUB		R1, M[Canhao_int]
ChocaInferior:	CMP		R1, 1600h				;Choca com o limite inferior?
				BR.N	ChocaEsquerda
				SUB		R1, M[Canhao_int]
ChocaEsquerda:	MOV		R3,R0
				MVBL	R3,R1
				CMP		R3,0000h				;Choca com o limite da esquerda?
				BR.P	ChocaDireita
				SUB		R1, M[Canhao_int]
ChocaDireita:	MOV		R3,R0
				MVBL	R3,R1
				CMP		R3, 004Fh				;Choca com o limite da direita?
				BR.N	DentroMapa
				SUB		R1, M[Canhao_int]
DentroMapa:		PUSH	R1						;Esta dentro, pode escrever nave
				CALL	EscreveNave
				MOV		M[Canhao_pos], R1
				;MOV	M[LCD_WRITE], R1
				POP		R1
				POP		R3
				RET

EsperaIni:		CMP		M[IntE], R0
				BR.Z	EsperaIni
ApagaIni:		PUSH	EspacoVar1
				PUSH	pos_VarText1
				CALL	EscString

				PUSH	EspacoVar2
				PUSH	pos_VarText2
				CALL	EscString
				RET

; _|_|_|_|_|  _|_|_|  _|_|_|      _|_|      _|_|_|
;     _|        _|    _|    _|  _|    _|  _|
;     _|        _|    _|_|_|    _|    _|    _|_|
;     _|        _|    _|    _|  _|    _|        _|
;     _|      _|_|_|  _|    _|    _|_|    _|_|_|

CriaTiro:		PUSH	R1
				PUSH	R2
				DEC		M[IntTiro]			;Reinicia a flag dos tiros
				MOV		R1, 5
				CMP		M[NoTiros], R1		;Numero max de tiros foi atingido?
				BR.Z	SaiDoCTiros			;Se sim, nao cria nada
				INC		M[NoTiros]			;Adiciona novo tiro
				MOV		R2, Tiro			;Em R2 mete a posi de mem do 1o tiro
TestaMemCTiro:	CMP		M[R2], R0			;Testa se ja ha algum tiro ai
				BR.Z	GuardaTiro			;Se nao, guarda nessa posi
				INC		R2					;Se houver, verifica na proxima posi
				BR		TestaMemCTiro
GuardaTiro:		MOV 	R1,	M[Canhao_pos]	;Tiro na posi a seguir ao canhao
				ADD		R1, 0001h
				MOV		M[R2], R1
SaiDoCTiros:	POP		R2
				POP		R1
				RET

Tiros:			PUSH	R1
				PUSH	R2
				PUSH	R3
				MOV		R1, 0001h
				MOV		R2, Tiro			;Em R2 mete a posi de mem do 1o tiro
				MOV		R3, M[NoTiros]		;Em R3 mete o n de tiros a verificar
HaveraTiros:	CMP		R3, R0				;Todos os tiros verificados=
				BR.Z	SaiDosTiros			;Se sim, nao move nada
TestaMemTiro:	CMP		M[R2], R0			;Testa se ha tiros na posicao R2
				BR.NZ	MoveTiro			;Se houver, usa essa posicao
				INC		R2					;Se nao, verifica na proxima
				BR		TestaMemTiro
MoveTiro:		DEC		R3					;Diminui o n de tiros a verificar
				PUSH	M[R2]
				PUSH	ESPACO
				CALL	EscCar				;Apagar o tiro do ecra
				ADD		M[R2], R1
				PUSH	M[R2]
				PUSH	BALA				;Escrever na posicao a seguir
				CALL	EscCar
				INC		R2
				BR		HaveraTiros			;Repete para a proxima posi de mem
SaiDosTiros:	POP		R3
				POP		R2
				POP		R1
				RET

;_|_|_|_|_|  _|_|_|_|  _|      _|  _|_|_|      _|_|    _|_|_|    _|_|_|
;    _|      _|        _|_|  _|_|  _|    _|  _|    _|  _|    _|    _|
;    _|      _|_|_|    _|  _|  _|  _|_|_|    _|    _|  _|_|_|      _|
;    _|      _|        _|      _|  _|        _|    _|  _|    _|    _|
;    _|      _|_|_|_|  _|      _|  _|          _|_|    _|    _|  _|_|_|

Chamar_Temp:	PUSH	R7
				MOV		R7, 0001h
				MOV		M[TEMP_DURACAO], R7
				MOV		R7, 0001h
				MOV		M[TEMP_CONTROLO], R7
				POP		R7
				RET

Temporizador:	DEC		M[IntTemp]
				CALL	Chamar_Temp
				CALL	Tiros
				RET
;  ZONA IV.IV ROTINAS DE LIMITES -----------------------------------------------
;  EscreveLimites:	Evoca a rotina EscreveLimite e da lhe parametros atraves da
;					pilha para escrever os limites superior e inferior
;						Entradas: ---
;						Saidas: pilha
;						Efeitos: ---
EscreveLimites:	PUSH	sup_esquerdo
				PUSH	sup_direito
				CALL	EscreveLimite
				PUSH	inf_esquerdo
				PUSH	inf_direito
				CALL	EscreveLimite
				RET

;  ZONA IV.V ROTINA INICIAL ----------------------------------------------------
; _|_|_|  _|      _|  _|_|_|    _|_|_|  _|_|_|    _|_|    _|
;   _|    _|_|    _|    _|    _|          _|    _|    _|  _|
;   _|    _|  _|  _|    _|    _|          _|    _|_|_|_|  _|
;   _|    _|    _|_|    _|    _|          _|    _|    _|  _|
; _|_|_|  _|      _|  _|_|_|    _|_|_|  _|_|_|  _|    _|  _|_|_|_|
;Programa que desenha um mapa de jogo e uma nave permitindo o seu deslocamento
;em resposta a butoes, estando limitado pelas dimensoes mapa
Inicio:			MOV		R7, SP_INICIAL
				MOV		SP, R7
				MOV		R7, INT_MASK
				MOV		M[INT_MASK_ADDR], R7
				MOV		R1, FFFFh
				MOV		M[FFFCh], R1
				MOV		R1, pos_canhao_i	;Definir posicao inicial do canhao
				MOV		M[Canhao_pos], R1
				ENI
				PUSH	VarTexto1			;Escrever a mensagem inicial
				PUSH	pos_VarText1
				CALL	EscString
				PUSH	VarTexto2
				PUSH	pos_VarText2
				CALL	EscString
				CALL	EsperaIni		;Aguardar pela resposta do utilizador
				CALL	EscreveLimites	;Escrever nave e limites
				PUSH	M[Canhao_pos]
				CALL	EscreveNave
				CALL	Chamar_Temp
				JMP		Jogo
;  ZONA IV.V ROTINA PRINCIPAL --------------------------------------------------
; _|      _|    _|_|    _|_|_|  _|      _|
; _|_|  _|_|  _|    _|    _|    _|_|    _|
; _|  _|  _|  _|_|_|_|    _|    _|  _|  _|
; _|      _|  _|    _|    _|    _|    _|_|
; _|      _|  _|    _|  _|_|_|  _|      _|
;  Verifica se algum interruptor foi acionado e corre a rotina correspontente

Jogo:			CMP		M[IntNav], R0
				CALL.NZ	Nave
				CMP		M[IntTiro], R0
				CALL.NZ CriaTiro
				CMP		M[IntTemp], R0
				CALL.NZ	Temporizador
				BR		Jogo
Fim:			BR		Fim
