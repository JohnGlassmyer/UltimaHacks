[bits 16]

startPatch EXE_LENGTH, call-eop-determineItemBulk
	startBlockAt addr_doesItemFit_getBulkOfItems
		; get bulk of dropped item
		push word [doesItemFit_reg_pn_droppedIbo]
		callVarArgsEopFromOverlay determineItemBulk, 1
		pop cx
		mov [bp+doesItemFit_var_droppedItemBulk], ax
		
		; get capacity of destination container
		mov es, word [dseg_itemBufferSegment]
		mov bx, [doesItemFit_reg_pn_destinationIbo]
		mov ax, [es:bx+4]
		and ax, 0x3FF
		push ax
		callFromOverlay getItemTypeBulk
		pop cx
		mov [bp+doesItemFit_var_destinationCapacity], ax
		
		; get bulk of destination container's contents
		push doesItemFit_reg_pn_destinationIbo
		callFromOverlay determineBulkOfContents
		pop cx
		mov [bp+doesItemFit_var_destinationContentsBulk], ax
		
		times 16 nop
	endBlockWithFillAt nop, off_doesItemFit_getBulkOfItems_end
	
	; ibo from var, bulk into ax
	startBlockAt addr_determineBulkOfContents_site
		push word [bp+determineBulkOfContents_var_itemIbo]
		callVarArgsEopFromOverlay determineItemBulk, 1
		pop cx
	endBlockWithFillAt nop, off_determineBulkOfContents_site_end
endPatch
