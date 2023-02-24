
; SCREEN HANDLER

;------------------------------------------------
;	FILL SCREEN BY SYM 
;	FROM ( X; Y ) to ( X + WIDTH; Y + HEIGHT )
;------------------------------------------------
; ENTRY:	AH = COLOR ATTR
;			AL = SYM
;			BH = X LEFT CORNER COORDS [0; 79]
;			BL = Y LEFT CORNER COORDS [0; 24]
;			CH = WIDTH
;			CL = HEIGHT
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	NONE  
;------------------------------------------------

FillScreen		proc
			
				push bx				; push (1)
				push cx				; push (2)
				push dx				; push (3)

				push ax				; push (4)
				call GetVideoPos
				mov bx, ax			
				pop ax				; pop  (4)

				__NextLine:			mov dh, ch		; i = CH	

									push bx			; push (5)
									
									__Next:			mov es:[bx], ax
													add bx, 2

													dec dh			; i--

													cmp dh, 0d		; if( dh == 0 )
													je __End

													jmp __Next		
									__End:	

									pop bx			; pop  (5)

									add bx, 160d	; BX += 2*80

									dec cl 			; CL--

									cmp cl, 0d   	; if( CL == 0 )
									je __EndNextLine

									jmp __NextLine
				__EndNextLine:

				pop dx				; pop  (3)									
				pop cx				; pop  (2)
				pop bx				; pop  (1)

				ret
				endp

;------------------------------------------------
;	CLEAR SCREEN BY SYM 
;------------------------------------------------
; ENTRY:	AH = COLOR ATTR
;			AL = SYM
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	NONE  
;------------------------------------------------

ClrScreen		proc

				push bx				; push (1)
				push cx				; push (2)

				xor bx, bx			; X = 0; Y = 0
				mov ch, 80d			
				mov cl, 25d
				call FillScreen

				pop cx				; pop  (2)
				pop bx				; pop  (1)

				ret
				endp

;------------------------------------------------
;	GET VIDEO POS FROM (X; Y)
;------------------------------------------------
; ENTRY:	BH = X LEFT CORNER COORDS [0; 79]
;			BL = Y LEFT CORNER COORDS [0; 24]
; EXIT:		AX = POS
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	AX
;------------------------------------------------

GetVideoPos		proc	

				shl bh, 1		; bh /= 2

				push dx			; push (1)
				
				mov al, 160d	; ax = 160 * Y + 2 * X
				mul bl
				mov dx, 0
				add dl, bh
				add ax, dx

				pop dx			; pop  (1)

				shr bh, 1		; bh *= 2

				ret	
				endp

;------------------------------------------------
;	PRINT SYM IN (X; Y)
;------------------------------------------------
; ENTRY:	AH = SYM COLOR
;			AL = SYM CHAR
;			BH = X LEFT CORNER COORDS [0; 79]
;			BL = Y LEFT CORNER COORDS [0; 24]
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	NONE
;------------------------------------------------

PrintChar		proc	

				push di			; push (1)
				push ax			; push (2)
				
				call GetVideoPos

				mov di, ax		; print( ax )
				pop ax			; pop  (2)
				stosw			

				pop di    		; pop  (1)

				ret
				endp

;------------------------------------------------
;	PRINT STR IN (X; Y)
;	END SYM '\0' or '$'
;------------------------------------------------
; ENTRY:	AH = SYM COLOR
;			BH = X LEFT CORNER COORDS [0; 79]
;			BL = Y LEFT CORNER COORDS [0; 24]
;			CX = STR ADDR
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	NONE
;------------------------------------------------

PrintStr		proc

				push ax			; push (1) 
				push bx			; push (2)	
				push dx			; push (3)
				push si			; push (4)

				mov si, cx		; SI = StrAddr

				__Next:			mov dl, [si]	; DX = CurrSym

								cmp dl, 0d		; if( DL == 0 )
								je __End
								cmp dl, '$'		; if( DL == '$' )
								je __End

								mov al, [si]	; AL = CurrSym
								call PrintChar

								inc bh			; X++
								inc si			; CurrSymPos++

								loop __Next
				__End:

				pop si			; pop  (4)
				pop dx			; pop  (3)
				pop ax			; pop  (2)
				pop bx			; pop  (1)

				ret
				endp

