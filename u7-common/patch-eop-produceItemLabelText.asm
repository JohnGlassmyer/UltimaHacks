; Produce text to label a clicked item, substituting the item's weight or
; bulk in place of its name if the Shift key or Ctrl key, respectively, is held.
;
; The original game did not reveal any information about the bulk of items to
; the player other than by blocking attempts to place items inside of containers
; having insufficient space.

[bits 16]

startPatch EXE_LENGTH, eop-produceItemLabelText
	startBlockAt addr_eop_produceItemLabelText
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_itemLabelType       0x08
		%assign arg_ibo                 0x06
		%assign arg_pn_string           0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_itemType           -0x02
		%assign var_itemFrame          -0x04
		%assign var_itemQuantity       -0x06
		%assign var_valueOfItem        -0x08
		%assign var_valueOfContents    -0x0A
		%assign var_capacityOfItem     -0x0C
		%assign var_valueString        -0x0E
		%assign var_valueLength        -0x10
		%assign var_templateVarCount   -0x12
		%assign var_templateBuffer     -0x62
		add sp, var_templateBuffer
		
		push si
		push di
		
		; get type
		mov es, word [dseg_itemBufferSegment]
		mov bx, [bp+arg_ibo]
		mov ax, [es:bx+4]
		and ax, 0x3FF
		mov [bp+var_itemType], ax
		
		; truncate string before doing anything else
		mov bx, [bp+arg_pn_string]
		mov byte [bx], 0
		mov byte [bx+79], 0
		
		mov ax, [bp+arg_itemLabelType]
		cmp ax, ItemLabelType_NAME
		jz produceItemNameText
		cmp ax, ItemLabelType_WEIGHT
		jz produceWeightText
		cmp ax, ItemLabelType_BULK
		jz produceBulkText
		
		jmp procEnd
		
		weightString                    db 'weight', 0
		bulkString                      db 'bulk', 0
		
		itemTemplate                    db ': %d.%d', 0
		itemContentsTemplate            db ': %d.%d (contents: %d.%d)', 0
		itemContentsCapacityTemplate    db ': %d.%d (contents: %d.%d of %d.%d)', 0
		contentsTemplate                db ' of contents: %d.%d', 0
		
		produceWeightText:
			lea ax, [bp+arg_ibo]
			push ax
			callFromOverlay Item_getWeight
			pop cx
			mov word [bp+var_valueOfItem], ax
			
			lea ax, [bp+arg_ibo]
			push ax
			callFromOverlay determineWeightOfContents
			pop cx
			mov word [bp+var_valueOfContents], ax
			
			cmp word [bp+var_valueOfItem], 0
			jz dontIncludeWeightOfContents
			add word [bp+var_valueOfItem], ax
			dontIncludeWeightOfContents:
			
			mov word [bp+var_capacityOfItem], 0
			
			mov si, offsetInCodeSegment(weightString)
			mov cx, 6
			
			jmp haveValues
			
		produceBulkText:
			push word [bp+arg_ibo]
			callVarArgsEopFromOverlay determineItemBulk, 1
			pop cx
			mov word [bp+var_valueOfItem], ax
			
			lea ax, [bp+arg_ibo]
			push ax
			callFromOverlay determineBulkOfContents
			pop cx
			mov word [bp+var_valueOfContents], ax
			
			push word [bp+var_itemType]
			callFromOverlay getItemTypeBulk
			pop cx
			mov word [bp+var_capacityOfItem], ax
			
			mov si, offsetInCodeSegment(bulkString)
			mov cx, 4
			
		haveValues:
			mov word [bp+var_valueLength], cx
			
			; copy value string from code segment into stack
			lea di, [bp+var_templateBuffer]
			fmemcpy ss, di, cs, si, cx
			
			mov word [bp+var_templateVarCount], 0
			
			%macro pushDiv10 1
				mov ax, %1
				mov dl, 10
				div dl
				movzx cx, ah
				push cx
				inc word [bp+var_templateVarCount]
				mov cl, al
				push cx
				inc word [bp+var_templateVarCount]
			%endmacro

			cmp word [bp+var_valueOfItem], 0
			jnz haveItem
			
			cmp word [bp+var_valueOfContents], 0
			jz procEnd
			
			mov si, offsetInCodeSegment(contentsTemplate)
			pushDiv10 word [bp+var_valueOfContents]
			jmp applyTemplate
			
		haveItem:
			cmp word [bp+var_valueOfContents], 0
			jnz haveItemAndContents
			
			mov si, offsetInCodeSegment(itemTemplate)
			pushDiv10 word [bp+var_valueOfItem]
			jmp applyTemplate
			
		haveItemAndContents:
			cmp word [bp+var_capacityOfItem], 0
			jnz haveItemAndContentsAndCapacity
			
			mov si, offsetInCodeSegment(itemContentsTemplate)
			pushDiv10 word [bp+var_valueOfContents]
			pushDiv10 word [bp+var_valueOfItem]
			jmp applyTemplate
			
		haveItemAndContentsAndCapacity:
			mov si, offsetInCodeSegment(itemContentsCapacityTemplate)
			pushDiv10 word [bp+var_capacityOfItem]
			pushDiv10 word [bp+var_valueOfContents]
			pushDiv10 word [bp+var_valueOfItem]
			
		applyTemplate:
			mov cx, 80
			sub cx, [bp+var_valueLength]
			
			; copy template from code segment into stack
			lea di, [bp+var_templateBuffer]
			add di, [bp+var_valueLength]
			fmemcpy ss, di, cs, si, cx
			
			sprintfTemplate:
			lea ax, [bp+var_templateBuffer]
			push ax
			push word [bp+arg_pn_string]
			callFromOverlay sprintf
			pop cx
			pop cx
			mov ax, [bp+var_templateVarCount]
			shl ax, 1
			add sp, ax
			
			jmp procEnd
			
		produceItemNameText:
		; get frame
			mov es, word [dseg_itemBufferSegment]
			mov bx, [bp+arg_ibo]
			mov ax, [es:bx+4]
			and ax, 0x7C00
			shr ax, 10
			mov [bp+var_itemFrame], ax
			
		; get quantity
			mov ax, [bp+var_itemType]
			mov dx, 3
			imul dx
			mov bx, ax
			mov al, [dseg_itemTypeInfo+1+bx]
			and ax, 0xF
			cmp ax, 3
			jnz itemTypeHasNoQuantity
			
			lea ax, [bp+arg_ibo]
			push ax
			callFromOverlay Item_getQuantity
			pop cx
			mov word [bp+var_itemQuantity], ax
			jmp haveQuantity
			
			itemTypeHasNoQuantity:
				mov word [bp+var_itemQuantity], 0
				
		haveQuantity:
			callProduceItemDisplayName
			
		procEnd:
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_produceItemLabelText_end
endPatch
