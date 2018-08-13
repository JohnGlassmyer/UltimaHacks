%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; Call new number-select procedure in the following contexts:
; A) while dragging an item, to select where to drop the item
;   (making it easy to have a particular party member "get" an item)
; B) while selecting with crosshairs, to select a target
;   (making it easy to use a spell or item on a particular party member)
startPatch EXE_LENGTH, \
		call eop-numberSelect while dragging or selecting
		
	off_dragItem_afterDragging          EQU 0x0D6A
	off_dragItem_afterDragging_end      EQU 0x0DB9
	off_dragItem_putItemBack            EQU 0x0DD9
	off_dragItem_determineWhereToPut    EQU 0x0E1F
	off_dragItem_endProc                EQU 0x0E59
	startBlockAt 340, off_dragItem_afterDragging
		mov [bp-0xA], ax ; save result of dragging while calling destructor
		
		push 2
		lea ax, [bp-0x2E+0xE]
		push ax
		mov bx, word [bp-0x2E+0x16] ; first destructor
		call far [bx]
		pop cx
		pop cx
		
		xor ax, ax
		push ax
		lea ax, [bp-0x2E]
		push ax
		callFromOverlay dragItem_secondDesctructor
		pop cx
		pop cx
		
		push word [bp-4] ; var_draggedIbo
		callEopFromOverlay 1, doesItemHaveQuantity
		pop cx
		mov byte [bp-7], al ; var_draggedItemHasQuantity
		
		mov ax, [bp-0xA]
		cmp ax, 1
		jz calcJump(off_dragItem_endProc)
		cmp ax, 2
		jz calcJump(off_dragItem_putItemBack)
		
		mov word [bp-6], 0 ; var_onScreenInventory
		
		jmp calcJump(off_dragItem_determineWhereToPut)
	endBlockWithFillAt nop, off_dragItem_afterDragging_end
	
	off_waitDuringDrag_beforeLoop       EQU 0x01D5
	off_waitDuringDrag_loopEnd          EQU 0x0267
	startBlockAt 343, off_waitDuringDrag_beforeLoop
		; si: MouseState*
		; di: DraggedItemDisplay*
		
		%assign var_hasShown     -0x2
		%assign var_selectedIbo  -0x4
		
		mov word [bp+var_hasShown], 0
		
		loopStart:
		push si
		callFromOverlay readMouseStateIntoRef
		pop cx
		
		; call showItem only once
		cmp word [bp+var_hasShown], 0
		jnz afterShowing
			push di
			mov bx, [di+0xC]
			call far [bx+4] ; DraggedItemDisplay_?showItem
			add sp, 2
			mov word [bp+var_hasShown], 1
			
		afterShowing:
		; try to place the dragged item into an item selected by key
			push 0 ; key code (none)
			callEopFromOverlay 1, numberSelect
			pop cx
			
			cmp ax, 0
			jz waitDuringDrag_processMouse
			
			push ax ; targetIbo
			callEopFromOverlay 1, placeItemOrReportNoCanDo
			pop cx
			
			cmp ax, 0
			jz failedToPlace
			
			mov ax, 1
			jmp exitLoop
			
		failedToPlace:
			mov ax, 2
			jmp exitLoop
			
		waitDuringDrag_processMouse:
			cmp byte [si+7], 4
			jnz afterUpdatingDisplay
			
			; mouse moved (??), so update where the item is displayed
				push word [si+4]
				mov ax, [si+2]
				sar ax, 1
				push ax
				push di
				mov bx, [di+0xC]
				call far [bx+0x14] ; DraggedItemDisplay_updatePosition
				add sp, 6
				
			afterUpdatingDisplay:
			cmp byte [si+7], 3
			jnz loopStart
			cmp byte [si+1], 1
			jnz loopStart
			
			mov ax, 0
			
		exitLoop:
		; ax == 0 : dropped by mouse
		; ax == 1 : dropped by key
		; ax == 2 : failed to drop by key
	endBlockWithFillAt nop, off_waitDuringDrag_loopEnd 
	
	off_target_checkingForClick         EQU 0x0039
	off_target_checkingForClick_end     EQU 0x006E
	off_target_loopStart                EQU 0x00F9
	off_target_loopEndWithSelection     EQU 0x0105
	startBlockAt 234, off_target_checkingForClick
		%assign var_hasSelected     -0x01
		%assign var_selectedIbo     -0x04
		%assign var_mouseState      -0x1A
		
		push 0 ; key code (none)
		callEopFromOverlay 1, numberSelect
		pop cx
		
		; did player select a target by key?
		cmp ax, 0
		jz processMouse
		
		mov [bp+var_selectedIbo], ax
		jmp calcJump(off_target_loopEndWithSelection)
		
		processMouse:
		; no target selected; process mouse state as originally done
		lea ax, [bp+var_mouseState]
		push ax
		callFromOverlay readMouseStateIntoRef
		pop cx
		
		mov al, byte [bp+var_mouseState+MouseState_action]
		cmp al, 1
		jz interpretMouseClick
		
		noClick:
		jmp calcJump(off_target_loopStart)
		
		interpretMouseClick:
	endBlockWithFillAt nop, off_target_checkingForClick_end
endPatch
