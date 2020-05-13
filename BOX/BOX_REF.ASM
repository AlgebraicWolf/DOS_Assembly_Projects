.186
.model tiny

locals @@

.data

Msg:	db 'Just like DVD!', 0
Len		equ 14
Del		equ 3
MainWindowColor		equ 070h
MainWindowShadow	equ 80h
.code
org 100h

Start:		
		cld
		mov ax, 1003h
		mov bl, 0h
		int 10h
		mov ah, 01h
		mov cl, 20h
		mov ch, 20h
		int 10h
		mov ax, 0b800h
		mov es, ax
		call ClearScreen
		call Zoom
		mov di, 0
		mov cx, 80d
		mov dx, 25d
		mov ah, 00h
		mov al, MainWindowColor
		call DrawBox
		mov ch, 5d
		mov cl, 3d
		mov ah, 1d
		mov al, 1d
		push ax
		mov dx, 9e00h
		call Animation
		int 20h

Zoom	proc
		mov ch, 11d
		mov cl, 11d
		call CalcPosition
		push bx
		push 3
		push 58
@@Cycle:
		pop cx dx di
		sub di, 162d
		add cx, 2
		add dx, 2
		cmp cx, 78
		jae @@EndCycle
		push di dx cx
		mov ah, MainWindowShadow
		mov al, MainWindowColor
		call DrawBox
		call Delay
		jmp @@Cycle
@@EndCycle:
		ret
Zoom	endp

Animation proc	
		push ax	
@@AnimCycle:	
		call DrawRoutine
		pop ax
		add ch, ah
		add cl, al
		call CollisionCheck
		push ax
		call KeyTerminate
		jmp @@AnimCycle
		ret
Animation endp

;===============================================
; Terminates program if any key is pressed
; DESTR: AH
;===============================================
KeyTerminate	proc
		mov ah, 01h
		int 16h
		jz @@Continue
		int 20h
@@Continue:	ret
KeyTerminate	endp


CollisionCheck	proc	
		cmp ch, 21
		jb @@SkipBottom
		add dh, 10000b
		mov ch,	21
		mov ah, -1
		jmp @@SkipTop	
@@SkipBottom:	cmp ch, 1
		ja @@SkipTop
		add dh, 10000b
		mov ch, 1
		mov ah, 1
@@SkipTop:	cmp cl, 1
		ja @@SkipLeft
		add dh, 10000b
		mov cl, 1
		mov al, 1
		jmp @@SkipRight
@@SkipLeft:	mov dl, cl
		add dl, Len
		inc dl
		cmp dl, 78
		jb @@SkipRight
		add dh, 10000b
		mov al, -1
		mov cl, dl
		dec cl
		sub cl, Len
@@SkipRight:	
		and dh, 01110000b
		cmp dh, 0
		ja @@SkipBlackReset
		add dh, 10000b
		jmp @@SkipWhiteReset
@@SkipBlackReset:
		cmp dh, 01110000b
		jb @@SkipWhiteReset
		add dh, 100000b
@@SkipWhiteReset:
		mov dl, dh
		shr dl, 4
		not dl
		and dl, 1111b
		add dh, dl
		or dh, 10001000b
		ret
CollisionCheck endp

DrawRoutine	proc
		push dx
		push cx
		push cx
		push cx
		push dx
		call WriteText
		pop dx
		pop cx
		call Delay
		pop cx
		call ClearText
		pop cx
		pop dx
		ret
DrawRoutine	endp

;================================================
; Function that performs delay 
;================================================

Delay 	proc	
		mov ah, 01h
		mov cx, 0
		mov dx, 0
		int 1ah
		mov ah, 00h
@@Cycle:	int 1ah
		cmp dx, Del
		jae @@EndDelay
		jmp @@Cycle
@@EndDelay:	ret
Delay	endp


;================================================
; Procedure that removes the drawn box as well as
; the text, disabling shadow
;================================================
ClearText	proc
		call CalcPosition
		mov di, bx
		mov cx, Len + 2
		call ClearLine
		mov cx, 2
		mov ah, MainWindowColor
		call CastShadow

		add bx, 160d
		mov di, bx
		mov cx, Len + 2
		call ClearLine
		mov cx, 2
		mov ah, MainWindowColor
		call CastShadow

		add bx, 160d
		mov di, bx
		mov cx, Len + 2
		call ClearLine
		mov cx, 2
		mov ah, MainWindowColor
		call CastShadow

		add bx, 160d
		mov di, bx
		mov cx, Len + 4
		mov ah, MainWindowColor
		call CastShadow
		ret
