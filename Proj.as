;					~~~
;	<<< Joao Daniel Silva 86445, Francisco Sousa, 86416 >>>
;					~~~
; ZONA I:  CONSTANTES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FIM_TEXTO			EQU		'@'
LIMITE				EQU		'#'
ESPACO				EQU		' '
NAVECAR1			EQU		'>'
NAVECAR2			EQU		')'
NAVECAR3			EQU		'\'
NAVECAR4			EQU		'/'
BALA				EQU		'-'
ASTERISCO			EQU 		'*'
BNEGRO 				EQU 		'o'
NOMAXTIROS			EQU		50
NOMAXOBST			EQU		0010h				;16
PERIODAST			EQU		5
PERIODBUR			EQU		3
INT_MASK			EQU		1100000000011111b
INT_MASK2 			EQU 		0111111111111111b
SP_INICIAL			EQU		F0FFh
LCD_WRITE			EQU		FFF5h
TEMP_DURACAO			EQU		FFF6h
TEMP_CONTROLO			EQU		FFF7h
INT_MASK_ADDR			EQU		FFFAh
IO_CONTROLO			EQU		FFFCh
IO_STATUS			EQU		FFFDh
IO_WRITE			EQU		FFFEh
IO_READ				EQU		FFFFh
sup_esquerdo			EQU		0000h				;(0a linha, 0a coluna (00,00))
sup_direito			EQU		004Eh				;(0a linha, 78a coluna (00,78))
inf_esquerdo			EQU		1700h				;(23a linha, 0a coluna(23,00))
inf_direito			EQU		174Eh				;(23a linha, 78a coluna(23,78))
pos_canhao_i			EQU		0401h				;(04a linha, 01a coluna(04,01))
pos_VarText1			EQU		0B23h				;(12a linha, 35a coluna)
pos_VarText2			EQU		0D20h				;(14a linha, 32a coluna)
pos_TextFim 			EQU 		0B23h   			;(12a linha, 35a coluna)
pos_TextPonts 			EQU 		0D23h   			;(14a linha, 35a coluna)

; ZONA II:  VARIAVEIS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				ORIG		8000h
IntNav				WORD		0
IntTiro				WORD		0
IntE				WORD		0
IntTemp				WORD		0
Flag_Reset 			WORD 		0
Canhao_pos			WORD		0
Canhao_int			WORD		0
NoTiros				WORD		0
NoObstaculos			WORD 		0
RandomNumb 			WORD 		0
PosUltAst 			WORD  		0
ContaBuracoN 			WORD 		0
ContadorTemp			WORD 		0
VarTexto1			STR		'Prepare-se', FIM_TEXTO
EspacoVar1			STR		'          ', FIM_TEXTO
VarTexto2			STR		'Prima o botao IE', FIM_TEXTO
EspacoVar2			STR		'                ', FIM_TEXTO
VarTextFim			STR 		'Fim do Jogo', FIM_TEXTO
EspacoTxtF			STR		'           ', FIM_TEXTO
VarTextPonts 			STR 		'Pontuacao: ', FIM_TEXTO
EspacoTxtP 			STR 		'           ', FIM_TEXTO
Tiro				TAB		NOMAXTIROS			;tabela com as posicoes dos tiros
Obstaculo			TAB 		NOMAXOBST			;tabela com as posicoes dos obstaculos
CarObstaculo 			TAB 		NOMAXOBST 			;tabela com os carateres dos obstaculos

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
;		conjunto de instrucoes Assembly, ordenadas de forma a realizar
;		as funcoes pretendidas
				ORIG		0000h
				JMP		Inicio

;  ZONA IV.I: ROTINAS DE INTERRUPCAO -------------------------------------------
;_|_|_|  _|      _|  _|_|_|_|_|  _|_|_|_|  _|_|_|    _|_|_|    _|    _|  _|_|_|
;  _|    _|_|    _|      _|      _|        _|    _|  _|    _|  _|    _|  _|    _|
;  _|    _|  _|  _|      _|      _|_|_|    _|_|_|    _|_|_|    _|    _|  _|_|_|
;  _|    _|    _|_|      _|      _|        _|    _|  _|    _|  _|    _|  _|
;_|_|_|  _|      _|      _|      _|_|_|_|  _|    _|  _|    _|    _|_|    _|
Descer:				INC		M[IntNav]
				MOV		R1,0100h
				MOV		M[Canhao_int], R1
				RTI

