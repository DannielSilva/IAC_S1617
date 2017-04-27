;					~~~
;	<<< Joao Daniel Silva 86445, Francisco Sousa, 86416 >>>
;					~~~
; ZONA I:  CONSTANTES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FIM_TEXTO			EQU			'@'
LIMITE				EQU			'#'
ESPACO				EQU			' '
NAVECAR1			EQU			'>'
NAVECAR2			EQU			')'
NAVECAR3			EQU			'\'
NAVECAR4			EQU			'/'
BALA				EQU			'-'
ASTERISCO			EQU 			'*'
BNEGRO 				EQU 			'o'
NOMAXTIROS			EQU			5					;No maximo de tiros no ecra
NOMAXOBST			EQU			0010h				;16
PERIODAST			EQU			5					;Periodicidade dos obstac/tempori
PERIODBUR			EQU			3					;Periodicidade dos buracos/asteroides
DURACAOLEDS			EQU			5				;Numero de ciclos do temp em que os leds estao acesos
INT_MASK			EQU			1100000000011111b	;Mascara do jogo
INT_MASK2 			EQU 			0111111111111111b	;Mascara do reinicio
SP_INICIAL			EQU			F0FFh
IO_DISPLAY      		EQU     		FFF0h
LCD_CONTROL			EQU 			FFF4h
LCD_WRITE			EQU			FFF5h
TEMP_DURACAO			EQU			FFF6h
TEMP_CONTROLO			EQU			FFF7h
LEDS_CONTROLO			EQU			FFF8h
INT_MASK_ADDR			EQU			FFFAh
IO_CONTROLO			EQU			FFFCh
IO_STATUS			EQU			FFFDh
IO_WRITE			EQU			FFFEh
IO_READ				EQU			FFFFh
sup_esquerdo			EQU			0000h				;(0a linha, 0a coluna (00,00))
sup_direito			EQU			004Eh				;(0a linha, 78a coluna (00,78))
inf_esquerdo			EQU			1700h				;(23a linha, 0a coluna(23,00))
inf_direito			EQU			174Eh				;(23a linha, 78a coluna(23,78))
pos_canhao_i			EQU			0401h				;(04a linha, 01a coluna(04,01))
pos_VarText1			EQU			0B23h				;(12a linha, 35a coluna)
pos_VarText2			EQU			0D20h				;(14a linha, 32a coluna)
pos_TextFim 			EQU 			0B23h   			;(12a linha, 35a coluna)
pos_TextPonts 			EQU 			0D23h   			;(14a linha, 35a coluna)

; ZONA II:  VARIAVEIS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

					ORIG		8000h
IntNav				WORD		0
IntTiro				WORD		0
IntE				WORD		0
IntTemp				WORD		0
Flag_Reset 			WORD 		0
Canhao_pos			WORD		0
Canhao_int			WORD		0
LedsAcesos			WORD		0
LedsCount			WORD		0
NoTiros				WORD		0
NoObstaculos			WORD 		0
RandomNumb 			WORD 		0
Pontuacao 			WORD  		0
PosUltAst 			WORD  		0
ContaBuracoN 			WORD 		0
ContadorTemp			WORD 		0
Tiro				TAB		NOMAXTIROS			;tabela com as posicoes dos tiros
Obstaculo			TAB 		NOMAXOBST			;tabela com as posicoes dos obst
CarObstaculo 			TAB 		NOMAXOBST 			;tabela com os carateres dos obst
PontuacaoFinal 			TAB 		3
VarTexto1			STR		'Prepare-se', FIM_TEXTO
EspacoVar1			STR		'          ', FIM_TEXTO
VarTexto2			STR		'Prima o botao IE', FIM_TEXTO
EspacoVar2			STR		'                ', FIM_TEXTO
VarTextFim			STR 		'Fim do Jogo', FIM_TEXTO
EspacoTxtF			STR		'           ', FIM_TEXTO
VarTextPonts 			STR 		'Pontuacao: ', FIM_TEXTO
EspacoTxtP 			STR 		'           ', FIM_TEXTO
VarTxTLinhas 			STR 		'Linha: ', FIM_TEXTO
VarTxTColunas 			STR 		'Coluna: ', FIM_TEXTO
StringVazia			STR		'                                                                                ', FIM_TEXTO

; ZONA III:  INTERRUPCOES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
					ORIG		FE00h
INT_0				WORD		Descer
INT_1				WORD		Subir
INT_2				WORD		Esquerda
INT_3				WORD		Direita
INT_4				WORD		Disparar
INT_5				WORD		ResetJogo
INT_6				WORD	 	ResetJogo
INT_7				WORD	 	ResetJogo
INT_8				WORD	 	ResetJogo
INT_9				WORD	 	ResetJogo
INT_A 				WORD	 	ResetJogo
INT_B 				WORD	 	ResetJogo
INT_C 				WORD	 	ResetJogo
INT_D 				WORD	 	ResetJogo
INT_E				WORD		Comecar
INT_F				WORD		Temporizar

; ZONA IV:  CODIGO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Conjunto de instrucoes Assembly, ordenadas de forma a realizar
;	as funcoes pretendidas
					ORIG		0000h
					JMP		Inicio

;  ZONA IV.I: ROTINAS DE INTERRUPCAO -------------------------------------------
;_|_|_|  _|      _|  _|_|_|_|_|  _|_|_|_|  _|_|_|    _|_|_|    _|    _|  _|_|_|
;  _|    _|_|    _|     _|      _|        _|    _|  _|    _|  _|    _|  _|    _|
;  _|    _|  _|  _|      _|      _|_|_|    _|_|_|    _|_|_|    _|    _|  _|_|_|
;  _|    _|    _|_|      _|      _|        _|    _|  _|    _|  _|    _|  _|
;_|_|_|  _|      _|      _|      _|_|_|_|  _|    _|  _|    _|    _|_|    _|
;	Rotinas a ser executadas dependendo das interrupcoes
Descer:					INC		M[IntNav]
					MOV		R1, 0100h		;Aumenta em uma linha
					MOV		M[Canhao_int], R1
					RTI

Subir:					INC		M[IntNav]
					MOV		R1, 0100h
					NEG		R1				;Diminui em uma linha
					MOV		M[Canhao_int], R1
					RTI

Esquerda:				INC		M[IntNav]
					MOV		R1, 0001h
					NEG		R1				;Diminui uma coluna
					MOV		M[Canhao_int], R1
					RTI

Direita:				INC		M[IntNav]
					MOV		R1, 0001h		;Aumenta uma linha
					MOV		M[Canhao_int], R1
					RTI

Disparar:				INC		M[IntTiro]
					RTI

ResetJogo:				INC  		M[Flag_Reset]
					RTI

Comecar:				INC		M[IntE]
					RTI

Temporizar:				INC		M[IntTemp]
					RTI

