%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; Try to put the item currently being dragged into a target item.
; Report "cannot place" in the same manner as the original game.
startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        expanded overlay procedure: placeItemOrReportNoCanDo
        
    startBlockAt off_eop_placeItemOrReportNoCanDo
        push bp
        mov bp, sp
        
        ; bp-based stack frame:
        %assign arg_targetIbo           0x04
        %assign ____callerIp            0x02
        %assign ____callerBp            0x00
        %assign var_itemIbo            -0x02
        %assign var_itemXCoordinate    -0x06
        %assign var_itemYCoordinate    -0x0A
        
        sub sp, 0xA
        push si
        push di
        
        lea ax, [bp+var_itemIbo]
        push ax
        callWithRelocation o_getItemBeingDragged
        pop cx
        
        ; stop if nothing's being dragged
        test ax, ax
        jz failSilently
        
        ; don't drop items into a spellbook. that would be bad,
        ; as there's no way to get items out of a spellbook.
        mov es, [dseg_itemBufferSegment]
        mov bx, [bp+arg_targetIbo]
        mov ax, [es:bx+4]
        and ax, 0x3FF
        cmp ax, 761
        jz failSilently
        
        ; get item's x coordinate
        lea ax, [bp+var_itemIbo]
        push ax
        push ss
        lea ax, [bp+var_itemXCoordinate]
        push ax
        callWithRelocation o_getItemXCoordinate
        add sp, 6
        
        ; get item's y coordinate
        lea ax, [bp+var_itemIbo]
        push ax
        push ss
        lea ax, [bp+var_itemYCoordinate]
        push ax
        callWithRelocation o_getItemYCoordinate
        add sp, 6
        
        push 0 ; shouldSetBit
        push 1 ; shouldTryToStack
        lea ax, [bp+arg_targetIbo]
        push ax
        callWithRelocation o_tryToPlaceItem
        add sp, 6
        
        test ax, ax
        jnz notSuccessful
        
        ; move was successful
            lea ax, [bp+var_itemYCoordinate]
            push ax
            lea ax, [bp+var_itemXCoordinate]
            push ax
            lea ax, [bp+var_itemIbo]
            push ax
            callWithRelocation o_reactToItemMovement
            add sp, 6
            
        ; close dialogs if move triggered a reaction
            test ax, ax
            jz playDropItemSound
            
            cmp byte [dseg_isDialogMode], 0
            jz playDropItemSound
            
            mov byte [dseg_dialogState], 6
            
        playDropItemSound:
            push 73
            callWithRelocation o_playSoundSimple
            pop cx
            
            mov ax, 1
            jmp endProc
            
        notSuccessful:
        cmp ax, 1
        jz error4
        cmp ax, 2
        jz error0
        cmp ax, 3
        jz error0
        cmp ax, 4
        jz error5
        ja failSilently
        
        error0:
            mov ax, 0
            jmp failWithError
        
        error4:
            mov ax, 4
            jmp failWithError
            
        error5:
            mov ax, 5
            jmp failWithError
            
        failWithError:
            push ax
            callWithRelocation o_reportNoCanDo
            pop cx
            mov ax, 0
            jmp endProc
            
        failSilently:
            mov ax, 0
            jmp endProc
            
        endProc:
        pop di
        pop si
        mov sp, bp
        pop bp
        retn
        
    endBlockAt off_eop_placeItemOrReportNoCanDo_end
endPatch
