%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

startPatch EXE_LENGTH, \
		call eop to use new item-bulk calculation
		
	off_doesItemFit_getBulkOfItems     EQU 0x0ED3
	off_doesItemFit_getBulkOfItems_end EQU 0x0F16
	startBlockAt 214, off_doesItemFit_getBulkOfItems
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
		callFromOverlay getItemTypeBulk
		add sp, 2
		mov [bp-4], ax
		
		; get bulk of destination container's contents
		push si
		callFromOverlay determineBulkOfContents
		add sp, 2
		mov [bp-6], ax
	endBlockWithFillAt nop, off_doesItemFit_getBulkOfItems_end
	
	; ibo from [bp-6], bulk into ax
	off_determineBulkOfContents_site     EQU 0x0283
	off_determineBulkOfContents_site_end EQU 0x0298
	startBlockAt 272, off_determineBulkOfContents_site
		; [bp-6] is item ibo
		push word [bp-6]
		callEopFromOverlay 1, determineItemBulk
		add sp, 2
	endBlockWithFillAt nop, off_determineBulkOfContents_site_end
endPatch