;  ZONA IV.II: ROTINAS DE ESCRITA ----------------------------------------------
; _|_|_|_|    _|_|_|    _|_|_|  _|_|_|    _|_|_|  _|_|_|_|_|    _|_|
; _|        _|        _|        _|    _|    _|        _|      _|    _|
; _|_|_|      _|_|    _|        _|_|_|      _|        _|      _|_|_|_|
; _|              _|  _|        _|    _|    _|        _|      _|    _|
; _|_|_|_|  _|_|_|      _|_|_|  _|    _|  _|_|_|      _|      _|    _|
; EscCar:	Recebe um caracter e a posicao na janela de texto onde o escrever, e
;			efectua essa escrita
;				Entradas: pilha - posicao na janela, caracter
;				Saidas: ---
;				Efeitos: escreve na janela de texto o caracter nessa posicao
EscCar:					PUSH		R1
					PUSH		R2
					MOV		R1, M[SP+5]			;Recebe em R1 a posi na janela p escrever
					MOV		M[IO_CONTROLO], R1
					MOV		R2, M[SP+4]			;Recebe em R2 o caracter a escrever
					MOV		M[IO_WRITE], R2
					POP		R2
					POP		R1
					RETN		2

; EscString:	Rotina que efectua a escrita de uma cadeia de caracter, finalizada
;		pelo caracter FIM_TEXTO, chamando a EscCar
;				Entradas:	pilha - posi de memoria da string, posi na janela
;				Saidas:		pilha - posi a escrever, caracter p/ EscCar
;				Efeitos:	---
EscString:				PUSH		R1
					PUSH		R2
					PUSH		R3
					MOV		R2, M[SP+6]			;Recebe em R2 a 1a posi de mem do string
					MOV		R3, M[SP+5]			;Recebe emm R3 a 1a posi do ecra p escrever
CicloEscStr:				MOV		R1, M[R2]			;Em R1 o caracter atual
					CMP		R1, FIM_TEXTO		;Eh o FIM_TEXTO?
					BR.Z		FimEscStr			;Se sim, sai
					PUSH		R3					;Se nao, manda posicao de escrita
					PUSH		R1					;Manda carater a ser escrito
					CALL		EscCar				;Escreve
					INC		R2					;Incrementa a posi de mem e do ecra
					INC		R3
					BR		CicloEscStr
FimEscStr:				POP		R3
					POP		R2
					POP		R1
					RETN		2

; EscreveNave:	Evoca a rotina EscCar para escrever a nave na janela de texto
;			com os carateres que a constituem. O canhao eh escrito primeiro
;			e a posicao das restantes partes da nave dependem da posicao dele
;					Entradas:	pilha - posicao do canhao
;					Saidas:		pilha - posi na janela de texto, caracter das
;								partes da nave p/EscCar
;					Efeitos:	---
EscreveNave:				PUSH		R1
					MOV		R1, M[SP+3]		;Em R1 a posi do canhao na janela
					PUSH		R1				;Posi do canhao
					PUSH		NAVECAR1		;Caracter do canhao
					CALL		EscCar			;Escreve canhao
					SUB		R1, 0001h		;Calcula posi do motor
					PUSH		R1
					PUSH		NAVECAR2
					CALL		EscCar			;Escreve motor
					SUB		R1, 0100h		;Calcula posi de uma asa
					PUSH		R1
					PUSH		NAVECAR3
					CALL		EscCar			;Escreve asa
					ADD		R1, 0200h		;Calcula posi da outra asa
					PUSH		R1
					PUSH		NAVECAR4
					CALL		EscCar			;Escreve asa
					POP		R1
					RETN		1

; ApagaNave:	Evoca a rotina EscCar para apagar a nave da janela
;			de texto, colocando espaços em todas as posicoes da nave
;				Entradas:	pilha - posicao do canhao
;				Saidas:		posi na janela de texto das partes da nave, espaços p/EscCar
;				Efeitos:	---
ApagaNave:				PUSH		R1
					MOV		R1, M[Canhao_pos]
					PUSH		R1
					PUSH		ESPACO
					CALL		EscCar		;Escreve no canhao
					SUB		R1, 0001h
					PUSH		R1
					PUSH		ESPACO
					CALL		EscCar		;Escreve no motor
					SUB		R1, 0100h
					PUSH		R1
					PUSH		ESPACO
					CALL		EscCar		;Escreve numa asa
					ADD		R1, 0200h
					PUSH		R1
					PUSH		ESPACO
					CALL		EscCar		;Escreve na outra asa
					POP		R1
					RET

; _|        _|_|_|_|  _|_|_|      _|_|_|
; _|        _|        _|    _|  _|
; _|        _|_|_|    _|    _|    _|_|
; _|        _|        _|    _|        _|
; _|_|_|_|  _|_|_|_|  _|_|_|    _|_|_|
AcendeLeds:				PUSH		R1
					MOV		R1, FFFFh
					MOV		M[LEDS_CONTROLO], R1
					MOV		R1, 1
					MOV		M[LedsAcesos], R1
					MOV		R1, DURACAOLEDS
					MOV		M[LedsCount], R1
					POP		R1
					RET

ApagahLeds:				PUSH		R1
					DEC		M[LedsCount]
					CMP		M[LedsCount], R0
					BR.NZ		SaiDoApaLeds
ApagaLeds:				MOV		M[LEDS_CONTROLO], R0
					MOV		M[LedsAcesos], R0
SaiDoApaLeds:				POP		R1
					RET

; ___       ________  ________
;|\  \     |\   ____\|\   ___ \
;\ \  \    \ \  \___|\ \  \_|\ \
; \ \  \    \ \  \    \ \  \ \\ \
;  \ \  \____\ \  \____\ \  \_\\ \
;   \ \_______\ \_______\ \_______\
;    \|_______|\|_______|\|_______|
; EscreveLCD:	Rotina que escreve no LCD, na primeira linha 'Linhas :'
;		e na segunda 'Colunas :'
;			Entradas: ---
;			Saidas: ---
;			Efeitos: Alteracao da posicao de memoria do porto de
;			escrita e de controlo do LCD
EscreveLCD:				PUSH 		R1
					PUSH 		R2
					PUSH 		R3
					MOV 		R2, VarTxTLinhas
					MOV 		R3, 1000000000000000b
CicloLinLCD:				MOV 		R1, M[R2]
					CMP 		R1, FIM_TEXTO		;compara o carater em R1 com o carater final
					BR.Z 		EscLCDCols			;se sim escreve as COLUNAS
					PUSH 		R3
					PUSH 		R1
					CALL 		EscTextoLCD
					INC 		R2
					INC 		R3					;passa o porto de controlo para a nova coluna do LCD
					BR 		CicloLinLCD
EscLCDCols:				MOV 		R2, VarTxTColunas
					MOV 		R3, 1000000000010000b
CicloColLCD:				MOV 		R1, M[R2]
					CMP 		R1, FIM_TEXTO 	;compara o carater em R1 com o carater final
					BR.Z 		SaiEscTxtLCD 	;se sim sai da rotina
					PUSH 		R3
					PUSH 		R1
					CALL 		EscTextoLCD
					INC 		R2
					INC 		R3
					BR 		CicloColLCD
SaiEscTxtLCD:				POP 		R3
					POP 		R2
					POP 		R1
					RET

; EscTextoLCD:	rotina de suporte para a escrita de texto no LCD
;			Entradas:	R1 com o carater a ser escrito, R3 com a posicao do mesmo
;			Saidas: 	---
;			Efeitos:	Alteracao do porto de escrita e de controlo do LCD
EscTextoLCD:				PUSH 		R1
					PUSH 		R2
					MOV 		R1, M[SP+5]
					MOV 		M[LCD_CONTROL], R1	;Em R3 palavra de alteracao do porto de controlo
					MOV 		R2, M[SP+4]
					MOV 		M[LCD_WRITE], R2	;Em R1 o carater a ser escrito
					POP 		R2
					POP 		R1
					RETN 		2


