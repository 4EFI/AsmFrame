
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
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	DX DI
;------------------------------------------------

PrintVrtLine	proc

				cmp cl, 0		; if( cl <= 0 ) ret
				jbe __End

				push bx 

				xor dx, dx		; i = 0

				__Next:			call PrintChar
						
								inc bl
								inc dl

								cmp dl, cl
								jne __Next
				pop bx

				__End:
				ret
				endp

;------------------------------------------------
;	PRINT BOX
;------------------------------------------------
; ENTRY:	BX = DATA ADDR
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	AX DX DI
;------------------------------------------------

TypeSize = 9

;				0		1 		2 		3		4		5		6		7
;				lt	  	ld		rt	  	rd		lv	 	rv		th	  	dh
type_1 	db 		0c9h, 	0c8h, 	0bbh, 	0bch, 	0bah, 	0bah,	0cdh,	0cdh
type_2	db		0c9h, 	0c8h, 	0bbh, 	0bch, 	003h, 	003h, 	003h, 	003h

X_Num   = 0
Y_Num   = 1
W_Num   = 2
H_Num   = 3
Clr_Num = 4				

PrintBox		proc

				push ax 			; push (1)
				push cx				; push (2)

				mov ah, 07 ; bx[Clr_Num]

				mov byte ptr ch, 4 ; bx[W_Num]		; set WIDTH	
				mov byte ptr cl, bx[H_Num]		; set HEIGHT	

				mov byte ptr al, type_1[6]		; set horizontal sym
				mov byte ptr dh, type_1[0]		; set left  top  sym
				mov byte ptr dl, type_1[2]		; set right top  sym
 				mov byte ptr bh, bx[X_Num]		; set X
				mov byte ptr bl, bx[Y_Num]		; set Y
				call PrintHrzLine				; Print top horizontal line

				pop cx				; pop  (2)
				pop ax				; pop  (1)

				ret
				endp

;------------------------------------------------
;	INPUT STR
;------------------------------------------------
; ENTRY:	NONE
; EXIT:		AX = STR LEN
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
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
