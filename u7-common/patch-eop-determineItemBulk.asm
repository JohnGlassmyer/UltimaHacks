; Calculate an item's bulk (an integer used to determined whether an item
; will fit into a container). Unless the item is a flexible container (a bag or
; backpack), this is done as in the original game, by looking up the value in a
; table indexed by item-type. However, if the item is a flexible container,
; then its bulk is instead determined to be the sum of the total bulk of its
; contents and one eighth of its table value.
;
; This makes flexible containers less bulky when they are empty or only
; partially full, in particular allowing more bags to fit within a backpack
; and allowing bags and/or backpacks to be placed within each other.
;
; (The original game had no concept of flexible containers; an empty bag would
; take up as much space as a full bag.)
	
[bits 16]

startPatch EXE_LENGTH, eop-determineItemBulk
	ITEM_TYPE_BACKPACK                      EQU 801
	ITEM_TYPE_BAG                           EQU 802
	
	startBlockAt addr_eop_determineItemBulk
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_ibo                 0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_itemBulk           -0x02
		add sp, var_itemBulk
		
		push si
		push di
		
		mov es, word [dseg_itemBufferSegment]
		
		; get type
		mov bx, [bp+arg_ibo]
		mov ax, [es:bx+4]
		and ax, 0x3FF
		
		cmp ax, ITEM_TYPE_BAG
		jz flexibleContainer
		cmp ax, ITEM_TYPE_BACKPACK
		jz flexibleContainer
		jmp short notFlexibleContainer
		
		flexibleContainer:
		; bulk = contentsBulk + max(containerBulk / 8, 1)
		push ax
		callFromOverlay getItemTypeBulk
		pop cx
		shr ax, 3
		cmp ax, 0
		jnz haveWeightOfContainer
		mov ax, 1
		haveWeightOfContainer:
		mov [bp+var_itemBulk], ax
		
		lea ax, [bp+arg_ibo]
		push ax
		callFromOverlay determineBulkOfContents
		pop cx
		mov bx, [bp+var_itemBulk]
		add ax, bx
		jmp short procEnd
		
		notFlexibleContainer:
		push ax
		callFromOverlay getItemTypeBulk
		pop cx
		
		procEnd:
		; return ax = bulk of item
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_determineItemBulk_end
endPatch
