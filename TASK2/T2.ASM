.model tiny
.data
Msg:		db 'I am a message printed using BIOS interrupt', 0

.code
org 100h

Start:		mov cx, 1
		mov bx, offset Msg
		
Print:		mov al, [bx]
		mov ah, 0eh
		int 10h
		inc bx
		cmp byte ptr [bx], 0
		je EndPrn
		jmp Print
		
EndPrn:		ret

end		Start