
;------------------------------------------------
;	GET STR LEN
;------------------------------------------------
; ENTRY:	BX = STR ADDR
; EXIT:		AX = LEN
; EXPECTS:  END SYM = '$' or '\0'
; DESTROYS: AX	
;------------------------------------------------

StrLen          proc

                xor ax, ax     	; i = 0

				push cx			; push (1)
				push si			; push (2)

                __Next:			mov  si, bx     ; SI = BX + i	    
							    add  si, ax
								
								inc  ax			; i++	
								mov  cx, [si]	; CX = current symbol

								cmp  ch, '$'	; if( ch == '$' )
								je __End	
								cmp  ch, 0d 	; if( ch == '\0' )
								je __End	

								jmp __Next

				__End:
				pop si			; pop  (2)
				pop cx			; pop  (1)		

                ret 
                endp

;------------------------------------------------
;	TRANSLATE STR TO NUMBER
;------------------------------------------------
; ENTRY:	BX = STR ADDR
; EXIT:		AX = NUM
; EXPECTS:	CX = STR LEN
; DESTROYS:	AX
;------------------------------------------------

Atoi			proc	

				xor ax, ax		; AX = 0

				push dx			; push (1)
				push si			; push (2)

				xor dx, dx		; i = 0

				__Next:			mov si, bx		; SI = BX + STR_LEN - i
								add si, cx
								sub si, dx
								sub si, 1

								push cx			; push (3)

								push ax			; push (4) 
								xor  ax, ax    	; AX = 0
								mov  al, [si]	; AX = [SI] - '0'
								sub  al, 48d

								push dx			; push (5)
								mov  cx, dx		; AX = AX * 10^DX 
								mov  si, 10d
								jcxz __NoMul

								__Mul:			mul si
								
												dec cx
												cmp cx, 0
												jne __Mul
								
								__NoMul:
								pop  dx			; pop  (5)
								mov  cx, ax	 

								pop ax			; pop  (4)
								add ax, cx
								pop cx			; pop  (3)

								inc dx			; i++

								cmp dx, cx		; if( i == CX )
								jne __Next	

				pop si			; pop  (2)
				pop dx			; pop  (1)	

				ret	
				endp

;------------------------------------------------