; LCDCanhaoPos:	Escreve a posicao da nave no LCD
;			Entradas:	conteudo da posicao de memoria Canhao_pos
;			Saidas:		---
;			Efeitos:	Alteracao do porto de escrita e de controlo do LCD
LCDCanhaoPos:				PUSH 		R1
					PUSH 		R2
					PUSH 		R3
					PUSH 		R4
					PUSH 		R5
					PUSH 		R6
					MOV 		R1, R0 		;limpa os registos
					MOV 		R2, R0
					MVBH 		R1, M[Canhao_pos]	;escreve as linhas do canhao em R1
					ROR 		R1, 8			;deslocacao dos bits para o octeto
					PUSH 		R0			;de menor peso para converter para decimal
					PUSH 		R1
					CALL 		CnvrtDec
					POP 		R1			;escrita do R1 em decimal
					ROL 		R1, 8			;rotacao para o octeto de maior peso

					MVBL		R2, M[Canhao_pos] ;escreve as colunas do canhao em R2
					PUSH 		R0
					PUSH 		R2
					CALL 		CnvrtDec
					POP 		R2			;escrita do R2 em decimal

					MOV 		R3, F000h		;mascara para selecao dos 4 bits mais significativos
					MOV 		R4, 1000000000000111b	;palavara para o controlo do LCD
CicloLinLCDCP:				MOV 		R5, R3			;escrita da mascara
					CMP 		R5, 00F0h 		;verifica se ja escreveu os dois
					BR.Z 		LCDColunaCPos	  	;se sim sai para escrver a posicao da coluna
					AND 		R5, R1 			;seleciona o primeiro digito das linhas
					ROR 		R5, 8 			;desloca os bits para serem escritos no LCD
					CMP 		R5, 000Fh 		;verifica se o numero a ser escrito tem 2 digitos
					BR.NP 		CnvrtLinAscii		;se nao vai para a rotina de escrita
					ROR 		R5, 4 			;se sim desloca os bits para os menos significativos

CnvrtLinAscii:				ADD 		R5,'0'			;conversao para ASCII
					PUSH 		R4
					PUSH 		R5
					CALL 		EscTextoLCD 		;rotina de escrita no LCD
					ROR 		R3, 4			;rotacao da mascara em R3 para selecao do bit seguinte
					INC 		R4 			;mudanca de coluna de escrita no LCD
					BR 		CicloLinLCDCP 		;repete para a escrita do segundo digito da linha
LCDColunaCPos:				MOV 		R4, 1000000000010111b	;mudanca de linha de escrita do LCD
CicloColLCDCP:				MOV 		R5, R3 			;atualizacao da mascara em R5
					CMP 		R5, F000h 		;verifica se ja escreveu os dois digitos
					BR.Z 		SaiLCDCPos 		;se sim sai da rotina de escrita
					AND 		R5, R2 			;seleciona o primeiro digito das colunas
					CMP 		R5, 000Fh 		;verifica se o numero a ser escrito tem 2 digitos
					BR.NP 		CnvrtColAscii 		;se nao vai para a rotina de escrita
					ROR 		R5, 4 			;se sim desloca os bits para a posicao correta
CnvrtColAscii:				ADD 		R5, '0'			;conversao para ASCII
					PUSH 		R4
					PUSH 		R5
					CALL 		EscTextoLCD 		;escrita no LCD
					ROR 		R3, 4 			;rotacao da mascara em R3 para selecao do bit seguinte
					INC 		R4 			;mudanca de coluna de escrita no LCD
					BR 		CicloColLCDCP 		;repete para a escrita do segundo digito da coluna
SaiLCDCPos:				POP  		R6
					POP 		R5
					POP 		R4
					POP 		R3
					POP 		R2
					POP 		R1
					RET

; CnvrtDec:	Rotina que dado um numero em hexa, converte-o para decimal
;			Entradas:	pilha - numero para conversao
;			Saidas:		pilha - numer convertido em decimal
;			Efeitos:	---
CnvrtDec: 				PUSH 		R1
					PUSH 		R2
					MOV 		R1, M[SP+4]		;escrita em R1 do numero a ser convertido
					MOV 		R2, 10
					DIV 		R1, R2			;resultado em R1 e o resto em R2
					SHL 		R1, 4			;rotacao a esquerda para poder concatenar
					ADD 		R1, R2			;o resto com o resultado da divisao
					MOV 		M[SP+5], R1		;guarda na pilha
					POP 		R2
					POP 		R1
					RETN 		1

