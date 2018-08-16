; Execute actions corresponding to a pressed key.
;
; Having this as a separate procedure which can be called either in dialog-mode
;     or non-dialog-mode allows the same key commands to be used in both modes.

[bits 16]

startPatch EXE_LENGTH, eop-keyActions
	startBlockAt addr_eop_keyActions
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_keyCode              0x04
		%assign ____callerIp             0x02
		%assign ____callerBp             0x00
		%assign var_isAvatarUnconscious -0x02
		%assign var_selectedIbo         -0x04
		%assign var_isStats             -0x06
		%assign var_wasDialogMode       -0x08
		add sp, var_wasDialogMode
		
		push si
		push di
		
		tryCastByKey:
			push word [bp+arg_keyCode]
			callVarArgsEopFromOverlay castByKey, 1
			pop cx
			
			test ax, ax
			jnz usedCastByKey
			
		%ifnum dseg_isPlayerControlDisabled
		; skip other key actions is Usecode has disabled player control
			cmp byte [dseg_isPlayerControlDisabled], 0
			jnz noneToUse
		%endif
		
		; none of the other sections are intended to respond to no-key
		cmp word [bp+arg_keyCode], 0
		jz noneToUse
		
		; many key actions will be unavailable if the Avatar is unconscious
		push dseg_avatarIbo
		callFromOverlay isNpcUnconscious
		pop cx
		mov [bp+var_isAvatarUnconscious], al
		
		%ifnum COMBAT_STATUS_KEY
		tryCombatStatus:
			cmp word [bp+arg_keyCode], COMBAT_STATUS_KEY
			jnz .notCombatStatus
			
			.forbidWithMoreThanSix:
				cmp byte [dseg_partySize], 6
				jbe .sixOrFewer
				
				; rather than suddenly exiting the game with an error message,
				;     as U7SI originally did, we play an "error" sound and have
				;     the Avatar bark the error message.
				
				push Sound_CAN_NOT
				callFromOverlay playSoundSimple
				pop cx
				
				push word 1
				push word 15
				push word 5
				push dseg_heyWeGotMoreThanSix
				push word [dseg_avatarIbo]
				push dseg_spriteManager
				callFromOverlay SpriteManager_barkOnItem
				add sp, 12
				
				jmp .notCombatStatus
				
				.sixOrFewer:
				
			mov word [bp+var_isStats], 0
			mov word [bp+var_selectedIbo], 0
			call openItemDialog
			jmp openedItemDialog
			
			.notCombatStatus:
		%endif
		
		tryOpenOrCloseDialogs:
			mov ax, [bp+arg_keyCode]
			cmp ax, 'i'
			jz openNextInventory
			cmp ax, 'z'
			jz openNextStats
			cmp ax, 27 ; Escape
			jz closeDialogs
			jmp notOpenOrCloseDialogs
			
			openNextInventory:
				mov word [bp+var_isStats], 0
				jmp openDialogForNextPartyMember
				
			openNextStats:
				mov word [bp+var_isStats], 1
				
			openDialogForNextPartyMember:
				mov di, 0
				forPartyMember:
				; display the first dialog of requested type not already open
					cmp di, 8
					jge noPartyMemberToOpen
					
					push di
					callVarArgsEopFromOverlay getPartyMemberIbo, 1
					pop cx
					test ax, ax
					jz nextPartyMember
					mov word [bp+var_selectedIbo], ax
					
					push word [bp+var_isStats]
					lea ax, [bp+var_selectedIbo]
					push ax
					callFromOverlay getOpenItemDialogListNode
					pop cx
					pop cx
					test ax, ax
					jnz nextPartyMember
					call openItemDialog
					jmp openedItemDialog
					
					nextPartyMember:
					inc di
					jmp forPartyMember
					
			closeDialogs:
				mov byte [dseg_dialogState], DialogState_CLOSE_ALL
				jmp closedDialogs
				
			notOpenOrCloseDialogs:
			
		tryOpenableItem:
			; <n> or b      => open inventory (via eop-openableItemForKey)
			; Shift+Alt+<n> => open stats
			mov word [bp+var_isStats], 0
			cmp word [bp+arg_keyCode], 0x178 ; Alt+1
			jb afterTryingAltDigit
			cmp word [bp+arg_keyCode], 0x17F ; Alt+8
			ja afterTryingAltDigit
			callFromOverlay getLeftAndRightShiftStatus
			test ax, ax
			jz afterTryingAltDigit
			mov word [bp+var_isStats], 1
			sub word [bp+arg_keyCode], (0x178 - '1') ; map Alt+1 to '1', etc.
			
			afterTryingAltDigit:
			
			push word [bp+arg_keyCode]
			callVarArgsEopFromOverlay openableItemForKey, 1
			pop cx
			
			test ax, ax
			jz notOpenableItem
			
			mov [bp+var_selectedIbo], ax
			call openItemDialog
			jmp openedItemDialog
			
			notOpenableItem:
			
		tryKeyUsableItems:
			; using an item in combat is impossible (the Avatar would just try
			;     to attack the item)
			callFromOverlay isAvatarInCombat
			test ax, ax
			jnz notUsableItem
			
			; using items while unconscious is not allowed
			cmp byte [bp+var_isAvatarUnconscious], 0
			jnz notUsableItem
			
			jmp keyUsableItems_end
			; defineKeyUsableItem keyCode, type, frame, quality
			%macro defineKeyUsableItem 4
				dw %1, %2, %3, %4
			%endmacro
			keyUsableItems:
			defineKeyUsableItem 'g',  675,   11, 0xFF ; abacus
			defineKeyUsableItem 'm',  178,    0, 0xFF ; cloth map
			defineKeyUsableItem 'p',  627, 0xFF, 0xFF ; lockpicks
			defineKeyUsableItem 'x',  650, 0xFF, 0xFF ; sextant
			defineGameSpecificKeyUsableItems
			keyUsableItems_end:
			
			mov bx, offsetInCodeSegment(keyUsableItems)
			mov dx, offsetInCodeSegment(keyUsableItems_end)
			forKeyUsableItem:
				cmp bx, dx
				jae notUsableItem
				
				mov ax, [cs:bx]
				cmp ax, [bp+arg_keyCode]
				jnz notThisItemMapping
				
				push word [cs:bx+4] ; frame
				push word [cs:bx+6] ; quality
				push word [cs:bx+2] ; type
				callVarArgsEopFromOverlay usePartyItem, 3
				add sp, 6
				
				; may have consumed an item in an open inventory
				call refreshInventoryDialogs
				
				jmp usedItem
				
				notThisItemMapping:
				
				add bx, 8
				jmp  forKeyUsableItem
				
			notUsableItem:
			
		tryEnableKeyMouse:
			cmp byte [dseg_dialogState], DialogState_NONE
			jz notEnableKeyMouse
			cmp byte [dseg_dialogState], DialogState_CLOSE_ALL
			jz notEnableKeyMouse
			
			cmp word [bp+arg_keyCode], ' '
			jnz notEnableKeyMouse
			
			; start key-mouse mode
				mov ax, [dseg_mouseXx]
				mov [dseg_keyMouseXx], ax
				mov ax, [dseg_mouseY]
				mov [dseg_keyMouseY], ax
				
				mov byte [dseg_isKeyMouseEnabled], 1
				
				push MouseCursor_FINGER
				callFromOverlay selectMouseCursor
				pop cx
				
			jmp enabledKeyMouse
			notEnableKeyMouse:
			
		tryKeyEops:
			jmp keyEops_end
			
			off_call_displayControls EQU block_currentOffset
				callVarArgsEopFromOverlay displayControls, 0
				retn
				
			; defineKeyEop isAvailableWhileUnconscious, keyCode, eop
			%macro defineKeyEop 3
					dw %1, %2, %3
			%endmacro
			%assign KeyEop_SIZE 6
			keyEops:
			defineKeyEop 1,   'a', off_eop_toggleAudio
			defineKeyEop 1,   'c', off_eop_toggleCombat
			defineKeyEop 0,   'f', off_eop_feed
			defineKeyEop 1,   'h', off_eop_toggleMouseHand
			defineKeyEop 0,   'k', off_eop_selectAndUseKey
			defineKeyEop 1,   's', off_eop_doSaveDialog
			defineKeyEop 0,   't', off_eop_target
			defineKeyEop 1,   'v', off_eop_displayVersion
			defineKeyEop 1, 0x125, off_call_displayControls
			defineKeyEop 1, 0x12D, off_eop_promptToExit
			defineKeyEop 1, 0x132, off_eop_displayMemoryStats
			defineGameSpecificKeyEops
			keyEops_end:
			
			mov bx, offsetInCodeSegment(keyEops)
			mov dx, offsetInCodeSegment(keyEops_end)
			forKeyEop:
				cmp bx, dx
				jae notEopActions
				
				mov al, [cs:bx+0]
				sub al, [bp+var_isAvatarUnconscious]
				jl notThisKeyEop
				
				mov ax, [bp+arg_keyCode]
				cmp ax, [cs:bx+2]
				jnz notThisKeyEop
				
				; call the eop
				call near [cs:bx+4]
				
				; may have consumed an item in an open inventory
				call refreshInventoryDialogs
				
				jmp calledKeyEop
				
				notThisKeyEop:
				
				add bx, KeyEop_SIZE
				jmp forKeyEop
				
			notEopActions:
			
		noPartyMemberToOpen:
		noneToUse:
			mov ax, 0
			jmp endProc
			
		usedCastByKey:
			mov ax, 1
			jmp endProc
			
		openedItemDialog:
			mov ax, 2
			jmp endProc
			
		closedDialogs:
			mov ax, 3
			jmp endProc
			
		usedItem:
			mov ax, 4
			jmp endProc
			
		enabledKeyMouse:
			mov ax, 5
			jmp endProc
			
		calledKeyEop:
			mov ax, 6
			jmp endProc
			
		endProc:
			; ax == 0 : did not use key
			; ax != 0 : used key, as above
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
		openItemDialog:
			; can open only stats while unconscious
				mov al, [bp+var_isStats]
				sub al, [bp+var_isAvatarUnconscious]
				jl .canNotOpen
				
			; decide whether dialog mode was already active
				mov word [bp+var_wasDialogMode], 0
				movzx dx, [dseg_dialogState]
				cmp dx, DialogState_NONE
				jz .wasNotDialogMode
				cmp dx, DialogState_CLOSE_ALL
				jz .wasNotDialogMode
				mov word [bp+var_wasDialogMode], 1
				.wasNotDialogMode:
				
			; activate dialog mode if it wasn't already active
				cmp word [bp+var_wasDialogMode], 0
				jnz .inDialogMode
				; start inventory mode (doesn't automatically open any dialog)
				push word DialogState_INVENTORY
				callFromOverlay startNumberedDialog
				pop cx
				.inDialogMode:
				
			; open the requested stats or inventory dialog
				push word [bp+var_isStats]
				lea ax, [bp+var_selectedIbo]
				push ax
				callFromOverlay displayItemDialog
				pop cx
				pop cx
				callFromOverlay redrawDialogs
				
			; do item dialog input loop, if not previously in dialog mode
				cmp word [bp+var_wasDialogMode], 0
				jnz .outOfDialogMode
				callFromOverlay itemDialogInputLoop
				.outOfDialogMode:
				
			.canNotOpen:
				retn
				
		; update displayed contents of all open containers (in case an item has
		;   been consumed or altered)
		refreshInventoryDialogs:
			cmp byte [dseg_isDialogMode], 0
			jz afterRedrawing
			
			push 1
			callFromOverlay updateOpenInventoryDialogs
			pop cx
			
			callFromOverlay redrawDialogs
			
			afterRedrawing:
			retn
			
	endBlockAt off_eop_keyActions_end
endPatch