;------------------------------------------------
;	PRINT HORIZONTAL LINE IN (X; Y)
;------------------------------------------------
; ENTRY:	AH = SYM COLOR
;			AL = SYM CHAR
;			BH = X LEFT CORNER COORDS [0; 79]
;			BL = Y LEFT CORNER COORDS [0; 24]
;			CH = WIDTH
;			DH = LEFT  SYM
;			DL = RIGHT SYM
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	NONE
;------------------------------------------------

PrintHrzLine	proc

				cmp ch, 1			; if( ch <= 1 ) ret
				jbe __End

				push bx				; push (1) 
				push dx				; push (2)


				push ax				; push (3)
				mov al, dh			; printf( "%c", LeftSym )
				call PrintChar
				pop ax				; pop  (3)

				push ax				; push (4)
				push bx				; push (5)
				add bh, ch			; X += ( WIDTH - 1 )			
				sub bh, 1
				mov al, dl			; printf( "%c", RightSym )
				call PrintChar
				pop bx				; pop  (5)
				pop ax				; pop  (4)

				push bx				; push (6)
				push cx				; push (7)

				add bh, 1			; X += 1		
				sub ch, 2			; WIDTH -= 2

				cmp ch, 0			; if( ch == 0 )
				je 	__EndPrinting	

				xor dx, dx			; i = 0

				__Next:			call PrintChar
						
								inc bh
								inc dh

								cmp dh, ch
								je  __EndPrinting

								jmp __Next

				__EndPrinting:

				pop cx				; pop  (7)
				pop bx				; pop  (6)
				

				pop dx				; pop  (2)
				pop bx				; pop  (1)			

				__End:
				ret
				endp

;------------------------------------------------
;	PRINT VERTICAL LINE IN (X; Y)
;------------------------------------------------
; ENTRY:	AH = SYM COLOR
;			AL = SYM CHAR
;			BH = X LEFT CORNER COORDS [0; 79]
;			BL = Y LEFT CORNER COORDS [0; 24]
;			CL = HEIGHT
;			DH = TOP  SYM
;			DL = DOWN SYM
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	NONE
;------------------------------------------------

PrintVrtLine	proc

				cmp cl, 1			; if( cl <= 1 ) ret
				jbe __End

				push bx				; push (1) 
				push dx				; push (2)


				push ax				; push (3)
				mov al, dh			; printf( "%c", TopSym )
				call PrintChar
				pop ax				; pop  (3)

				push ax				; push (4)
				push bx				; push (5)
				add bl, cl			; Y += ( HEIGHT - 1 )			
				sub bl, 1
				mov al, dl			; printf( "%c", DownSym )
				call PrintChar
				pop bx				; pop  (5)
				pop ax				; pop  (4)

				push bx				; push (6)
				push cx				; push (7)

				add bl, 1			; Y += 1		
				sub cl, 2			; HEIGHT -= 2

				cmp cl, 0			; if( cl == 0 )
				je 	__EndPrinting	

				xor dx, dx			; i = 0

				__Next:			call PrintChar
						
								inc bl
								inc dl

								cmp dl, cl
								je  __EndPrinting

								jmp __Next

				__EndPrinting:

				pop cx				; pop  (7)
				pop bx				; pop  (6)
				

				pop dx				; pop  (2)
				pop bx				; pop  (1)			

				__End:
				ret
				endp

;------------------------------------------------
;	PRINT BOX
;------------------------------------------------
; ENTRY:	AX = STR  ADDR
;			BX = DATA ADDR
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	NONE
;------------------------------------------------

TypeSize = 9

; User's type
Type_0	db		9 dup (0)

; Template types
;				0		1 		2 		3		4		5		6		7		9
;				lt	  	ld		rt	  	rd		lv	 	rv		th	  	dh		fill
Type_1 	db 		0c9h, 	0c8h, 	0bbh, 	0bch, 	0bah, 	0bah,	0cdh,	0cdh, 	0d
Type_2	db		003h, 	003h, 	003h, 	003h, 	003h, 	003h, 	003h, 	003h,  	0d

