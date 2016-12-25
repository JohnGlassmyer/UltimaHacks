%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; Determine whether an Alt key is held.
;
; TODO: use this for Alt-clicking on items
startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        expanded overlay procedure: getKeyboardAltStatus
        
    startBlockAt off_eop_getKeyboardAltStatus
        push bp
        mov bp, sp
        
        ; bp-based stack frame:
        %assign ____callerIp            0x02
        %assign ____callerBp            0x00
        
        push si
        push di
        
        mov ah, 2
        int 16h
        and ax, 8
        
        ; ax == 8 if Alt is held, 0 otherwise
        
        pop di
        pop si
        mov sp, bp
        pop bp
        retn
        
    endBlockAt off_eop_getKeyboardAltStatus_end
endPatch
