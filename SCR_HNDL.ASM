
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

				push ax			; push sym
				
				mov al, 160d	; ax = 160 * Y + 2 * X
				mul bl
				mov dx, 0
				add dl, bh
				add ax, dx

				mov di, ax		; print( ax )
				pop ax
				stosw			

				shr bh, 1		; bh *= 2

				ret
				endp	

;------------------------------------------------
;	PRINT HORIZONTAL LINE IN (X, Y)
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

				cmp ch, 0
				je __EndFunc

				push bx 		

				xor dx, dx		; i = 0

	__Next:			push dx
					call PrintChar
					pop  dx
						
					inc bh
					inc dh

					cmp dh, ch
					jne __Next

				pop bx

	__EndFunc:

				ret
				endp

;------------------------------------------------
;	PRINT VERTICAL LINE IN (X, Y)
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

				cmp cl, 0
				je __EndFunc

				push bx 

				xor dx, dx		; i = 0

	__Next:			push dx
					call PrintChar
					pop  dx
						
					inc bl
					inc dl

					cmp dl, cl
					jne __Next

				pop bx

	__EndFunc:

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

lt_ch 	db		0dah	; left  top  char
ld_ch	db		0c0h	; left  down char
rt_ch	db 		0bfh	; right top  char
rd_ch	db 		0d9h	; rigth down char

v_ch	db 		0b3h	; vertical 	 char
h_ch  	db 		0c4h	; horizontal char

PrintBox		proc

				push bx				; print left top char
				mov al, lt_ch		
				mov ah, 70h
				call PrintChar
				pop bx			

				push bx				; print left down char
				add bl, cl			
				sub bl, 1
				mov al, ld_ch
				mov ah, 70h
				call PrintChar
				pop bx
							
				push bx				; print right top char		
				add bh, ch					
				sub bh, 1
				mov al, rt_ch
				mov ah, 70h
				call PrintChar
				pop bx

				push bx				; print right down char	
				add bh, ch						
				sub bh, 1
				add bl, cl
				sub bl, 1
				mov al, rd_ch
				mov ah, 70h
				call PrintChar
				pop bx

				push bx				; print top horizontal line	
				add bh, 1					
				mov al, h_ch
				mov ah, 70h
				sub ch, 2
				call PrintHrzLine
				add ch, 2
				pop bx
				
				push bx 			; print down horizontal line	
				add bh, 1					
				add bl, cl
				sub bl, 1
				mov al, h_ch
				mov ah, 70h
				sub ch, 2
				call PrintHrzLine
				add ch, 2
				pop bx

				push bx				; print left vertical line	
				add bl, 1					
				mov al, v_ch
				mov ah, 70h
				sub cl, 2
				call PrintVrtLine
				add cl, 2
				pop bx
				
				push bx 			; print right vertical line	
				add bl, 1					
				add bh, ch
				sub bh, 1
				mov al, v_ch
				mov ah, 70h
				sub cl, 2
				call PrintVrtLine
				add cl, 2
				pop bx

				ret
				endp

;------------------------------------------------