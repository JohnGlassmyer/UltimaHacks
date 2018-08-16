%assign RESULT_CAPACITY       0x100

%assign SelectMode_NONE       0
%assign SelectMode_CLASSIFIED 1
%assign SelectMode_USE        2
%assign SelectMode_TALK       4
%assign SelectMode_GET        8
%assign SelectMode_ANY        -1

%assign FindResult_ibo        0
%assign FindResult_distance   2
%assign FindResult_SIZE       4

%assign tk_selectMode         0x000
%assign tk_resultCount        0x002
%assign tk_selectedIndex      0x004
%assign tk_results            0x020
%assign tk_typeSelectModeBits tk_results + RESULT_CAPACITY * FindResult_SIZE
%assign tk_SIZE               tk_typeSelectModeBits + 0x400

[bits 16]

startPatch EXE_LENGTH, eop-targetKeys
	startBlockAt addr_eop_targetKeys
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_isContinuation      0x06
		%assign arg_pn_selectedIbo      0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_keyCode            -0x02
		%assign var_selectMode         -0x04
		%assign var_selectionDirection -0x06
		%assign var_avatarX            -0x08
		%assign var_avatarY            -0x0A
		%assign var_avatarZ            -0x0C
		%assign var_maxX               -0x0E
		%assign var_maxY               -0x10
		%assign var_minX               -0x12
		%assign var_minY               -0x14
		%assign var_itemX              -0x16
		%assign var_itemY              -0x18
		%assign var_selectedIbo        -0x1A
		%assign var_keyOpenableIbo     -0x1C
		%assign var_findItemQuery      -0x50
		%assign var_labelText          -0xA0
		%assign var_template           -0xC0
		%assign var_printText          -0xE0
		%assign var_printX             -0xE2
		%assign var_printY             -0xE4
		add sp, var_printY
		
		push esi
		push edi
		
		push VOODOO_SELECTOR
		pop fs
		
		callFromOverlay cyclePalette
		
		; load address of previously allocated memory
			mov esi, [dseg_pf_targetKeysData]
			test esi, esi
			jnz haveDataAddress
			
		; memory not previously allocated;
		; allocate memory and save the address for future calls
			push word 0
			push word tk_SIZE
			push dseg_pf_voodooXmsBlock
			callFromOverlay allocateVoodooMemory
			add sp, 6
			
			push dx
			push ax
			pop esi
			
			test esi, esi
			jz returnWithoutIbo
			
			mov [dseg_pf_targetKeysData], esi
			
			; initialize the allocated memory
				mov word [fs:esi+tk_selectMode], SelectMode_NONE
				
				xor eax, eax
				mov ecx, 0x400 / 4
				push VOODOO_SELECTOR
				pop es
				lea edi, [esi+tk_typeSelectModeBits]
				a32 rep stosd
				
		haveDataAddress:
		
		mov word [bp+var_selectedIbo], 0
		mov word [bp+var_keyOpenableIbo], 0
		
		clearUnlessContinuing:
			cmp byte [bp+arg_isContinuation], 0
			jnz .afterClearing
			mov word [fs:esi+tk_selectMode], SelectMode_NONE
			.afterClearing:
			
		recallPreviouslySelectedItem:
			cmp word [fs:esi+tk_selectMode], SelectMode_NONE
			jz .noPreviouslySelectedItem
			cmp word [fs:esi+tk_resultCount], 0
			jz .noPreviouslySelectedItem
			
			movzx ebx, word [fs:esi+tk_selectedIndex]
			mov ax, [fs:esi+tk_results + ebx*4 + FindResult_ibo]
			mov [bp+var_selectedIbo], ax
			
			.noPreviouslySelectedItem:
			
		push 1
		callFromOverlay pollKey
		pop cx
		mov [bp+var_keyCode], ax
		
		cmp word [bp+var_keyCode], 0
		jz returnWithoutIbo
		
		tryOpenableItemKey:
			push word [bp+var_keyCode]
			callVarArgsEopFromOverlay openableItemForKey, 1
			pop cx
			test ax, ax
			jz .notOpenableItemKey
			
			mov [bp+var_keyOpenableIbo], ax
			jmp select
			
			.notOpenableItemKey:
			
		; Enter key to select current find-result
		cmp word [bp+var_keyCode], 13
		jz select
		
		; Escape key to cancel selection
		cmp word [bp+var_keyCode], 27
		jz cancelSelect
		
		trySelectModeKey:
			jmp .selectModeKeys_end
			%assign SelectModeKey_SIZE 6
			%macro defineSelectModeKey 3
				dw %1, %2, %3
			%endmacro
			.selectModeKeys:
				defineSelectModeKey 'a', SelectMode_ANY,   1
				defineSelectModeKey 'A', SelectMode_ANY,  -1
				defineSelectModeKey 'g', SelectMode_GET,   1
				defineSelectModeKey 'G', SelectMode_GET,  -1
				defineSelectModeKey 'r', SelectMode_USE,   1
				defineSelectModeKey 'R', SelectMode_USE,  -1
				defineSelectModeKey 't', SelectMode_TALK,  1
				defineSelectModeKey 'T', SelectMode_TALK, -1
				.selectModeKeys_end:
				
			mov ax, [bp+var_keyCode]
			mov bx, offsetInCodeSegment(.selectModeKeys)
			.forSelectModeKey:
				cmp bx, offsetInCodeSegment(.selectModeKeys_end)
				jae .notSelectModeKey
				
				cmp ax, [cs:bx+0]
				jnz .notThisSelectModeKey
				
				mov ax, [cs:bx+2]
				mov word [bp+var_selectMode], ax
				mov ax, [cs:bx+4]
				mov word [bp+var_selectionDirection], ax
				jmp haveFilter
				
				.notThisSelectModeKey:
				add bx, SelectModeKey_SIZE
				jmp .forSelectModeKey
				
			.notSelectModeKey:
			
		jmp returnWithoutIbo
		
		select:
			trySelectForUsecode:
				cmp byte [dseg_isSelectingFromEopTarget], 0
				jnz .notSelectForUsecode
				
				mov ax, [bp+var_keyOpenableIbo]
				test ax, ax
				jz .notKeyOpenable
				mov [bp+var_selectedIbo], ax
				.notKeyOpenable:
				
				cmp word [bp+var_selectedIbo], 0
				jz .notSelectForUsecode
				
				jmp returnSelectedByRef
				
				.notSelectForUsecode:
				
			tryGet:
				cmp word [fs:esi+tk_selectMode], SelectMode_GET
				jnz .notGet
				cmp word [bp+var_selectedIbo], 0
				jz returnWithoutIbo
				
				call canAvatarReachSelected
				test al, al
				jz forbidSelect
				
				; subject of get is key-selected item, or Avatar
				mov ax, [bp+var_keyOpenableIbo]
				test ax, ax
				jnz .haveSubject
				mov ax, [dseg_avatarIbo]
				.haveSubject:
				
				push word [bp+var_selectedIbo]
				push ax
				call getObjectWithSubject
				pop cx
				pop cx
				
				jmp cancelSelect
				
				.notGet:
				
			tryAttack:
				cmp word [fs:esi+tk_selectMode], SelectMode_TALK
				jnz .notAttack
				callFromOverlay isAvatarInCombat
				test ax, ax
				jz .notAttack
				cmp word [bp+var_selectedIbo], 0
				jz returnWithoutIbo
				
				.dontAttackPartyMember:
					lea ax, [bp+var_selectedIbo]
					push ax
					callFromOverlay Item_isPartyMember
					pop cx
					jz .notPartyMember
					
					; forbid ordering one party member to attack another
					cmp word [bp+var_keyOpenableIbo], 0
					jnz forbidSelect
					
					; rather than attacking party member, open their inventory
					jmp .notAttack
					
					.notPartyMember:
					
				.setTarget:
					cmp word [bp+var_keyOpenableIbo], 0
					jz .attackWithEntireParty
					
					.attackWithOne:
						push word [bp+var_selectedIbo]
						push word [bp+var_keyOpenableIbo]
						call attackTargetWithSubject
						pop cx
						pop cx
						
						jmp .afterSettingTarget
						
					.attackWithEntireParty:
						xor di, di
						.forPartyMember:
							movzx ax, [dseg_partySize]
							cmp di, ax
							jae .noMorePartyMembers
							
							mov bx, di
							shl bx, 1
							push word [bp+var_selectedIbo]
							push word [dseg_partyMemberIbos+bx]
							call attackTargetWithSubject
							pop cx
							pop cx
							
							inc di
							jmp .forPartyMember
							
							.noMorePartyMembers:
							
					.afterSettingTarget:
						jmp cancelSelect
						
				.notAttack:
				
			tryUse:
				mov ax, [bp+var_keyOpenableIbo]
				test ax, ax
				jz .notKeyOpenable
				mov [bp+var_selectedIbo], ax
				.notKeyOpenable:
				
				cmp word [bp+var_selectedIbo], 0
				jz .notUse
				
				.requireReachUnlessTalking:
					cmp word [fs:esi+tk_selectMode], SelectMode_TALK
					jz .notRequireCanReach
					
					call canAvatarReachSelected
					test al, al
					jz forbidSelect
					
					.notRequireCanReach:
					
				jmp returnSelectedByRef
				
				.notUse:
				
			jmp returnWithoutIbo
			
		forbidSelect:
			push word Sound_CAN_NOT
			callFromOverlay playSoundSimple
			pop cx
			jmp returnWithoutIbo
			
		cancelSelect:
			; (could canceling ever be a problem when selecting for Usecode?)
			
			mov word [bp+var_selectedIbo], 0
			jmp returnSelectedByRef
			
		haveFilter:
			call eraseText
			
			mov ax, [bp+var_selectMode]
			
			cmp word [fs:esi+tk_selectMode], ax
			jz stepAndPrint
			
			mov word [fs:esi+tk_resultCount], 0
			
			lea ax, [bp+var_avatarY]
			push ax
			lea ax, [bp+var_avatarX]
			push ax
			push dseg_avatarIbo
			callFromOverlay Item_getXAndY
			add sp, 6
			
			push word [dseg_avatarIbo]
			callVarArgsEopFromOverlay getItemZ, 1
			pop cx
			mov word [bp+var_avatarZ], ax
			
			mov ax, [bp+var_avatarX]
			sub ax, 48
			mov [bp+var_minX], ax
			mov ax, [bp+var_avatarX]
			add ax, 48
			mov [bp+var_maxX], ax
			
			mov ax, [bp+var_avatarY]
			sub ax, 48
			mov [bp+var_minY], ax
			mov ax, [bp+var_avatarY]
			add ax, 48
			mov [bp+var_maxY], ax
			
			push word 0xFF ; frame
			push word 0xFF ; quality
			push word 0xFFFF ; type
			push 0 ; flags
			
			lea ax, [bp+var_maxY]
			push ax
			lea ax, [bp+var_maxX]
			push ax
			lea ax, [bp+var_minY]
			push ax
			lea ax, [bp+var_minX]
			push ax
			lea ax, [bp+var_findItemQuery]
			push ax
			callFromOverlay findItemInArea
			add sp, 18
			
			xor edi, edi
			forFoundItem:
				cmp edi, RESULT_CAPACITY
				jae doneFindingItems
				
				lea ax, [bp+var_findItemQuery]
				push ax
				callFromOverlay findItem
				pop cx
				
				; end of this FindItem query?
					cmp word [bp+var_findItemQuery+FindItemQuery_ibo], 0
					jz doneFindingItems
					
				; filter out found items by several criteria, roughly in order
				;     of increasing computational expense
				
				; don't include the avatar in the results
					mov ax, [bp+var_findItemQuery+FindItemQuery_ibo]
					cmp ax, [dseg_avatarIbo]
					jz forFoundItem
					
				; filter out invisible Avatar bodies (type 400, frame 0)
				; (they can still be stepped on, though. gruesome AND spooky.)
					mov es, [dseg_itemBufferSegment]
					mov bx, word [bp+var_findItemQuery+FindItemQuery_ibo]
					mov ax, [es:bx+4]
					and ax, 0x3FF
					cmp ax, 400
					jnz notInvisibleAvatarBody
					mov ax, [es:bx+4]
					and ax, 0x7C00
					test ax, ax
					jz forFoundItem
					notInvisibleAvatarBody:
					
				; filter out types not appropriate for the selectMode
					cmp word [bp+var_selectMode], SelectMode_ANY
					jz afterFilterByType
					
					mov es, [dseg_itemBufferSegment]
					mov bx, word [bp+var_findItemQuery+FindItemQuery_ibo]
					mov ax, [es:bx+4]
					and ax, 0x3FF
					push ax
					call classifyType
					pop cx
					
					test ax, [bp+var_selectMode]
					jz forFoundItem
					
					afterFilterByType:
					
				; filter out if itemZ > ceilingZ
					push word [bp+var_findItemQuery+FindItemQuery_ibo]
					callVarArgsEopFromOverlay getItemZ, 1
					pop cx
					cmp ax, [dseg_ceilingZ]
					ja forFoundItem
					
				; filter out if coords are far off-screen
					lea ax, [bp+var_itemY]
					push ax
					lea ax, [bp+var_itemX]
					push ax
					lea ax, [bp+var_findItemQuery+FindItemQuery_ibo]
					push ax
					callFromOverlay Item_getXAndY
					add sp, 6
					
					push dseg_screenCenterWorldX
					lea ax, [bp+var_itemX]
					push ax
					callFromOverlay compareWorldCoords
					pop cx
					pop cx
					cmp ax, -21
					jl forFoundItem
					cmp ax, 21
					jg forFoundItem
					
					push dseg_screenCenterWorldY
					lea ax, [bp+var_itemY]
					push ax
					callFromOverlay compareWorldCoords
					pop cx
					pop cx
					cmp ax, -13
					jl forFoundItem
					cmp ax, 13
					jg forFoundItem
					
				mov ax, [bp+var_findItemQuery+FindItemQuery_ibo]
				mov [fs:esi+tk_results + edi*4 + FindResult_ibo], ax
				
				push word [bp+var_avatarZ]
				lea ax, [bp+var_avatarY]
				push ax
				lea ax, [bp+var_avatarX]
				push ax
				lea ax, [bp+var_findItemQuery+FindItemQuery_ibo]
				push ax
				callFromOverlay Item_greatestDeltaToCoords
				add sp, 8
				
				mov [fs:esi+tk_results + edi*4 + FindResult_distance], ax
				
				inc edi
				jmp forFoundItem
				
			doneFindingItems:
			
			mov [fs:esi+tk_resultCount], di
			
			; selection-sort the results by distance
			xor edi, edi
			forSorted:
				cmp di, word [fs:esi+tk_resultCount]
				jae haveSortedResults
				
				mov ecx, edi
				mov edx, edi
				inc edx
				forUnsorted:
					cmp dx, word [fs:esi+tk_resultCount]
					jae ecxHasNearestUnsorted
					
					mov ax, word [fs:esi+tk_results + ecx*4 + FindResult_distance]
					cmp ax, word [fs:esi+tk_results + edx*4 + FindResult_distance]
					jbe ecxHasNearer
					mov ecx, edx
					ecxHasNearer:
					
					inc edx
					jmp forUnsorted
					
				ecxHasNearestUnsorted:
				cmp ecx, edi
				jz afterSwapping
				xchg eax, [fs:esi+tk_results + edi*4]
				xchg eax, [fs:esi+tk_results + ecx*4]
				xchg eax, [fs:esi+tk_results + edi*4]
				afterSwapping:
				
				inc edi
				jmp forSorted
				
			haveSortedResults:
			
			mov word [fs:esi+tk_selectedIndex], 0
			
			mov ax, [bp+var_selectMode]
			mov word [fs:esi+tk_selectMode], ax
			
			jmp printSelected
			
		stepAndPrint:
			cmp word [fs:esi+tk_resultCount], 0
			jz returnWithoutIbo
			
			call eraseText
			
			; increment or decrement selectedIndex, modulo resultCount
				mov ax, word [fs:esi+tk_selectedIndex]
				add ax, word [bp+var_selectionDirection]
				add ax, word [fs:esi+tk_resultCount]
				cwd
				div word [fs:esi+tk_resultCount]
				mov word [fs:esi+tk_selectedIndex], dx
				
		printSelected:
			cmp word [fs:esi+tk_resultCount], 0
			jz returnWithoutIbo
			
			movzx edi, word [fs:esi+tk_selectedIndex]
			
			mov ax, [fs:esi+tk_results + edi*4 + FindResult_ibo]
			mov [bp+var_selectedIbo], ax
			
			push ItemLabelType_NAME
			push word [bp+var_selectedIbo]
			lea ax, [bp+var_labelText]
			push ax
			callVarArgsEopFromOverlay produceItemLabelText, 3
			add sp, 6
			
			; format the item's label-text with an appropriate template
				jmp afterPrintTemplates
				selectTemplate: db "select: %s", 0
				attackTemplate: db "attack: %s", 0
				talkTemplate: db "talk: %s", 0
				useTemplate: db "use: %s", 0
				getTemplate: db "get: %s", 0
				afterPrintTemplates:
				
				trySelectTemplate:
					cmp byte [dseg_isSelectingFromEopTarget], 0
					jnz .notSelectTemplate
					
					mov ax, offsetInCodeSegment(selectTemplate)
					jmp havePrintTemplate
					
					.notSelectTemplate:
				
				tryGetTemplate:
					cmp word [fs:esi+tk_selectMode], SelectMode_GET
					jnz .notGetTemplate
					
					mov ax, offsetInCodeSegment(getTemplate)
					jmp havePrintTemplate
					
					.notGetTemplate:
					
				tryAttackTemplate:
					callFromOverlay isAvatarInCombat
					test ax, ax
					jz .notAttackTemplate
					
					mov ax, offsetInCodeSegment(attackTemplate)
					jmp havePrintTemplate
					
					.notAttackTemplate:
					
				tryUseTemplate:
					cmp word [fs:esi+tk_selectMode], SelectMode_ANY
					jz .useTemplate
					cmp word [fs:esi+tk_selectMode], SelectMode_USE
					jz .useTemplate
					jmp .notUseTemplate
					
					.useTemplate:
					mov ax, offsetInCodeSegment(useTemplate)
					jmp havePrintTemplate
					
					.notUseTemplate:
					
				mov ax, offsetInCodeSegment(talkTemplate)
				
				havePrintTemplate:
				lea bx, [bp+var_template]
				fmemcpy ss, bx, cs, ax, 0x10
				
				lea ax, [bp+var_labelText]
				push ax
				lea ax, [bp+var_template]
				push ax
				lea ax, [bp+var_printText]
				push ax
				callFromOverlay sprintf
				add sp, 6
				
			lea ax, [bp+var_itemY]
			push ax
			lea ax, [bp+var_itemX]
			push ax
			lea ax, [bp+var_selectedIbo]
			push ax
			callFromOverlay Item_getXAndY
			add sp, 6
			
			lea ax, [bp+var_printY]
			push ax
			lea ax, [bp+var_printX]
			push ax
			lea ax, [bp+var_itemY]
			push ax
			lea ax, [bp+var_itemX]
			push ax
			callFromOverlay worldCoordsToScreen
			add sp, 8
			
			; adjust text position for item z (altitude)
				push word [bp+var_selectedIbo]
				callVarArgsEopFromOverlay getItemZ, 1
				pop cx
				shl ax, 2
				sub [bp+var_printX], ax
				sub [bp+var_printY], ax
				
			; center text on item's tile
				sub word [bp+var_printX], 8
				sub word [bp+var_printY], 8
				
			; TODO: center text on item's shape
			
			; TODO: bound text position to screen
			
			lea ax, [bp+var_printText]
			push ax
			push TextAlignment_HORIZONTAL_CENTER \
					| TextAlignment_VERTICAL_CENTER
			push Font_RED
			push word [bp+var_printY]
			push word [bp+var_printX]
			push dseg_viewport
			callVarArgsEopFromOverlay printText, 6
			add sp, 12
			
			callFromOverlay copyFrameBuffer
			
			; debug-print some diagnostic info about the selected item
				jmp debugTemplate_end
				debugTemplate:
					db '0x%04x (%d) at %u %u,%u %u,%u', 0
					debugTemplate_end:
					
				lea bx, [bp+var_template]
				fmemcpy ss, bx, \
						cs, offsetInCodeSegment(debugTemplate), \
						(debugTemplate_end - debugTemplate)
				
				push word [bp+var_printY]
				push word [bp+var_printX]
				push word [bp+var_itemY]
				push word [bp+var_itemX]
				push word [fs:esi+tk_results + edi*4 + FindResult_distance]
				mov es, [dseg_itemBufferSegment]
				mov bx, [bp+var_selectedIbo]
				mov ax, [es:bx+4]
				and ax, 0x3FF
				push ax
				push word [bp+var_selectedIbo]
				lea ax, [bp+var_template]
				push ax
				push 1
				push 1
				callFromOverlay debugPrintfAtCoords
				add sp, 20
				
			jmp returnWithoutIbo
			
		returnSelectedByRef:
			; clear result so that next invocation will start fresh
			mov word [fs:esi+tk_selectMode], SelectMode_NONE
			
			mov bx, [bp+arg_pn_selectedIbo]
			mov ax, [bp+var_selectedIbo]
			mov [bx], ax
			
			mov ax, 1
			jmp returnAx
			
		returnWithoutIbo:
			mov ax, 0
			
		returnAx:
		
		pop edi
		pop esi
		mov sp, bp
		pop bp
		retn
		
		canAvatarReachSelected:
			; (canAvatarReach is computationally expensive; calling it while
			;     building the list of found items would be too slow.)
			movzx ax, [dseg_isHackMoverEnabled]
			push ax
			lea ax, [bp+var_selectedIbo]
			push ax
			callFromOverlay canAvatarReach
			pop cx
			pop cx
			retn
			
		getObjectWithSubject:
			push bp
			mov bp, sp
			
			%assign .arg_objectIbo       0x06
			%assign .arg_subjectIbo      0x04
			%assign .var_pn_worldArea   -0x02
			%assign .var_selectedIbo    -0x04
			%assign .var_itemX          -0x06
			%assign .var_itemY          -0x08
			%assign .var_itemZ          -0x0A
			add sp, .var_itemZ
			
			push esi
			push edi
			
			callVarArgsEopFromOverlay ensureDragAndDropAreasInitialized, 0
			
			; configure drop area to try to place the item into the destination
			mov bx, [dseg_pn_dropArea]
			mov ax, [bp+.arg_subjectIbo]
			mov [bx+InventoryArea_ibo], ax
			
			lea ax, [bp+.var_itemY]
			push ax
			lea ax, [bp+.var_itemX]
			push ax
			lea ax, [bp+.arg_objectIbo]
			push ax
			callFromOverlay Item_getXAndY
			add sp, 6
			
			push word [bp+.arg_objectIbo]
			callVarArgsEopFromOverlay getItemZ, 1
			pop cx
			mov [bp+.var_itemZ], ax
			
			; configure drag area to place the item back at its original
			;     position if dropping fails
			mov bx, [dseg_pn_dragArea]
			mov word [bx+InventoryArea_ibo], 0 ; moving item from world
			mov ax, [bp+.arg_objectIbo]
			mov word [bx+InventoryArea_draggedIbo], ax
			mov ax, [bp+.var_itemX]
			mov word [bx+InventoryArea_worldX], ax
			mov ax, [bp+.var_itemY]
			mov word [bx+InventoryArea_worldY], ax
			mov ax, [bp+.var_itemZ]
			mov word [bx+InventoryArea_worldZ], ax
			
			; have the game think that our drag area is the world area, so that
			;     it will apply gravity to newly unsupported items and trigger
			;     reactions to item movement
			mov ax, [dseg_pn_worldArea]
			mov [bp+.var_pn_worldArea], ax
			mov ax, [dseg_pn_dragArea]
			mov [dseg_pn_worldArea], ax
			
			; execute drag, specifying our drag area as the source. our code
			;     in the patched dragItem loop will notice the configured drop
			;     area and choose it as the target for dropping.
			callFromOverlay getLastMouseState
			push ax
			push word [dseg_pn_dragArea]
			callFromOverlay dragItem
			pop cx
			pop cx
			
			; restore the world area
			mov ax, [bp+.var_pn_worldArea]
			mov [dseg_pn_worldArea], ax
			
			pop edi
			pop esi
			
			mov sp, bp
			pop bp
			retn
			
		attackTargetWithSubject:
			push bp
			mov bp, sp
			
			%assign .arg_targetIbo       0x06
			%assign .arg_subjectIbo      0x04
			
			lea ax, [bp+.arg_targetIbo]
			push ax
			callFromOverlay Item_getNpcNumber
			pop cx
			
			push 1 ; isPrimaryVsSecondary
			push ax
			lea ax, [bp+.arg_subjectIbo]
			push ax
			callFromOverlay Item_setNpcTarget
			add sp, 6
			
			mov sp, bp
			pop bp
			retn
			
		eraseText:
			cmp byte [dseg_isDialogMode], 0
			jz .notInDialogMode
			
			callFromOverlay redrawDialogs
			jmp .afterRedrawing
			
			.notInDialogMode:
			push dseg_camera
			callFromOverlay drawWorld
			pop cx
			
			.afterRedrawing:
			
			callFromOverlay copyFrameBuffer
			
			retn
			
		classifyType:
			push bp
			mov bp, sp
			
			%assign arg_itemType      0x04
			%assign var_filterBits   -0x02
			%assign var_item         -0x0A
			%assign var_pn_item      -0x0C
			%assign var_linkdep1_0   -0x0E
			%assign var_linkdep1_2   -0x10
			%assign var_linkdep1_4m0 -0x12
			add sp, var_linkdep1_4m0
			
			push esi
			push edi
			
			mov esi, [dseg_pf_targetKeysData]
			
			; if we've previously computed a value, we return that value.
				movzx ebx, word [bp+arg_itemType]
				movzx ax, byte [fs:esi+tk_typeSelectModeBits + ebx]
				test ax, SelectMode_CLASSIFIED
				jnz .returnAx
				
			mov word [bp+var_filterBits], 0
			
			; determine whether type is talkable by testing its NPC class bit.
				mov ax, [bp+arg_itemType]
				mov dx, 3
				mul dx
				mov bx, ax
				movzx bx, byte [dseg_itemTypeInfo+bx+1]
				and bx, 0xF
				shl bx, 1
				test word [dseg_itemTypeClassFlags+bx], ItemClassBit_NPC
				jz .notTalkable
				mov word [bp+var_filterBits], SelectMode_TALK
				jmp .recordClassification
				.notTalkable:
				
			; determine whether item type is openable. the canBeOpened function
			;   takes a pointer to an item in the item buffer, while we need to
			;   make a decision about an item type, so we'll create a fake item
			;   with the given type in the near segment and pretend that the
			;   item-buffer segment is the near segment.
			; canBeOpened might do bad things if we passed it a fake item with
			;   an NPC item-type, but an NPC type won't pass through this path
			;   because it will have been classified as talkable.
				lea bx, [bp+var_item]
				mov ax, [bp+arg_itemType]
				mov [bx+4], ax
				mov [bp+var_pn_item], bx
				
				push word [dseg_itemBufferSegment]
				mov [dseg_itemBufferSegment], ds
				lea ax, [bp+var_pn_item]
				push ax
				callFromOverlay Item_canBeOpened
				pop cx
				pop word [dseg_itemBufferSegment]
				
				test al, al
				jnz .openable
				
			; determine whether item type is usable by looking it up in the use
			;   index.
				lea ax, [bp+var_linkdep1_2]
				push ax
				lea ax, [bp+var_linkdep1_4m0]
				push ax
				lea ax, [bp+var_linkdep1_0]
				push ax
				push word [bp+arg_itemType]
				callFromOverlay lookupLinkdep1
				add sp, 8
				cmp word [bp+var_linkdep1_2], 0xFFFF
				jnz .usable
				
				jmp .notUsable
				
				.openable:
				.usable:
				or word [bp+var_filterBits], SelectMode_USE
				.notUsable:
				
			; determine whether type is gettable. assuming that gettable/movable
			;   items are those with non-zero weight.
				push word [bp+arg_itemType]
				callFromOverlay getItemTypeWeight
				pop cx
				test ax, ax
				jz .notGettable
				or word [bp+var_filterBits], SelectMode_GET
				.notGettable:
				
			.recordClassification:
			
			mov ax, [bp+var_filterBits]
			or ax, SelectMode_CLASSIFIED
			
			; record the value so we won't have to compute for this type again.
				movzx ebx, word [bp+arg_itemType]
				mov byte [fs:esi+tk_typeSelectModeBits + ebx], al
				
			.returnAx:
			
			pop edi
			pop esi
			
			mov sp, bp
			pop bp
			retn
			
	endBlockAt off_eop_targetKeys_end
endPatch
