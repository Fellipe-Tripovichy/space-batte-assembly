; ------- TABELA DE CORES -------
; adicione ao caracter para Selecionar a cor correspondente

; 0 branco						0000 0000
; 512 verde						0010 0000
; 1792 prata						0111 0000
; 2048 cinza						1000 0000
; 3072 azul						1100 0000
; 3584 aqua						1110 0000
; 3840 branco						1111 0000

;----------------------------------------------------

jmp main
MsnTop: string "             SPACE BATTLE                "
Msn0: string "        FIM DE JOGO!          "
Msn1: string "    TENTAR NOVAMENTE? S/N          "
Msn2: string "                SCORE:      "

Letra: var #1		; Contem a letra que foi digitada

posNave: var #1			; Contem a posicao atual da Nave
posAntNave: var #1		; Contem a posicao anterior da Nave

posAlien: var #1		; Contem a posicao atual do Alien
posAntAlien: var #1		; Contem a posicao anterior do Alien

posTorpedo: var #1			; Contem a posicao atual do Torpedo
posAntTorpedo: var #1		; Contem a posicao anterior do Torpedo
FlagTorpedo: var #1		; Flag para ver se disparou ou nao (Barra de Espaco!!)
score: var #1
remains: var #1

;--------------- Codigo principal ---------------
main:
	
	call EncerrarTela
	loadn R1, #telaInicialLinha0	; Endereco onde comeca a primeira linha do cenario!!
	loadn R2, #0512  				
	call ShowTela2   			;  Rotina de Impresao de Cenario na Tela Inteira  
	
	call Intro
	call EncerrarTela	
	
	loadn R1, #tela2Linha0	; Endereco onde comeca a primeira linha do cenario!!
	loadn R2, #3072  			
	call ShowTela2   		;  Rotina de Impresao de Cenario na Tela Inteira

	loadn R1,#8
	loadn R2,#'9'
	call ImprimeRemains

	loadn R1,#20
	loadn R2,#'0'
	call ImprimeScore


	loadn R0, #160	
	store posNave, R0		; Zera Posicao Atual da Nave
	store posAntNave, R0	; Zera Posicao Anterior da Nave
	
	loadn R1, #0
	store FlagTorpedo, R1		; Zera o Flag para marcar que ainda nao disparou!
	store posTorpedo, R0		; Zera Posicao Atual do Torpedo
	store posAntTorpedo, R0	; Zera Posicao Anterior do Torpedo
	
	loadn R0, #1195
	store posAlien, R0		; Zera Posicao Atual do Alien
	store posAntAlien, R0	; Zera Posicao Anterior do Alien
	
	loadn R0, #0			; Contador para os Mods	= 0
	loadn R2, #0			; Para verificar se (mod(c/10)==0

	Loop:
	
		loadn R1, #10
		mod R1, R0, R1
		cmp R1, R2		; if (mod(c/10)==0
		ceq MoveNave	; Chama Rotina de movimentacao da Nave
	
		loadn R1, #30
		mod R1, R0, R1
		cmp R1, R2		; if (mod(c/30)==0
		ceq MoveAlien	; Chama Rotina de movimentacao do Alien
	
		loadn R1, #2
		mod R1, R0, R1
		cmp R1, R2		; if (mod(c/2)==0
		ceq MoveTorpedo	; Chama Rotina de movimentacao do Torpedo
	
		call Delay
		inc R0 
		jmp Loop
	rts
	

ImprimeRemains:
	outchar R2, R1
	dec R2
	store remains,R2
	rts


ImprimeScore:
	store score,R2
	outchar R2, R1 
	

	
MoveNave:
	push r0
	push r1
	
	call MoveNave_RecalculaPos		; Recalcula Posicao da Nave

; So Apaga e Redesenha se (pos != posAnt)
;	If (posNave != posAntNave)	{	
	load r0, posNave
	load r1, posAntNave
	cmp r0, r1
	jeq MoveNave_Skip
		call MoveNave_Apaga
		call MoveNave_Desenha		;}
  MoveNave_Skip:
	
	pop r1
	pop r0
	rts

	
MoveNave_Apaga:		; Apaga a Nave preservando o Cenario!
	push R0
	push R1
	push R2
	push R3
	push R4
	push R5	

	load R0, posAntNave	; R0 = posAnt
	
	; As linhas a seguir consideram a existencia de um cenario
	loadn R1, #tela1Linha0	; Endereco onde comeca a primeira linha do cenario!!
	add R2, R1, r0	; R2 = tela2Linha0 + posAnt
	loadn R4, #40
	div R3, R0, R4	; R3 = posAnt/40
	add R2, R2, R3	; R2 = tela2Linha0 + posAnt + posAnt/40
	
	loadn R5, #' '	; R5 = Char (Tela(posAnt))
	
	outchar R5, R0	; Apaga arco 3
	dec R0
	outchar R5, R0	; Apaga pes Nave
	inc R0
	sub R0, R0, R4	; Subtrai 40 da posicao para apagar o arco 2
	outchar R5, R0	; Apaga o arco 2
	dec R0
	outchar R5, R0	; Apaga o tronco do Nave
	inc R0
	sub R0, R0, R4	; Subtrai 40 da posicao para apagar o arco 1
	outchar R5, R0	; Apaga o arco 1
	dec R0
	outchar R5, R0	; Apaga a cabeca do Nave	
	
	pop R5
	pop R4
	pop R3
	pop R2
	pop R1
	pop R0
	rts
	
MoveNave_RecalculaPos:		; Recalcula posicao da Nave em funcao das Teclas pressionadas
	push R0
	push R1
	push R2
	push R3

	load R0, posNave
	
	inchar R1				; Le Teclado para controlar a Nave
		
	loadn R2, #'w'
	cmp R1, R2
	jeq MoveNave_RecalculaPos_W
		
	loadn R2, #'s'
	cmp R1, R2
	jeq MoveNave_RecalculaPos_S
	
	loadn R2, #' '
	cmp R1, R2
	jeq MoveNave_RecalculaPos_Torpedo
	
  MoveNave_RecalculaPos_Fim:	; Se nao for nenhuma tecla valida, vai embora
	store posNave, R0
	pop R3
	pop R2
	pop R1
	pop R0
	rts  
	
  FazNada:
  	nop
  	jmp MoveNave_RecalculaPos_Fim
  	
  MoveNave_RecalculaPos_W:	; Move Nave para Cima	
	
	; Evitar que o arqueiro se mova para o header
	loadn R1, #40
	cmp R0, R1
	jeq FazNada
	
	loadn R1, #40
	
	cmp R0, R1		; Testa condicoes de Contorno
	jle MoveNave_RecalculaPos_Fim
	sub R0, R0, R1	; pos = pos - 40
	jmp MoveNave_RecalculaPos_Fim

  MoveNave_RecalculaPos_S:	; Move Nave para Baixo
  
  ; Evitar que o arqueiro se mova para o footer
	loadn R1, #1080
	cmp R0, R1
	jeq FazNada
  
	;loadn R1, #1159
	;cmp R0, R1		; Testa condicoes de Contorno 
	;jgr MoveNave_RecalculaPos_Fim
	loadn R1, #40
	add R0, R0, R1	; pos = pos + 40
	jmp MoveNave_RecalculaPos_Fim	
	
  MoveNave_RecalculaPos_Torpedo:	
	loadn R1, #1			; Se ATorpedou:
	store FlagTorpedo, R1		; FlagTorpedo = 1
	store posTorpedo, R0		; posTorpedo = posNave
	

	load R2, remains
	loadn R3, #'0'
	cmp R2, R3
	jle GameOver
	
	loadn R1, #8
	call ImprimeRemains

		
	jmp MoveNave_RecalculaPos_Fim
	call EncerrarTela	


MoveNave_Desenha:	; Desenha caractere da Nave
	push R0
	push R1
	push R2
	
	Loadn R1, #'"'	; Cabeca Nave	
	load R0, posNave
	outchar R1, R0
	
	Loadn R1, #'#'	; Arco 1		
	inc R0
	outchar R1, R0
	
	Loadn R1, #'$'	; Corpo Nave	
	dec R0
	Loadn R2, #40
	add R0, R0, R2
	outchar R1, R0
	
	Loadn R1, #'%'	; Arco 2		
	inc R0
	outchar R1, R0
	
	Loadn R1, #'&'	; Corpo Nave	
	dec R0
	Loadn R2, #40
	add R0, R0, R2
	outchar R1, R0
	
	Loadn R1, #'''	; Arco 2		
	inc R0
	outchar R1, R0
	
	store posAntNave, R0	; Atualiza Posicao Anterior da Nave = Posicao Atual	 
	
	pop R2
	pop R1
	pop R0
	rts

MoveAlien:
	push r0
	push r1
	
	call MoveAlien_RecalculaPos
	
; So Apaga e Redesenha se (pos != posAnt)
;	If (pos != posAnt)	{	
	load r0, posAlien
	load r1, posAntAlien
	cmp r0, r1
	jeq MoveAlien_Skip
		call MoveAlien_Apaga
		call MoveAlien_Desenha		;}
  MoveAlien_Skip:
	
	pop r1
	pop r0
	rts
		
		
MoveAlien_Apaga:
	push R0
	push R4
	push R5

	load R0, posAntAlien	; R0 == posAnt
		loadn r5, #' '		; Se o Torpedo passa sobre o Nave, apaga com um X, senao apaga com o cenario 
  
  ;MoveAlien_Apaga_Fim:	
  	loadn R4, #40
	outchar R5, R0	; Apaga Alien 4
	dec R0
	outchar R5, R0	; Apaga Alien 3
	inc R0
	sub R0, R0, R4
	outchar R5, R0	; Apaga Alien 2
	dec R0
	outchar R5, R0	; Apaga Alien 1	
	
	
	pop R5
	pop R4
	pop R0
	rts

MoveAlien_RecalculaPos:
	push R0
	push R1
	push R2
	push R3
	
	load R0, posAlien
	
 ; Case 1 : posAlien = posAlien -40
   MoveAlien_RecalculaPos_Case1:
	loadn r1, #40
	loadn r2, #80
	sub r0, r0, r1
	cmp r0,r2
		jel RetomaPos
		
  	jmp MoveAlien_RecalculaPos_FimSwitch	; Break do Switch


   RetomaPos:
	loadn R0, #1195
	jmp MoveAlien_RecalculaPos_Case1


 ; Fim Switch:
  MoveAlien_RecalculaPos_FimSwitch:	
	store posAlien, R0	; Grava a posicao alterada na memoria
	pop R3
	pop R2
	pop R1
	pop R0
	rts

MoveAlien_Desenha:
	push R0
	push R1
	push R2
	
	loadn R1, #'{'	; Alien 1
	load R0, posAlien
	outchar R1, R0	
	
	loadn R1, #'|'	; Alien 2
	inc R0
	outchar R1, R0
	
	loadn R1, #'}' ; Alien 3	
	loadn R2, #40
	dec R0
	add R0, R0, R2
	outchar R1, R0
	
	loadn R1, #'~'	; Alien 2
	inc R0
	outchar R1, R0
	
	store posAntAlien, R0	
	
	pop R2
	pop R1
	pop R0
	rts

MoveTorpedo:
	push r0
	push r1
	
	call MoveTorpedo_RecalculaPos

; So Apaga e Redesenha se (pos != posAnt)
;	If (pos != posAnt)	{	
	load r0, posTorpedo
	load r1, posAntTorpedo
	cmp r0, r1
	jeq MoveTorpedo_Skip
		call MoveTorpedo_Apaga
		call MoveTorpedo_Desenha		;}
  MoveTorpedo_Skip:
	
	pop r1
	pop r0
	rts
	
MoveTorpedo_Apaga:
	push R0
	push R1
	push R2
	push R3
	push R4
	push R5	

	; Compara Se (posAntTorpedo == posAntNave)
	load R0, posAntTorpedo	; R0 = posAnt
		loadn R5, #' '		; Se o Torpedo passa sobre o Nave, apaga com um X, senao apaga com o cenario 		

  ;MoveTorpedo_Apaga_Fim:	
	outchar R5, R0	; Apaga o Obj na tela com o Char correspondente na memoria do cenario
	dec R0			; Decrementa a posicao do Obj
	outchar R5, R0	; Apaga o segundo elemento que compoe o Obj
	
	pop R5
	pop R4
	pop R3
	pop R2
	pop R1
	pop R0
	rts


MoveTorpedo_RecalculaPos:
	push R0
	push R1
	push R2
	push R3
	
	load R1, FlagTorpedo	; Se disparou, movimenta a Torpedo!
	loadn R2, #1
	cmp R1, R2			; If FlagTorpedo == 1  Movimenta o Torpedo
	jne MoveTorpedo_RecalculaPos_Fim2	; Se nao vai embora!
	
	load R0, posTorpedo	; Testa se o Torpedo Pegou no Alien
	inc R0
	load R1, posAlien
	loadn R2, #40
	sub R1, R1, R2
	cmp R0, R1			; IF posTorpedo == posAlien  BOOM!!	
		jeq MoveTorpedo_RecalculaPos_Boom
	
	loadn R1, #40		; Testa condicoes de Contorno 
	loadn R2, #39
	mod R1, R0, R1		
	cmp R1, R2			; Se Torpedo chegou na ultima linha
	call MoveTorpedo_Apaga
	jne MoveTorpedo_RecalculaPos_Fim
	loadn R0, #0
	store FlagTorpedo, R0	; Zera FlagTorpedo
	store posTorpedo, R0	; Zera e iguala posTorpedo e posAntTorpedo
	store posAntTorpedo, R0
	jmp MoveTorpedo_RecalculaPos_Fim2	
	
  MoveTorpedo_RecalculaPos_Fim:
	inc R0
	store posTorpedo, R0
  MoveTorpedo_RecalculaPos_Fim2:
  	pop R3	
	pop R2
	pop R1
	pop R0
	rts

  MoveTorpedo_RecalculaPos_Boom:	
  	loadn R3, #'*'
	outchar R3, R1
	call delay2
	call delay2
	call delay2
	loadn R3, #' '
	outchar R3,R1
	
	;Muda o score quando atinge o Alien
	loadn R1, #20
  	load R2, score
  	inc R2
  	call ImprimeScore
  	
	jmp RetomaPos ; apos fazer efeito de atingir o Alien,volta pro inicio
	   		
	
	GameOver:
	loadn R0, #160	
	store posNave, R0		; Zera Posicao Atual da Nave
	store posAntNave, R0	; Zera Posicao Anterior da Nave
	call EncerrarTela
	loadn r0, #40
	loadn r1, #MsnTop
	loadn r2, #0
	call ImprimeStr
	
  
  	loadn r0, #526
	loadn r1, #Msn0
	loadn r2, #0
	call ImprimeStr
	
	;imprime quer jogar novamente	
	loadn r0, #605
	loadn r1, #Msn1
	loadn r2, #0
	call ImprimeStr
	
	loadn r0, #758
	loadn r1, #Msn2
	loadn r2, #0
	call ImprimeStr
	
	loadn R1, #783
	load R2, score
	call ImprimeScore
	
	call DigLetra
	loadn r0, #'s'
	load r1, Letra
	cmp r0, r1				; tecla == 's' ?
	jne MoveTorpedo_RecalculaPos_FimJogo	; tecla nao e 's'
	
	; Se quiser jogar novamente...
	call EncerrarTela
	
	pop r2
	pop r1
	pop r0

	pop r0	; Da um Pop a mais para acertar o ponteiro da pilha, pois nao vai dar o RTS !!
	jmp main

  MoveTorpedo_RecalculaPos_FimJogo:
	call EncerrarTela
	halt



delay2:
	loadn R3,#120000000000000
wait:
	dec R3
	jnz wait
	
MoveTorpedo_Desenha:
	push R0
	push R1
	push R2	
	
	loadn R1, #'('	; Torpedo tras
	load R0, posTorpedo
	loadn R2, #40
	add R0, R0, R2
	outchar R1, R0
	
	
	Loadn R2, #')'	; Torpedo ponta
	inc R0
	outchar R2, R0	
	
	store posAntTorpedo, R0
	
	pop R2
	pop R1
	pop R0
	rts


; ---------- Tela inicial ---------------
Intro:
	push r1
	push r2

	loadn r1, #0
	loadn r2, #13 ; numero do enter

intro_volta:
	inchar r1
	cmp r1, r2
	jeq intro_fim
	jmp intro_volta


intro_fim:
	pop r2
	pop r1
	rts

; ---------- Atraso ---------------		

Delay:
						;Utiliza Push e Pop para nao afetar os Ristradores do programa principal
	Push R0
	Push R1
	
	Loadn R1, #5  ; a
   Delay_volta2:				;Quebrou o contador acima em duas partes (dois loops de decremento)
	Loadn R0, #10000	; b - atrasa a Torpedo
   Delay_volta: 
	Dec R0					; (4*a + 6)b = 1000000  == 1 seg  em um clock de 1MHz
	JNZ Delay_volta	
	Dec R1
	JNZ Delay_volta2
	
	Pop R1
	Pop R0
	
	RTS							;return

; ---------- Tela 1 ---------------

ShowTela: 	;  Rotina de Impresao de Cenario na Tela Inteira
		;  r1 = endereco onde comeca a primeira linha do Cenario
		;  r2 = cor do Cenario para ser impresso

	push r0	; protege o r3 na pilha para ser usado na subrotina
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r4 na pilha para ser usado na subrotina

	loadn R0, #0  	; posicao inicial tem que ser o comeco da tela!
	loadn R3, #40  	; Incremento da posicao da tela!
	loadn R4, #41  	; incremento do ponteiro das linhas da tela
	loadn R5, #1200 ; Limite da tela!
	
   ShowTela_Loop:
		call ImprimeStr
		add r0, r0, r3  	; incrementaposicao para a segunda linha na tela -->  r0 = R0 + 40
		add r1, r1, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		cmp r0, r5			; Compara r0 com 1200
		jne ShowTela_Loop	; Enquanto r0 < 1200

	pop r5	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
		
	
ImprimeStr:	;  Rotina de Impresao de Mensagens:    r0 = Posicao da tela que o primeiro caractere da mensagem sera impresso;  r1 = endereco onde comeca a mensagem; r2 = cor da mensagem.   Obs: a mensagem sera' impressa ate' encontrar "/0"
	push r0	; protege o r0 na pilha para preservar seu valor
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	
	loadn r3, #'\0'	; Criterio de parada

   ImprimeStr_Loop:	
		loadi r4, r1
		cmp r4, r3		; If (Char == \0)  vai Embora
		jeq ImprimeStr_Sai
		add r4, r2, r4	; Soma a Cor
		outchar r4, r0	; Imprime o caractere na tela
		inc r0			; Incrementa a posicao na tela
		inc r1			; Incrementa o ponteiro da String
		jmp ImprimeStr_Loop
	
   ImprimeStr_Sai:	
	pop r4	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r3
	pop r2
	pop r1
	pop r0
	rts

; ---------- Tela 2 ---------------	

ShowTela2: 	;  Rotina de Impresao de Cenario na Tela Inteira
		;  r1 = endereco onde comeca a primeira linha do Cenario
		;  r2 = cor do Cenario para ser impresso

	push r0	; protege o r3 na pilha para ser usado na subrotina
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r5 na pilha para ser usado na subrotina
	push r6	; protege o r6 na pilha para ser usado na subrotina
	loadn R0, #0  	; posicao inicial tem que ser o comeco da tela!
	loadn R3, #40  	; Incremento da posicao da tela!
	loadn R4, #41  	; incremento do ponteiro das linhas da tela
	loadn R5, #1200 ; Limite da tela!
	loadn R6, #tela1Linha0	; Endereco onde comeca a primeira linha do cenario!!
	
   ShowTela2_Loop:
		call ImprimeStr2
		add r0, r0, r3  	; incrementaposicao para a segunda linha na tela -->  r0 = R0 + 40
		add r1, r1, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		add r6, r6, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		cmp r0, r5			; Compara r0 com 1200
		jne ShowTela2_Loop	; Enquanto r0 < 1200

	pop r6	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
	
ImprimeStr2:	;  Rotina de Impresao de Mensagens:    r0 = Posicao da tela que o primeiro caractere da mensagem sera impresso;  r1 = endereco onde comeca a mensagem; r2 = cor da mensagem.   Obs: a mensagem sera' impressa ate' encontrar "/0"
	push r0	; protege o r0 na pilha para preservar seu valor
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r5 na pilha para ser usado na subrotina
	push r6	; protege o r6 na pilha para ser usado na subrotina
	
	
	loadn r3, #'\0'	; Criterio de parada
	loadn r5, #' '	; Espaco em Branco

   ImprimeStr2_Loop:	
		loadi r4, r1
		cmp r4, r3		; If (Char == \0)  vai Embora
		jeq ImprimeStr2_Sai
		cmp r4, r5		; If (Char == ' ')  vai Pula outchar do espaco para na apagar outros caracteres
		jeq ImprimeStr2_Skip
		add r4, r2, r4	; Soma a Cor
		outchar r4, r0	; Imprime o caractere na tela
		storei r6, r4
   ImprimeStr2_Skip:
		inc r0			; Incrementa a posicao na tela
		inc r1			; Incrementa o ponteiro da String
		inc r6			; Incrementa o ponteiro da String da Tela 0
		jmp ImprimeStr2_Loop
	
   ImprimeStr2_Sai:	
	pop r6	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
	
; ---------- Input ---------------	

DigLetra:	; Espera que uma tecla seja digitada e salva na variavel global "Letra"
	push r0
	push r1
	loadn r1, #255	; Se nao digitar nada vem 255

   DigLetra_Loop:
		inchar r0			; Le o teclado, se nada for digitado = 255
		cmp r0, r1			;compara r0 com 255
		jeq DigLetra_Loop	; Fica lendo ate que digite uma tecla valida

	store Letra, r0			; Salva a tecla na variavel global "Letra"

	pop r1
	pop r0
	rts



; ---------- Encerrar Tela ---------------	

EncerrarTela:
	push r0
	push r1
	
	loadn r0, #1200		; apaga as 1200 posicoes da Tela
	loadn r1, #' '		; com "espaco"
	
	   EncerrarTela_Loop:	;;label for(r0=1200;r3>0;r3--)
		dec r0
		outchar r1, r0
		jnz EncerrarTela_Loop
 
	pop r1
	pop r0
	rts	

	
;------------------------	
; Declara uma tela vazia para ser preenchida em tempo de execucao:
tela1Linha0  : string "                                        "
tela1Linha1  : string "                                        "
tela1Linha2  : string "                                        "
tela1Linha3  : string "                                        "
tela1Linha4  : string "                                        "
tela1Linha5  : string "                                        "
tela1Linha6  : string "                                        "
tela1Linha7  : string "                                        "
tela1Linha8  : string "                                        "
tela1Linha9  : string "                                        "
tela1Linha10 : string "                                        "
tela1Linha11 : string "                                        "
tela1Linha12 : string "                                        "
tela1Linha13 : string "                                        "
tela1Linha14 : string "                                        "
tela1Linha15 : string "                                        "
tela1Linha16 : string "                                        "
tela1Linha17 : string "                                        "
tela1Linha18 : string "                                        "
tela1Linha19 : string "                                        "
tela1Linha21 : string "                                        "
tela1Linha22 : string "                                        "
tela1Linha23 : string "                                        "
tela1Linha24 : string "                                        "
tela1Linha25 : string "                                        "
tela1Linha26 : string "                                        "
tela1Linha27 : string "                                        "
tela1Linha28 : string "                                        "
tela1Linha29 : string "                                        "

; Declara e preenche tela linha por linha (40 caracteres):
tela2Linha0  : string "  TIROS:     PONTOS:                    "
tela2Linha1  : string "                                        " 
tela2Linha2  : string "                                        "
tela2Linha3  : string "                                        "
tela2Linha4  : string "                                        "
tela2Linha5  : string "                                        "
tela2Linha6  : string "                                        "
tela2Linha7  : string "                                        "
tela2Linha8  : string "                                        "
tela2Linha9  : string "                                        "
tela2Linha10 : string "                                        "
tela2Linha11 : string "                                        "
tela2Linha12 : string "                                        "
tela2Linha13 : string "                                        "
tela2Linha14 : string "                                        "
tela2Linha15 : string "                                        "
tela2Linha16 : string "                                        "
tela2Linha17 : string "                                        "
tela2Linha18 : string "                                        "
tela2Linha19 : string "                                        "
tela2Linha21 : string "                                        "
tela2Linha22 : string "                                        "
tela2Linha23 : string "                                        "
tela2Linha24 : string "                                        "
tela2Linha25 : string "                                        "
tela2Linha26 : string "                                        "
tela2Linha27 : string "                                        "
tela2Linha28 : string "                                        "
tela2Linha29 : string "                                        "

; Declara e preenche tela linha por linha (40 caracteres):					                  
;----------------------1234567890123456789012345678901234567890						
telaInicialLinha0  : string "                                        "
telaInicialLinha1  : string "             ============               "
telaInicialLinha2  : string "             SPACE BATTLE               "
telaInicialLinha3  : string "             ============               "
telaInicialLinha4  : string "                                        "
telaInicialLinha5  : string "                   @                    "
telaInicialLinha6  : string "                  @@@                   "
telaInicialLinha7  : string "                @@@@@@@                 "
telaInicialLinha8  : string "                @@@@@@@                 "
telaInicialLinha9  : string "               @@@@@@@@@                "
telaInicialLinha10 : string "               @@@@@@@@@                "
telaInicialLinha11 : string "          @    @@@@@@@@@    @           "
telaInicialLinha12 : string "         @@   @@@@@@@@@@@   @@          "
telaInicialLinha13 : string " @       @@ @@@@@@@@@@@@@@@ @@        @ "
telaInicialLinha14 : string " @       @@@@@@@@@@@@@@@@@@@@@        @ "
telaInicialLinha15 : string "@@      @@@@@@@@@@@@@@@@@@@@@@@       @@"
telaInicialLinha16 : string "@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@     @@"
telaInicialLinha17 : string "@@  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@"
telaInicialLinha18 : string "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
telaInicialLinha19 : string "@@@@  @@@@@@@@            @@@@@@@@  @@@@"
telaInicialLinha20 : string "@@@   @@@@@@@@            @@@@@@@@   @@@"
telaInicialLinha21 : string " @    @@@@@@@@            @@@@@@@@    @ "
telaInicialLinha22 : string "                                        "
telaInicialLinha23 : string "                                        "
telaInicialLinha24 : string "               CONTROLES                "
telaInicialLinha25 : string "  CIMA [W], BAIXO [S], ATIRAR [ESPACO]  "
telaInicialLinha26 : string "                                        "
telaInicialLinha27 : string "                                        "
telaInicialLinha28 : string "          > ENTER PARA INICIAR          "
telaInicialLinha29 : string "                                        "