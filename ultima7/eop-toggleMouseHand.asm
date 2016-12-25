%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        expanded overlay procedure: toggleMouseHand
        
    startBlockAt off_eop_toggleMouseHand
        push bp
        mov bp, sp
        
        ; bp-based stack frame:
        %assign ____callerIp            0x02
        %assign ____callerBp            0x00
        %assign var_newMouseHand       -0x02
        %assign var_string             -0x04
        
        sub sp, 0x4
        push si
        push di
        
        cmp word [dseg_mouseHand], 0
        jz setToLeftHanded
        
        ; set to right-handed
            mov word [bp+var_newMouseHand], 0
            mov word [bp+var_string], dseg_rightHandedMouseString
            jmp haveNewMouseHand
            
        setToLeftHanded:
            mov word [bp+var_newMouseHand], 1
            mov word [bp+var_string], dseg_leftHandedMouseString
            
        haveNewMouseHand:
            mov ax, [bp+var_newMouseHand]
            mov [dseg_mouseHand], ax
            
            push word 0
            push word 15
            push word 5
            push word [bp+var_string]
            push word [dseg_avatarIbo]
            push dseg_graphicsThing
            callWithRelocation o_barkOnItemInWorld
            add sp, 0xC
            
        pop di
        pop si
        mov sp, bp
        pop bp
        retn
        
    endBlockAt off_eop_toggleMouseHand_end
endPatch
