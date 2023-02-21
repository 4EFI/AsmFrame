
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

			mov bh, 0d		; X
			mov bl, 4d		; Y
			mov ch, 50d		; WIDTH
			mov cl, 10d		; HEIGHT
			call PrintBox

			mov ax, [CmdData]

			mov bh, 1d		; X
			mov bl, 5d		; Y
			call PrintNum

			EXIT	

;------------------------------------------------

CmdData	dw	20 dup (0)		; Cmd line data

;			X   Y   W    H    CLR
arr db		0d, 4d, 50d, 10d, 07h

include 	SCR_HNDL.ASM 	; Clear screen function
include 	CMD_HNDL.ASM 	; CMD line handler
include 	STR_HNDL.ASM 	; Str handler
include 	NUM_CNVR.ASM 	; Print AX in BIN/DEC/HEX	

end			Start

;------------------------------------------------
