%include "include/UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; Call the new key-handler procedure from the gump (dialog) loop
; to enable the use of many key commands while Stats or Inventory
; dialogs are on-screen. Gives the player flexibility and removes
; some of the distinction between the two modes of gameplay.
startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        call new key-handler in dialog loop
        
    off_handleKeyInput                  EQU 0xA0452
    off_afterHandlingKeyInput           EQU 0xA0510
    startBlockAt off_handleKeyInput
        cmp byte [dseg_isKeyMouseEnabled], 0
        jnz afterKeyActions
        push 0
        callEopFromOverlay 1, keyActions
        pop cx
        afterKeyActions:
        
        jmp calcJump(off_afterHandlingKeyInput)
    endBlockAt off_afterHandlingKeyInput
    
    off_mappingTable                    EQU 0xA05C0
    off_mappingTable_end                EQU 0xA05D4
    startBlockAt off_mappingTable
        ; 'i', 'z', and Escape are now handled in eop-keyActions
    endBlockAt off_mappingTable_end
endPatch
