; Calls eop-targetKeys when selecting with crosshairs.
; This enables the player to select, attack, talk to, get, or use a nearby item
;     or NPC using the keyboard, without having to move the mouse cursor.
; Also, as eop-targetKeys defers when possible to eop-openableItemForKey, this
;     enables the player to target a party member with a single keypress when
;     casting a spell or using an item such as food.

[bits 16]

startPatch EXE_LENGTH, selectByKey
	; we can repurpose these unused bytes between stack variables
	%assign var_hasRunTargetKeys -0x08
	
	startBlockAt addr_havePlayerSelect_setUnusedField
		; the code here (before the loop) was zeroing var_mouseState's
		;     rawAction field, which was/is never read in this procedure.
		; we can reuse those bytes of code to initialize our own variable.
		mov byte [bp+var_hasRunTargetKeys], 0
	endBlockOfLength 4
	
	startBlockAt addr_havePlayerSelect_checkingForClick
		%assign var_selectedIbo      -0x04
		%assign var_mouseState       -0x1A
		
		movzx ax, [bp+var_hasRunTargetKeys]
		push ax
		lea ax, [bp+var_selectedIbo]
		push ax
		callVarArgsEopFromOverlay targetKeys, 2
		pop cx
		pop cx
		
		mov byte [bp+var_hasRunTargetKeys], 1
		
		test ax, ax
		jnz calcJump(off_havePlayerSelect_loopEndWithSelection)
		
		; no target selected by key, so check for a mouse-button press
		
		lea ax, [bp+var_mouseState]
		push ax
		callFromOverlay updateAndCopyMouseState
		pop cx
		
		; unlike original, respond only to press, not e.g. to double-click.
		;     mainly because it saves bytes, but also because responding to
		;     double-click here produces inconsistent results.
		testForButton1Press:
			cmp byte [bp+var_mouseState+MouseState_action], MouseAction_PRESS
			jnz calcJump(off_havePlayerSelect_loopStart)
			cmp byte [bp+var_mouseState+MouseState_button], 1
			jnz calcJump(off_havePlayerSelect_loopStart)
			
		; get mouse X (in fewer bytes) for the following code to use
		mov di, [bp+var_mouseState+MouseState_xx]
		shr di, 1
		
		times 5 nop
	endBlockAt off_havePlayerSelect_haveMouseXInDi
endPatch
