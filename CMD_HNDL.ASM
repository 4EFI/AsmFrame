
;------------------------------------------------
;	DIVIDE CMD LINE ARGS ( FROM 82h + CL ) 
;   TO ARRAY ( BYTE PTR )
;------------------------------------------------
; ENTRY:    BX = ARR ADDR ( ARGS )
;           CL = CMD LINE OFFSET
;           CH = AMOUNT OF NUMBERS TO HANDLE
; EXIT:		AX = NEW CMD LINE OFFSET
; DESTROYS:	AX
;------------------------------------------------

CmdLineHndl     proc

                xor ax, ax      ; AX = 0 ( num args counter = 0 ) 

                push cx         ; push (1)
                push si         ; push (2)

                push cx         ; push (3)
                xor  ch, ch     ; CH = 0
                mov  si, 82h    ; CurrSymPos = 82h + offset
                add  si, cx     
                pop  cx         ; pop  (3)

                cmp ch, 0       ; if( CH = 0 )
                je __EndNum 

                __NextNum:          push cx         ; push (4)    
                                    xor  cx, cx     ; i = 0

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
                                    push bx         ; push (5)
                                    push ax         ; push (6)
                                    mov  bx, si     ; BX = SI - i
                                    sub  bx, cx          
                                    call Atoi
                                    mov  cx, ax     ; CX = AX 
                                    pop  ax         ; pop  (6) 
                                    pop  bx         ; pop  (5)

                                    ; put NUM to ARR
                                    push bx                     ; push (7)
                                    add  bx, ax                 ; BX += CurrNumArg
                                    mov  byte ptr [bx], cl      ; arr[AX] = NUM 
                                    pop  bx                     ; pop  (7)

                                    inc ax                      ; NumArgs++

                                    __EndArgsCheck:

                                    pop cx                      ; pop (4)

                                    cmp al, ch                  ; if( AL == CH )
                                    je __EndNum

                                    cmp byte ptr [si], 13d      ; if( CurrSym == '\r' )
                                    je __EndNum
                                    cmp byte ptr [si], 0d       ; if( CurrSym == '\0' )
                                    je __EndNum

                                    inc si                      ; CurrSymPos++ 

                                    jmp __NextNum
                __EndNum:

                mov ax, si      ; AX = SI - 82h
                sub ax, 82h

                pop si          ; pop  (2)
                pop cx          ; pop  (1)

                ret
                endp

;------------------------------------------------