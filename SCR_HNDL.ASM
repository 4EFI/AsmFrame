
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

ClearScreen		proc
			
				mov bx, 0			; bx = 0
				mov cx, 80d * 25d

__Next:			mov es:[bx], ax
				add bx, 2

				loop __Next

				ret
				endp

;------------------------------------------------