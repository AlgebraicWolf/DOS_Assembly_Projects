.186
.model tiny

locals @@

.data
Str1    db "AAAAB$"
Str2    db "AAAAC$"

.code
org 100h

Start:
    mov ax, ds
    mov es, ax
    mov di, offset Str2
    mov si, offset Str1
    mov cx, 6
    call memcmp

    mov ah, '$'
    mov di, offset Str1
    mov si, offset Str2
    call strcmp
    
    mov al, '$'
    mov di, offset Str1
    mov si, offset Str2
    call strlen
    int 20h


;================================================
; Function that searches first occurance of byte
; ENTER: ES:[DI] - Address to start search 
;        CX - Amount of bytes to search
;        AL - Byte to search for
; EXIT:  ES:[DI] - Pointer to the symbol to the
;                  end of string
;        ZF - Whether value was found
; DESTR: CX
;================================================
memchr  proc
    repne scasb
    ret
memchr   endp


;================================================
; Function that compares two arrays of bytes
; ENTER: DS:[SI] - First array
;        ES:[DI] - Second array
;        CX - Array length
; EXIT: DS:[SI] - Pointer to the end of search
;       ES:[DI] -             -||-
;       ZF - Whether end was reachd
;       AH - Difference (first - second)
; DESTR: CX
;================================================
memcmp  proc
    repe cmpsb
    mov ah, byte ptr ds:[si-1]
    sub ah, byte ptr es:[di-1]
    ret
memcmp  endp

;================================================
; Function that sets value to an array
; ENTER: ES:[DI] - Array
;        AH - Value
;        CX - Array length
; DESTR: ES:[DI], CX
;================================================
memset  proc
    rep stosb
    ret
memset  endp

;================================================
; Copies one array into another
; ENTER: DS:[SI] - Source
;        ES:[DI] - Destination
;        CX - Array length
; DESTR: DS:[SI], ES:[DI], CX
;================================================
memcpy   proc
    rep movsb
    ret
memcpy  endp

;================================================
; Function that calculates length of string
; ENTER: AL - String terminator
;        ES:[DI] - String
; EXIT:  CX - Length
; DESTR: ES:[DI]
;================================================ 
strlen  proc
    xor cx, cx
@@Search:
    scasb
    je @@End
    inc cx
    jmp @@Search
@@End:
    ret
strlen  endp

;================================================
; Function that searches for symbol in string
; ENTER: AH - Symbol to search for
;        BH - String terminator
;        ES:[DI] - String
; EXIT: ES:[DI] - Pointer to symbol
; DESTR: AL
;================================================
strchr  proc
@@Search:
    lodsb
    cmp ah, al
    je @@End
    cmp bh, al
    je @@End
    jmp @@Search
@@End:
    ret
strchr  endp

;================================================
; Function that copies string
; ENTER: DS:[SI] - String to copy from
;        ES:[DI] - String to copy to
;        AH - String terminator
; DESTR: DS:[SI], ES:[DI] 
;================================================
strcpy  proc
@@Copy:
    cmp byte ptr ds:[si], ah
    movsb
    jne @@Copy
    ret
strcpy  endp

;================================================
; Function that compares two strings
; ENTER: DS:[SI] - First string
;        ES:[DI] - Second string
;        AH - String terminator`
; EXIT:  AL - String differense
; DESTR: DS:[SI], ES:[DI] 
;================================================
strcmp  proc
@@Compare:
    cmp byte ptr ds:[si], ah
    je @@End
    cmp byte ptr es:[di], ah
    je @@End
    cmpsb
    jne @@End
    jmp @@Compare
@@End:
    mov al, byte ptr ds:[si-1]
    sub al, byte ptr es:[di-1]
    ret
strcmp  endp

end Start