; Calls eop-keyActions from the gump (dialog) loop to enable the use of many key
;     commands while Stats or Inventory dialogs are on-screen.
; This gives the player flexibility and removes some of the distinction between
;     the two modes of gameplay.
; Also, calls eop-cycleInventoryDialogs on Tab to facilitate keyboard-only
;     inventory management easier.

[bits 16]

startPatch EXE_LENGTH, processKeyInDialogMode
	startBlockAt addr_handleKeyInput
		%assign var_keyCode -0x10
		
		cmp byte [dseg_isKeyMouseEnabled], 0
		jnz afterProcessingKeys
		
		push 1
		callFromOverlay pollKey
		pop cx
		mov [bp+var_keyCode], ax
		
		push ax
		callVarArgsEopFromOverlay keyActions, 1
		pop cx
		test ax, ax
		jnz afterProcessingKeys
		
		; 'i', 'z', and Escape are now handled in eop-keyActions
		
		; (Shift+)Tab: cycle open dialogs
		tryCycleDialogs:
			cmp word [bp+var_keyCode], 9
			jnz .notCycleReverse
			mov ax, -1
			jmp .callCycleEop
			.notCycleReverse:
			
			cmp word [bp+var_keyCode], 0x10F
			jnz .notCycleDialogs
			mov ax, 1
			
			.callCycleEop:
			push ax
			callVarArgsEopFromOverlay cycleInventoryDialogs, 1
			pop cx
			
			.notCycleDialogs:
			
		afterProcessingKeys:
		jmp calcJump(off_handleKeyInput_end)
		
		times 123 nop
	endBlockAt off_handleKeyInput_end
	
	startBlockAt addr_mappingTable
		times 20 nop
	endBlockAt off_mappingTable_end
endPatch