;7MM111Yb. `7MMF' .MPQQbgd  `7MMHHHMq.`7MMF'            db   `YMM'   `MM'
;  MM    `Yb. MM  ,MI    Y    MM   `MM. MM             :MM:    VMA   ,V
;  MM     `Mb MM  `MMb.       MM   ,M9  MM            ,V^MM.    VMA ,V
;  MM      MM MM    `YMMNq.   MMmmdM9   MM           ,M  `MM     VMMP
;  MM     ,MP MM  .     `MM   MM        MM      ,    AbmmmqMA     MM
;  MM    ,dP' MM  Mb     dM   MM        MM     ,M   A'     VML    MM
;.JMMmmmdP' .JMML.PHYbmmdP  .JMML.    .JMMmmmmMMM .AMA.   .AMMA..JMML.

EscDisplay: 				PUSH 		R1
					PUSH 		R2
					PUSH 		R3
					PUSH 		R4
					PUSH 		R5
					PUSH 		R6
					MOV 		R1, M[Pontuacao]  ;escrita da pontuacao em R1
					MOV 		R4, IO_DISPLAY 	  ;escrita da posicao de memoria do primeiro display
					MOV 		R6, PontuacaoFinal

					PUSH 		R0
					PUSH 		R1
					CALL 		CnvrtDec   		;conversao para decimal do numero em R1
					POP 		R1

					MOV 		R3, 000Fh 		 ;mascara para selecao de bits
CicloEscDSP: 				MOV 		R5, R3
					AND 		R5, R1  		 ;escrita do bit em R5
					MOV 		M[R4], R5 		 ;escrita do bit no display
					MOV 		M[R6], R5 		 ;escrita do bit na tab de PontuacaoFinal
					ROL 		R3,4 			 ;rotacao da mascara
					INC 		R4 				 ;proximo display
					INC 		R6 				 ;proxima posicao da tab PontuacaoFinal

					MOV 		R5, R3 			 ;escrita do bit em R5
					AND 		R5, R1 			 ;escrita do bit no display
					ROR 		R5, 4 			 ;escrita do bit na tab de PontuacaoFinal
					MOV 		M[R4], R5 		 ;rotacao da mascara
					MOV 		M[R6], R5 		 ;proximo display
					ROL 		R3,4 			 ;proxima posicao da tab PontuacaoFinal

SaiEscDSP:				POP 		R6
					POP 		R5
					POP 		R4
					POP 		R3
					POP 		R2
					POP 		R1
					RET

PontFinal:				PUSH 		R1
					PUSH 		R2
					PUSH 		R3
					MOV 		R3, PontuacaoFinal ;escreve em R3 a pontuacao final
					MOV 		R1, M[R3] 		   ;escreve em R1, o primeiro digito da pontuacao
					ADD 		R1, '0' 		   ;conversao para ASCII
					MOV 		M[R3],R1 		   ;escreve na tabela o digito da pontuacao em ASCII
					INC 		R3 				   ;proxima posicao da tabela
					MOV  		R2, M[R3] 		   ;escreve em R2, o segundo digito da pontuacao
					ADD 		R2, '0' 		   ;conversao para ASCII
					MOV 		M[R3], R2 		   ;escreve na tabela o digito da pontuacao em ASCII
					POP 		R3
					POP 		R2
					POP 		R1
					RET

; _|      _|  _|_|_|_|  _|      _|    _|_|_|    _|_|      _|_|_|  _|_|_|_|  _|      _|    _|_|_|
; _|_|  _|_|  _|        _|_|    _|  _|        _|    _|  _|        _|        _|_|    _|  _|
; _|  _|  _|  _|_|_|    _|  _|  _|    _|_|    _|_|_|_|  _|  _|_|  _|_|_|    _|  _|  _|    _|_|
; _|      _|  _|        _|    _|_|        _|  _|    _|  _|    _|  _|        _|    _|_|        _|
; _|      _|  _|_|_|_|  _|      _|  _|_|_|    _|    _|    _|_|_|  _|_|_|_|  _|      _|  _|_|_|
; EscreveMsgIni:	Evoca a rotina EscString para escrever a mensagem inicial na janela
;					Entradas:	---
;					Saidas:		posi de mem das strings, posi na janela p/ EscString
;					Efeitos:	---
EscreveMsgIni:				PUSH		VarTexto1		;Manda 1a posi de mem da string da linha 1
					PUSH		pos_VarText1	;Manda posi do 1o car da linha na janela
					CALL		EscString		;Escreve 1a linha
					PUSH		VarTexto2
					PUSH		pos_VarText2
					CALL		EscString		;Escreve 2a linha
					RET

; EscreveMsgFin:	Evoca a rotina EscString para escrever a mensagem final na janela
;					Entradas:	---
;					Saidas:		posi de mem das strings, posi na janela p/ EscString
;					Efeitos:	---
EscreveMsgFin:				PUSH		VarTextFim
					PUSH		pos_VarText1
					CALL		EscString		;Escreve 1a linha
					PUSH		VarTextPonts
					PUSH		pos_VarText2
					CALL		EscString		;Escreve 2a linha
					RET

; EsperaInicio:	Cria um ciclo que nao prossegue ate o utilizador premir o botao IE.
;			Aqui tambem gera um numero random para o RandomNumb. Quando
;			prossegue, apaga a mensagem inicial
;					Entradas:	Flag IntE
;					Saidas:		RandomNumb, posi de mem das strings vazias, posi
;								da mensagem inicial na janela p/ EscString
;					Efeitos:	---
EsperaInicio:				CMP		M[IntE], R0		;Botao premido==Flag=1?
					BR.NZ		ApagaInicio		;Se sim apaga a mensagem
					INC 		M[RandomNumb]	;Se nao, repete o ciclo
					BR		EsperaInicio
ApagaInicio:				DEC 		M[IntE]			;Reinicia a flag
					PUSH		EspacoVar1
					PUSH		pos_VarText1
					CALL		EscString		;Escreve 1a linha
					PUSH		EspacoVar2
					PUSH		pos_VarText2
					CALL		EscString		;Escreve 2a linha
					RET

; EsperaFim:
;				Entradas:	pilha -
;				Saidas:		posi
;				Efeitos:	---
EsperaFim:  				CMP		M[IntNav], R0
					BR.NZ		ApagaFim
					CMP		M[IntTiro], R0
					BR.NZ		ApagaFim
					CMP		M[Flag_Reset], R0
					BR.NZ		ApagaFim
					CMP		M[IntE], R0
					BR.NZ		ApagaFim
					BR 		EsperaFim
ApagaFim:				MOV 		M[IntNav],R0
					MOV 		M[IntTiro],R0
					MOV 		M[Flag_Reset],R0
					MOV 		M[IntE],R0
					PUSH		EspacoTxtF
					PUSH		pos_TextFim
					CALL		EscString
					PUSH		EspacoTxtP
					PUSH		pos_TextPonts
					CALL		EscString
					RET

; EscreveLimite:	Evoca a rotina EscCar para escrever uma linha de limite
;				Entradas:	pilha - coordenada do inicio e fim do limite
;				Saidas:		---
;				Efeitos:	---
EscreveLimite:				PUSH		R1
					MOV		R1, M[SP+4]			;limite inferior
CicloLim:				CMP		R1, M[SP+3]			;limite superior
					BR.P		FimEscLim
					PUSH		R1
					PUSH		LIMITE
					CALL		EscCar
					INC		R1
					BR		CicloLim
FimEscLim:				POP		R1
					RETN		2

LimparMemorias:				PUSH		Tiro
					PUSH		NOMAXTIROS
					CALL		LimpaMemoria
					PUSH		Obstaculo
					PUSH		NOMAXOBST
					CALL		LimpaMemoria
					PUSH		CarObstaculo
					PUSH		NOMAXOBST
					CALL		LimpaMemoria
					RET

LimparEcra:				PUSH		R1
					MOV		R1, R0
CicloLimpa:				PUSH		StringVazia
					PUSH		R1
					CALL		EscString
					CMP		R1, 1800h
					BR.Z		SaiDoLimpaEcra
					ADD		R1, 0100h
					BR		CicloLimpa
SaiDoLimpaEcra:				POP		R1
					RET


LimpaMemoria:				PUSH		R1
					PUSH		R2
					MOV		R1, M[SP+5]
					MOV		R2, M[SP+4]
HaveraMem:				CMP		R2, R0
					BR.Z		SaiDoLimpaMem
					MOV		M[R1], R0
					INC		R1
					DEC		R2
					BR		HaveraMem
SaiDoLimpaMem:				POP		R2
					POP		R1
					RETN		2

LimpaFlags:				MOV		M[IntNav], R0
					MOV		M[IntTiro], R0
					MOV		M[IntE], R0
					MOV		M[IntTemp], R0
					MOV		M[NoTiros], R0
					MOV		M[NoObstaculos], R0
					MOV		M[PosUltAst], R0
					MOV		M[ContaBuracoN], R0
					MOV		M[ContadorTemp], R0
					RET

;  ZONA IV.III ROTINAS DA NAVE -------------------------------------------------
; _|      _|    _|_|    _|      _|  _|_|_|_|
; _|_|    _|  _|    _|  _|      _|  _|
; _|  _|  _|  _|_|_|_|  _|      _|  _|_|_|
; _|    _|_|  _|    _|    _|  _|    _|
; _|      _|  _|    _|      _|      _|_|_|_|
; Nave:		Apaga a nave, verifica se a proxima posicao da nave coincide com
;		limite e, se sim, volta a escrever na posicao anterior.
;		Se nao, evoca a rotina EscreveNave para escrever a nave
;		na nova posicao.
;				Entradas: pilha - coordenada no inicio e do limite para
;				onde escrever o limite
;				Saidas: ---
;				Efeitos: alteracao do conteudo de M[Canhao_pos]
Nave:					PUSH		R1
					PUSH		R3
					DSI
					DEC		M[IntNav]			;Reinicia a flag do mov da nave
					MOV		R1, M[Canhao_pos]
					ADD		R1, M[Canhao_int]		;Mete em R1 a posi nova da nave
NChocaSuperior:				CMP		R1, 0200h			;Choca com o limite superior?
					JMP.NP		FimNave
NChocaInferior:				CMP		R1, 1600h			;Choca com o limite inferior?
					JMP.NN		FimNave
NChocaEsquerda:				MOV		R3, R0
					MVBL		R3, R1
					CMP		R3, 0000h			;Choca com o limite da esquerda?
					JMP.NP		FimNave
NChocaDireita:				MOV		R3, R0				;SERAO ESTAS LINHAS OPCIOONAIS AAOMSAOMAIOSA
					MVBL		R3, R1
					CMP		R3, 004Fh			;Choca com o limite da direita?
					JMP.NN		FimNave
NChocaObstac:				PUSH		R0
					PUSH		R1
					PUSH		Obstaculo
					PUSH		M[NoObstaculos]
					CALL		HaNaveLa
					POP		R3
					CMP		R3, R0
					JMP.NZ		Final
DentroMapa:				CALL		ApagaNave			;Esta dentro, pode escrever nave
					PUSH		R1
					CALL		EscreveNave
					MOV		M[Canhao_pos], R1
					CALL 		LCDCanhaoPos
FimNave:				ENI
					POP		R3
					POP		R1
					RET

;          :::      :::::::: ::::::::::: :::::::::: :::::::::   :::::::: ::::::::::: :::::::::  :::::::::: ::::::::
;       :+: :+:   :+:    :+:    :+:     :+:        :+:    :+: :+:    :+:    :+:     :+:    :+: :+:       :+:    :+:
;     +:+   +:+  +:+           +:+     +:+        +:+    +:+ +:+    +:+    +:+     +:+    +:+ +:+       +:+
;   +#++:++#++: +#++:++#++    +#+     +#++:++#   +#++:++#:  +#+    +:+    +#+     +#+    +:+ +#++:++#  +#++:++#++
;  +#+     +#+        +#+    +#+     +#+        +#+    +#+ +#+    +#+    +#+     +#+    +#+ +#+              +#+
; #+#     #+# #+#    #+#    #+#     #+#        #+#    #+# #+#    #+#    #+#     #+#    #+# #+#       #+#    #+#
;###     ###  ########     ###     ########## ###    ###  ######## ########### #########  ########## ########
; Obstaculos:
Obstaculos:				PUSH		R1
					PUSH		R2
					PUSH		R3
					PUSH		R4
					PUSH		R5
					CALL 		GeraObstaculos			;Gera ou nao obstaculos
					MOV		R1, 0001h
					MOV		R2, Obstaculo			;Em R2 mete a posi de mem do 1o obstaculos
					MOV		R5, CarObstaculo		;Em R5 a posi de mem do car do 1o obstaculo
					MOV		R4, M[NoObstaculos]		;Em R4 mete o n de obstaculos a verificar
HaveraObsts:				CMP		R4, R0				;Todos os obstaculos verificados?
					BR.Z		SaiDosObsts			;Se sim, nao move nada

TestaMemObsts:				CMP		M[R2], R0			;Testa se ha obstaculos na posicao R2
					BR.NZ		MoveObstaculo			;Se houver, usa essa posicao
					INC		R2				;Se nao, verifica na proxima
					INC		R5				;A posi de mem do car acompanha
					BR		TestaMemObsts
MoveObstaculo:				DEC		R4				;Diminui o n de obstaculos a verificar
					MOV		R3, M[R2]			;Escreve em R3 a posicao do obstaculo
					SUB		R3, R1				;Calcula a nova posicao
					PUSH		M[R2]				;Manda a posicao inicial
					PUSH		R3				;Manda a posicao seguinte
					PUSH		R2				;Manda o endereco de memoria
					PUSH		M[R5]				;Manda o caracter
					CALL		VeriColisoes			;Verifica colisoes e move ou nao
					INC		R2				;Aumenta a posi de mem a verificar
					INC		R5				;A posi de mem dos caracteres acompanha
					BR		HaveraObsts			;Repete para a proxima posi de mem
SaiDosObsts:				POP 		R5
					POP		R4
					POP		R3
					POP		R2
					POP		R1
					RET




; GeraObstaculos
GeraObstaculos: 			PUSH		R1
					PUSH		R2
					INC 		M[PosUltAst]
					MOV		R1, PERIODAST
					CMP 		R1, M[PosUltAst]		;Ve se ja passaram 5 posis
					BR.NN		FimGeraObst			;Se nao, sai
					MOV  		M[PosUltAst],R0			;Se sim, reinicia contador
					MOV		R1, PERIODBUR
					MOV		R2, M[ContaBuracoN]
					CMP 		R2, R1				;Ja passaram 3 asteroides?
					BR.NZ 		GeraObstFalse			;Se nao, salta para false
GeraObstTrue:				MOV		M[ContaBuracoN], R0		;Se sim, reinicia o contador do buraco negro
					PUSH 		BNEGRO				;Manda buraco negro e cria obstaculo
					BR 		ContGeraObst
GeraObstFalse:				INC 		M[ContaBuracoN]			;Se nao: incrementa o contador para criar o buraco negro
					PUSH		ASTERISCO			;Manda asteroide e cria obstaculo
ContGeraObst:				CALL 		CriaObstaculo
FimGeraObst:				POP		R2
					POP		R1
					RET



; CriaObstaculo
CriaObstaculo: 				PUSH 		R1
					PUSH 		R2
					PUSH 		R3
					PUSH 		R4
					MOV 		R4, M[SP+6]			;Em R4 mete o caracter
					MOV 		R1, NOMAXOBST
					CMP 		M[NoObstaculos], R1		;Numero max de obst atingido?
					BR.Z 		SaiDosCObst			;Se sim, sai do ciclo
					INC 		M[NoObstaculos]			;Se nao, adiciona novo obstaculo
					MOV 		R2, Obstaculo			;Em R2 a posi de memoria do 1o obst
					MOV 		R3, CarObstaculo		;Em R3 a posi de mem do caracter do 1o obst
TestaMemCObst: 				CMP 		M[R2], R0			;Ja ha algum tiro nesta posi?
					BR.Z 		GuardaObst			;Se nao, guarda nessa posi (salto)
					INC 		R2				;Se houver, verifica na proxima
					INC 		R3
					BR		TestaMemCObst
GuardaObst: 				PUSH		R0
					CALL 		PseudoRndm			;Se nao: gera numero random
					POP		R1				;Em R5 o numero random
					SHL		R1, 8
					ADD		R1, 024Eh
					MOV 		M[R2], R1			;A posicao do obstaculo eh o numero random
					MOV 		M[R3], R4			;Mete o tipo de obstaculo na memoria
SaiDosCObst:				POP 		R4
					POP 		R3
					POP 		R2
					POP 		R1
					RETN 		1

; _|_|_|_|_|  _|_|_|  _|_|_|      _|_|      _|_|_|
;     _|        _|    _|    _|  _|    _|  _|
;     _|        _|    _|_|_|    _|    _|    _|_|
;     _|        _|    _|    _|  _|    _|        _|
;     _|      _|_|_|  _|    _|    _|_|    _|_|_|

;CriaTiro
CriaTiro:				PUSH		R1
					PUSH		R2
					MOV		M[IntTiro], R0			;Reinicia a flag dos tiros
					MOV		R1, NOMAXTIROS
					CMP		M[NoTiros], R1			;Numero max de tiros foi atingido?
					BR.Z		SaiDoCTiros			;Se sim, nao cria nada,sai do ciclo
					INC		M[NoTiros]			;Adiciona novo tiro
					MOV		R2, Tiro			;Em R2 mete a posi de mem do 1o tiro
TestaMemCTiro:				CMP		M[R2], R0			;Ja ha algum tiro nessa posi
					BR.Z		GuardaTiro			;Se nao, guarda nessa posi
					INC		R2				;Se houver, verifica na proxima posi
					BR		TestaMemCTiro
GuardaTiro:				MOV 		R1, M[Canhao_pos]		;Se nao: Tiro na posi a seguir ao canhao
					ADD		R1, 0001h
					MOV		M[R2], R1
SaiDoCTiros:				POP		R2
					POP		R1
					RET

;Tiros
Tiros:					PUSH		R1
					PUSH		R2
					PUSH		R3
					PUSH		R4
					MOV		R1, 0001h
					MOV		R2, Tiro			;Em R2 mete a posi de mem do 1o tiro
					MOV		R4, M[NoTiros]			;Em R4 mete o n de tiros a verificar
HaveraTiros:				CMP		R4, R0				;Todos os tiros verificados?
					BR.Z		SaiDosTiros			;Se sim, nao move nada

TestaMemTiro:				CMP		M[R2], R0			;Testa se ha tiros na posicao R2
					BR.NZ		MoveTiro			;Se houver, usa essa posicao
					INC		R2				;Se nao, verifica na proxima
					BR		TestaMemTiro

MoveTiro:				DEC		R4				;Diminui o n de tiros a verificar
					MOV		R3, M[R2]
					ADD		R3, R1				;Calcula a nova posicao

					PUSH		M[R2]				;Manda a posicao inicial
					PUSH		R3				;Manda a posicao seguinte
					PUSH		R2				;Manda o endereco de memoria
					PUSH		BALA				;Manda o caracter
					CALL		VeriColisoes
					INC		R2
					BR		HaveraTiros			;Repete para a proxima posi de mem
SaiDosTiros:				POP		R4
					POP		R3
					POP		R2
					POP		R1
					RET

; e88~-_    ,88~-_   888     888 ,d88~~\   ,88~-_   888~~  ,d88~~\
;d888   \  d888   \  888     888 8888     d888   \  888___ 8888
;8888     88888    | 888     888 `Y88b   88888    | 888    `Y88b
;8888     88888    | 888     888  `Y88b, 88888    | 888     `Y88b,
;Y888   /  Y888   /  888     888    8888  Y888   /  888       8888
; "88_-~    `88_-~   888____ 888 \__88P'   `88_-~   888___ \__88P'
; VeriColisoes:	Rotina que testa as diversas colisoes que o objecto pode ser
;		sujeito a, e apaga-o ou move-o consoante o resultado. Testa
;		primeiro colisoes com os limites e depois testa colisoes
;		consoante o tipo de objecto que é: Tiro, obstaculo ou nave.
;			Entradas:	pilha - posicao inicial, seguinta, endereco de memoria e caracter
;			Saidas:		pilha - posicoes e enderecos e caracteres para rotinas
;			Efeitos:	---
VeriColisoes:				PUSH		R1
					PUSH		R2
					PUSH		R3
					PUSH		R4
					PUSH		R5
					PUSH		R6
					MOV		R1, M[SP+000Bh]		;Recebe a posicao inicial, em R1
					MOV		R2, M[SP+000Ah]		;Recebe a posicao seguinte, em R2
					MOV		R3, M[SP+0009h]		;Recebe o endereco de memoria da posicao, em R3
					MOV		R4, M[SP+0008h]		;Recebe o caracter, em R4
					MOV		R5, R0
					MVBL		R5, R2		;00FF
					MOV		R6, R5
					SHL 		R6, 8
