%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; show memory usage stats in a "scroll" popup
startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        expanded overlay procedure: doSaveDialog
        
    startBlockAt off_eop_doSaveDialog
        push bp
        mov bp, sp
        
        ; bp-based stack frame:
        %assign ____callerIp            0x02
        %assign ____callerBp            0x00
        
        push si
        push di
        
        ; 2 => Save dialog
        push 2
        callWithRelocation o_startDialogLoopWithDialogType
        add sp, 2
        
        pop di
        pop si
        mov sp, bp
        pop bp
        retn
    endBlockAt off_eop_doSaveDialog_end
endPatch
