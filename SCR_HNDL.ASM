
; SCREEN HANDLER

;------------------------------------------------
;	CLEAR SCREEN BY SYM
;------------------------------------------------
; ENTRY:	AH = COLOR ATTR
;			Al = SYM
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	BX CX  
;------------------------------------------------

ClrScrn			proc
			
				mov bx, 0			; bx = 0
				mov cx, 80d * 25d

				__Next:			mov es:[bx], ax
								add bx, 2

								loop __Next

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
; DESTROYS:	DI
;------------------------------------------------

PrintChar		proc	

				push ax			; push (1)
				
				call GetVideoPos

				mov di, ax		; print( ax )
				pop ax			; pop  (1)
				stosw			

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
; DESTROYS:	DI
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
; DESTROYS:	DI
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
; ENTRY:	BX = DATA ADDR
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	NONE
;------------------------------------------------

TypeSize = 9

;				0		1 		2 		3		4		5		6		7		9
;				lt	  	ld		rt	  	rd		lv	 	rv		th	  	dh		fill
Type_1 	db 		0c9h, 	0c8h, 	0bbh, 	0bch, 	0bah, 	0bah,	0cdh,	0cdh, 	0d
Type_2	db		0c9h, 	0c8h, 	0bbh, 	0bch, 	003h, 	003h, 	003h, 	003h,  	0d

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

				xor ax, ax				; BP = Type_1 + ( Type - 1 ) * 9
				mov al, bx[Type_Num]	
				sub al, 1
				mov cx, 9d				
				mul cx 
				mov bp, ax
				add bp, offset Type_1

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

 				mov  bh, si[X_Num]		; set X
				mov  dl, si[Y_Num]	    ; Y += ( HEIGHT - 1 )
				add  dl, cl
				sub  dl, 1
				mov  bl, dl				; set Y
				mov  al, bp[7]			; set horizontal sym
				mov  dh, bp[1]			; set left  down sym
				mov  dl, bp[3]			; set right down sym
				call PrintHrzLine		; Print down horizontal line

				mov  dl, si[X_Num]	    ; X += ( WIDTH - 1 )
				add  dl, ch
				sub  dl, 1  
				mov  bh, dl				; set X
				mov  bl, si[Y_Num]		; set Y
				mov  al, bp[5]			; set vertical  sym
				mov  dh, bp[2]			; set right top  sym
				mov  dl, bp[3]			; set right down sym
				call PrintVrtLine		; Print right vertical line

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
