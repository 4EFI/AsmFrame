
.186
.model tiny
.code 
org 100h

locals __

include 	TOOLS.ASM 			; Exit

;------------------------------------------------

Start:		mov bx, 0b800h 		; ES = VideoSeg
			mov es, bx

			mov byte ptr ax, ' '
			call ClrScrn

			mov bh, 0d		; X
			mov bl, 4d		; Y
			mov ch, 50d		; WIDTH
			mov cl, 10d		; HEIGHT
			call PrintBox

			mov bh, 1d		; X
			mov bl, 5d		; Y 
			mov ax, 2556d	; NUM
			call PrintBin

			mov bh, 1d		; X
			mov bl, 6d		; Y 
			mov ax, 2556d	; NUM
			call PrintHex

			EXIT	

;------------------------------------------------

include 	SCR_HNDL.ASM 	; Clear Screen function
include 	NUM_CNVR.ASM 	; Print AX in BIN/DEC/HEX	

end			Start

;------------------------------------------------