X_Num    = 0
Y_Num    = 1
W_Num    = 2
H_Num    = 3
Clr_Num  = 4	
Type_Num = 5				

PrintBox		proc

				push ax 				; push (1)
				push bx					; push (2)
				push cx					; push (3)
				push dx					; push (4)
				push si					; push (5)
				push di					; push (6)
				push bp					; push (7)

				mov si, bx				; SI = DATA ADDR( BX )

				xor ax, ax				; BP = Type_0 + Type * 9
				mov al, bx[Type_Num]
				mov cx, 9d				
				mul cx 
				mov bp, ax
				add bp, offset Type_0

				mov ah, bx[Clr_Num]		; AH = Color

				mov ch, bx[W_Num]		; CH = WIDTH	
				mov cl, bx[H_Num]		; CL = HEIGHT	
						
 				mov  bh, si[X_Num]		; BH = X
				mov  bl, si[Y_Num]		; BL = Y
				mov  al, bp[6]			; AL = horizontal sym
				mov  dh, bp[0]			; DH = left  top  sym
				mov  dl, bp[2]			; DL = right top  sym
				call PrintHrzLine		; Print top horizontal line

 				mov  bh, si[X_Num]		; BH = X
				mov  bl, si[Y_Num]		; BL = Y
				mov  al, bp[4]			; AL = vertical  sym
				mov  dh, bp[0]			; DH = left top  sym
				mov  dl, bp[1]			; DL = left down sym
				call PrintVrtLine		; Print left vertical line

 				mov  bh, si[X_Num]		; BH = X
				mov  dl, si[Y_Num]	    ; Y += ( HEIGHT - 1 )
				add  dl, cl
				sub  dl, 1
				mov  bl, dl				; BL = Y
				mov  al, bp[7]			; AL = horizontal sym
				mov  dh, bp[1]			; DH = left  down sym
				mov  dl, bp[3]			; DL = right down sym
				call PrintHrzLine		; Print down horizontal line

				mov  dl, si[X_Num]	    ; X += ( WIDTH - 1 )
				add  dl, ch
				sub  dl, 1  
				mov  bh, dl				; BH = X
				mov  bl, si[Y_Num]		; BL = Y
				mov  al, bp[5]			; AL = vertical   sym
				mov  dh, bp[2]			; DH = right top  sym
				mov  dl, bp[3]			; DL = right down sym
				call PrintVrtLine		; Print right vertical line

				push bx					; push (8)
				push cx					; push (9)
				mov  bh, si[X_Num]		; BH = X + 1
				add  bh, 1
				mov  bl, si[Y_Num]		; BL = Y + 1
				add  bl, 1
				mov  al, bp[8]			; AL = filling sym
				sub  ch, 2				; WIDTH  -= 2
				sub  cl, 2				; HEIGHT -= 2
				call FillScreen			; Fill Box
				pop cx					; pop  (9)
				pop bx					; pop  (8)

				pop bp					; pop  (7)
				pop di					; pop  (6)
				pop si					; pop  (5)
				pop dx					; pop  (4)
				pop cx					; pop  (3)
				pop bx					; pop  (2)
				pop ax					; pop  (1)

				ret
				endp

;------------------------------------------------
;	INPUT STR
;------------------------------------------------
; ENTRY:	NONE
; EXIT:		AX = STR LEN
; DESTROYS:	AX
;------------------------------------------------

InputLen = 100
InputStr db 	InputLen dup (0) 			

Input			proc 

				push dx			; push (1)
				xor  dx, dx		; i = 0

				__Next:			mov ah, 01h					; input char
								int 21h

								push si						; push (2)

								xor si, si					; SI = 0

								mov si, offset InputStr		; SI = InputStr + DX
								add si, dx 					
								
								mov [si], al

								pop si						; pop  (2)

								cmp al, 13d					; if( al == '\r' )
								je __End

								inc dx						; i++
								cmp dx, InputLen			; if( i == InputLen )
								jne __Next	

				__End:	

				mov ax, dx
				pop dx			; pop  (1)
			
				ret 
				endp

;------------------------------------------------