Subir:				INC		M[IntNav]
				MOV		R1,0100h
				NEG		R1
				MOV		M[Canhao_int], R1
				RTI

Esquerda:			INC		M[IntNav]
				MOV		R1,0001h
				NEG		R1
				MOV		M[Canhao_int], R1
				RTI

Direita:			INC		M[IntNav]
				MOV		R1,0001h
				MOV		M[Canhao_int], R1
				RTI

Disparar:			INC		M[IntTiro]
				RTI

ResetJogo:			INC  		M[Flag_Reset]
				RTI

Comecar:			INC		M[IntE]
				RTI

Temporizar:			INC		M[IntTemp]
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
EscCar:				PUSH		R1
				PUSH		R2
				MOV		R2, M[SP+5]
				MOV		M[IO_CONTROLO], R2
				MOV		R1, M[SP+4]
				MOV		M[IO_WRITE], R1
				POP		R2
				POP		R1
				RETN		2

; EscString:Rotina que efectua a escrita de uma cadeia de caracter, terminada
;			pelo caracter FIM_TEXTO.
;				Entradas: R2 - apontador para o inicio da cadeia de caracteres
;				Saidas: ---
;				Efeitos: ---
EscString:			PUSH		R1
				PUSH		R2
				PUSH		R3
				MOV		R2, M[SP+6]
				MOV		R3, M[SP+5]
CicloEscStr:			MOV		R1, M[R2]			;Carater de uma cadeia
				CMP		R1, FIM_TEXTO
				BR.Z		FimEscStr
				PUSH		R3				;posicao de escrita
				PUSH		R1				;carater a ser escrito
				CALL		EscCar
				INC		R2
				INC		R3
				BR		CicloEscStr
FimEscStr:			POP		R3
				POP		R2
				POP		R1
				RETN		2

;  EscreveNave:	Evoca a rotina EscCar para escrever a nave na janela de texto
;			Entradas: pilha - posicao do canhao
;			Saidas: ---
;			Efeitos:
EscreveNave:			PUSH		R1
				MOV		R1, M[SP+3]
				PUSH		R1
				PUSH		NAVECAR1
				CALL		EscCar
				SUB		R1, 1
				PUSH		R1
				PUSH		NAVECAR2
				CALL		EscCar
				SUB		R1, 0100h
				PUSH		R1
				PUSH		NAVECAR3
				CALL		EscCar
				ADD		R1, 0200h
				PUSH		R1
				PUSH		NAVECAR4
				CALL		EscCar
				POP		R1
				RETN		1

;ApagaNave:	Evoca a rotina EscCar para apagar a nave da janela
;			de texto
;				Entradas: pilha - posicao do canhao
;				Saidas: ---
;				Efeitos:
ApagaNave:			PUSH		R1
				MOV		R1, M[Canhao_pos]
				PUSH		R1
				PUSH		ESPACO
				CALL		EscCar
				SUB		R1,1
				PUSH		R1
				PUSH		ESPACO
				CALL		EscCar
				SUB		R1,0100h
				PUSH		R1
				PUSH		ESPACO
				CALL		EscCar
				ADD		R1,0200h
				PUSH		R1
				PUSH		ESPACO
				CALL		EscCar
				POP		R1
				RET


EscreveMsgIni:			PUSH		VarTexto1			;Escrever a mensagem inicial
				PUSH		pos_VarText1
				CALL		EscString
				PUSH		VarTexto2
				PUSH		pos_VarText2
				CALL		EscString
				RET

EscreveMsgFin:			PUSH		VarTextFim			;Escrever a mensagem final
				PUSH		pos_VarText1
				CALL		EscString
				PUSH		VarTextPonts
				PUSH		pos_VarText2
				CALL		EscString
				RET

EsperaInicio:			CMP		M[IntE], R0
				BR.NZ		ApagaInicio
				INC 		M[RandomNumb]
				BR		EsperaInicio

ApagaInicio:			DEC 		M[IntE]
				PUSH		EspacoVar1
				PUSH		pos_VarText1
				CALL		EscString

				PUSH		EspacoVar2
				PUSH		pos_VarText2
				CALL		EscString
				RET

