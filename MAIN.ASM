.186
.model tiny
.code 
org 100h

locals __

include 	TOOLS.ASM 			; Exit

Start:		mov bx, 0b800h 		; ES = VideoSeg
			mov es, bx

			mov byte ptr ax, ' '
			call ClearScreen 			

			EXIT	

include 	SCR_HNDL.ASM 		; Clear Screen function
; include 	NUM_CONVERT.ASM 	; To BIN/DEC/HEX	

end			Start

;------------------------------------------------
