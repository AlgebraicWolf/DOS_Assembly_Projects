.model tiny
.data

Msg:		db "Just like DVD!", 0
Len		equ 14
Del		equ 6
.code
org 100h

Start:		mov ah, 01h
		mov cl, 20h
		mov ch, 20h
		int 10h
		mov ax, 0b800h
		mov es, ax
		call ClearScreen
		call DrawBox
		mov ch, 5d
		mov cl, 3d
		mov ah, 1d
		mov al, 1d
		push ax
		mov dx, 0
		call Animation
		int 20h

Animation:	push ax	
AnimCycle:	call DrawRoutine
		pop ax
		add ch, ah
		add cl, al
		call CollisionCheck
		push ax
		jmp AnimCycle
		ret

CollisionCheck:	cmp ch, 21
		jb SkipBottom
		add dh, 10000b
		mov ch,	21
		mov ah, -1
		jmp SkipTop	
SkipBottom:	cmp ch, 1
		ja SkipTop
		add dh, 10000b
		mov ch, 1
		mov ah, 1
SkipTop:	cmp cl, 1
		ja SkipLeft
		add dh, 10000b
		mov cl, 1
		mov al, 1
		jmp SkipRight
SkipLeft:	mov dl, cl
		add dl, Len
		inc dl
		cmp dl, 78
		jb SkipRight
		add dh, 10000b
		mov al, -1
		mov cl, dl
		dec cl
		sub cl, Len
SkipRight:	and dh, 01110000b
		or dh, 00001111b
		ret

DrawRoutine:	push dx
		push cx
		push cx
		push cx
		push dx
		call WriteText
		pop dx
		pop cx
		call Colorize
		call Delay
		pop cx
		call ClearText
		pop cx
		pop dx
		ret

Colorize:	push dx
		call CalcPosition
		pop dx
		inc bx
		push bx
		call ColorizeLine
		pop bx
		add bx, 160d
		push bx
		call ColorizeLine
		pop bx
		add bx, 160d
		call ColorizeLine
		ret

ColorizeLine:	mov byte ptr es:[bx], dh
		add bx, 2
		mov dl, 0
ColorizeCycle:	mov byte ptr es:[bx], dh
		inc dl
		add bx, 2
		cmp dl, Len
		je EndColorize
		jmp ColorizeCycle
EndColorize:	mov byte ptr es:[bx], dh
		ret

Delay:		mov ah, 01h
		mov cx, 0
		mov dx, 0
		int 1ah
		mov ah, 00h
DCycle:		int 1ah
		cmp dx, Del
		jae EndDelay
		jmp DCycle
EndDelay:	ret

ClearText:	call CalcPosition
		push bx
		call ClearLine
		pop bx
		add bx, 160d
		push bx
		call ClearLine
		pop bx
		add bx, 160d
		call ClearLine
		ret

ClearLine:	mov byte ptr es:[bx], 0
		inc bx
		mov byte ptr es:[bx], 00001111b
		inc bx
		mov ax, 0
CLCycle:	mov byte ptr es:[bx], 0
		inc bx
		mov byte ptr es:[bx], 00001111b 
		inc bx
		inc ax
		cmp ax, Len
		je EndCLCycle
		jmp CLCycle
EndCLCycle:	mov byte ptr es:[bx], 0
		inc bx
		mov byte ptr es:[bx], 00001111b
		ret

CalcPosition:	mov ax, 0
		mov al, ch
		mov bx, 80d
		push dx
		mul bx
		pop dx
		mov ch, 0
		add ax, cx
		mov bx, 2
		push dx
		mul bx
		pop dx
		mov bx, ax
		ret

WriteText:	call CalcPosition
		push bx
		call DrawTB
		mov dx, 0
		pop bx
		add bx, 162d
		push bx
		mov bx, offset Msg
WritingCycle:	mov dl, [bx]
		mov cx, bx
		cmp dl, 0
		je EndWC
		pop bx
		mov byte ptr es:[bx], dl
		add bx, 2
		push bx
		mov bx, cx
		inc bx
		jmp WritingCycle
EndWC:		pop bx
		ret

DrawTB:		mov byte ptr es:[bx], 0dah
		push bx
		add bx, 2
		call DrawTBH
		mov byte ptr es:[bx], 0bfh
		add bx, 160d
		mov byte ptr es:[bx], 0b3h
		pop bx
		add bx, 160d
		mov byte ptr es:[bx], 0b3h
		add bx, 160d
		mov byte ptr es:[bx], 0c0h
		add bx, 2d
		call DrawTBH
		mov byte ptr es:[bx], 0d9h
		ret

DrawTBH:	mov dx, 0
TBHCycle:	mov byte ptr es:[bx], 0c4h
		inc dx
		add bx, 2
		cmp dx, Len
		jb TBHCycle
		ret 

DrawBox:	mov bx, 0
		mov byte ptr es:[bx], 0c9h
		add bx, 2d
		call DrawHorLine
		mov byte ptr es:[bx], 0bbh
		add bx, 160d
		call DrawVerLine
		mov bx, 160d
		call DrawVerLine
		mov byte ptr es:[bx], 0c8h
		add bx, 2
		call DrawHorLine
		mov byte ptr es:[bx], 0bch
		ret

DrawHorLine:	mov cx, 0
HorLineCycle:	mov byte ptr es:[bx], 0cdh
		inc cx
		add bx, 2
		cmp cx, 78d
		jb HorLineCycle
		ret

DrawVerLine:	mov cx, 0
VerLineCycle:	mov byte ptr es:[bx], 0bah
		inc cx
		add bx, 2d*80d
		cmp cx, 23d
		jb VerLineCycle
		ret

ClearScreen:	mov bx, 0b
ClearCycle:	mov byte ptr es:[bx], 0
		inc bx
		mov byte ptr es:[bx], 1111b
		inc bx
		cmp bx, 25d*80d*2
		ja EndClrCycle
		jmp ClearCycle
EndClrCycle:	ret

end Start