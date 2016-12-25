%include "../UltimaPatcher.asm"
%include "include/u7.asm"

[bits 16]

off_SaveSlot_processInput_loopForMouseUp    EQU 0x9F221

off_keyOrMouse                              EQU 0xA6050
off_handleKeyWithActiveSlot                 EQU 0xA6062

off_handleKeyAfterTimerMode                 EQU 0xA609A
off_disableLoadOnFirstEdit                  EQU 0xA6178
off_determineSlotTextWidth                  EQU 0xA618C

off_textNoLongerUnedited                    EQU 0xA6234
off_enableOrDisableSaveButton               EQU 0xA6239

off_handleKey                               EQU 0xA62E4
off_checkForMouseButton2                    EQU 0xA6390
off_handleMouse                             EQU 0xA63AC

off_triggerClose                            EQU 0xA63CE
off_triggerLoad                             EQU 0xA64DB
off_triggerSave                             EQU 0xA64AF

off_saveSlotLoopStart                       EQU 0xA6522

off_usedSlotSelected                        EQU 0xA66BF
off_usedSlotSelected_end                    EQU 0xA66D8

off_afterSlotSelected                       EQU 0xA66EF
off_end                                     EQU 0xA66FF

startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        Save dialog keyboard controls and right-click-to-close
; SaveSlot_processInput
    
    ; Don't wait for mouse button to be released after a click on a save slot,
    ; because we are now using simulated clicks to activate slots.
    startBlockAt off_SaveSlot_processInput_loopForMouseUp
        nop
        nop
    endBlockAt off_SaveSlot_processInput_loopForMouseUp + 2
    
    off_SaveDialog_appendChar_testSpecialKey    EQU 0xA5070
    off_SaveDialog_appendChar_maybeTruncate     EQU 0xA508A
    off_SaveDialog_appendChar_afterTruncate     EQU 0xA50A8
    off_SaveDialog_appendChar_append            EQU 0xA50B4
    off_SaveDialog_appendChar_endProc           EQU 0xA50C7
    
; SaveDialog_appendChar -- non-printable keys do not truncate text
    
    startBlockAt off_SaveDialog_appendChar_testSpecialKey
        cmp ax, ' '
        jb calcJump(off_SaveDialog_appendChar_endProc)
        jmp calcJump(off_SaveDialog_appendChar_afterTruncate + 2)
    endBlockAt off_SaveDialog_appendChar_testSpecialKey + 7
    
    startBlockAt off_SaveDialog_appendChar_afterTruncate
        jmp calcJump(off_SaveDialog_appendChar_append)
        cmp ax, '~'
        ja calcJump(off_SaveDialog_appendChar_endProc)
        jmp calcJump(off_SaveDialog_appendChar_maybeTruncate)
    endBlockAt off_SaveDialog_appendChar_append
    
; SaveDialog_processInput
    
    %define arg_mouseState      0x8
    %define var_returnCode     -0x5
    %define var_keyWasPressed  -0x6
    %define var_pressedKeyCode -0xA
    
    startBlockAt off_keyOrMouse
        cmp byte [bp+var_keyWasPressed], 0
        jz calcJump(off_checkForMouseButton2)
        jmp calcJump(off_handleKey)
    endBlockAt off_handleKeyWithActiveSlot
    
    startBlockAt off_handleKeyAfterTimerMode
        cmp word [bp+var_pressedKeyCode], 0xD ; Enter
        jz trySaveButton
        
        cmp word [bp+var_pressedKeyCode], 0x11F ; Alt+S
        jz trySaveButton
        
        cmp word [bp+var_pressedKeyCode], 0x126 ; Alt+L
        jz tryLoadButton
        
        jmp neitherSaveNorLoad
        
        tryLoadButton:
        ; if Load button is enabled, load
        mov ax, si
        add ax, 0x2E
        push ax
        callWithRelocation o_Control_isVisible
        pop cx
        mov ah, 0
        test ax, ax
        jnz calcJump(off_triggerLoad)
        jmp neitherSaveNorLoad
        
        trySaveButton:
        ; if Save button is enabled, save
        mov ax, si
        add ax, 0x4A
        push ax
        callWithRelocation o_Control_isVisible
        pop cx
        mov ah, 0
        test ax, ax
        jnz calcJump(off_triggerSave)
        
        neitherSaveNorLoad:
        jmp calcJump(off_determineSlotTextWidth)
    endBlockAt off_disableLoadOnFirstEdit
    
    ; new - jump target for below
    startBlockAt off_disableLoadOnFirstEdit
        mov byte [si+0x157], 0
        mov ax, si
        add ax, 0x2E
        push ax
        callWithRelocation o_Control_setInvisible
        pop cx
        jmp calcJump(off_enableOrDisableSaveButton)
    endBlockAt off_determineSlotTextWidth
    
    ; prev: just set a bit indicating text had been edited
    ; now:  (jump to) disable Load button
    startBlockAt off_textNoLongerUnedited
        jmp calcJump(off_disableLoadOnFirstEdit)
    endBlockAt off_enableOrDisableSaveButton
    
    startBlockAt off_handleKey
        mov di, [si+0x2C]
        
        mov ax, [bp+var_pressedKeyCode]
        cmp ax, 27
        jz escape
        cmp ax, 0x148
        jz up
        cmp ax, 0x150
        jz down
        
        cmp di, -1
        jnz calcJump(off_handleKeyWithActiveSlot)
        
        cmp ax, '0'
        jz zeroKey
        jb notNumberKey
        cmp ax, '9'
        ja notNumberKey
        sub ax, '1'
        mov di, ax
        jmp setActive
        
        zeroKey:
        mov di, 9
        jmp setActive
        
        notNumberKey:
        jmp calcJump(off_checkForMouseButton2)
        
        escape:
        mov byte [bp+var_returnCode], 1
        jmp calcJump(off_end)
        
        up:
        cmp di, -1
        jz upToBottom
        cmp di, 0
        jz upToBottom
        dec di
        jmp setActive
        upToBottom:
        mov di, 9
        jmp setActive
        
        down:
        cmp di, -1
        jz downToTop
        cmp di, 9
        jz downToTop
        inc di
        jmp setActive
        downToTop:
        mov di, 0
        
        setActive:
        ; alter mouse state to simulate a click on the save slot
        ; bx = new slot
        mov bx, di
        shl bx, 1
        add bx, si
        add bx, 0xE
        mov bx, [bx]
        mov di, [bp+arg_mouseState]
        ; mouseState.2x = saveSlot.left * 2
        mov ax, [bx+0xE]
        shl ax, 1
        mov [di+2], ax
        ; mouseState.y = saveSlot.top
        mov ax, [bx+0x10]
        mov [di+4], ax
        ; mouseState.buttons = 1
        mov byte [di+7], 1
        
        ; let the click-detection code respond to the forged mouse state
        jmp calcJump(off_saveSlotLoopStart)
    endBlockAt off_checkForMouseButton2
    
    ; the right-click-to-close patch allows mouse button 2 to reach dialogs
    startBlockAt off_checkForMouseButton2
        mov bx, [bp+arg_mouseState]
        cmp byte [bx+MouseState_action], 1
        jnz notClose
        cmp byte [bx+MouseState_button], 2
        jnz notClose
        jmp calcJump(off_triggerClose)
        
        notClose:
        jmp calcJump(off_handleMouse)
    endBlockAt off_handleMouse
endPatch
