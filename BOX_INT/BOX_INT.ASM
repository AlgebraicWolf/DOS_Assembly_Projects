.186

.model tiny

locals @@

.data
AX_text  db "AX: XXXX"
BX_text  db "BX: XXXX"
CX_text  db "CX: XXXX"
DX_text  db "DX: XXXX"
old_int08h	 dd 0
EndLabel:
tsr_mode	equ 3100h
int08h_addr	equ	8*4
.code
org 100h

Start:
		xor ax,ax
		mov es,ax

		cli ; Disable INTs
		mov bx, int08h_addr ; Save address of int08h handler
		mov ax, word ptr es:[bx]
		mov cx, word ptr es:[bx+2] 
		mov word ptr cs:[old_int08h], ax ; Save pointer to old handler
		mov word ptr cs:[old_int08h + 2], cx
		mov word ptr es:[bx], offset Int08hHandler ; Rewrite handler
		mov ax, cs
		mov word ptr es:[bx+2], ax
		sti ; Enable INTs

        mov ax, 1003h ; Disable blinking colors
		mov bl, 0h
		int 10h

		mov ax, tsr_mode ; DOS function to enable TSR
		mov dx, offset EndLabel ; Get program size
		shr dx, 4 ; Turn it into segment
		add dx, 8 ; Ceiling
		int 21h ; Call function


Int08hHandler	proc
		push di bx ax cx dx es ds si bp
		pushf
		call dword ptr cs:[old_int08h]
		call WriteRegisters
		pop bp si ds es dx cx ax bx di
		iret
Int08hHandler	endp

;================================================
; Function that saves register value to memory
; ENTER: DI - Pointer to memory pos
; 		 AX - Register to save
; DESTR: DI
;================================================


UpdateRegister	proc
		push ax
		shr ax, 12
		;mov di, AX_text
		add di, 4
		call WriteRegister
		
		pop ax
		push ax

		shl ax, 4
		shr ax, 12
		add di, 1
		call WriteRegister

		pop ax
		push ax

		shl ax, 8
		shr ax, 12
		add di, 1
		call WriteRegister

		pop ax
		push ax

		shl ax, 12
		shr ax, 12
		add di, 1
		call WriteRegister

		pop ax
		ret
UpdateRegister endp

;================================================
; Function that writes register values to proper
; positions
; ENTER: AX, BX, CX, DX - Values
; DESTR: 
;================================================

UpdateRegisters proc
		push ax

		mov di, offset AX_text
		call UpdateRegister

		mov di, offset BX_text
		mov ax, bx
		call UpdateRegister

		mov di, offset CX_text
		mov ax, cx
		call UpdateRegister

		mov di, offset DX_text
		mov ax, dx
		call UpdateRegister
		
		pop ax
		ret
UpdateRegisters endp

;================================================
; Function that translates number in register 
; into a single HEX digit
; ENTER: DI - Where to save digit
; 		 AX - Digit
; EXIT: CS:[DI] - Desired character
;================================================

HexStr db '0123456789ABCDEF'

WriteRegister	proc
		mov bx, offset HexStr
		xlat						; mov al, [bx+al]


		mov byte ptr cs:[di], '0'
		add byte ptr cs:[di], al
		cmp ax, 10
		jb @@SkipLetter
		add byte ptr cs:[di], 7
@@SkipLetter:
		ret
WriteRegister	endp

;================================================
; Function that performs all the routine
; DESTR: ES, DI, DX, CX, AX, BX
;================================================

WriteRegisters proc
		cld
		call UpdateRegisters
        push 0b800h
        pop es
        xor di, di
        mov dx, 6d
        mov cx, 10d
        mov ah, 00100111b
        mov al, 10101110b
        call DrawBox
        mov di, 162d
		push cs
		pop ds
        
        mov cx, 8d
        mov si, cs:[offset AX_text]
        call WriteText

        add di, 144d
        mov cx, 8d
        call WriteText

        add di, 144d
        mov cx, 8d
        call WriteText


        add di, 144d
        mov cx, 8d
        call WriteText
        ret
WriteRegisters endp

extrn WriteText:proc
extrn CastShadow:proc
extrn DrawBox:proc
extrn DrawHorLine:proc

end Start