
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
;	PRINT SYM IN (X, Y)
;------------------------------------------------
; ENTRY:	AH = SYM COLOR
;			AL = SYM CHAR
;			BH = X LEFT CORNER COORDS [0; 79]
;			BL = Y LEFT CORNER COORDS [0; 24]
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	DX DI BP
;------------------------------------------------

PrintChar		proc	

				shl bh, 1		; bh /= 2

				mov bp, ax		; CX = AX
				
				mov al, 160d	; ax = 160 * Y + 2 * X
				mul bl
				mov dx, 0
				add dl, bh
				add ax, dx 	

				mov di, ax		; print( ax )
				mov ax, bp
				stosw			

				shr bh, 1		; bh *= 2

				ret
				endp	

;------------------------------------------------
;	PRINT BOX
;------------------------------------------------
; ENTRY:	BH = X LEFT CORNER COORDS [0; 79]
;			BL = Y LEFT CORNER COORDS [0; 24]
;			CH = WIDTH
;			CL = HEIGHT
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	AX DX DI BP SI
;------------------------------------------------

lt_ch 	db		0dah	; left  top  char
ld_ch	db		0c0h	; left  down char
rt_ch	db 		0bfh	; right top  char
rd_ch	db 		0d9h	; rigth down char

v_ch	db 		0c4h	; vertical 	 char
h_ch  	db 		0b3h	; horizontal char

PrintBox		proc

				mov si, bx			; SI = BX

				mov al, lt_ch		; print left top char
				mov ah, 70h
				call PrintChar

				add bl, cl			; print left down char
				sub bl, 1
				mov al, ld_ch
				mov ah, 70h
				call PrintChar
				mov bx, si
							
				add bh, ch			; print right top char				
				sub bh, 1
				mov al, rt_ch
				mov ah, 70h
				call PrintChar
				mov bx, si

				add bh, ch			; print right down char				
				sub bh, 1
				add bl, cl
				sub bl, 1
				mov al, rd_ch
				mov ah, 70h
				call PrintChar
				mov bx, si
				

__Next:			

				; loop __Next

				ret
				endp

;------------------------------------------------