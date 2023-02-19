
;------------------------------------------------
;	GET STR LEN
;------------------------------------------------
; ENTRY:	BX = STR ADDR
; EXIT:		AX = LEN
; EXPECTS:  END SYM = '$' or '\0'
; DESTROYS: NONE	
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
; DESTROYS:	AX DX DI
;------------------------------------------------

Atoi			proc	

				xor dx, dx		; i = 0



				ret	
				endp

;------------------------------------------------