EsperaFim:  			CMP		M[IntNav], R0
				BR.NZ		ApagaFim
				CMP		M[IntTiro], R0
				BR.NZ		ApagaFim
				CMP		M[Flag_Reset], R0
				BR.NZ		ApagaFim
				CMP		M[IntE], R0
				BR.NZ		ApagaFim
				BR 		EsperaFim

ApagaFim:			MOV 		M[IntNav],R0
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

;  EscreveLimite:Evoca a rotina EscCar para escrever uma linha de limite
;				Entradas: pilha - coordenada do inicio e fim do limite
;				Saidas: ---
;				Efeitos: ---
EscreveLimite:			PUSH		R1
				MOV		R1, M[SP+4]			;limite inferior
CicloLim:			CMP		R1, M[SP+3]			;limite superior
				BR.P		FimEscLim
				PUSH		R1
				PUSH		LIMITE
				CALL		EscCar
				INC		R1
				BR		CicloLim
FimEscLim:			POP		R1
				RETN		2

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
Nave:				PUSH		R1
				PUSH		R3
				DSI
				DEC		M[IntNav]			;Reinicia a flag do mov da nave
				MOV		R1, M[Canhao_pos]
				ADD		R1, M[Canhao_int]		;Mete em R1 a posi nova da nave
ChocaSuperior:			CMP		R1, 0200h			;Choca com o limite superior?
				BR.NP		FimNave
ChocaInferior:			CMP		R1, 1600h			;Choca com o limite inferior?
				BR.NN		FimNave
ChocaEsquerda:			MOV		R3, R0
				MVBL		R3, R1
				CMP		R3, 0000h			;Choca com o limite da esquerda?
				BR.NP		FimNave
ChocaDireita:			MOV		R3, R0				;SERAO ESTAS LINHAS OPCIOONAIS AAOMSAOMAIOSA
				MVBL		R3, R1
				CMP		R3, 004Fh			;Choca com o limite da direita?
				BR.NN		FimNave
DentroMapa:			PUSH		R1				;Esta dentro, pode escrever nave
				CALL		ApagaNave
				CALL		EscreveNave
				MOV		M[Canhao_pos], R1
				;MOV		M[LCD_WRITE], R1
FimNave:			ENI
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

;Asteroides
Asteroides:			PUSH		R1
				PUSH		R2
				PUSH		R3
				PUSH		R4
				PUSH		R5
				CALL 		GeraObstaculos			;Gera ou nao obstaculos
				MOV		R1, 0001h
				MOV		R2, Obstaculo			;Em R2 mete a posi de mem do 1o obstaculos
				MOV		R5, CarObstaculo		;Em R5 a posi de mem do car do 1o obstaculo
				MOV		R4, M[NoObstaculos]		;Em R4 mete o n de obstaculos a verificar
HaveraAsts:			CMP		R4, R0				;Todos os obstaculos verificados?
				BR.Z		SaiDosAsts			;Se sim, nao move nada

TestaMemAsts:			CMP		M[R2], R0			;Testa se ha obstaculos na posicao R2
				BR.NZ		MoveAsteroide			;Se houver, usa essa posicao
				INC		R2				;Se nao, verifica na proxima
				INC		R5				;A posi de mem do car acompanha
				BR		TestaMemAsts
MoveAsteroide:			DEC		R4				;Diminui o n de obstaculos a verificar
				MOV		R3, M[R2]			;Escreve em R3 a posicao do obstaculo
				SUB		R3, R1				;Calcula a nova posicao
				PUSH		M[R2]				;Manda a posicao inicial
				PUSH		R3				;Manda a posicao seguinte
				PUSH		R2				;Manda o endereco de memoria
				PUSH		M[R5]				;Manda o caracter
				CALL		VeriColisoes			;Verifica colisoes e move ou nao
				INC		R2				;Aumenta a posi de mem a verificar
				INC		R5				;A posi de mem dos caracteres acompanha
				BR		HaveraAsts			;Repete para a proxima posi de mem
SaiDosAsts:			POP 		R5
				POP		R4
				POP		R3
				POP		R2
				POP		R1
				RET




