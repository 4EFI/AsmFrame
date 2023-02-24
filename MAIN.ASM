
.186
.model tiny
.code 
org 100h

locals __

include 	TOOLS.ASM 			; Exit

;------------------------------------------------

Start:		mov bx, 0b800h 				; ES = VideoSeg
			mov es, bx

			mov cl, 0					; Cmd line box handler
			mov ch, 6
			mov bx, offset CmdData
			call CmdLineHndl

			cmp CmdData[Type_Num], 0	; if( Type != 0 )
			jne	__NotUserType

			mov cl, al					; User's box handler
			mov ch, 9
			mov bx, offset Type_0
			call CmdLineHndl

			__NotUserType:

			mov ax, ' '	
			call ClrScreen			

			mov bx, offset CmdData
			call PrintBox

			; mov ax, 123d				; set NUM
			; mov bh, 1d				; X
			; mov bl, 5d				; Y
			; call PrintNum

			EXIT	

;------------------------------------------------

CmdData	db	20 dup (0)		; Cmd line data

include 	SCR_HNDL.ASM 	; Clear screen function
include 	CMD_HNDL.ASM 	; CMD line handler
include 	STR_HNDL.ASM 	; Str handler
include 	NUM_CNVR.ASM 	; Print AX in BIN/DEC/HEX	

end			Start

;------------------------------------------------
