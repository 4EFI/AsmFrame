
.186
.model tiny
.code 
org 100h

locals __

include 	TOOLS.ASM 					; Exit

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

			push ax
			mov  ax, ' '	
			call ClrScreen		
			pop  ax	

			add ax, 83h
			mov bx, offset CmdData
			call PrintBox

			mov  bx, offset New
			mov  cl, 'A'
			mov  dx, 5d
			call MemSet

			mov  ah, 07h
			xor  bx, bx
			mov  cx, offset New
			; call PrintStr

			mov  bx, offset Nam
			mov  cx, offset New
			call StrCmp

			; mov ax, 123d				; set NUM
			; mov bh, 1d				; X
			; mov bl, 5d				; Y
			; call PrintNum

			EXIT	

;------------------------------------------------

CmdData	db	20 dup (0)		; Cmd line data

Nam    	db	"AAAAA", 0
New 	db  10 dup (0)

include 	SCR_HNDL.ASM 	; Clear screen function
include 	CMD_HNDL.ASM 	; CMD line handler
include 	STR_HNDL.ASM 	; Str handler
include 	NUM_CNVR.ASM 	; Print AX in BIN/DEC/HEX	

end			Start

;------------------------------------------------