;GeraObstaculos
GeraObstaculos: 		PUSH		R1
				PUSH		R2
				INC 		M[PosUltAst]
				MOV		R1, PERIODAST
				CMP 		M[PosUltAst], R1		;Ve se ja passaram 5 posis
				BR.NZ		FimGeraAst			;Se nao, sai
				MOV  		M[PosUltAst],R0			;Se sim, reinicia contador
				MOV		R1, PERIODBUR
				MOV		R2, M[ContaBuracoN]
				CMP 		R2, R1				;Ja passaram 3 asteroides?
				BR.NZ 		GeraAstFalse			;Se nao, salta para false
GeraAstTrue:			MOV		M[ContaBuracoN], R0		;Se sim, reinicia o contador do buraco negro
				PUSH 		BNEGRO				;Manda buraco negro e cria obstaculo
				BR 		ContGeraAst
GeraAstFalse:			INC 		M[ContaBuracoN]			;Se nao: incrementa o contador para criar o buraco negro
				PUSH		ASTERISCO			;Manda asteroide e cria obstaculo
ContGeraAst:			CALL 		CriaObstaculo
FimGeraAst:			POP		R2
				POP		R1
				RET



;CriaObstaculo
CriaObstaculo: 			PUSH 		R1
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
TestaMemCObst: 			CMP 		M[R2], R0			;Ja ha algum tiro nesta posi?
				BR.Z 		GuardaObst			;Se nao, guarda nessa posi (salto)
				INC 		R2				;Se houver, verifica na proxima
				INC 		R3
				BR		TestaMemCObst
GuardaObst: 			PUSH		R0
				CALL 		PseudoRndm			;Se nao: gera numero random
				POP		R1				;Em R5 o numero random
				SHL		R1, 8
				ADD		R1, 024Eh
				MOV 		M[R2], R1			;A posicao do obstaculo eh o numero random
				MOV 		M[R3], R4			;Mete o tipo de obstaculo na memoria
SaiDosCObst:			POP 		R4
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
CriaTiro:			PUSH		R1
				PUSH		R2
				DEC		M[IntTiro]			;Reinicia a flag dos tiros
				MOV		R1, NOMAXTIROS
				CMP		M[NoTiros], R1			;Numero max de tiros foi atingido?
				BR.Z		SaiDoCTiros			;Se sim, nao cria nada,sai do ciclo
				INC		M[NoTiros]			;Adiciona novo tiro
				MOV		R2, Tiro			;Em R2 mete a posi de mem do 1o tiro
TestaMemCTiro:			CMP		M[R2], R0			;Ja ha algum tiro nessa posi
				BR.Z		GuardaTiro			;Se nao, guarda nessa posi
				INC		R2				;Se houver, verifica na proxima posi
				BR		TestaMemCTiro
GuardaTiro:			MOV 		R1, M[Canhao_pos]		;Se nao: Tiro na posi a seguir ao canhao
				ADD		R1, 0001h
				MOV		M[R2], R1
SaiDoCTiros:			POP		R2
				POP		R1
				RET

;Tiros
Tiros:				PUSH		R1
				PUSH		R2
				PUSH		R3
				PUSH		R4
				MOV		R1, 0001h
				MOV		R2, Tiro			;Em R2 mete a posi de mem do 1o tiro
				MOV		R4, M[NoTiros]			;Em R4 mete o n de tiros a verificar
HaveraTiros:			CMP		R4, R0				;Todos os tiros verificados?
				BR.Z		SaiDosTiros			;Se sim, nao move nada

TestaMemTiro:			CMP		M[R2], R0			;Testa se ha tiros na posicao R2
				BR.NZ		MoveTiro			;Se houver, usa essa posicao
				INC		R2				;Se nao, verifica na proxima
				BR		TestaMemTiro

MoveTiro:			DEC		R4				;Diminui o n de tiros a verificar
				MOV		R3, M[R2]
				ADD		R3, R1				;Calcula a nova posicao

				PUSH		M[R2]				;Manda a posicao inicial
				PUSH		R3				;Manda a posicao seguinte
				PUSH		R2				;Manda o endereco de memoria
				PUSH		BALA				;Manda o caracter
				CALL		VeriColisoes
				INC		R2
				BR		HaveraTiros			;Repete para a proxima posi de mem
