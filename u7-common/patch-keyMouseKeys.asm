; Adds some key-commands while in key-mouse mode:
;     - Escape     : quit key-mouse, and close dialogs if any are open
;     - Space      : quit key-mouse
;     - (Ctrl+)Tab : cycle to next inventory dialog (to facilitate moving items
;         between inventories)

[bits 16]

startPatch EXE_LENGTH, keyMouseKeys
	startBlockAt addr_valueForKey
		%assign var_valueForKey -0x05
		
		cmp ax, 27
		jz endKeyMouseAndDialogMode
		
		cmp ax, ' '
		jz endKeyMouse
		
		cmp ax, 9
		jz cycleToBottomDialog
		cmp ax, 0x194
		jz cycleToBottomDialog
		jmp tryKeyMouseKeys
		
		endKeyMouseAndDialogMode:
			cmp byte [dseg_isDialogMode], 0
			jz endKeyMouse
			mov byte [dseg_dialogState], DialogState_CLOSE_ALL
		endKeyMouse:
			mov byte [dseg_isKeyMouseEnabled], 0
			jmp recordMoveAction
			
		cycleToBottomDialog:
			push -1
			callVarArgsEopFromLoadModule cycleInventoryDialogs, 1
			pop cx
			jmp recordMoveAction
			
		recordMoveAction:
			mov ax, MouseAction_MOVE
			jmp calcJump(off_mouseActionInAx)
			
		tryKeyMouseKeys:
			mov bx, offsetInCodeSegment(keyMouseKeys)
			.forKeyMouseKey:
				cmp bx, offsetInCodeSegment(keyMouseKeys_end)
				jb .haveNextKey
				mov al, 0x10
				jmp .haveValueForKey
				.haveNextKey:
				
				cmp ax, [cs:bx+0]
				jnz .notThisKeyMouseKey
				mov al, [cs:bx+2]
				jmp .haveValueForKey
				.notThisKeyMouseKey:
				
				add bx, KeyMouseKey_SIZE
				jmp .forKeyMouseKey
				
			.haveValueForKey:
				mov [bp+var_valueForKey], al
				jmp calcJump(off_valueForKey_end)
				
		%macro defineKeyMouseKey 2
			dw %1
			db %2
		%endmacro
		KeyMouseKey_SIZE EQU 3
		keyMouseKeys:
			defineKeyMouseKey '1',   5
			defineKeyMouseKey '2',   4
			defineKeyMouseKey '3',   3
			defineKeyMouseKey '4',   6
			defineKeyMouseKey '6',   2
			defineKeyMouseKey '7',   7
			defineKeyMouseKey '8',   0
			defineKeyMouseKey '9',   1
			defineKeyMouseKey 0x147, 7
			defineKeyMouseKey 0x148, 0
			defineKeyMouseKey 0x149, 1
			defineKeyMouseKey 0x14B, 6
			defineKeyMouseKey 0x14D, 2
			defineKeyMouseKey 0x14F, 5
			defineKeyMouseKey 0x150, 4
			defineKeyMouseKey 0x151, 3
			defineKeyMouseKey 0x173, 6
			defineKeyMouseKey 0x174, 2
			defineKeyMouseKey 0x175, 5
			defineKeyMouseKey 0x176, 3
			defineKeyMouseKey 0x177, 7
			defineKeyMouseKey 0x184, 1
			defineKeyMouseKey 0x18D, 0
			defineKeyMouseKey 0x191, 4
			keyMouseKeys_end:
			
		times 50 nop
	endBlockAt off_valueForKey_end
endPatch