ColLimEsq:				CMP		R6, 0000h		;Choca com o limite da esquerda?
					BR.NN		ColLimDir		;Se nao, testa o outro limite
					PUSH		R1			;Se sim eh porque eh obstaculo e manda posi ini
					PUSH		R3			;Manda endereco memoria do obst
					CALL		ApagaObstaculo		;Apaga o obstaculo
					JMP		SaiDasColisoes
ColLimDir:				CMP		R5, 004Fh		;Choca com o limite da direita?
					BR.N		ColTiro			;Se nao, testa se eh tiro
					PUSH		R1			;Se sim eh porque eh tiro
					PUSH		R3
					CALL		ApagaTiro		;Apaga o obstaculo
					JMP		SaiDasColisoes
					PUSH		R2
					PUSH		R4
					CALL		EscCar
ColTiro:				CMP		R4, BALA		;Eh tiro?
					JMP.NZ		ColAst			;Se nao, eh asteroide
					PUSH		R0			;Guarda espaco para o retorno
					PUSH		Obstaculo		;Manda o endereco inicial da tabela a percorrer
					PUSH		R2			;Manda a posicao a verificar
					PUSH		M[NoObstaculos]		;Manda o no de obstaculos no ecra
					CALL		HaAlgoLa
					POP		R5			;Em R5, 0 se nao, ou um endereco de memoria do obstaculo
					CMP		R5, R0			;Ha endereco em R5?
					JMP.Z		EscreveObjecto		;Se sim, faz colisoes tiros obst
					PUSH		R1
					PUSH		R3
					PUSH		R5
					PUSH		SaiDasColisoes
					JMP		ColTiroObs
