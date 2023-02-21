
;------------------------------------------------
;	DIVIDE CMD LINE ARGS TO ARRAY
;------------------------------------------------
; ENTRY:	BX = ARR ADDR ( ARGS )
; EXIT:		AX = NUM ARGS
; DESTROYS:	AX
;------------------------------------------------

CmdLineHndl     proc

                xor ax, ax      ; AX = 0 ( num args counter = 0 ) 

                push si         ; push (1)
                push cx         ; push (2)
                push dx         ; push (3)

                mov si, 82h     ; CurrSymPos = 82h

                __NextNum:          xor cx, cx      ; i = 0

                                    __Next:         cmp byte ptr [si], ' '      ; if( CurrSym == ' ' )
                                                    je __End
                                                    cmp byte ptr [si], 0d       ; if( CurrSym == '\0' )
                                                    je __End
                                                    cmp byte ptr [si], 13d      ; if( CurrSym == '\r' )
                                                    je __End
                                                    
                                                    inc cx                      ; i++
                                                    inc si                      ; CurrSymPos++
                                            
                                                    jmp __Next
                                    __End:

                                    cmp cx, 0       ; if( i == 0 )
                                    je __EndNum

                                    ; STR to NUM
                                    push bx         ; push (4)
                                    push ax         ; push (5)
                                    mov  bx, si     ; BX = SI - i
                                    sub  bx, cx          
                                    call Atoi
                                    mov  cx, ax     ; CX = AX 
                                    pop  ax         ; pop  (5) 
                                    pop  bx         ; pop  (4)

                                    ; put NUM to ARR
                                    push bx                     ; push (6)
                                    add  bx, ax                 ; BX += CurrNumArg
                                    mov  word ptr [bx], cx      ; arr[AX] = NUM 
                                    pop  bx                     ; pop  (6)

                                    inc ax                      ; NumArgs++

                                    cmp byte ptr [si], 13d      ; if( CurrSym == '\r' )
                                    je __EndNum
                                    cmp byte ptr [si], 0d       ; if( CurrSym == '\0' )
                                    je __EndNum

                                    inc si                      ; CurrSymPos++ 

                                    jmp __NextNum
                __EndNum:

                pop dx          ; pop  (3)
                pop cx          ; pop  (2)
                pop si          ; pop  (1)

                ret
                endp

;------------------------------------------------