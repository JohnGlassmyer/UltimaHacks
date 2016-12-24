%include "include/UltimaPatcher.asm"
%include "include/u7.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        do not enable key-mouse when starting dialog mode
        
    ; original: skip enabling keyMouse if dialog is clickable world
    ; now:      skip enabling keyMouse for any dialog
    off_startDialogMode_maybeEnableKeyMouse EQU 0x9F817
    off_startDialogMode_afterEnableKeyMouse EQU 0x9F835
    startBlockAt off_startDialogMode_maybeEnableKeyMouse
        jmp short calcJump(off_startDialogMode_afterEnableKeyMouse)
    endBlockAt off_startDialogMode_maybeEnableKeyMouse + 2
endPatch
