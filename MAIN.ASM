
.186
.model tiny
.code 
org 100h

locals __

include 	TOOLS.ASM 					; Exit

;------------------------------------------------

Start:		mov bx, 0b800h 				; ES = VideoSeg
			mov es, bx

			mov cl, 0					; CMD line box handler
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

			mov bx, offset CmdStr		; Copy str from CMD line
			add ax, 83h
			mov cx, ax
			call StrCpy
			call StrLen					; CmdStr[ strlen( CmdStr ) - 1 ] = '\0'		// remove last '\r'
			mov  si, ax
			dec  si
			mov  byte ptr bx[si], 0d	

			push ax
			mov  ax, ' '	
			call ClrScreen		
			pop  ax	

			push ax
			mov  ax, 1234d
			mov  bh, 41d
			mov  bl, 15d 
			call PrintNum
			pop  ax
			
			mov ax, offset CmdStr
			mov bx, offset CmdData
			call PrintBox

			EXIT	

;------------------------------------------------

CmdData	db	20 dup (0)		; Cmd line data
CmdStr  db	20 dup (0)		; Cmd line str

include 	SCR_HNDL.ASM 	; Clear screen function
include 	CMD_HNDL.ASM 	; CMD line handler
include 	STR_HNDL.ASM 	; Str handler
include 	REG_PRNT.ASM 	; Print AX in BIN/DEC/HEX	

end			Start

;------------------------------------------------
