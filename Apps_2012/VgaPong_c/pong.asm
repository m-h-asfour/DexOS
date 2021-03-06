;=========================================================;
; SpacePong                                      00/00/05 ;
;---------------------------------------------------------;
; For DexOS                                               ;
; by Craig Bamford.                                       ;
;                                                         ;
;=========================================================;
format binary as 'dex'					  ;
use32							  ;
	ORG	0x1A00000				  ; where our program is loaded to
	jmp	start					  ; jump to the start of program.
	db	'DEX6'					  ; We check for this, to make shore it a valid DexOS file ver.
include 'pongfunctions.inc'				  ;
include 'VgaFont.inc'					  ;
start:							  ;
	mov	ax,18h					  ;
	mov	ds,ax					  ;
	mov	es,ax					  ;
;=======================================================  ;
; Get calltable address.                                  ;
;=======================================================  ;
	mov	edi,Functions				  ; fill the function table
	mov	al,0					  ; so we have some usefull functions
	mov	ah,0x0a 				  ;
	int	50h					  ;
;=======================================================  ;
; Change to mode 13h.                                     ;
;=======================================================  ;
	mov	ax,0x0013				  ;
	call	[RealModeInt10h]			  ;
;=======================================================  ;
; Set some vars up.                                       ;
;=======================================================  ;
	mov	[PadLy],100				  ;
	mov	[PadRy],100				  ;
	mov	[BallX],20				  ;
	mov	[BallY],100				  ;
	mov	[BallXstate],1				  ;
	mov	[BallYstate],1				  ;
;=======================================================  ;
; Set time ticks per second.                              ;
;=======================================================  ;
	mov	cx,100					  ;
	call	[InterruptTimer]			  ;
;=======================================================  ;
; Randomly get the x for stars.                           ;
;=======================================================  ;
	call	rand					  ;
	mov	[Seed],ax				  ;
	mov	ecx,35					  ;
	xor	ebx,ebx 				  ;
@@:							  ;
	call	rand					  ;
	mov	ah,0					  ;
	add	ax,62					  ;
	mov	[Star3x+ebx],ax 			  ;
	inc	ebx					  ;
	inc	ebx					  ;
	loop	@b					  ;
							  ;
	mov	ecx,35					  ;
	xor	ebx,ebx 				  ;
	call	rand					  ;
	mov	[Seed],ax				  ;
@@:							  ;
	call	rand					  ;
	mov	ah,0					  ;
	add	ax,62					  ;
	mov	[Star2x+ebx],ax 			  ;
	inc	ebx					  ;
	inc	ebx					  ;
	loop	@b					  ;
							  ;
	mov	ecx,35					  ;
	xor	ebx,ebx 				  ;
	call	rand					  ;
	mov	[Seed],ax				  ;
@@:							  ;
	call	rand					  ;
	mov	ah,0					  ;
	add	ax,62					  ;
	mov	[Star1x+ebx],ax 			  ;
	inc	ebx					  ;
	inc	ebx					  ;
	loop	@b					  ;
;=======================================================  ;
;  Replace keyboard with Game keyboard.                   ;
;=======================================================  ;
	call	[GameKeyBoardOn]			  ;
	mov	[KeyDown],esi				  ;
;=======================================================  ;
;  Main Game loop                                         ;
;=======================================================  ;
@@:							  ;
	mov	ax,18h					  ;
	mov	es,ax					  ;
	mov	ds,ax					  ;
	mov	edi,ScreenBuffer			  ;
	mov	ecx,320*200/4				  ;
	mov	eax,0x00000000				  ;
	cld						  ;
	cli						  ;
	rep	stosd					  ;
	sti						  ;
	call	PutStars				  ;
	call	PutTextB				  ;
	call	CheScore				  ;
	mov	[VGAcolor],0x4A 			  ;
	mov	bx,188					  ;
	mov	ax,74					  ;
	mov	esi,message2				  ;
	call	PrintVGAstringSmall			  ;
	CALL	BounceBall				  ;
	mov	ax,[BallX]				  ;
	mov	bx,[BallY]				  ;
	CALL	PutPix					  ;
	mov	esi,Ball1				  ;
	call	PutBall 				  ;
	mov	ax,[PadLx]				  ;
	mov	bx,[PadLy]				  ;
	call	PutPix					  ;
	mov	esi,RedPad				  ;
	call	PutPad					  ;
	call	KeyPressed				  ;
	mov	ax,[PadRx]				  ;
	mov	bx,[PadRy]				  ;
	call	PutPix					  ;
	mov	esi,BluePad				  ;
	call	PutPad					  ;
	call	CheWinner				  ;
	call	CheckDelay				  ;
