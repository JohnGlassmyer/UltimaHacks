; Keyboard controls and right-click-to-close for the Save dialog.

[bits 16]

startPatch EXE_LENGTH, saveDialog
	; SaveSlot_processInput

	; Don't wait for mouse button to be released after a click on a save slot,
	; because we are now using simulated clicks to activate slots.
	startBlockAt addr_SaveSlot_processInput_loopForMouseUp
		nop
		nop
	endBlock

	; SaveDialog_appendChar -- non-printable keys do not truncate text

	startBlockAt addr_SaveDialog_appendChar_testSpecialKey
		cmp ax, ' '
		jb calcJump(off_SaveDialog_appendChar_endProc)
		jmp calcJump(off_SaveDialog_appendChar_afterTruncate + 2)
	endBlock
	
	startBlockAt addr_SaveDialog_appendChar_afterTruncate
		jmp calcJump(off_SaveDialog_appendChar_append)
		cmp ax, '~'
		ja calcJump(off_SaveDialog_appendChar_endProc)
		jmp calcJump(off_SaveDialog_appendChar_maybeTruncate)
	endBlock

	; SaveDialog_processInput

	%define arg_mouseState      0x8
	%define var_returnCode     -0x5
	%define var_keyWasPressed  -0x6
	%define var_pressedKeyCode -0xA
	
	startBlockAt addr_keyOrMouse
		cmp byte [bp+var_keyWasPressed], 0
		jz calcJump(handleMouse - handleKey + off_handleKey)
		jmp calcJump(off_handleKey)
	endBlock
	
	startBlockAt addr_handleKeyAfterBlinking
		handleKeyAfterBlinking:
		
		cmp word [bp+var_pressedKeyCode], 0xD ; Enter
		jz trySaveButton
		
		cmp word [bp+var_pressedKeyCode], 0x11F ; Alt+S
		jz trySaveButton
		
		cmp word [bp+var_pressedKeyCode], 0x126 ; Alt+L
		jz tryLoadButton
		
		jmp neitherSaveNorLoad
		
		tryLoadButton:
		; if Load button is enabled, load
		lea ax, [si+0x2E]
		push ax
		callFromOverlay Control_isVisible
		pop cx
		mov ah, 0
		test ax, ax
		jnz calcJump(off_triggerLoad)
		jmp neitherSaveNorLoad
		
		trySaveButton:
		; if Save button is enabled, save
		lea ax, [si+0x4A]
		push ax
		callFromOverlay Control_isVisible
		pop cx
		mov ah, 0
		test ax, ax
		jnz calcJump(off_triggerSave)
		
		neitherSaveNorLoad:
		jmp calcJump(off_determineSlotTextWidth)
		
		disableLoadOnFirstEdit:
		mov byte [si+0x157], 0
		lea ax, [si+0x2E]
		push ax
		callFromOverlay Control_setInvisible
		pop cx
		jmp calcJump(off_enableOrDisableSaveButton)
	endBlock
	
	; prev: just set a bit indicating text had been edited
	; now:  (jump to) disable Load button
	startBlockAt addr_textNoLongerUnedited
		jmp calcJump(disableLoadOnFirstEdit \
				- handleKeyAfterBlinking + off_handleKeyAfterBlinking)
	endBlock
	
	startBlockAt addr_handleKey
		handleKey:
		
		mov di, [si+0x2C]
		
		mov ax, [bp+var_pressedKeyCode]
		cmp ax, 27
		jz escape
		cmp ax, 0x148
		jz up
		cmp ax, 0x150
		jz down
		
		cmp di, -1
		jnz calcJump(off_handleKeyWithActiveSlot)
		
		cmp ax, '0'
		jz zeroKey
		jb notNumberKey
		cmp ax, '9'
		ja notNumberKey
		sub ax, '1'
		mov di, ax
		jmp setActive
		
		zeroKey:
		mov di, 9
		jmp setActive
		
		notNumberKey:
		jmp calcJump(handleMouse - handleKey + off_handleKey)
		
		escape:
		mov byte [bp+var_returnCode], 1
		jmp calcJump(off_SaveDialog_processInput_end)
		
		up:
		cmp di, -1
		jz upToBottom
		cmp di, 0
		jz upToBottom
		dec di
		jmp setActive
		upToBottom:
		mov di, 9
		jmp setActive
		
		down:
		cmp di, -1
		jz downToTop
		cmp di, 9
		jz downToTop
		inc di
		jmp setActive
		downToTop:
		mov di, 0
		
		setActive:
		; alter mouse state to simulate a click on the save slot
		; bx = new slot
		mov bx, di
		shl bx, 1
		add bx, si
		add bx, 0xE
		mov bx, [bx]
		mov di, [bp+arg_mouseState]
		; mouseState.2x = saveSlot.left * 2
		mov ax, [bx+0xE]
		shl ax, 1
		mov [di+2], ax
		; mouseState.y = saveSlot.top
		mov ax, [bx+0x10]
		mov [di+4], ax
		; mouseState.buttons = 1
		mov byte [di+7], 1
		
		; let the click-detection code respond to the forged mouse state
		jmp calcJump(off_saveSlotLoopStart)
		
		; the right-click-to-close patch allows mouse button 2 to reach dialogs
		handleMouse:
		mov bx, [bp+arg_mouseState]
		cmp byte [bx+MouseState_action], 1
		jnz notClose
		cmp byte [bx+MouseState_button], 2
		jnz notClose
		jmp calcJump(off_triggerClose)
		
		notClose:
		jmp calcJump(off_handleMouseButton1)
	endBlock
endPatch
