%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; Determine by type of item whether it has a quantity value.
;
; This code was inlined in the original game,
; but typing it out again is painful and costs bytes.
startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        expanded overlay procedure: doesItemHaveQuantity
        
    startBlockAt off_eop_doesItemHaveQuantity
        push bp
        mov bp, sp
        
        ; bp-based stack frame:
        %assign arg_ibo                 0x04
        %assign ____callerIp            0x02
        %assign ____callerBp            0x00
        
        sub sp, 0
        push si
        push di
        
        mov es, [dseg_itemBufferSegment]
        mov bx, [bp+arg_ibo]
        mov ax, word [es:bx+4]
        and ax, 0x3FF
        mov dx, 3
        imul dx
        mov bx, ax
        mov al, [dseg_itemTypeInfo+bx]
        and ax, 0xF
        
        cmp ax, 3
        jnz nope
        
        mov ax, 1
        jmp endProc
        
        nope:
        xor ax, ax
        
        endProc:
            ; ax == 1 if the item has quantity; 0 otherwise
            
        pop di
        pop si
        mov sp, bp
        pop bp
        retn
        
    endBlockAt off_eop_doesItemHaveQuantity_end
endPatch