;=======================================================  ;
;  Mov buffer to screen                                   ;
;=======================================================  ;
	mov	ax,8h					  ;
	mov	es,ax					  ;
	mov	esi,ScreenBuffer			  ;
	mov	edi,0xA0000				  ;
	mov	ecx,320*200/4				  ;
	rep	movsd					  ;
;=======================================================  ;
;  See if a key as been press                             ;
;=======================================================  ;
	mov	ax,2					  ;
	call	[SetDelay]				  ;
	cmp	[ExitYesNo],0				  ;
	je	@b					  ;
							  ;
	call	NoSound 				  ;
	mov	ax,500					  ;
	call	[SetDelay]				  ;
	call	[GameKeyBoardOff]			  ;
	mov	cx,0					  ;
	call	[InterruptTimer]			  ;
;=======================================================  ;
;  Exit Game.                                             ;
;=======================================================  ;
	mov	ax,0x0003				  ;
	call	[RealModeInt10h]			  ;
	call	[Clstext]				  ;
	ret						  ; Exit.
							  ;
;=======================================================  ;
;  Put stars.                                             ;
;=======================================================  ;
PutStars:						  ;
	pushad						  ;
	xor	ebx,ebx 				  ;
	xor	eax,eax 				  ;
	mov	ax,18h					  ;
	mov	ds,ax					  ;
	mov	es,ax					  ;
	mov	[IndexBX13],0				  ;
	mov	[IndexBX23],0				  ;
	mov	ecx,33					  ;
@@:							  ;
	call	Stary1					  ;
	call	Starx1					  ;
	mov	ax,[IndexX3]				  ;
	mov	bx,[IndexY3]				  ;
	call	PutPix					  ;
	mov	al,0x1c 				  ;dark 
	stosb						  ;
	loop	@b					  ;
							  ;
	mov	[IndexBX12],0				  ;
	mov	[IndexBX22],0				  ;
	mov	ecx,33					  ;
							  ;
	cmp	[Switch2],2				  ;
	jne	@f					  ;
	mov	[Switch2],0				  ;
@@:							  ;
							  ;
	call	Stary2					  ;
	call	Starx2					  ;
	mov	ax,[IndexX2]				  ;
	mov	bx,[IndexY2]				  ;
	call	PutPix					  ;
	mov	al,0x05 				  ;
	stosb						  ;
	loop	@b					  ;
	mov	[IndexBX1],0				  ;
	mov	[IndexBX2],0				  ;
	mov	ecx,33					  ;
							  ;
	cmp	[Switch],3				  ;
	jne	Yes0					  ;
	mov	[Switch1],1				  ;
	mov	[Switch],0				  ;
	jmp	@f					  ;
Yes0:							  ;
	mov	[Switch1],0				  ;
@@:							  ;
	call	Stary3					  ;
	call	Starx3					  ;
	mov	ax,[IndexX]				  ;
	mov	bx,[IndexY]				  ;
	call	PutPix					  ;
	mov	al,0x16 				  ;light                            
	stosb						  ;
	loop	@b					  ;
	inc	[Switch]				  ;
	inc	[Switch2]				  ;
	popad						  ;
	ret						  ;
							  ;
;=======================================================  ;
; Starx2                                                  ;
;=======================================================  ;
Starx2: 						  ;
	xor	ebx,ebx 				  ;
	xor	eax,eax 				  ;
	mov	bx,[IndexBX12]				  ;
	mov	esi,Star2x				  ;
	add	esi,ebx 				  ;
	push	ebx					  ;
	cld						  ;
	lodsw						  ;
	sub	ax,[Switch2]				  ;
	cmp	ax,2					  ;
	jae	@f					  ;
	mov	ax,311					  ;
@@:							  ;
	mov	[IndexX2],ax				  ;
	pop	ebx					  ;
	mov	edi,Star2x				  ;
	add	edi,ebx 				  ;
	stosw						  ;
	add	bx,2					  ;
	mov	[IndexBX12],bx				  ;
	ret						  ;
							  ;
							  ;
Stary2: 						  ;
	xor	ebx,ebx 				  ;
	xor	eax,eax 				  ;
	mov	bx,[IndexBX22]				  ;
	mov	esi,Star2Y				  ;
	add	esi,ebx 				  ;
	cld						  ;
	lodsb						  ;
	mov	[IndexY2],ax				  ;
	add	bx,1					  ;
	mov	[IndexBX22],BX				  ;
	ret						  ;
							  ;
