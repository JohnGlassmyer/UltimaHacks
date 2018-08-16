; Allow advancing through conversation dialogue as well as text of books,
;     scrolls, and signs with Enter or other keys.
; Also, select conversation options using Tab and other keys.

[bits 16]

startPatch EXE_LENGTH, conversationKeys
	startBlockAt addr_textLoop_procStart
		push cs
		call calcJump(off_prepareConversationGump)
		
		; signLoop (below) jumps here to also use this key/mouse loop
		off_textLoop_fromSignLoop EQU block_currentOffset
		
		; assume that the player advances text by mouse, not by key
		mov byte [dseg_conversationKeys_usedKeyInTextLoop], 0
		
		; disable key-mouse, as it would interfere
		mov byte [dseg_isKeyMouseEnabled], 0
		
		.loopStart:
		
		callFunctionsInLoop
		
		; end loop if pressed Ctrl
		callFromOverlay getCtrlStatus
		cmp al, [dseg_previousCtrlStatus]
		jg .endedByKey
		
		; end loop of pressed Enter or Space
		push 1
		callFromOverlay pollKey
		pop cx
		cmp ax, 13
		je .endedByKey
		cmp ax, ' '
		je .endedByKey
		
		; end loop if MB1 pressed or double-clicked (as in original game)
		callFromOverlay updateAndGetMouseState
		mov bx, ax
		cmp byte [bx+MouseState_button], 1
		jne .notClick
		mov al, [bx+MouseState_action]
		cmp al, MouseAction_PRESS
		je .endLoop
		cmp al, MouseAction_DOUBLE_CLICK
		je .endLoop
		.notClick:
		
		jmp .loopStart
		
		.endedByKey:
		; record that the player used a keypress to advance text
		mov byte [dseg_conversationKeys_usedKeyInTextLoop], 1
		
		.endLoop:
		
		retf
		
		times 0 nop
	endBlockAt off_textLoop_procEnd
	
	startBlockAt addr_optionsLoop_beforeLoop
		; if the player advanced preceding text by key rather by mouse, then
		;   position the cursor to the left of conversation options in order
		;   to prevent the player from accidentally selecting an option by key.
		;   this allows the player to advance quickly through dialogue without
		;   risk of skipping through the succeeding options prompt.
		cmp byte [dseg_conversationKeys_usedKeyInTextLoop], 1
		jne .afterPreparingCursor
		mov bx, [dseg_pn_conversationGump]
		add bx, ConversationGump_optionsGump + ConversationOptionsGump_xyBounds
		mov ax, [bx+XyBounds_minY]
		add ax, 4
		push ax ; toLeftOfOptions_y
		mov ax, [bx+XyBounds_minX]
		sub ax, 6
		push ax ; toLeftOfOptions_x
		callFromOverlay setMouseCursorPosition
		pop cx
		pop cx
		callFromOverlay copyFrameBuffer
		.afterPreparingCursor:
		
		; prepare to move by key to first or last conversation option
		mov byte [dseg_conversationKeys_optionIndex], -1
		
		; disable key-mouse, as it would interfere
		mov byte [dseg_isKeyMouseEnabled], 0
		
		.loopStart:
		
		callFromOverlay playAmbientSounds
		callFromOverlay cyclePalette
		
		; don't filter mouse events; let the conversation gump receive them all
		callFromOverlay updateAndGetMouseState
		push ax
		mov bx, [dseg_pn_conversationGump]
		push bx
		mov bx, [bx+0xC]
		call far [bx+8]
		pop cx
		pop cx
		test al, al
		jz .loopStart
		
		;fall through
		
		times 3 nop
	endBlockAt off_optionsLoop_loopEnd
	
	startBlockAt addr_ConversationGump_checkGumpBounds
		%define .reg_pn_mouseState di
		mov word [dseg_conversationKeys_keyCode], 0
		
		; pressed Enter or Space?
		push 1
		callFromOverlay pollKey
		pop cx
		cmp ax, 13
		je .fakeClick
		cmp ax, ' '
		je .fakeClick
		
		mov [dseg_conversationKeys_keyCode], ax
		
		; pressed Ctrl?
		callFromOverlay getCtrlStatus
		mov al, [dseg_previousCtrlStatus]
		cmp byte [dseg_ctrlStatus], al
		jg .fakeClick
		
		jmp .afterFakeClick
		
		.fakeClick:
		
		mov byte [.reg_pn_mouseState+MouseState_action], MouseAction_PRESS
		
		mov byte [dseg_conversationKeys_mouseEvent+MouseState_rawAction], \
				MouseRawAction_RELEASE
		push word dseg_conversationKeys_mouseEvent
		callFromOverlay enqueueMouseEvent
		pop cx
		
		.afterFakeClick:
		
		; let the options gump receive all mouse events, including fake clicks
		jmp calcJump(off_ConversationGump_callOptionsGump)
		
		; =========
		%macro defineOptionKey 2
			%assign %%keyCode %1
			%assign %%direction %2
			
			dw %%keyCode
			db %%direction
		%endmacro
		off_optionKeys EQU block_currentOffset
			defineOptionKey 9,      1 ; Tab
			defineOptionKey 0x14D,  1 ; Right
			defineOptionKey 0x14B, -1 ; Left
			defineOptionKey 0x10F, -1 ; Shift+Tab
			defineOptionKey '`',   -1 ; backquote
		off_optionKeys_end EQU block_currentOffset
	endBlockAt off_ConversationGump_callOptionsGump
	
	startBlockAt addr_OptionsGump_checkGumpBounds
		; checking gump bounds here is redundant because the bounds of the
		;   individual options are checked below. so instead we can use
		;   this space to move the cursor in response to key-presses.
		
		%assign .arg_pn_mouseState 0x08
		%define .reg_pn_this si
		
		call calcJump(off_OptionsGump_selectOptionByKeyCode)
		
		test ax, ax
		jz .afterMovingCursor
		
		.moveCursor:
		
		push 0
		push word dseg_yellowTextPrinter
		callFromOverlay TextPrinter_getLineHeight
		pop cx
		pop cx
		mov dx, ax
		
		movzx bx, [dseg_conversationKeys_optionIndex]
		shl bx, 1
		add bx, dseg_conversationOptionCoords
		
		; y
		movzx ax, [bx+ConversationOptionCoords_line]
		sub ax, [.reg_pn_this+0x17]
		imul dx
		add ax, [.reg_pn_this+0x10]
		add ax, 4
		push ax
		; x
		movzx ax, [bx+ConversationOptionCoords_x]
		add ax, [.reg_pn_this+0xE]
		add ax, 3
		push ax
		callFromOverlay setMouseCursorPosition
		pop cx
		pop cx
		
		callFromOverlay copyFrameBuffer
		
		.afterMovingCursor:
		
		mov bx, [bp+.arg_pn_mouseState]
		
		cmp byte [bx+MouseState_button], 1
		jne calcJump(off_OptionsGump_notInBounds)
		
		mov al, [bx+MouseState_action]
		cmp al, MouseAction_PRESS
		jz calcJump(off_OptionsGump_considerOptions)
		cmp al, MouseAction_DOUBLE_CLICK
		jz calcJump(off_OptionsGump_considerOptions)
		
		; fall through
		
		times 26 nop
	endBlockAt off_OptionsGump_notInBounds
	
	startBlockAt addr_OptionsGump_checkOptionBounds
		%assign .arg_pn_mouseState 0x08
		%define .reg_pn_xyBounds di
		
		mov bx, [bp+.arg_pn_mouseState]
		
		mov ax, [bx+MouseState_xx]
		shr ax, 1
		cmp ax, [.reg_pn_xyBounds+XyBounds_minX]
		jb .nope
		cmp ax, [.reg_pn_xyBounds+XyBounds_maxX]
		ja .nope
		
		mov ax, [bx+MouseState_y]
		cmp ax, [.reg_pn_xyBounds+XyBounds_minY]
		jb .nope
		cmp ax, [.reg_pn_xyBounds+XyBounds_maxY]
		ja .nope
		
		jmp calcJump(off_OptionsGump_withinOptionBounds)
		
		.nope:
		jmp calcJump(off_OptionsGump_forOption)
		
		; =========
		off_OptionsGump_selectOptionByKeyCode EQU block_currentOffset
			mov ax, [dseg_conversationKeys_keyCode]
			
			mov bx, off_optionKeys
			.forOptionKey:
				cmp ax, [cs:bx]
				jnz .notThisOptionKey
				mov al, [cs:bx+2]
				jmp .haveDirection
				.notThisOptionKey:
				add bx, 3
				cmp bx, off_optionKeys_end
				jb .forOptionKey
				jmp .returnZero
				
			.haveDirection:
			cmp byte [dseg_conversationKeys_optionIndex], 0
			jge .alreadyInitialized
			; first movement will be to first or last option
			inc al
			shr al, 1
			dec al
			jmp .modulo
			
			.alreadyInitialized:
			; bound index to [0, options.size)
			add al, [dseg_conversationKeys_optionIndex]
			.modulo:
			mov bl, byte [dseg_conversationOptionList+ConversationOptions_SIZE]
			add al, bl
			cbw
			div bl
			mov [dseg_conversationKeys_optionIndex], ah
			
			mov ax, 1
			jmp .endProc
			
			.returnZero:
			xor ax, ax
			
			.endProc:
			retn
	endBlockAt off_OptionsGump_withinOptionBounds
	
	startBlockAt addr_signLoop_start
		; not enough space here to check for key-presses, but enough to jump
		;   into the conversation text loop, which has been been patched (above)
		;   to check for those key-presses (and which is, fortunately, in the
		;   same overlay segment).
		
		; prepare for textLoop's epilogue/retf
		push bp
		push si
		push cs
		push off_signLoop_returnFromTextLoop
		
		jmp calcJump(off_textLoop_fromSignLoop)
		
		; textLoop will return here and close the Sign display
		off_signLoop_returnFromTextLoop EQU block_currentOffset
	endBlockAt off_signLoop_end
endPatch