ColAst:					PUSH		R0			;Guarda espaco para o retorno
					PUSH		Tiro			;Manda o endereco inicial da tabela a percorrer
					PUSH		R2			;Manda a posicao a verificar
					PUSH		M[NoTiros]		;Manda o no de tiros no ecra
					CALL		HaAlgoLa
					POP		R5			;Em R5, 0 se nao, ou um endereco de memoria do tiro
					CMP		R5, R0			;Ha endereco em R5?
					JMP.Z		ColcNave
					PUSH		R1
					PUSH		R5
					PUSH		R3
					PUSH		SaiDasColisoes
					JMP		ColTiroObs		;Se sim, faz colisoes tiros obst
ColcNave:				PUSH		R0
					PUSH		M[Canhao_pos]
					PUSH		R3
					PUSH		1
					CALL		HaNaveLa
					POP		R5
					CMP		R5, R0
					JMP.NZ		Final
EscreveObjecto:				PUSH		R1			;Apagar o objecto do ecra
					PUSH		ESPACO
					CALL		EscCar
					PUSH		R2			;Escrever na posicao a seguir
					PUSH		R4
					CALL		EscCar
					MOV		M[R3], R2		;Escreve a nova posicao na memoria
SaiDasColisoes:				POP		R6
					POP		R5
					POP		R4
					POP		R3
					POP		R2
					POP		R1
					RETN		4

; ColTiroObs
ColTiroObs:				PUSH		R1
					PUSH		R3
					PUSH		R5
					PUSH		R4
					MOV		R1, M[SP+8]		;Recebe a posicao inicial em R1
					MOV		R3, M[SP+7]		;Recebe o endereco de mem do tiro em R3
					MOV		R5, M[SP+6]		;Recebe o endereco de mem do obst em R5
					MOV		R4, R5			;Em R4 o endereço de memoria do obstaculo
					SUB		R5, Obstaculo
					ADD		R5, CarObstaculo	;Em R5 o endereço de mem do caracter
					MOV		R2, BNEGRO
					CMP		M[R5], R2		;Eh buraco negro?
					BR.Z		ColTirosObsFim		;Se sim, salta para o fim
					PUSH		M[R4]			;Se nao, manda a posicao do obst
					PUSH		R4			;Manda endereco de mem do obst e apaga
					CALL		ApagaObstaculo
					CALL		AcendeLeds
					CALL 		EscDisplay