;=======================================================  ;
; Starx1                                                  ;
;=======================================================  ;
Starx1: 						  ;
	xor	ebx,ebx 				  ;
	xor	eax,eax 				  ;
	mov	bx,[IndexBX13]				  ;
	mov	esi,Star1x				  ;
	add	esi,ebx 				  ;
	push	ebx					  ;
	cld						  ;
	lodsw						  ;
	dec	ax					  ;
	cmp	ax,2					  ;
	jae	@f					  ;
	mov	ax,311					  ;
@@:							  ;
	mov	[IndexX3],AX				  ;
	pop	ebx					  ;
	mov	edi,Star1x				  ;
	add	edi,ebx 				  ;
	stosw						  ;
	add	bx,2					  ;
	mov	[IndexBX13],bx				  ;
	ret						  ;
							  ;
Stary1: 						  ;
	xor	ebx,ebx 				  ;
	xor	eax,eax 				  ;
	mov	bx,[IndexBX23]				  ;
	mov	esi,Star1Y				  ;
	add	esi,ebx 				  ;
	cld						  ;
	lodsb						  ;
	mov	[IndexY3],ax				  ;
	add	bx,1					  ;
	mov	[IndexBX23],bx				  ;
	ret						  ;
							  ;
;=======================================================  ;
; Starx3                                                  ;
;=======================================================  ;
Starx3: 						  ;
	xor	ebx,ebx 				  ;
	xor	eax,eax 				  ;
	mov	bx,[IndexBX1]				  ;
	mov	esi,Star3x				  ;
	add	esi,ebx 				  ;
	cld						  ;
	lodsw						  ;
	sub	ax,[Switch1]				  ;
	cmp	ax,2					  ;
	jae	@F					  ;
	mov	ax,311					  ;
@@:							  ;
	mov	[IndexX],ax				  ;
	mov	edi,Star3x				  ;
	add	edi,ebx 				  ;
	stosw						  ;
	add	bx,2					  ;
	mov	[IndexBX1],bx				  ;
	ret						  ;
							  ;
Stary3: 						  ;
	xor	ebx,ebx 				  ;
	xor	eax,eax 				  ;
	mov	bx,[IndexBX2]				  ;
	mov	esi,Star3Y				  ;
	add	esi,ebx 				  ;
	cld						  ;
	lodsb						  ;
	mov	[IndexY],ax				  ;
	add	bx,1					  ;
	mov	[IndexBX2],bx				  ;
	ret						  ;
							  ;
;=======================================================  ;
; PutBall                                                 ;
;=======================================================  ;
PutBall:						  ;
	mov	[Count2],6				  ;
A2q:							  ;
	mov	cx,3					  ;
	cld						  ;
Aq1:							  ;
	lodsw						  ;
	xchg	ah,al					  ;
	stosw						  ;
	loop	Aq1					  ;
	add	edi,314 				  ;
	dec	[Count2]				  ;
	cmp	[Count2],0				  ;
	jne	A2q					  ;
	ret						  ;
							  ;
;=======================================================  ;
; PutPad                                                  ;
;=======================================================  ;
PutPad: 						  ;
	mov	[Count],16				  ;
A2qq:							  ;
	mov	cx,3					  ;
	cld						  ;
Aqq1:							  ;
	lodsw						  ;
	xchg	ah,al					  ;
	stosw						  ;
	loop	Aqq1					  ;
							  ;
	add	edi,314 				  ;
	dec	[Count] 				  ;
	cmp	[Count],0				  ;
	jne	A2qq					  ;
	ret						  ;
;=======================================================  ;
; KeyPressed                                              ;
;=======================================================  ;
KeyPressed:						  ;
	push	esi					  ;
	mov	esi,[KeyDown]				  ;
;=======================================================  ;
; Is ESC held down?                                       ;
;=======================================================  ;
	test	byte[esi+EscKey],1			  ;
	JZ	Next					  ;
	mov	[VGAcolor],0x16 			  ;
	mov	bx,99					  ;
	mov	ax,133					  ;
	mov	esi,message5				  ;
	call	PrintVGAstringSmall			  ;
	mov	[VGAcolor],0x0e 			  ;
	mov	bx,100					  ;
	mov	ax,134					  ;
	mov	esi,message5				  ;
	call	PrintVGAstringSmall			  ;
	mov	[ExitYesNo],1				  ;
	jmp	Exit					  ;
;=======================================================  ;
; Is Q down?                                              ;
;=======================================================  ;
Next:							  ;
	test	byte[esi+Q],1				  ;
	jz	Next1					  ;
	cmp	[PadLy],2				  ;
	jbe	Next1					  ;
	sub	[PadLy],2				  ;
