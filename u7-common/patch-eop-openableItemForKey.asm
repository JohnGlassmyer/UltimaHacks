; Selects an item (party member, backpack of party member, or spellbook)
;     corresponding to the specified key-code.
;
; Initially inspired by the ability in Ultima VI to select a party member,
;   in multiple contexts, by pressing a number key.
	
[bits 16]

startPatch EXE_LENGTH, eop-openableItemForKey
	%assign KeyOpenableItem_SIZE 4 * 2
	
	startBlockAt addr_eop_openableItemForKey
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_keyCodeOrZero       0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_shiftStatus        -0x02
		%assign var_keyCode            -0x04
		%assign var_itemBeingDragged   -0x06
		%assign var_partyMemberIbo     -0x08
		%assign var_itemFrame          -0x0A
		%assign var_itemQuality        -0x0C
		%assign var_itemType           -0x0E
		%assign var_foundIboList       -0x10
		%assign var_foundIboListNode   -0x12
		%assign var_foundIbo           -0x14
		add sp, var_foundIbo
		
		push si
		push di
		
		mov word [bp+var_shiftStatus], 0
		
		; use the key code passed as a parameter, or poll for one
			mov ax, [bp+arg_keyCodeOrZero]
			or ax, ax
			jnz haveKeyCode
			
			callFromOverlay pollKey
			or ax, ax
			jz noKeyCode
			
		haveKeyCode:
			mov [bp+var_keyCode], ax
			
		; translate a number key to a party member
			mov ax, word [bp+var_keyCode]
			cmp ax, '1'
			jl tryShiftedNumber
			cmp ax, '8'
			jg tryShiftedNumber
			sub ax, '1'
			jmp haveNumber
			
		tryShiftedNumber:
		; see if the pressed key is Shift+<number key>
			cmp ax, '!'
			jnz tryShift2
			mov ax, 0
			jmp haveShiftedNumber
			
			tryShift2:
			cmp ax, '@'
			jnz tryShift3
			mov ax, 1
			jmp haveShiftedNumber
			
			tryShift3:
			cmp ax, '#'
			jnz tryShift4
			mov ax, 2
			jmp haveShiftedNumber
			
			tryShift4:
			cmp ax, '$'
			jnz tryShift5
			mov ax, 3
			jmp haveShiftedNumber
			
			tryShift5:
			cmp ax, '%'
			jnz tryShift6
			mov ax, 4
			jmp haveShiftedNumber
			
			tryShift6:
			cmp ax, '^'
			jnz tryShift7
			mov ax, 5
			jmp haveShiftedNumber
			
			tryShift7:
			cmp ax, '&'
			jnz tryShift8
			mov ax, 6
			jmp haveShiftedNumber
			
			tryShift8:
			cmp ax, '*'
			jnz notShiftedNumber
			mov ax, 7
			jmp haveShiftedNumber
			
			notShiftedNumber:
			jmp tryKeyOpenableItems
			
		haveShiftedNumber:
			mov word [bp+var_shiftStatus], 1
			
		haveNumber:
			cmp ax, [dseg_partySize]
			jge noItem
			
			push ax
			callVarArgsEopFromOverlay getPartyMemberIbo, 1
			pop cx
			mov [bp+var_partyMemberIbo], ax
			
			cmp word [bp+var_shiftStatus], 0
			jnz backpack
			
			mov ax, [bp+var_partyMemberIbo]
			jmp haveOpenableIboInAx
			
			backpack:
				push word BACKPACK_INVENTORY_SLOT
				push word [bp+var_partyMemberIbo]
				callFromOverlay getItemInSlot
				pop cx
				pop cx
				
				mov [bp+var_foundIbo], ax
				
				; don't return the backpack item if it's not an openable item.
				;     (the player could have put anything in the backpack slot.)
				lea ax, [bp+var_foundIbo]
				push ax
				callFromOverlay Item_canBeOpened
				pop cx
				test al, al
				jz noItem
				
				mov ax, [bp+var_foundIbo]
				jmp haveOpenableIboInAx
				
		tryKeyOpenableItems:
			mov word [bp+var_foundIbo], 0
			
			mov si, offsetInCodeSegment(keyOpenableItems)
			forKeyOpenableItem:
				cmp si, offsetInCodeSegment(keyOpenableItems_end)
				jae notKeyOpenableItem
				
				mov ax, [bp+var_keyCode]
				cmp ax, [cs:si+0]
				jnz afterThisKeyOpenableItem
				
				mov ax, [cs:si+2]
				mov word [bp+var_itemType], ax
				mov ax, [cs:si+4]
				mov word [bp+var_itemFrame], ax
				mov ax, [cs:si+6]
				mov word [bp+var_itemQuality], ax
				jmp findAndSelectItem
				
				afterThisKeyOpenableItem:
				
				add si, KeyOpenableItem_SIZE
				jmp forKeyOpenableItem
				
			notKeyOpenableItem:
			
			jmp noItem
			
			findAndSelectItem:
			; get a list of items held by party members
				push word [bp+var_itemFrame]
				push word [bp+var_itemQuality]
				push word [bp+var_itemType]
				callVarArgsEopFromOverlay findAllPartyItems, 3
				add sp, 6
				
				test ax, ax
				jz noItem
				
			; select one of the found items
				mov [bp+var_foundIboList], ax
				mov word [bp+var_foundIboListNode], 0
				forFoundIbo:
					lea ax, [bp+var_foundIboListNode]
					push ax
					push word [bp+var_foundIboList]
					callFromOverlay List_stepForward
					pop cx
					pop cx
					
					test ax, ax
					jz doneWithList
					
					; list node's payload is ibo of found item
					mov bx, [bp+var_foundIboListNode]
					mov ax, [bx+ListNode_payload]
					mov [bp+var_foundIbo], ax
					
					; choose this item if it doesn't have an open inventory
					;     dialog. (if this item already has an open inventory
					;     dialog, then we'll prefer a subsequent matching item.)
						push 0 ; statsVsInventory
						lea ax, [bp+var_foundIbo]
						push ax
						callFromOverlay getOpenItemDialogListNode
						pop cx
						pop cx
						
						test ax, ax
						jz doneWithList
						
					; consider the next item in the list
					jmp forFoundIbo
					
				doneWithList:
					; destroy/deallocate the list and its nodes
					push word [bp+var_foundIboList]
					callFromOverlay List_removeAndDestroyAll
					pop cx
					
					push word [bp+var_foundIboList]
					callFromOverlay deallocateNearMemory
					pop cx
					
					mov ax, [bp+var_foundIbo]
					jmp haveOpenableIboInAx
					
		noKeyCode:
		noItem:
			xor ax, ax
			
		haveOpenableIboInAx:
		
		; ax == found ibo or 0
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
		; defineKeyOpenableItem keyCode, type, frame, quality
		%macro defineKeyOpenableItem 4
			dw %1, %2, %3, %4
		%endmacro
		
		keyOpenableItems:
			defineKeyOpenableItem 'b', ItemType_SPELLBOOK, 0xFF, 0xFF
			defineKeyOpenableItem 'B', ItemType_SPELLBOOK, 0xFF, 0xFF
			
			defineGameSpecificKeyOpenableItems
		keyOpenableItems_end:
		
	endBlockAt off_eop_openableItemForKey_end
endPatch
