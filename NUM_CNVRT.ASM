
;------------------------------------------------
;	AX TO BIN
;------------------------------------------------
; ENTRY:	AX = NUM
;			Al = SYM
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	BX CX  
;------------------------------------------------

ToBin		    proc
			
				mov bx, 0			; bx = 0
				mov cx, 80d * 25d

__Next:			mov es:[bx], ax
				add bx, 2

				loop __Next

				ret
				endp

;------------------------------------------------