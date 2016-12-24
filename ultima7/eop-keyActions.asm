%include "include/UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; Execute actions corresponding to a pressed key.
;
; Having this as a separate proc which can be called
; in either gameplay mode (with or without dialogs on screen)
; allows the same key commands to be used in both modes.
startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        expanded overlay procedure: keyActions
        
    startBlockAt off_eop_keyActions
        push bp
        mov bp, sp
        
        ; bp-based stack frame:
        %assign arg_keyCodeOrZero       0x04
        %assign ____callerIp            0x02
        %assign ____callerBp            0x00
        %assign var_keyCode            -0x02
        %assign var_selectedIbo        -0x04
        %assign var_isStats            -0x06
        %assign var_wasDialogMode      -0x08
        
        sub sp, 0x8
        push si
        push di
        
        ; if a key code was passed as a parameter, use it
            mov ax, [bp+arg_keyCodeOrZero]
            or ax, ax
            jnz haveKeyCode
            
        ; if no key code was provided as a parameter,
        ; then use the code of a pressed key, if one has been pressed
            callWithRelocation o_pollKeyToGlobalDiscarding
            test ax, ax
            jz noPolledKey
            mov ax, [dseg_polledKey]
            noPolledKey:
            
        haveKeyCode:
            mov [bp+var_keyCode], ax
            
        ; try cast-by-key
            push word [bp+var_keyCode]
            callEopFromOverlay 1, castByKey
            pop cx
            
            test ax, ax
            jnz usedCastByKey
            
            cmp word [bp+var_keyCode], 0
            jz noneToUse
            
        ; try to open or close dialogs
            mov ax, [bp+var_keyCode]
            cmp ax, 'i'
            jz openNextInventory
            cmp ax, 'z'
            jz openNextStats
            cmp ax, 27 ; Escape
            jz closeDialogs
            jmp trySelectInventory
            
            openNextInventory:
                mov word [bp+var_isStats], 0
                jmp openDialogForNextPartyMember
                
            openNextStats:
                mov word [bp+var_isStats], 1
                
            openDialogForNextPartyMember:
                mov di, 0
                forPartyMember:
                ; display the first dialog of requested type not already open
                    cmp di, 8
                    jge noPartyMemberToOpen
                    
                    push di
                    callEopFromOverlay 1, getPartyMemberIbo
                    pop cx
                    test ax, ax
                    jz nextPartyMember
                    mov word [bp+var_selectedIbo], ax
                    
                    push word [bp+var_isStats]
                    lea ax, [bp+var_selectedIbo]
                    push ax
                    callWithRelocation o_getOpenItemDialogListNode
                    add sp, 4
                    test ax, ax
                    jz openItemDialog
                    
                    nextPartyMember:
                    inc di
                    jmp forPartyMember
                    
        closeDialogs:
            mov byte [dseg_dialogState], 6
            jmp closedDialogs
            
        trySelectInventory:
            mov word [bp+var_isStats], 0
            
            push word [bp+var_keyCode]
            callEopFromOverlay 1, numberSelect
            add sp, 2
            
            test ax, ax
            jz trySelectStats
            
            mov [bp+var_selectedIbo], ax
            jmp openItemDialog
            
        trySelectStats:
            mov ax, [bp+var_keyCode]
            cmp ax, 0x178 ; Alt+1
            jb tryUseItem
            cmp ax, 0x17F ; Alt+8
            ja tryUseItem
            
            sub ax, (0x178 - '1') ; convert Alt+digit => digit
            
            push ax
            callEopFromOverlay 1, numberSelect
            add sp, 2
            
            test ax, ax
            jz tryUseItem
            
            mov word [bp+var_isStats], 1
            mov [bp+var_selectedIbo], ax
            
            jmp openItemDialog
            
        openItemDialog:
            ; decide whether dialog mode was already active
                mov word [bp+var_wasDialogMode], 0
                mov dx, [dseg_dialogState]
                cmp dx, 0
                jz wasNotDialogMode
                cmp dx, 6
                jz wasNotDialogMode
                mov word [bp+var_wasDialogMode], 1
                wasNotDialogMode:
                
            ; activate dialog mode, if it's not already active
                cmp word [bp+var_wasDialogMode], 0
                jnz doDisplayItemDialog
                
                ; 1 => inventory mode (doesn't automatically open a dialog)
                push 1
                callWithRelocation o_startDialogMode
                pop cx
                
            doDisplayItemDialog:
            ; open the requested stats or inventory dialog
                push word [bp+var_isStats]
                lea ax, [bp+var_selectedIbo]
                push ax
                callWithRelocation o_displayItemDialog
                add sp, 4
                
                callWithRelocation o_redrawDialogs
                
            ; do item dialog input loop, if not previously in dialog mode
                cmp word [bp+var_wasDialogMode], 0
                jnz openedAnItemDialog
                
                callWithRelocation o_itemDialogInputLoop
                
                jmp openedAnItemDialog
                
        tryUseItem:
            jmp itemMappingEnd
            
            ; mapItem keyCode, frame, quality, type
            %macro mapItem 4
                dw %1, %2, %3, %4
            %endmacro
            
            itemMappingStart:
            mapItem 'f', 0xFF, 0xFF, 377 ; food items
            mapItem 'g',   11, 0xFF, 675 ; abacus
            mapItem 'm', 0xFF, 0xFF, 178 ; cloth map
            mapItem 'o', 0xFF, 0xFF, 785 ; Orb of the Moons
            mapItem 'p', 0xFF, 0xFF, 627 ; lockpicks
            mapItem 'w', 0xFF, 0xFF, 159 ; pocketwatch
            mapItem 'x', 0xFF, 0xFF, 650 ; sextant
            itemMappingEnd:
            
            itemMappingCount EQU (itemMappingEnd - itemMappingStart) / 8
            mov cx, word itemMappingCount
            mov bx, offsetInEopSegment(itemMappingStart)
            tryItemMapping:
                mov ax, [cs:bx]
                cmp ax, [bp+var_keyCode]
                jnz notThisItemMapping
                    push word [cs:bx+2] ; frame
                    push word [cs:bx+4] ; quality
                    push word [cs:bx+6] ; type
                    callEopFromOverlay 3, usePartyItem
                    add sp, 6
                    
                    callWithRelocation o_redrawDialogs
                    
                    jmp usedPartyItem
                notThisItemMapping:
                    add bx, 8
                    loop tryItemMapping
                    
            jmp tryEnableKeyMouseInDialogMode
            
        tryEnableKeyMouseInDialogMode:
            cmp byte [dseg_isDialogMode], 0
            jz tryEopActions
            
            cmp word [bp+var_keyCode], ' '
            jnz tryEopActions
            
            ; start key-mouse mode
                mov ax, [dseg_mouseXxPosition]
                mov [dseg_keyMouseXxPosition], ax
                mov ax, [dseg_mouseYPosition]
                mov [dseg_keyMouseYPosition], ax
                
                mov byte [dseg_isKeyMouseEnabled], 1
                
                push MouseCursor_Finger
                callWithRelocation o_selectMouseCursor
                pop cx
                
            jmp enabledKeyMouse
            
        tryEopActions:
            jmp afterKeyMappings
            
            %define mapKeyToEop(keyCode, eop) \
                    dw keyCode, off_eop_ %+ eop - off_eop_segmentZero
            %define mappingCount (mappingsEnd - mappingsStart) / 4
            mappingsStart:
            mapKeyToEop(  'a', toggleAudio)
            mapKeyToEop(  'c', toggleCombat)
            mapKeyToEop(  'h', toggleMouseHand)
            mapKeyToEop(  'k', selectAndUseKey)
            mapKeyToEop(  's', doSaveDialog)
            mapKeyToEop(  't', target)
            mapKeyToEop(  'v', displayVersion)
            mapKeyToEop(0x12D, promptToExit)
            mapKeyToEop(0x132, displayMemoryStats)
            mappingsEnd:
            
            afterKeyMappings:
            
            mov ax, [bp+var_keyCode]
            mov bx, offsetInEopSegment(mappingsStart)
            mov cx, mappingCount
            forKeyMapping:
                cmp ax, [cs:bx]
                jnz notThisKeyMapping
                call near [cs:bx+2]
                jmp performedOtherAction
                
                notThisKeyMapping:
                add bx, 4
                loop forKeyMapping
                
            jmp noneToUse
            
        noPartyMemberToOpen:
        noneToUse:
            mov ax, 0
            jmp endProc
            
        usedCastByKey:
            mov ax, 1
            jmp endProc
            
        openedAnItemDialog:
            mov ax, 2
            jmp endProc
            
        closedDialogs:
            mov ax, 3
            jmp endProc
            
        usedPartyItem:
            mov ax, 4
            jmp endProc
            
        enabledKeyMouse:
            mov ax, 5
            jmp endProc
            
        performedOtherAction:
            mov ax, 6
            jmp endProc
            
        endProc:
            ; ax == 0 : did not use key
            ; ax != 0 : used key, as above
            
        pop di
        pop si
        mov sp, bp
        pop bp
        retn
        
    endBlockAt off_eop_keyActions_end
endPatch
