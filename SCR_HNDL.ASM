
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
;	CLEAR SCREEN BY SYM
;------------------------------------------------
; ENTRY:	BH = X LEFT CORNER COORDS [0; 79]
;			BL = Y LEFT CORNER COORDS [0; 24]
;			CH = WIDTH
;			CL = HEIGHT
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	BX CX  
;------------------------------------------------

lt_ch 	db		0dah	; left  top  char
ld_ch	db		0c0h	; left  down char
rt_ch	db 		0bfh	; right top  char
rd_ch	db 		0d9h	; rigth down char

v_ch	db 		0c4h	; vertical 	 char
h_ch  	db 		0b3h	; horizontal char

PrintBox		proc

				mov di, 0		; di  = 0
				std	

				mov al, 160d	; ax = 160 * Y + 2 * X
				mul bl
				shl bh, 1
				mov dx, 0
				add dl, bh
				add ax, dx 	

				add di, ax		; di += ax

				mov al, lt_ch
				mov ah, 70h

				stosw

__Next:			
	

				; loop __Next

				ret
				endp

;------------------------------------------------