ColTirosObsFim:				PUSH		M[R3]			;Manda a posicao inicial do tiro
					PUSH		R3			;Endereco de mem do tiro e apaga
					CALL		ApagaTiro
					POP		R4
					POP		R5
					POP		R3
					POP		R1
					RETN		3

; ApagaTiro
ApagaTiro:				PUSH		R1
					PUSH		R3
					MOV		R1, M[SP+5]				;Posi inicial
					MOV		R3, M[SP+4]				;Endereco de mem
					PUSH		R1					;Apagar do ecra
					PUSH		ESPACO
					CALL		EscCar
					MOV		M[R3], R0			;Apagar da memoria
					DEC		M[NoTiros]			;Decrementar o no de tiros no ecra
					POP		R3
					POP		R1
					RETN		2

; ApagaObstaculo
ApagaObstaculo:				PUSH		R1
					PUSH		R3
					PUSH		R5
					MOV		R1, M[SP+6]			;Recebe posi inicial em R1
					MOV		R3, M[SP+5]			;Recebe o endereco de memoria em R3
					PUSH		R1				;Apagar do ecra
					PUSH		ESPACO
					CALL		EscCar
					MOV		M[R3], R0			;Apagar a posi da memoria
					MOV		R5, R3				;Em R5 o endereco de memoria da posi
					SUB		R5, Obstaculo			;Subtrair a origem da tabela para ficar so o intervalo
					ADD		R5, CarObstaculo		;Adicionar a origem da tabela dos caracteres
					MOV		M[R5], R0			;Apagar o caracter da memoria
					DEC		M[NoObstaculos]			;Decrementar o numero de obstaculos no ecra
					POP		R5
					POP		R3
					POP		R1
					RETN		2

; HaAlgoLa:
HaAlgoLa:				PUSH		R1
					PUSH		R2
					PUSH		R3
					MOV		R1, M[SP+7]			;Recebe o endereco inicial da tabela
					MOV		R2, M[SP+6]			;Recebe a posicao a verificar
					MOV		R3, M[SP+5]			;Recebe o no de enderecos ocupados
HaveraAlgo:				CMP		R3, R0				;Todos os enderecos verificados?
					BR.Z		SaiDoHaAlgo			;Se sim, sai
TestaMemAlgo:				CMP		M[R1], R0			;Testa se o endereco esta vazio
					BR.NZ		TestaAlgo			;Se nao estiver, usa esse endereco
					INC		R1				;Se estiver, verifica o proximo
					BR		TestaMemAlgo
TestaAlgo:				DEC		R3				;Dec o no de posis ocupadas por verificar
					CMP		M[R1], R2			;O que esta na posi eh a posicao?
					JMP.Z		EncontreiOAlgo			;Se sim, salta
					INC		R1				;Se nao, muda o endereco a verificar
					BR		HaveraAlgo
EncontreiOAlgo:				MOV		M[SP+8], R1			;Retorna o endereço da tabela com a posi
SaiDoHaAlgo:				POP		R3
					POP		R2
					POP		R1
					RETN		3

; HaNaveLa
HaNaveLa:				PUSH		R1
					PUSH		R2
					PUSH		R3
					PUSH		R4
					MOV		R1, M[SP+8]		;Recebe a posicao do canhao
					MOV		R2, M[SP+7]		;Recebe o endereco inicial da tabela
					MOV		R3, M[SP+6]		;Recebe o no de enderecos ocupados
					PUSH		R0			;Guarda espaco para o retorno
					PUSH		R2			;Manda o endereco inicial da tabela a percorrer
					PUSH		R1			;Manda a posicao a verificar
					PUSH		R3			;Manda o no de obstaculos no ecra
					CALL		HaAlgoLa
					POP		R4
					CMP		R4, R0
					JMP.NZ		SaiDoHaNave
					SUB		R1, 1			;Calcula posi do motor
					PUSH		R0			;Guarda espaco para o retorno
					PUSH		R2			;Manda o endereco inicial da tabela a percorrer
					PUSH		R1			;Manda a posicao a verificar
					PUSH		R3			;Manda o no de obstaculos no ecra
					CALL		HaAlgoLa
					POP		R4
					CMP		R4, R0
					JMP.NZ		SaiDoHaNave
					SUB		R1, 0100h		;Calcula posi de uma asa
					PUSH		R0			;Guarda espaco para o retorno
					PUSH		R2			;Manda o endereco inicial da tabela a percorrer
					PUSH		R1			;Manda a posicao a verificar
					PUSH		R3			;Manda o no de obstaculos no ecra
					CALL		HaAlgoLa
					POP		R4
					CMP		R4, R0
					JMP.NZ		SaiDoHaNave
					ADD		R1, 0200h		;Calcula posi da outra asa
					PUSH		R0			;Guarda espaco para o retorno
					PUSH		R2			;Manda o endereco inicial da tabela a percorrer
					PUSH		R1			;Manda a posicao a verificar
					PUSH		R3			;Manda o no de obstaculos no ecra
					CALL		HaAlgoLa
					POP		R4
					CMP		R4, R0
					JMP.NZ		SaiDoHaNave
SaiDoHaNave:				MOV		M[SP+9], R4		;Manda para fora 0 ou o endereço
					POP		R4
					POP		R3
					POP		R2
					POP		R1
					RETN		3

;_|_|_|_|_|  _|_|_|_|  _|      _|  _|_|_|      _|_|    _|_|_|    _|_|_|
;    _|      _|        _|_|  _|_|  _|    _|  _|    _|  _|    _|    _|
;    _|      _|_|_|    _|  _|  _|  _|_|_|    _|    _|  _|_|_|      _|
;    _|      _|        _|      _|  _|        _|    _|  _|    _|    _|
;    _|      _|_|_|_|  _|      _|  _|          _|_|    _|    _|  _|_|_|
; Chamar_Temp
Chamar_Temp:				PUSH		R7
					MOV		R7, 0001h
					MOV		M[TEMP_DURACAO], R7
					MOV		R7, 0001h
					MOV		M[TEMP_CONTROLO], R7
					POP		R7
					RET

; Temporizador
Temporizador:				DEC		M[IntTemp]
					CALL		Chamar_Temp
					CALL		Tiros
					CMP		M[LedsAcesos], R0
					CALL.NZ		ApagahLeds
					CMP 		M[ContadorTemp], R0		;Ja vai na 2a vez?
					BR.NZ 		TempObstTrue			;Se sim, salta para o true
TempObstFalse:				INC 		M[ContadorTemp]			;Se nao, aumenta a variavel e sai
					BR 		SaiDoTemp
TempObstTrue:				MOV 		M[ContadorTemp], R0		;Se sim: reinicia o contador
					CALL 		Obstaculos			;Corre Obstaculos
SaiDoTemp:				RET

