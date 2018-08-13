%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; Select an item (party member, backpack of party member, or spellbook)
; by pressed key.
;
; Inspired by the ability in Ultima VI to select a party member,
; in multiple contexts, by pressing a number key.
startPatch EXE_LENGTH, \
		eop-numberSelect
		
	startBlockAt seg_eop, off_eop_numberSelect
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
		%assign var_inventorySlot      -0x0A
		%assign var_itemFrame          -0x0C
		%assign var_itemQuality        -0x0E
		%assign var_itemType           -0x10
		%assign var_foundIboList       -0x12
		%assign var_foundIboListNode   -0x14
		%assign var_foundIbo           -0x16
		add sp, var_foundIbo
		
		push si
		push di
		
		mov word [bp+var_shiftStatus], 0
		
		; if a key code was passed as a parameter, use it
			mov ax, [bp+arg_keyCodeOrZero]
			or ax, ax
			jnz haveKeyCode
			
		; if no key code was provided as a parameter,
		; then use the code of a pressed key if one has been pressed
			callFromOverlay pollKeyToGlobalDiscarding
			or ax, ax
			jz noKeyCode
			mov ax, [dseg_polledKey]
			
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
			jnz tryLetter
			mov ax, 7
			jmp haveShiftedNumber
			
		haveShiftedNumber:
			mov word [bp+var_shiftStatus], 1
			
		haveNumber:
			cmp ax, [dseg_partySize]
			jge noIbo
			
			; get party member ibo
			push ax
			callEopFromOverlay 1, getPartyMemberIbo
			add sp, 2
			mov [bp+var_partyMemberIbo], ax
			
			cmp word [bp+var_shiftStatus], 0
			jz noSlot
			
			backpack:
				mov word [bp+var_inventorySlot], InventorySlot_BACKPACK
				jmp getSlotIbo
				
			noSlot:
				mov ax, [bp+var_partyMemberIbo]
				jmp haveIboInAx
				
			getSlotIbo:
				push word [bp+var_inventorySlot]
				push word [bp+var_partyMemberIbo]
				callFromOverlay getItemInSlot
				add sp, 4
				jmp haveIboInAx
				
		tryLetter:
			mov word [bp+var_foundIbo], 0
			
			cmp ax, 'b' ; Spellbook
			jnz notSpellbook
			mov word [bp+var_itemFrame],   0xFF
			mov word [bp+var_itemQuality], 0xFF
			mov word [bp+var_itemType],    761
			jmp findAndSelectItem
			
			notSpellbook:
			jmp noIbo
			
			findAndSelectItem:
			; get a list of items held by party members
				push word [bp+var_itemFrame]
				push word [bp+var_itemQuality]
				push word [bp+var_itemType]
				callEopFromOverlay 3, findAllPartyItems
				add sp, 6
				
				test ax, ax
				jz noIbo
				
			; select one of the found items
				mov [bp+var_foundIboList], ax
				mov word [bp+var_foundIboListNode], 0
				forFoundIbo:
					lea ax, [bp+var_foundIboListNode]
					push ax
					push word [bp+var_foundIboList]
					callFromOverlay list_stepForward
					add sp, 4
					
					test ax, ax
					jz doneWithList
					
					; list node's payload is ibo of found item
					mov bx, [bp+var_foundIboListNode]
					mov ax, [bx+ListNode_payload]
					mov [bp+var_foundIbo], ax
					
					; consider (and prefer) subsequent items if this one
					; already has an on-screen inventory dialog
						push 0 ; statsVsInventory
						lea ax, [bp+var_foundIbo]
						push ax
						callFromOverlay getOpenItemDialogListNode
						add sp, 4
						
						test ax, ax
						jz doneWithList
						
					; consider the next item in the list
					jmp forFoundIbo
					
				doneWithList:
					; destroy/deallocate the list and its nodes
					push word [bp+var_foundIboList]
					callFromOverlay list_removeAndDestroyAll
					callFromOverlay deallocateNearMemory
					pop cx
					
					mov ax, [bp+var_foundIbo]
					jmp endProc
					
		noKeyCode:
		noIbo:
			xor ax, ax
			
		haveIboInAx:
		
		endProc:
		; ax == found ibo or 0
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_numberSelect_end
endPatch
