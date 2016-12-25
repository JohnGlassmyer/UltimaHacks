%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; Returns ibo of nth party member
; (with party ordered by npc number).
startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        expanded overlay procedure: getPartyMemberIbo
        
    startBlockAt off_eop_getPartyMemberIbo
        push bp
        mov bp, sp
        
        ; bp-based stack frame:
        %assign arg_partyMemberIndex    0x04
        %assign ____callerIp            0x02
        %assign ____callerBp            0x00
        %assign var_npcNumber          -0x02
        %assign var_foundIt            -0x04
        %assign var_npcIbo             -0x06
        
        sub sp, 0x6
        push si
        push di
        
        mov ax, [dseg_partySize]
        cmp word [bp+arg_partyMemberIndex], ax
        jge notFound
        
        xor di, di
        mov word [bp+var_npcNumber], 0
        forNpc:
            cmp word [bp+var_npcNumber], 11
            jg notFound
            
            push word [bp+var_npcNumber]
            lea ax, [bp+var_npcIbo]
            push ax
            callWithRelocation o_getNpcIbo
            add sp, 4
            
            lea ax, [bp+var_npcIbo]
            push ax
            callWithRelocation o_getNpcBufferForIbo
            add sp, 2
            mov bx, ax
            mov es, dx
            test word [es:bx+4], 0x800 ; is npc in party?
            jz nextNpc
            
            cmp di, word [bp+arg_partyMemberIndex]
            jl nextPartyMember
            
            mov ax, [bp+var_npcIbo]
            jmp endProc
            
            nextPartyMember:
            inc di
            
            nextNpc:
            inc word [bp+var_npcNumber]
            jmp forNpc
            
        notFound:
            xor ax, ax
            
        endProc:
            ; ax == ibo of nth party member, or 0
            
        pop di
        pop si
        mov sp, bp
        pop bp
        retn
        
    endBlockAt off_eop_getPartyMemberIbo_end
endPatch