;  ZONA IV.IV ROTINAS DE LIMITES -----------------------------------------------
;_|        _|_|_|  _|      _|  _|_|_|  _|_|_|_|_|  _|_|_|_|    _|_|_|
;_|          _|    _|_|  _|_|    _|        _|      _|        _|
;_|          _|    _|  _|  _|    _|        _|      _|_|_|      _|_|
;_|          _|    _|      _|    _|        _|      _|              _|
;_|_|_|_|  _|_|_|  _|      _|  _|_|_|      _|      _|_|_|_|  _|_|_|
; EscreveLimites:	Evoca a rotina EscreveLimite e da lhe parametros atraves da
;					pilha para escrever os limites superior e inferior
;						Entradas: ---
;						Saidas: pilha
;						Efeitos: ---
EscreveLimites:				PUSH		sup_esquerdo
					PUSH		sup_direito
					CALL		EscreveLimite
					PUSH		inf_esquerdo
					PUSH		inf_direito
					CALL		EscreveLimite
					RET

;  ZONA IV.V ROTINA INICIAL ----------------------------------------------------
; _|_|_|  _|      _|  _|_|_|    _|_|_|  _|_|_|    _|_|    _|
;   _|    _|_|    _|    _|    _|          _|    _|    _|  _|
;   _|    _|  _|  _|    _|    _|          _|    _|_|_|_|  _|
;   _|    _|    _|_|    _|    _|          _|    _|    _|  _|
; _|_|_|  _|      _|  _|_|_|    _|_|_|  _|_|_|  _|    _|  _|_|_|_|
;Inicio:	Desenha um mapa de jogo e uma nave permitindo o seu deslocamento
;		em resposta a botoes, estando limitado pelas dimensoes mapa
Inicio:				MOV		R7, SP_INICIAL
				MOV		SP, R7
				MOV		R7, INT_MASK 			;MASK jogo
				MOV		M[INT_MASK_ADDR], R7
				MOV		R1, FFFFh
				MOV		M[FFFCh], R1
				MOV		R1, pos_canhao_i		;Definir posicao inicial do canhao
				MOV		M[Canhao_pos], R1
				ENI
				CALL		EscreveMsgIni
				CALL		EsperaInicio			;Aguardar pela resposta do utilizador
				CALL		LimpaFlags
				CALL		EscreveLimites			;Escrever nave e limites
				PUSH		M[Canhao_pos]
				CALL		EscreveNave
				CALL		Chamar_Temp
				CALL 		EscreveLCD
				CALL 		LCDCanhaoPos

				JMP		Jogo

;  ZONA IV.V ROTINA PRINCIPAL --------------------------------------------------
; _|      _|    _|_|    _|_|_|  _|      _|
; _|_|  _|_|  _|    _|    _|    _|_|    _|
; _|  _|  _|  _|_|_|_|    _|    _|  _|  _|
; _|      _|  _|    _|    _|    _|    _|_|
; _|      _|  _|    _|  _|_|_|  _|      _|
; Jogo:	Verifica se algum interruptor foi acionado e corre a rotina correspontente
Jogo:				CMP		M[IntNav], R0
				CALL.NZ		Nave
				CMP		M[IntTiro], R0
				CALL.NZ 	CriaTiro
				CMP		M[IntTemp], R0
				CALL.NZ		Temporizador
				BR		Jogo

;  ZONA IV.V ROTINA PSEUDO ALEATORIA --------------------------------------------
;      :::::::::      :::     ::::    ::: :::::::::   ::::::::    :::   :::          ::::::::  :::::::::: ::::    ::: :::::::::: :::::::::      ::: ::::::::::: ::::::::  :::::::::          :::::::::   ::::::::   :::::::: ::::::::::: ::::::::::: ::::::::::: ::::::::  ::::    :::
;     :+:    :+:   :+: :+:   :+:+:   :+: :+:    :+: :+:    :+:  :+:+: :+:+:        :+:    :+: :+:        :+:+:   :+: :+:        :+:    :+:   :+: :+:   :+:    :+:    :+: :+:    :+:         :+:    :+: :+:    :+: :+:    :+:    :+:         :+:         :+:    :+:    :+: :+:+:   :+:
;    +:+    +:+  +:+   +:+  :+:+:+  +:+ +:+    +:+ +:+    +:+ +:+ +:+:+ +:+       +:+        +:+        :+:+:+  +:+ +:+        +:+    +:+  +:+   +:+  +:+    +:+    +:+ +:+    +:+         +:+    +:+ +:+    +:+ +:+           +:+         +:+         +:+    +:+    +:+ :+:+:+  +:+
;   +#++:++#:  +#++:++#++: +#+ +:+ +#+ +#+    +:+ +#+    +:+ +#+  +:+  +#+       :#:        +#++:++#   +#+ +:+ +#+ +#++:++#   +#++:++#:  +#++:++#++: +#+    +#+    +:+ +#++:++#:          +#++:++#+  +#+    +:+ +#++:++#++    +#+         +#+         +#+    +#+    +:+ +#+ +:+ +#+
;  +#+    +#+ +#+     +#+ +#+  +#+#+# +#+    +#+ +#+    +#+ +#+       +#+       +#+   +#+# +#+        +#+  +#+#+# +#+        +#+    +#+ +#+     +#+ +#+    +#+    +#+ +#+    +#+         +#+        +#+    +#+        +#+    +#+         +#+         +#+    +#+    +#+ +#+  +#+#+#
; #+#    #+# #+#     #+# #+#   #+#+# #+#    #+# #+#    #+# #+#       #+#       #+#    #+# #+#        #+#   #+#+# #+#        #+#    #+# #+#     #+# #+#    #+#    #+# #+#    #+#         #+#        #+#    #+# #+#    #+#    #+#         #+#         #+#    #+#    #+# #+#   #+#+#
;###    ### ###     ### ###    #### #########   ########  ###       ###        ########  ########## ###    #### ########## ###    ### ###     ### ###     ########  ###    ###         ###         ########   ######## ###########     ###     ########### ########  ###    ####
; PseudoRndm:
PseudoRndm:  			PUSH  		R1
				PUSH 		R2
				PUSH 		R3
				PUSH 		R4
				MOV 		R1, 0001h			;R1 igual a 0000 0000 0000 0001b
				MOV  		R2, M[RandomNumb]
				MOV 		R4, 20				;24 linhas -2 duas dos limites -2
				MOV 		R3, R2  			;adjacentes aos limites
				AND 		R3, R1				;Armazena em R3 o bit de menor peso
				CMP 		R3, R0
				BR.NZ 		PseudoElse
				ROR 		R2, 1
				BR		FimPseudo
PseudoElse:			XOR 		R2, INT_MASK
				ROR 		R2, 1
FimPseudo: 			MOV 		M[RandomNumb], R2
				DIV 		R2, R4				;Guarda o resultado em R2 e o resto em R4
				MOV		M[SP+6], R4
				POP 		R4
				POP 		R3
				POP 		R2
				POP 		R1
				RET

;  ZONA IV.VI ROTINA FINAL ------------------------------------------------------
; _|_|_|_|  _|_|_|  _|      _|
; _|          _|    _|_|  _|_|
; _|_|_|      _|    _|  _|  _|
; _|          _|    _|      _|
; _|        _|_|_|  _|      _|
; Final:
Final:				MOV		R7, INT_MASK2			;MASK2 durante a mesnagem final
				MOV		M[INT_MASK_ADDR], R7
				ENI
				CALL		LimparEcra
				CALL		EscreveMsgFin
				CALL		EsperaFim
				CALL		LimparMemorias
				CALL		LimparEcra
				JMP 		Inicio

Fim:				BR		Fim