SaiDosTiros:			POP		R4
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
;Vericolisoes Recebe como argumentos a posicao inicial, a proxima posicao e o tipo de caracter
VeriColisoes:			PUSH		R1
				PUSH		R2
				PUSH		R3
				PUSH		R4
				PUSH		R5
				MOV		R1, M[SP+000Ah]			;Recebe a posicao inicial, em R1
				MOV		R2, M[SP+9]			;Recebe a posicao seguinte, em R2
				MOV		R3, M[SP+8]			;Recebe o endereco de memoria da posicao, em R3
				MOV		R4, M[SP+7]			;Recebe o caracter, em R4
				;PUSH		R2
				;PUSH		R4
				;CALL		EscCar
				MOV		R5, R0
				MVBL		R5, R2
				CMP		R5, 0000h			;Choca com o limite da esquerda?
				BR.P		ColLimEsq			;Se chocar eh porque eh obstaculo
				PUSH		R1				;Posi ini
				PUSH		R3				;Endereco mem
				CALL		ApagaObstaculo
				JMP		SaiDasColisoes
ColLimEsq:			CMP		R5, 004Fh			;Choca com o limite da direita?
				BR.N		ColBala				;Se chocar eh porque eh tiro
				PUSH		R1
				PUSH		R3
				CALL		ApagaTiro
				JMP		SaiDasColisoes
ColBala:			CMP		R4, BALA
				JMP.NZ		EscreveObjecto			;Se nao for um tiro
				PUSH		R0				;Guarda espaco para o retorno
				PUSH		Obstaculo			;Manda o endereco inicial da tabela a percorrer
				PUSH		R2				;Manda a posicao a verificar
				PUSH		M[NoObstaculos]			;Manda o no de obstaculos no ecra
				CALL		HaAlgoLa
				POP		R5				;Em R5, 0 se nao, ou um endereco de memoria do que colide
				CMP		R5, R0
				JMP.NZ		ColTiroObs
EscreveObjecto:			PUSH		R1				;Apagar o objecto do ecra
				PUSH		ESPACO
				CALL		EscCar
				PUSH		R2				;Escrever na posicao a seguir
				PUSH		R4
				CALL		EscCar
				MOV		M[R3], R2			;Escreve a nova posicao na memoria
SaiDasColisoes:			POP		R5
				POP		R4
				POP		R3
				POP		R2
				POP		R1
				RETN		4

ColTiroObs:			MOV		R4, R5				;Em R4 o endereço de memoria do obstaculo
				SUB		R5, Obstaculo
				ADD		R5, CarObstaculo		;Em R5 o endereço de mem do caracter
				MOV		R2, BNEGRO
				CMP		M[R5], R2
				BR.Z		ColTirosObsFim			;Se for buraco negro salta para o fim
				PUSH		M[R4]				;Posi ini
				PUSH		R4				;Endereco de mem
				CALL		ApagaObstaculo
ColTirosObsFim:			PUSH		R1				;Posi ini
				PUSH		R3				;Endereco de mem
				CALL		ApagaTiro
				JMP		SaiDasColisoes


ApagaTiro:			PUSH		R1				;Posi inicial
				PUSH		R3				;Endereco de mem
				MOV		R1, M[SP+5]
				MOV		R3, M[SP+4]
				PUSH		R1				;Apagar do ecra
				PUSH		ESPACO
				CALL		EscCar
				MOV		M[R3], R0			;Apagar da memoria
				DEC		M[NoTiros]			;Decrementar o no de tiros no ecra
				POP		R3
				POP		R1
				RETN		2

ApagaObstaculo:			PUSH		R1				;Recebe posi inicial
				PUSH		R3				;Recebe o endereco de memoria
				PUSH		R5
				MOV		R1, M[SP+6]
				MOV		R3, M[SP+5]
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

HaAlgoLa:			PUSH		R1
				PUSH		R2
				PUSH		R3
				MOV		R1, M[SP+7]			;Recebe o endereco inicial da tabela
				MOV		R2, M[SP+6]			;Recebe a posicao a verificar
				MOV		R3, M[SP+5]			;Recebe o no de enderecos ocupados
