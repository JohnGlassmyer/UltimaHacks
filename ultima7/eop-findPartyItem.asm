%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; Find one matching item held by a party member.
startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        expanded overlay procedure: findPartyItem
        
    startBlockAt off_eop_findPartyItem
        push bp
        mov bp, sp
        
        ; bp-based stack frame:
        %assign arg_itemFrame           0x08
        %assign arg_itemQuality         0x06
        %assign arg_itemType            0x04
        %assign ____callerIp            0x02
        %assign ____callerBp            0x00
        %assign var_iPartyMember       -0x02
        %assign var_findItemQuery      -0x30
        
        sub sp, 0x30
        push si
        push di
        
        mov word [bp+var_iPartyMember], 0
        tryPartyMember:
            mov al, byte [dseg_partySize]
            cbw
            cmp ax, [bp+var_iPartyMember]
            jle noMorePartyMembers
            mov bx, [bp+var_iPartyMember]
            
            push word [bp+arg_itemFrame]
            push word [bp+arg_itemQuality]
            push word [bp+arg_itemType]
            push word 0 ; queryFlags
            shl bx, 1
            lea ax, [dseg_partyMemberIbos+bx]
            push ax
            lea ax, [bp+var_findItemQuery]
            push ax
            callWithRelocation o_findItemInContainer
            add sp, 0xC
            mov ax, [bp+var_findItemQuery]
            
            test ax, ax
            jnz foundItem
            
            inc word [bp+var_iPartyMember]
            jmp tryPartyMember
            
        foundItem:
            jmp endProc
            
        noMorePartyMembers:
            mov ax, 0
            jmp endProc
            
        endProc:
            ; ax == foundItemIbo or 0
            
        pop di
        pop si
        mov sp, bp
        pop bp
        retn
        
    endBlockAt off_eop_findPartyItem_end
endPatch
