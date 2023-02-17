
;------------------------------------------------
;	AX TO BIN
;------------------------------------------------
; ENTRY:	AX = NUM
;			BH = X LEFT CORNER COORDS [0; 79]
;			BL = Y LEFT CORNER COORDS [0; 24]
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	DX DI  
;------------------------------------------------

bin_len	= 16d							; len of bin str	

PrintBin		proc
				
				push ax					; push (1)

				call GetVideoPos 		; AX = Video position from (X; Y)
				mov di, bin_len * 2d 	; i = bin_len * 2 + AX
				add di, ax
				std 

				pop  ax					; pop  (1)

				xor dx, dx				; i = 0

				push ax					; push (2)

__Next:			shr ax, 1				; AX /= 2

				push ax					; push (3)

				jc __One

__Zero:				mov al, '0'				; '0'
					jmp __End

__One:				mov al, '1'				; '1'

__End:			mov ah, 70h				; black on white

				sub di, 2				; print( ax ) // with 1 sym left( 2 bytes )
				stosw 					
				add di, 2				

				pop ax					; pop (3)

				inc dx

				cmp dx, bin_len			; if( di == bin_len )
				jne __Next

				pop ax					; pop  (2)

				ret
				endp

;------------------------------------------------