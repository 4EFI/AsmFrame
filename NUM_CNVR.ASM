
;------------------------------------------------
;	AX TO BIN
;------------------------------------------------
; ENTRY:	AX = NUM
;			BX = POS
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	BX CX DX DI  
;------------------------------------------------

PrintBin		proc
				
				mov dx, ax				; DX = AX
				mov cx, ax	

				mov di, 16d * 2d 	 	; i = 16 * 2
				add di, bx				; di += bx

				std 

__Next:			; shr ax, 1				; AX /= 2

				mov byte ptr ah, 70h	; black on white

				sub di, 2				; print( ax ) // with 1 sym left( 2 bytes )
				stosw 					
				add di, 2

				; mov al,
				mov ah, 0 

				cmp di, bx				; if( cx == bx )
				jne __Next

				mov ax, dx				; AX = DX

				ret
				endp

;------------------------------------------------