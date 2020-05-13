.186
.model tiny

locals @@

.code

public CastShadow
public DrawBox
public DrawHorLine
public WriteText


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
; Function that writes text
; ENTER: DS:[SI] - String
;        ES:[DI] - Pointer to string
;        CX - Length of string
; DESTR: DS:[SI], ES:[DI], CX
;================================================

WriteText   proc
@@Cycle:
        movsb
        inc di
        loop @@Cycle
        
        ret
WriteText   endp

end
