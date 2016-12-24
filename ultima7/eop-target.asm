%include "include/UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; Have the player select an item by clicking on it, and then "use"
; the selected item.
;
; Serpent Isle had this functionality mapped to the 'T' key
; (though only in non-dialog mode).
startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        expanded overlay procedure: target
        
    startBlockAt off_eop_target
        proc_target:
            push bp
            mov bp, sp
            
            ; bp-based stack frame:
            %assign ____callerIp            0x02
            %assign ____callerBp            0x00
            %assign var_unused             -0x02
            %assign var_ibo                -0x04
            
            sub sp, 4
            push si
            push di
            
            lea ax, [bp+var_unused]
            push ax
            lea ax, [bp+var_unused] ; coordinateY
            push ax
            lea ax, [bp+var_unused] ; coordinateX
            push ax
            lea ax, [bp+var_ibo]
            push ax
            callWithRelocation o_havePlayerSelect
            add sp, 8
            
            cmp word [bp+var_ibo], 0
            jz short target_nothingSelected
            
            push word 0 ; flags
            push word 0 ; y coordinate
            push word 0 ; x coordinate
            lea ax, [bp+var_ibo]
            push ax
            callWithRelocation o_use
            add sp, 8
            
            ; TODO: if the used item was displayed in an open inventory,
            ;   then redraw that inventory dialog
            
            mov ax, 1
            jmp short target_end
            
            target_nothingSelected:
            xor ax, ax
            
            target_end:
            
            pop di
            pop si
            mov sp, bp
            pop bp
            retn
    endBlockAt off_eop_target_end
endPatch
