
;------------------------------------------------
;	PRINT AX IN BIN
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

								__Zero:			mov al, '0'			; '0'
												jmp __End

								__One:			mov al, '1'			; '1'

				__End:			mov ah, 70h				; black on white

								sub di, 2				; print( ax ) // with 1 sym left( 2 bytes )
								stosw 					
								add di, 2				

								pop ax					; pop (3)

								inc dx

								cmp dx, bin_len			; if( dx == bin_len )
								jne __Next

				pop ax					; pop  (2)

				ret
				endp

;------------------------------------------------
;	PRINT AX IN HEX
;------------------------------------------------
; ENTRY:	AX = NUM
;			BH = X LEFT CORNER COORDS [0; 79]
;			BL = Y LEFT CORNER COORDS [0; 24]
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	CX DX DI  
;------------------------------------------------

hex_len	= 16d							; len of hex str	

PrintHex		proc
				
				push ax					; push (1)

				call GetVideoPos 		; AX = Video position from (X; Y)
				mov di, hex_len * 2d 	; i = hex_len * 2 + AX
				add di, ax
				std 

				pop  ax					; pop  (1)

				xor dx, dx				; i = 0

				push ax					; push (2)

				__Next:			mov cx, 0			; shifts counter			
	
								push dx				; push (4)
								mov  dx, 0			; DX = 0
								
								__Shift:		shr ax, 1		; AX /= 2
		
												jnc __End

												__One:			push ax			; push (3)
																mov  ax, 1 		; AX = 0001b
																shl  ax, cl		; DX += 2^CX
																add  dx, ax 
																pop	 ax			; pop  (3)
								
								__End:			inc cx			; shifts counter ++
												cmp cx, 4d		; if( numShifts == 4 )
												jne __Shift

								mov cx, ax			; CX = AX
								
								cmp dx, 10d			; if( DX >= 10 )
								jge __Sym

								__Digit:		add dx, 48d		; print( DX + '0' )
												mov al, dl		
												jmp __Print

								__Sym:			sub dx, 10		; print( DX - 10 + 'A' )
												add dx, 65d
												mov al, dl

				__Print:		pop dx				; pop  (4)

								mov ah, 70h			; black on white

								sub di, 2			; print( ax ) // with 1 sym left( 2 bytes )
								stosw 					
								add di, 2				

								mov ax, cx			; AX = CX

								inc dx				; i++

								cmp dx, hex_len		; if( dx == hex_len )
								jne __Next

				pop ax					; pop  (2)

				ret
				endp

;------------------------------------------------
;	PRINT AX IN DEC
;------------------------------------------------
; ENTRY:	AX = NUM
;			BH = X LEFT CORNER COORDS [0; 79]
;			BL = Y LEFT CORNER COORDS [0; 24]
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	CX DX DI  
;------------------------------------------------

dec_len	= 5d	

PrintDec		proc

				push ax					; push (1)

				call GetVideoPos 		; AX = Video position from (X; Y)
				mov di, dec_len * 2d 	; i = dec_len * 2 + AX
				add di, ax
				std 

				pop  ax					; pop  (1)

				xor dx, dx				; i = 0

				push ax					; push (2)

				mov cx, 10d				; CX = 10

				__Next:			push dx				; push (3)

								cmp ax, 10d		; if( ax > 10 )
								jg	__Num

								__Digit:		mov  dx, ax			; print( DL + '0' )
												add  dx, 48d	

												mov  ax, 0			; AX = 0
												push ax				; push (4.1)

												mov  al, dl			

												jmp __End		


								__Num:			div  cx				; AX /= 10

												push ax				; push (4.2)	

												add  dl, 48d		; print( DL + '0' )
												mov  al, dl	

				__End:			mov  ah, 70h		; black on white	

								sub di, 2			; print( ax ) // with 1 sym left( 2 bytes )
								stosw 					
								add di, 2				

								pop ax				; pop  (4)
								pop dx				; pop  (3)

								inc dx

								cmp dx, dec_len		; if( dx == dec_len )
								jne __Next

				pop ax					; pop  (2)

				ret 
				endp

;------------------------------------------------
;	PRINT AX IN BIN/HEX/DEC
;------------------------------------------------
; ENTRY:	AX = NUM
;			BH = X LEFT CORNER COORDS [0; 79]
;			BL = Y LEFT CORNER COORDS [0; 24]
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	CX DX DI  
;------------------------------------------------

PrintNum		proc

				push bx					; push (1)

				call PrintBin

				add bh, bin_len + 1d	; X 
				call PrintHex

				add bh, hex_len + 1d	; X
				call PrintDec

				pop bx					; pop  (1)

				ret
				endp

;------------------------------------------------