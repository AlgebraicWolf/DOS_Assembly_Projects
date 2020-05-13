.model tiny
.data

MyMsg:		db "This message has been printed directly to VRAM!", 0

.code
org 100h

Start:		mov ax, 0b800h
		mov es, ax
		mov ax, offset MyMsg
		mov bx, 0

ClrCycle:	mov byte ptr es:[bx], 0
		inc bx
		cmp bx, 2d*80d*25d
		je EndClrCycle
		jmp ClrCycle

endClrCycle:	mov bx, 2d*(13d*80d+16d)
		mov ch, 00011111b
	
PrnCycle:	push bx
		mov bx, ax
		mov cl, byte ptr [bx]
		pop bx
		mov byte ptr es:[bx], cl
		inc bx
		mov byte ptr es:[bx], ch
		inc bx
		inc ax
		add ch, 00010000b
		and ch, 01111111b
		cmp cl, 0
		je EndPrn
		jmp PrnCycle

EndPrn:

StartAnim:	mov bx, 2d*(13d*80d+16d)+1d
		mov cx, 0
		mov dx, 1
		mov ah, 01h
		int 1ah
		mov ah, 00h

Sleep:		int 1ah
		cmp dx, 7d
		jae EndSleep
		jmp Sleep	

EndSleep:	mov ch, byte ptr es:[bx]
		mov ah, 0

AnimCycle:	add bx, 2
		cmp bx, 2d*(13d*80d+16d)+1d+2d*47d
		jb SkipShift
		mov bx, 2d*(13d*80d+16d)+1d
		mov ah, 1
SkipShift:	mov cl, byte ptr es:[bx]
		mov byte ptr es:[bx], ch
		mov ch, cl
		cmp ah, 1
		je StartAnim
		jmp AnimCycle

EndAnim:	ret


end Start