HaveraAlgo:			CMP		R3, R0				;Todos os enderecos verificados?
				BR.Z		SaiDoHaAlgo			;Se sim, sai
TestaMemAlgo:			CMP		M[R1], R0			;Testa se o endereco esta vazio
				BR.NZ		TestaAlgo			;Se nao estiver, usa esse endereco
				INC		R1				;Se estiver, verifica o proximo
				BR		TestaMemAlgo
TestaAlgo:			DEC		R3				;Dec o no de posis ocupadas por verificar
				CMP		M[R1], R2			;O que esta na posi eh a posicao?
				JMP.Z		EncontreiOAlgo			;Se sim, salta
				INC		R1				;Se nao, muda o endereco a verificar
				BR		HaveraAlgo
EncontreiOAlgo:			MOV		M[SP+8], R1
SaiDoHaAlgo:			POP		R3
				POP		R2
				POP		R1
				RETN		3

;_|_|_|_|_|  _|_|_|_|  _|      _|  _|_|_|      _|_|    _|_|_|    _|_|_|
;    _|      _|        _|_|  _|_|  _|    _|  _|    _|  _|    _|    _|
;    _|      _|_|_|    _|  _|  _|  _|_|_|    _|    _|  _|_|_|      _|
;    _|      _|        _|      _|  _|        _|    _|  _|    _|    _|
;    _|      _|_|_|_|  _|      _|  _|          _|_|    _|    _|  _|_|_|

Chamar_Temp:			PUSH		R7
				MOV		R7, 0001h
				MOV		M[TEMP_DURACAO], R7
				MOV		R7, 0001h
				MOV		M[TEMP_CONTROLO], R7
				POP		R7
				RET

Temporizador:			DEC		M[IntTemp]
				CALL		Chamar_Temp
				CALL		Tiros
				CMP 		M[ContadorTemp], R0		;Ja vai na 2a vez?
				BR.NZ 		TempAstTrue			;Se sim, salta para o true
TempAstFalse:			INC 		M[ContadorTemp]			;Se nao, aumenta a variavel e sai
				BR 		SaiDoTemp
TempAstTrue:			MOV 		M[ContadorTemp], R0		;Se sim: reinicia o contador
				CALL 		Asteroides			;Corre asteroides
SaiDoTemp:			RET

;  ZONA IV.IV ROTINAS DE LIMITES -----------------------------------------------
;_|        _|_|_|  _|      _|  _|_|_|  _|_|_|_|_|  _|_|_|_|    _|_|_|
;_|          _|    _|_|  _|_|    _|        _|      _|        _|
;_|          _|    _|  _|  _|    _|        _|      _|_|_|      _|_|
;_|          _|    _|      _|    _|        _|      _|              _|
;_|_|_|_|  _|_|_|  _|      _|  _|_|_|      _|      _|_|_|_|  _|_|_|
;  EscreveLimites:	Evoca a rotina EscreveLimite e da lhe parametros atraves da
;					pilha para escrever os limites superior e inferior
;						Entradas: ---
;						Saidas: pilha
;						Efeitos: ---
EscreveLimites:			PUSH		sup_esquerdo
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
;Programa que desenha um mapa de jogo e uma nave permitindo o seu deslocamento
;em resposta a butoes, estando limitado pelas dimensoes mapa
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

				CALL		EscreveLimites			;Escrever nave e limites
				PUSH		M[Canhao_pos]
				CALL		EscreveNave
				CALL		Chamar_Temp

				JMP		Jogo

;  ZONA IV.V ROTINA PRINCIPAL --------------------------------------------------
; _|      _|    _|_|    _|_|_|  _|      _|
; _|_|  _|_|  _|    _|    _|    _|_|    _|
; _|  _|  _|  _|_|_|_|    _|    _|  _|  _|
; _|      _|  _|    _|    _|    _|    _|_|
; _|      _|  _|    _|  _|_|_|  _|      _|
;  Verifica se algum interruptor foi acionado e corre a rotina correspontente
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
;  Programa que
Final:				MOV		R7, INT_MASK2			;MASK2 durante a mesnagem final
				MOV		M[INT_MASK_ADDR], R7
				CALL		EscreveMsgFin
				CALL		EsperaFim
				JMP 		Inicio

Fim:				BR		Fim
