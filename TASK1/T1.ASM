.model tiny
.data
CR		equ 13
LF		equ 10
CRLF		equ CR, LF

PRINT		equ 09h
EXIT0		equ 4c00h

MyMsg:		db 'Soft kitty, warm kitty', CRLF, 'Little ball of fur!', CRLF, 'Happy kitty, sleepy kitty', CRLF, 'Purr, purr, purr!', CRLF, '$'

.code
org 100h
Start:		mov ah, PRINT
		mov dx, offset MyMsg
		int 21h
		mov ax, EXIT0
		int 21h
end Start