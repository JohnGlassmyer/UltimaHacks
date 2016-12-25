%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

startPatch EXPANDED_OVERLAY_U7_EXE_LENGTH, \
        call eop to use new item-bulk calculation
        
    off_doesItemFit_getBulkOfItems     EQU 0x549C3
    off_doesItemFit_getBulkOfItems_end EQU 0x54A06
    startBlockAt off_doesItemFit_getBulkOfItems
        ; get bulk of dropped item
        push word [di]
        callEopFromOverlay 1, determineItemBulk
        add sp, 2
        mov [bp-2], ax
        
        ; get capacity of destination container
        mov es, word [dseg_itemBufferSegment]
        mov bx, [si]
        mov ax, [es:bx+4]
        and ax, 0x3FF
        push ax
        callWithRelocation o_getItemTypeBulk
        add sp, 2
        mov [bp-4], ax
        
        ; get bulk of destination container's contents
        push si
        callWithRelocation o_determineBulkOfContents
        add sp, 2
        mov [bp-6], ax
    endBlockWithFillAt nop, off_doesItemFit_getBulkOfItems_end
    
    ; ibo from [bp-6], bulk into ax
    off_determineBulkOfContents_site     EQU 0x80CD3
    off_determineBulkOfContents_site_end EQU 0x80CE8
    startBlockAt off_determineBulkOfContents_site
        ; [bp-6] is item ibo
        push word [bp-6]
        callEopFromOverlay 1, determineItemBulk
        add sp, 2
    endBlockWithFillAt nop, off_determineBulkOfContents_site_end
endPatch
