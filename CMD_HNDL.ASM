
;------------------------------------------------
;	DIVIDE CMD LINE ARGS ( FROM 82h ) TO ARRAY ( BYTE PTR )
;------------------------------------------------
; ENTRY:	BX = ARR ADDR ( ARGS )
; EXIT:		AX = NUM ARGS
; DESTROYS:	AX
;------------------------------------------------

CmdLineHndl     proc

                xor ax, ax      ; AX = 0 ( num args counter = 0 ) 

                push si         ; push (1)
                push cx         ; push (2)

                mov si, 82h     ; CurrSymPos = 82h

                __NextNum:          xor cx, cx      ; i = 0

                                    __Next:         cmp byte ptr [si], ' '      ; if( CurrSym == ' ' )
                                                    je __End
                                                    cmp byte ptr [si], 9d       ; if( CurrSym == '\t' )
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
                                    je __EndArgsCheck

                                    ; STR to NUM
                                    push bx         ; push (3)
                                    push ax         ; push (4)
                                    mov  bx, si     ; BX = SI - i
                                    sub  bx, cx          
                                    call Atoi
                                    mov  cx, ax     ; CX = AX 
                                    pop  ax         ; pop  (4) 
                                    pop  bx         ; pop  (3)

                                    ; put NUM to ARR
                                    push bx                     ; push (5)
                                    add  bx, ax                 ; BX += CurrNumArg
                                    mov  byte ptr [bx], cl      ; arr[AX] = NUM 
                                    pop  bx                     ; pop  (5)

                                    inc ax                      ; NumArgs++

                                    __EndArgsCheck:

                                    cmp byte ptr [si], 13d      ; if( CurrSym == '\r' )
                                    je __EndNum
                                    cmp byte ptr [si], 0d       ; if( CurrSym == '\0' )
                                    je __EndNum

                                    inc si                      ; CurrSymPos++ 

                                    jmp __NextNum
                __EndNum:

                pop cx          ; pop  (2)
                pop si          ; pop  (1)

                ret
                endp

;------------------------------------------------