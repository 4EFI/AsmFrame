
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
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	DX DI
;------------------------------------------------

PrintHrzLine	proc

				cmp ch, 0		; if( ch <= 0 ) ret
				jbe __End

				push bx 		

				xor dx, dx		; i = 0

				__Next:			call PrintChar
						
								inc bh
								inc dh

								cmp dh, ch
								jne __Next
				pop bx

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
; ENTRY:	BH = X LEFT CORNER COORDS [0; 79]
;			BL = Y LEFT CORNER COORDS [0; 24]
;			CH = WIDTH
;			CL = HEIGHT
; EXIT:		NONE
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	AX DX DI
;------------------------------------------------

box_clr db		01fh	; yellow on red

lt_ch 	db		0c9h	; left  top  char
ld_ch	db		0c8h	; left  down char
rt_ch	db 		0bbh	; right top  char
rd_ch	db 		0bch	; rigth down char

v_ch	db 		0bah	; vertical 	 char
h_ch  	db 		0cdh	; horizontal char

PrintBox		proc

				push bx				; print left top char
				mov al, lt_ch		
				mov ah, box_clr
				call PrintChar
				pop bx			

				push bx				; print left down char
				add bl, cl			
				sub bl, 1
				mov al, ld_ch
				mov ah, box_clr
				call PrintChar
				pop bx
							
				push bx				; print right top char		
				add bh, ch					
				sub bh, 1
				mov al, rt_ch
				mov ah, box_clr
				call PrintChar
				pop bx

				push bx				; print right down char	
				add bh, ch						
				sub bh, 1
				add bl, cl
				sub bl, 1
				mov al, rd_ch
				mov ah, box_clr
				call PrintChar
				pop bx

				push bx				; print top horizontal line	
				add bh, 1					
				mov al, h_ch
				mov ah, box_clr
				sub ch, 2
				call PrintHrzLine
				add ch, 2
				pop bx
				
				push bx 			; print down horizontal line	
				add bh, 1					
				add bl, cl
				sub bl, 1
				mov al, h_ch
				mov ah, box_clr
				sub ch, 2
				call PrintHrzLine
				add ch, 2
				pop bx

				push bx				; print left vertical line	
				add bl, 1					
				mov al, v_ch
				mov ah, box_clr
				sub cl, 2
				call PrintVrtLine
				add cl, 2
				pop bx
				
				push bx 			; print right vertical line	
				add bl, 1					
				add bh, ch
				sub bh, 1
				mov al, v_ch
				mov ah, box_clr
				sub cl, 2
				call PrintVrtLine
				add cl, 2
				pop bx

				ret
				endp

;------------------------------------------------
;	INPUT STR
;------------------------------------------------
; ENTRY:	NONE
; EXIT:		DX = STR LEN
; EXPECTS:	ES = 0b800h (VIDEO SEGMENT)
; DESTROYS:	AX DX
;------------------------------------------------

InputLen = 100
InputStr db 	InputLen dup (0) 			

Input			proc 

				xor dx, dx		; i++

				__Next:			mov ah, 01h
								int 21h

								push si						; push (1)

								xor si, si					; SI = 0

								mov si, offset InputStr		; SI = InputStr + DX
								add si, dx 					
								
								mov [si], al

								pop si						; pop  (1)

								cmp al, 13d					; if( al == '\r' )
								je __End

								inc dx						; i++
								cmp dx, InputLen			; if( i == InputLen )
								jne __Next	

				__End:									
				ret 
				endp

;------------------------------------------------
