
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

			mov bh, 0d
			mov bl, 10d
			call PrintBox

			; mov byte ptr al, 'v' 
			; mov bx, 1920
			; call PrintBin

			EXIT	

;------------------------------------------------

include 	SCR_HNDL.ASM 	; Clear Screen function
include 	NUM_CNVR.ASM 	; Print AX in BIN/DEC/HEX	

end			Start

;------------------------------------------------
