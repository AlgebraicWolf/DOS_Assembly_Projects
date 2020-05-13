.model tiny

.code
org 100h

Start:		mov bl, 0
		mov cx, 1
		mov ah, 0eh
	
Cycle:		mov al, bl
		int 10h
		inc bx
		cmp bl, 0
		je EndCycle
		jmp Cycle

EndCycle:	int 20h

end Start