
.186
.model tiny
.code 
org 100h

locals __

include 	TOOLS.ASM 			; Exit

;------------------------------------------------

Start:		mov bx, 0b800h 		; ES = VideoSeg
			mov es, bx

			call Input
			mov cx, dx
			mov bx, offset InputStr
			call Atoi

			; mov bx, offset NameStr
			; scall StrLen

			mov bh, 1d		; X
			mov bl, 5d		; Y
			call PrintNum

			call Input

			mov byte ptr ax, ' '
			call ClrScrn

			mov bh, 0d		; X
			mov bl, 4d		; Y
			mov ch, 50d		; WIDTH
			mov cl, 10d		; HEIGHT
			call PrintBox

			mov bh, 1d		; X
			mov bl, 5d		; Y
			mov ax, 1456d	; NUM
			call PrintNum

			EXIT	

;------------------------------------------------

NameStr db 	"Vlad", 0
Msg  	db	100 dup (0) 

include 	SCR_HNDL.ASM 	; Clear screen function
include 	STR_HNDL.ASM 	; Str handler
include 	NUM_CNVR.ASM 	; Print AX in BIN/DEC/HEX	

end			Start

;------------------------------------------------
