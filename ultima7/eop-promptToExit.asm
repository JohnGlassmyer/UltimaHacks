%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; show memory usage stats in a "scroll" popup
startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        expanded overlay procedure: promptToExit
        
    startBlockAt off_eop_promptToExit
        push bp
        mov bp, sp
        
        ; bp-based stack frame:
        %assign ____callerIp            0x02
        %assign ____callerBp            0x00
        
        push si
        push di
        
        push 0
        callWithRelocation o_doYesNoDialog
        add sp, 2
        
        mov [dseg_shouldExitMainGameLoop], al
        
        test al, al
        jz redrawDialogs
        
        ; the player chose to exit, so close dialogs
        ; in order to get control back to the main game loop
            mov byte [dseg_dialogState], 6
            jmp endProc
            
        redrawDialogs:
        ; the player chose not to exit, so redraw dialogs
            callWithRelocation o_redrawDialogs
            
        endProc:
        
        pop di
        pop si
        mov sp, bp
        pop bp
        retn
    endBlockAt off_eop_promptToExit_end
endPatch