ClearText endp

;================================================
; Function that removes line of text
; ENTER: CX - Length of line
; 		 DI - Pointer to the line
; DESTR: DI, CX, AX
;================================================

ClearLine 	proc
		mov ah, MainWindowColor
		mov al, 00h
		rep stosw
		ret
ClearLine	endp

;================================================
; Function that calculates current position of 
; the text
; ENTER:	CH - X coordinate of the text
;		CL - Y coordinate of the text
; EXIT: BX - Current position of the text
; DESTR: BX CX
;================================================

CalcPosition	proc	
		xor bx, bx
		mov bl, ch
		shl bx, 2
		add bl, ch
		shl bx, 4
		mov ch, 0
		add bx, cx
		shl bx, 1
		ret
CalcPosition	endp
;================================================
; Function that prints text in a box
; ENTER: DI - Segment of Video RAM
; DESTR: SI, DI, AX, BX, CX, DX
;================================================

WriteText	proc	
		call CalcPosition ; Calculate TextBox position
		mov di, bx
		mov cx, Len + 2
		mov ah, dh
		mov al, dh
		;or al, 00001111b
		and ah, 01111111b
		mov dx, 3
		push bx
		call DrawBox
		pop bx
		add bx, 162d ; Move to the text position
		mov di, bx
		mov si, offset Msg
		mov cx, len
@@WritingCycle:
		movsb
		inc di
		loop @@WritingCycle
		ret ; Return
WriteText	endp

;================================================
; Function that casts shadow
; ENTER: CX - Length of shadow
;	 ES - Video RAM Segment
;	 AH - Shadow color
;	 DI - Shift to shadow position
; DESTR: CX, DI, AL
;================================================
CastShadow	proc
@@Cycle:
		mov al, byte ptr es:[di+1]
		and al, 07h
		and ah, 0f0h
		add ah, al	
		mov al, byte ptr es:[di]
		stosw
		loop @@Cycle
		ret
CastShadow	endp

;================================================
; Function that draws box
; ENTER: CX - Width (min: 2)
;	 DX - Height (min: 2)
;	 AH - Shadow color
;    AL - Text color
;	 DI - Box position
; DESTR: AX, BX, CX, DX, DI
;================================================
DrawBox		proc
		sub cx, 2
		sub dx, 2
		push ax cx
		xchg ah, al
		mov al, 0c9h
		mov bx, 0cdbbh
		call DrawHorLine ;top line
		mov cx, dx		

@@Verticals:
		mov dx, cx
		pop cx ax
		push ax cx
		xchg ah, al	
		mov al, 0bah
		mov bx, 0bah
		add di, 156d
		sub di, cx
		sub di, cx
		call DrawHorLine
		pop cx ax
		push ax cx
		mov cx, 2
		call CastShadow
		;pop cx ax
		;push ax cx
		sub di, 4
		mov cx, dx
		loop @@Verticals

		pop cx ax
		push ax cx
		xchg ah, al
		add di, 156d
		sub di, cx
		sub di, cx
		mov al, 0c8h
		mov bx, 0cdbch
		call DrawHorLine ;bottom line
		pop cx ax
		push cx
		mov cx, 2
		call CastShadow
		pop cx
		add di, 154d
		sub di, cx
		sub di, cx
		add cx, 3
		call CastShadow
		ret
DrawBox		endp

;================================================
; Procedure that draws a horizontal line of desired
; length with custom start, finish and intermediate
; symbols
;
; ENTER: CX - Number of repetitions of interm element
;	 ES - Shift to Video RAM
;	 DI - Position of line's first symbol
;	 AH - Line color
;        AL - First symbol
;        BL - Last symbol
;	 BH - Intermediate symbol
; EXIT:  DI - Position of the next after last symbol
; DESTR: CX, DI, AX
;================================================

DrawHorLine	proc
		stosw
		mov al, bh
		rep stosw
		mov al, bl
		stosw
		ret
DrawHorLine	endp


;================================================
; Procedure that clears the whole screen
; ENTER: ES - shift to video memort
; DESTR: DI, AX, CX
;================================================
ClearScreen 	proc	
		mov di, 0b
		mov cx, 80d * 25d
		mov ax, 0F00h
		rep stosw		
		ret
ClearScreen	endp

end Start