;=======================================================  ;
; Is A down?                                              ;
;=======================================================  ;
Next1:							  ;
	test	byte[esi+A],1				  ;
	jz	Next2					  ;
	cmp	[PadLy],182				  ;
	jae	Next2					  ;
	add	[PadLy],2				  ;
;=======================================================  ;
; Is down arrow down?                                     ;
;=======================================================  ;
Next2:							  ;
	test	byte[esi+Down],1			  ;
	jz	Next3					  ;
	cmp	[PadRy],182				  ;
	jae	Next3					  ;
	add	[PadRy],2				  ;
;=======================================================  ;
; Is UP arrow down?                                       ;
;=======================================================  ;
Next3:							  ;
	test	byte[esi+Up],1				  ;
	jz	Next4					  ;
	cmp	[PadRy],2				  ;
	jbe	Next4					  ;
	sub	[PadRy],2				  ;
Next4:							  ;
	test	byte[esi+W],1				  ;
	jz	Next5					  ;
	cmp	[BallX],30				  ;
	ja	Next5					  ;
	cmp	[BallXstate],2				  ;
	je	Next5					  ;
	mov	[Bstart],0				  ;
Next5:							  ;
	test	byte[esi+Left],1			  ;
	jz	Next6					  ;
	cmp	[BallX],290				  ;
	jb	Next6					  ;
	cmp	[BallXstate],1				  ;
	je	Next6					  ;
	mov	[Bstart],0				  ;
Next6:							  ;
	test	byte[esi+Down1],1			  ;
	jz	Last1					  ;
	cmp	[DelayCount],200			  ;
	jae	Last1					  ;
	inc	[DelayCount]				  ;
Last1:							  ;
	test	byte[esi+Up1],1 			  ;
	jz	Exit					  ;
	cmp	[DelayCount],1				  ;
	jbe	Exit					  ;
	dec	[DelayCount]				  ;
Exit:							  ;
	pop	esi					  ;
	ret						  ;
							  ;
;=======================================================  ;
; BounceBall                                              ;
;=======================================================  ;
BounceBall:						  ;
	CMP	[Bstart],2				  ;
	jne	Np1					  ;
	mov	[BallX],306				  ;
	jmp	B10					  ;
Np1:							  ;
	cmp	[Bstart],1				  ;
	jne	Np2					  ;
	mov	[BallX],8				  ;
	jmp	B10					  ;
Np2:							  ;
	cmp	[BallXstate],1				  ;
	je	A10					  ;
	sub	[BallX],2				  ;
	jmp	B10					  ;
A10:							  ;
	add	[BallX],2				  ;
B10:							  ;
	cmp	[Bstart],2				  ;
	jne	Np3					  ;
	mov	ax,[PadRy]				  ;
	add	ax,4					  ;
	mov	[BallY],ax				  ;
	jmp	B20					  ;
Np3:							  ;
	cmp	[Bstart],1				  ;
	jne	Np4					  ;
	mov	ax,[PadLy]				  ;
	add	ax,4					  ;
	mov	[BallY],ax				  ;
	jmp	B20					  ;
Np4:							  ;
	cmp	[BallYstate],1				  ;
	je	A20					  ;
	sub	[BallY],2				  ;
	jmp	B20					  ;
A20:							  ;
	add	[BallY],2				  ;
B20:							  ;
	cmp	[BallX],6				  ;
	jne	C10					  ;
	mov	ax,[BallY]				  ;
	mov	bx,[PadLy]				  ;
	sub	bx,3					  ;
	cmp	bx,ax					  ;
	jle	Z1					  ;
	inc	[Score2]				  ;
	mov	[Bstart],2				  ;
	jmp	D20					  ;
Z1:							  ;
	mov	CL,18					  ;
Z12:							  ;
	cmp	bx,ax					  ;
	je	Z2					  ;
	inc	bx					  ;
	loop	Z12					  ;
	inc	[Score2]				  ;
	mov	[Bstart],2				  ;
	jmp	D20					  ;
Z2:							  ;
	mov	[BallXstate],1				  ;
	call	Beep1					  ;
C10:							  ;
	cmp	[BallX],308				  ;
	jne	C20					  ;
	mov	ax,[BallY]				  ;
	mov	bx,[PadRy]				  ;
	sub	bx,3					  ;
	cmp	bx,ax					  ;
	jle	Q1					  ;
	inc	[Score1]				  ;
	mov	[Bstart],1				  ;
	jmp	D20					  ;
Q1:							  ;
	mov	cl,18					  ;
