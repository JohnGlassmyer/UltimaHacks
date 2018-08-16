; Allow the player to specify the destination of item-dragging by key rather
;     than by mouse, calling eop-openableItemForKey to specify the destination
;     and then calling eop-dropToPresetDestination to do the dropping.
; This makes it quicker and easier for the player to give a dragged item to a
;     particular party member.

[bits 16]

startPatch EXE_LENGTH, dropToKeySelectedItem	
	startBlockAt addr_loopDuringDrag_beforeLoop
		; si: pn_mouseState
		; di: pn_draggedItemDisplay
		
		%assign var_hasShown     -0x2
		%assign var_draggedIbo   -0x4
		
		mov word [bp+var_hasShown], 0
		
		callVarArgsEopFromOverlay ensureDragAndDropAreasInitialized, 0
		
		; if our drop area has already been configured with a destination,
		;     then we'll drop there without looping or checking for keys.
		mov bx, [dseg_pn_dropArea]
		cmp word [bx+InventoryArea_ibo], 0
		jz .loopStart
		mov ax, 1
		jmp .exitLoop
		
		.loopStart:
		
		; original game did not cycle palette during drag, but it's nice to do
		callFromOverlay cyclePalette
		
		push si
		callFromOverlay updateAndCopyMouseState
		pop cx
		
		; call showItem only once
		cmp word [bp+var_hasShown], 0
		jnz .afterShowing
		push di
		mov bx, [di+0xC]
		call far [bx+4] ; DraggedItemDisplay_?showItem
		pop cx
		mov word [bp+var_hasShown], 1
		.afterShowing:
		
		; don't let eop-openableItemForKey consume keys if the player is using
		;     key-mouse to drag
			cmp byte [dseg_isKeyMouseEnabled], 0
			jnz .processMouse
			
		; try to place the dragged item into an item selected by key
			push 0 ; key code (none)
			callVarArgsEopFromOverlay openableItemForKey, 1
			pop cx
			
			test ax, ax
			jz .processMouse
			
			; configure drop area to drop into the selected item
			mov bx, [dseg_pn_dropArea]
			mov [bx+InventoryArea_ibo], ax
			mov ax, 1
			jmp .exitLoop
			
		.processMouse:
			cmp byte [si+7], MouseAction_MOVE
			jnz .afterUpdatingDisplay
			
			; mouse moved, so update where the item is displayed
			push word [si+4]
			mov ax, [si+2]
			sar ax, 1
			push ax
			push di
			mov bx, [di+0xC]
			call far [bx+0x14] ; DraggedItemDisplay_updatePosition
			add sp, 6
			
			.afterUpdatingDisplay:
			cmp byte [si+7], 3
			jnz .loopStart
			cmp byte [si+1], 1
			jnz .loopStart
			
			mov ax, 0
			
		.exitLoop:
		; ax == 0 : dropped by mouse
		; ax == 1 : dropped by key; dropArea's ibo set to destination
	endBlockAt off_loopDuringDrag_loopEnd 
	
	startBlockAt addr_dragItem_afterDragging
		%assign var_draggedIbo           -0x04
		%assign var_pn_dialogListNode    -0x06
		%assign var_doesItemHaveQuantity -0x07
		%assign var_destinationIbo       -0x0A
		%assign var_draggedItemDisplay   -0x2E
		%define reg_pn_sourceControl     si
		
		; patched drag loop will return 0 if dropped by mouse, 1 if by key
		push ax
		
		; destroy the DraggedItemDisplay
			push 2
			lea ax, [bp+var_draggedItemDisplay+0xE]
			push ax
			mov bx, word [bp+var_draggedItemDisplay+0x16] ; first destructor
			call far [bx]
			pop cx
			pop cx
			
			push 0
			lea ax, [bp+var_draggedItemDisplay]
			push ax
			callFromOverlay AbstractInventoryDialog_destructor
			pop cx
			pop cx
			
		pop ax
		test ax, ax
		jz notDroppedByKey
		
		dropToDropArea:
			; try to drop the item into the key-selected destination
			push reg_pn_sourceControl
			callVarArgsEopFromOverlay dropToPresetDestination, 1
			pop cx
			
			; skip the rest of dragItem (trying to drop the item; putting the
			;     item back if the drop location was invalid)
			jmp calcJump(off_dragItem_endProc)
			
		notDroppedByKey:
		
		push word [bp+var_draggedIbo]
		callVarArgsEopFromOverlay doesItemHaveQuantity, 1
		pop cx
		mov byte [bp+var_doesItemHaveQuantity], al
		
		mov word [bp+var_pn_dialogListNode], 0
		
		jmp calcJump(off_dragItem_determineWhereToPut)
	endBlockWithFillAt nop, off_dragItem_afterDragging_end
endPatch
