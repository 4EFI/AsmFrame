
.186
.model tiny
.code 
org 100h

locals __

include 	TOOLS.ASM 			; Exit

;------------------------------------------------

Start:		mov bx, 0b800h 		; ES = VideoSeg
			mov es, bx

			mov bx, offset CmdData
			call CmdLineHndl

			mov byte ptr ax, ' '
			call ClrScrn

			mov ax, 123d	; set NUM	

			mov bh, 1d		; X
			mov bl, 5d		; Y
			call PrintNum

			mov bx, offset CmdData
			call PrintBox

			EXIT	

;------------------------------------------------

CmdData	db	20 dup (0)		; Cmd line data

include 	SCR_HNDL.ASM 	; Clear screen function
include 	CMD_HNDL.ASM 	; CMD line handler
include 	STR_HNDL.ASM 	; Str handler
include 	NUM_CNVR.ASM 	; Print AX in BIN/DEC/HEX	

end			Start

;------------------------------------------------