Q12:							  ;
	cmp	bx,ax					  ;
	je	Q2					  ;
	inc	bx					  ;
	loop	Q12					  ;
	inc	[Score1]				  ;
	mov	[Bstart],1				  ;
	jmp	D20					  ;
Q2:							  ;
	mov	[BallXstate],2				  ;
	call	Beep1					  ;
C20:							  ;
	cmp	[BallY],2				  ;
	jae	D10					  ;
	mov	[BallYstate],1				  ;
	call	Beep2					  ;
D10:							  ;
	cmp	[BallY],192				  ;
	jne	D20					  ;
	mov	[BallYstate],2				  ;
	call	Beep2					  ;
D20:							  ;
	ret						  ;
							  ;
;=======================================================  ;
; Beep1                                                   ;
;=======================================================  ;
Beep1:							  ;
	mov	[Hz],0x200				  ;
	call	Sound					  ;
	call	DeLay					  ;
	;call   NoSound                                   ;
	ret						  ;
							  ;
;=======================================================  ;
; Beep2                                                   ;
;=======================================================  ;
Beep2:							  ;
	mov	[Hz],0x175				  ;
	call	Sound					  ;
	call	DeLay					  ;
	;call   NoSound                                   ;
	ret						  ;
							  ;
;=======================================================  ;
; CheScore                                                ;
;=======================================================  ;
CheScore:						  ;
	mov	al,[Score1]				  ;
	cmp	al,9					  ;
	jbe	@f					  ;
	mov	[Score1],0				  ;
	mov	al,[Score1]				  ;
@@:							  ;
	mov	[VGAchar],al				  ;
	mov	[VgaX],113				  ;
	mov	[VgaY],26				  ;
	mov	[VGAcolor],0x0c 			  ;
	call	ConvertVGAtextSmall			  ;
							  ;
	mov	al,[Score2]				  ;
	cmp	al,9					  ;
	jbe	@f					  ;
	mov	[Score2],0				  ;
	mov	al,[Score2]				  ;
@@:							  ;
	mov	[VGAchar],al				  ;
	mov	[VgaX],193				  ;
	mov	[VgaY],26				  ;
	mov	[VGAcolor],0x09 			  ;
	call	ConvertVGAtextSmall			  ;
	ret						  ;
							  ;
;=======================================================  ;
; CheWinner                                               ;
;=======================================================  ;
CheWinner:						  ;
	cmp	[Score1],9				  ;
	jbe	NextOne 				  ;
	mov	[VGAcolor],0x16 			  ;
	mov	bx,99					  ;
	mov	ax,83					  ;
	mov	esi,message4				  ;
	call	PrintVGAstringSmall			  ;
	mov	[VGAcolor],0x0c 			  ;
	mov	bx,100					  ;
	mov	ax,84					  ;
	mov	esi,message4				  ;
	call	PrintVGAstringSmall			  ;
	mov	[ExitYesNo],1				  ;
	jmp	NextTwo 				  ;
NextOne:						  ;
	cmp	[Score2],9				  ;
	jbe	NextTwo 				  ;
	mov	[VGAcolor],0x16 			  ;
	mov	bx,99					  ;
	mov	ax,83					  ;
	mov	esi,message3				  ;
	call	PrintVGAstringSmall			  ;
	mov	[VGAcolor],0x09 			  ;
	mov	bx,100					  ;
	mov	ax,84					  ;
	mov	esi,message3				  ;
	call	PrintVGAstringSmall			  ;
	mov	[ExitYesNo],1				  ;
NextTwo:						  ;
	ret						  ;
							  ;
;=======================================================  ;
;  Delay                                                  ;
;=======================================================  ;
DeLay:							  ;
	push	eax					  ;
	mov	ax,10					  ;
	call	[TimerNoWait]				  ;
	pop	eax					  ;
	ret						  ;
							  ;
;=======================================================  ;
;  DelayB                                                 ;
;=======================================================  ;
DeLayb: 						  ;
	push	eax					  ;
	mov	ax,10					  ;
	call	[SetDelay]				  ;
	pop	eax					  ;
	ret						  ;
							  ;
;=======================================================  ;
;  CheckDelay                                             ;
;=======================================================  ;
CheckDelay:						  ;
	push	ax					  ;
	mov	ax,0					  ;
	call	[TimerNoWait]				  ;
	cmp	al,1					  ;
	je	CheckDelayExit				  ;
	call	NoSound 				  ;
CheckDelayExit: 					  ;
	pop   ax					  ;
	ret						  ;
							  ;
;=======================================================  ;
;  Data                                                   ;
;=======================================================  ;
include 'PongData.inc'					  ;
include 'Dex.inc'					  ;
