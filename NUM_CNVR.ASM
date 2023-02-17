
;------------------------------------------------
;	AX TO BIN
;------------------------------------------------
; ENTRY:	AX = NUM
;			BH = X LEFT CORNER COORDS [0; 79]
;			BL = Y LEFT CORNER COORDS [0; 24]
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	CX DX DI  
;------------------------------------------------

PrintBin		proc
				
				push ax

				call GetVideoPos 		; AX = Video position from (X; Y)
				mov di, 16d * 2d 	 	; i = 16 * 2 + AX
				add di, ax
				std 

				pop  ax

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