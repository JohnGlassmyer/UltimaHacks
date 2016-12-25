%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; show memory usage stats in a "scroll" popup
startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        expanded overlay procedure: displayMemoryStats
        
    startBlockAt off_eop_displayMemoryStats
        push bp
        mov bp, sp
        
        ; bp-based stack frame:
        %assign ____callerIp            0x02
        %assign ____callerBp            0x00
        %assign var_string             -0x80
        
        sub sp, 0x80
        push si
        push di
        
        push dseg_originalFreeMemoryStats
        callWithRelocation o_sprintfMemoryUsage
        add sp, 2
        
        ; massage the memory-stats text so that it displays
        ; nicely in the "scroll" popup without line-wrapping
            mov di, [dseg_workstring]
            lea bx, [bp+var_string]
            forCharacter:
                mov ax, [ds:di]
                cmp al, 0
                jz afterTranslatingString
                
                cmp ax, '  '
                jnz notTwoSpaces
                ; skip second of two subsequent spaces
                inc di
                notTwoSpaces:
                
                cmp al, "'"
                jnz notQuote
                ; skip single-quote mark
                inc di
                jmp forCharacter
                notQuote:
                
                cmp al, ' '
                jae notUnprintable
                mov al, '~'
                notUnprintable:
                
                doneWithCharacter:
                mov [bx], al
                inc di
                inc bx
                jmp forCharacter
                
            afterTranslatingString:
            mov byte [bx], 0
            
        push ss
        lea ax, [bp+var_string]
        push ax
        callEopFromOverlay 2, popupScrollWithText
        add sp, 4
        
        pop di
        pop si
        mov sp, bp
        pop bp
        retn
    endBlockAt off_eop_displayMemoryStats_end
    
endPatch
