[bits 16]

startPatch EXE_LENGTH, processKeyWithoutDialogs
	%define mapAction(keyCode, off_handler) dw keyCode, off_handler
	
	unresponsiveAvatarActionMappingCount \
		EQU (unresponsiveAvatarActionMappingEnd - actionMappingStart) / 4
	responsiveAvatarActionMappingCount \
		EQU (responsiveAvatarActionMappingEnd - actionMappingStart) / 4
	
	startBlockAt addr_gameStep_callDiscardKeys
		; was calling discardKeys, what a disgrace!
		times 5 nop
	endBlockOfLength 5
	
	startBlockAt addr_callTranslateKeyBeforeProcessKey
		; don't translate key here, so that eop-keyActions
		; can process keys even when a mouse button is held
		times 20 nop
	endBlockAt off_callTranslateKeyBeforeProcessKey_end
	
	startBlockAt addr_keyMappingCode
		%assign arg_pn_remainingMovementSteps   0x0C
		%assign arg_mouseY                      0x0A
		%assign arg_mouseX                      0x08
		%assign arg_keyCode                     0x06
		%assign var_wasKeyConsumed             -0x02
		
		; skip processing keys if the avatar is moving
			cmp byte [reg_pn_stepsRemaining], 0
			jnz calcJump(off_afterKeyHandlers)
			
		push 1 ; discard subsequent buffered keys
		callFromLoadModule pollKey
		pop cx
		mov [bp+arg_keyCode], ax
		
		; let eop-keyActions try to use the key
			push word [bp+arg_keyCode]
			callVarArgsEopFromLoadModule keyActions, 1
			pop cx
			mov [bp+var_wasKeyConsumed], ax
			
		; translate (e.g. mapping mouse actions to key codes) the key code
		;     read by eop-keyActions
			lea ax, [bp+arg_mouseY]
			push ax
			lea ax, [bp+arg_mouseX]
			push ax
			lea ax, [bp+arg_keyCode]
			push ax
			callFromLoadModule translateKeyWithMouse
			add sp, 6
			
		; let eop-keepMoving try to use the translated key.
			push reg_pn_stepsRemaining
			push word [bp+arg_keyCode]
			callVarArgsEopFromLoadModule keepMoving, 2
			pop cx
			pop cx
			or [bp+var_wasKeyConsumed], ax
			
		; don't further process a key that has been consumed by either eop
			cmp word [bp+var_wasKeyConsumed], 0
			jnz calcJump(off_afterKeyHandlers)
			
		%ifnum dseg_isPlayerControlDisabled
		; don't further process any key if Usecode has disabled player control
			cmp byte [dseg_isPlayerControlDisabled], 0
			jnz calcJump(off_afterKeyHandlers)
		%endif
		
		%ifdef reg_keyCode
			mov reg_keyCode, [bp+arg_keyCode]
		%endif
		
		push dseg_avatarIbo
		callFromLoadModule isNpcUnconscious
		pop cx
		or al, al
		jnz avatarUnresponsive
		
		avatarResponsive:
			mov ax, [bp+arg_keyCode]
			cmp ax, '1'
			jb notTranslatedNumberKey
			cmp ax, '9'
			ja notTranslatedNumberKey
			jmp calcJump(off_numberKeys)
			notTranslatedNumberKey:
			cmp ax, 0x147
			jb notDirectionKey
			cmp ax, 0x151
			ja notDirectionKey
			jmp calcJump(off_directionKeys)
			notDirectionKey:
			
			mov cx, responsiveAvatarActionMappingCount
			
			jmp tryKeyMappings
			
		avatarUnresponsive:
			mov bx, [bp+arg_pn_remainingMovementSteps]
			mov byte [bx], 0
			
			cmp byte [dseg_playerActionSuspended], 0
			jnz calcJump(off_endOfFunction)
			
			mov cx, unresponsiveAvatarActionMappingCount
			
		tryKeyMappings:
			cmp word [bp+arg_keyCode], 0
			jz afterTryingMappings
			
			mov bx, off_actionMappingTable
			tryActionMapping:
			mov ax, [cs:bx]
			cmp ax, [bp+arg_keyCode]
			jnz notThisActionMapping
			jmp [cs:bx+2]
			notThisActionMapping:
			add bx, 4
			loop tryActionMapping
			
		afterTryingMappings:
		
		jmp calcJump(off_afterKeyHandlers)
		
		; ---------
		off_toggleCheats EQU block_currentOffset
			callVarArgsEopFromLoadModule toggleCheats, 0
			jmp calcJump(off_afterKeyHandlers)
			
		gameSpecificKeyMappingCode
		
	endBlockAt off_keyMappingCode_end
	
	;-----------------------------------------------------------
	;-----------------------------------------------------------
	
	startBlockAt addr_actionMappingTable
		actionMappingStart:
		
		; mappings which may be used by a conscious or unconscious Avatar
			
			mapAction(0x203, off_mouseUse)          ; left button double
			
			mapAction(0x12B, off_toggleCheats)      ; Alt+Backslash
			
			; mapActionIfOffsetDefined keyCode, off_handler
			;   because different cheat keys/functions exist in U7BG vs in U7SI
			%macro mapActionIfOffsetDefined 2
				%ifnum %2
					mapAction(%1, %2)
				%endif
			%endmacro
			
			mapActionIfOffsetDefined 0x13B, off_cheat_f1
			mapActionIfOffsetDefined 0x13C, off_cheat_f2
			mapActionIfOffsetDefined 0x13D, off_cheat_f3
			mapActionIfOffsetDefined 0x13E, off_cheat_f4
			mapActionIfOffsetDefined 0x13F, off_cheat_f5
			mapActionIfOffsetDefined 0x141, off_cheat_f7
			mapActionIfOffsetDefined 0x142, off_cheat_f8
			mapActionIfOffsetDefined 0x143, off_cheat_f9
			
			mapActionIfOffsetDefined 0x16C, off_cheat_altf5
			mapActionIfOffsetDefined 0x16E, off_cheat_altf7
			mapActionIfOffsetDefined 0x16F, off_cheat_altf8
			mapActionIfOffsetDefined 0x170, off_cheat_altf9
			
			mapActionIfOffsetDefined 0x178, off_cheat_alt1
			mapActionIfOffsetDefined 0x179, off_cheat_alt2
			mapActionIfOffsetDefined 0x17A, off_cheat_alt3
			mapActionIfOffsetDefined 0x17B, off_cheat_alt4
			mapActionIfOffsetDefined 0x17C, off_cheat_alt5
			mapActionIfOffsetDefined 0x17D, off_cheat_alt6
			mapActionIfOffsetDefined 0x17E, off_cheat_alt7
			mapActionIfOffsetDefined 0x17F, off_cheat_alt8
			mapActionIfOffsetDefined 0x180, off_cheat_alt9
			
			mapActionIfOffsetDefined '`', off_cheat_backquote
			
			mapActionIfOffsetDefined 0x119, off_cheat_altP
			
			; (many actions are now handled by eop-keyActions rather than here,
			;     so that they are available also in dialog mode)
			
			unresponsiveAvatarActionMappingEnd:
			
		; mappings which may only be used by a conscious Avatar
			
			; to allow MB1-press here would enable not just labeling items, but
			;     also moving items, while unconscious.
			mapAction(0x201, off_mouseName)         ; MB1 pressed
			
			mapAction(0x205, off_mouseName)         ; MB1 held
			mapAction(0x202, off_mouseMove)         ; MB2 pressed
			mapAction(0x206, off_mouseMove)         ; MB2 held
			mapAction(0x204, off_mouseAutoroute)    ; MB2 double-clicked
			
			responsiveAvatarActionMappingEnd:
			
		times 72 nop
	endBlockAt off_actionMappingTable_end
endPatch
