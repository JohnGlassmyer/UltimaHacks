; Enable the player to select and cast a spell by typing its runes
; in real-time gameplay, without going through a spellbook dialog.
;
; Inspired by the ability to cast a spell by typing its runes
; (though not in real time) in Ultima VI.

%assign TIME_FOR_CASTING                130
%assign NUMBER_OF_RUNES                 27

%define START_CASTING_KEY               '/'
%define REMOVE_LAST_RUNE_KEY            8   ; Backspace
%define EXECUTE_CASTING_KEY             13  ; Enter
%define CANCEL_CASTING_KEY              27  ; Escape

[bits 16]

startPatch EXE_LENGTH, eop-castByKey
	startBlockAt addr_eop_castByKey
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_keyCode               0x04
		%assign ____callerIp              0x02
		%assign ____callerBp              0x00
		%assign var_wasKeyConsumed       -0x02
		%assign var_pn_spellbookList     -0x04
		%assign var_pn_spellbookListNode -0x06
		%assign var_spellNumber          -0x08
		%assign var_statusString         -0x50
		%assign var_runeString           -0x60
		add sp, var_runeString
		
		push esi
		push edi
		
		push VOODOO_SELECTOR
		pop fs
		
		; assume that we have not used the pressed key
		mov word [bp+var_wasKeyConsumed], 0
		
		; load address of previously allocated castByKey memory
			mov esi, [dseg_pf_castByKeyData]
			test esi, esi
			jnz haveDataAddress
			
		allocateAndInitialize:
			push word 0
			push word CastByKey_SIZE
			push dseg_pf_voodooXmsBlock
			callFromOverlay allocateVoodooMemory
			add sp, 6
			
			push dx
			push ax
			pop esi
			
			test esi, esi
			jz afterPrintingStatus
			
			push 8
			callFromOverlay allocateNearMemory
			pop cx
			mov [fs:esi+CastByKey_pn_timer], ax
			
			%macro copyStrings 3
				%define %%CastByKey_offset %1
				%define %%csStringsLabel %2
				%define %%stringCount %3
				
				xor edi, edi
				mov bx, offsetInCodeSegment(%%csStringsLabel)
				%%forString:
					cmp edi, %%stringCount
					jae %%noMoreStrings
					
					lea edx, [esi+%%CastByKey_offset + edi*8]
					mov dword [fs:edx+0], 0
					mov dword [fs:edx+4], 0
					
					%%forCharacter:
						mov al, [cs:bx]
						inc bx
						
						mov [fs:edx], al
						inc edx
						
						test al, al
						jz %%endOfString
						jmp %%forCharacter
						
						%%endOfString:
						
					inc edi
					jmp %%forString
					
					%%noMoreStrings:
			%endmacro
			
			copyStrings CastByKey_runeStrings, runeStrings, NUMBER_OF_RUNES
			copyStrings CastByKey_spellRunes, spellRunes, NUMBER_OF_SPELLS
			
			mov word [fs:esi+CastByKey_isCastingInProgress], 0
			
			mov [dseg_pf_castByKeyData], esi
			
		haveDataAddress:
		
		%ifnum dseg_isPlayerControlDisabled
		; cancel and skip if Usecode has disabled player control
			cmp byte [dseg_isPlayerControlDisabled], 0
			jz .notControlDisabled
			
			mov byte [fs:esi+CastByKey_isCastingInProgress], 0
			jmp afterProcessingKey
			
			.notControlDisabled:
		%endif
		
		; is a casting in progress?
			cmp byte [fs:esi+CastByKey_isCastingInProgress], 0
			jz noCastingInProgress
			
		; cancel any in-progress casting if the Avatar is unconscious
			push dseg_avatarIbo
			callFromOverlay isNpcUnconscious
			pop cx
			test al, al
			jnz noSpellToCast
			
		; if casting time has elapsed,
		; try to cast with whatever runes have been entered
			push word [fs:esi+CastByKey_pn_timer]
			callFromOverlay Timer_hasFinished
			pop cx
			test ax, ax
			jnz executeCasting
			
		jmp stillCasting
		
		noCastingInProgress:
			cmp word [bp+arg_keyCode], START_CASTING_KEY
			jz startCasting
			jmp afterProcessingKey
			
		startCasting:
			mov word [bp+var_wasKeyConsumed], 1
			
			.requireResponsiveAvatar:
				push dseg_avatarIbo
				callFromOverlay isNpcUnconscious
				pop cx
				jnz canNotCast
				
			.requireSpellbook:
				push 0xFF ; frame
				push 0xFF ; quality
				push ItemType_SPELLBOOK  ; type
				callVarArgsEopFromOverlay findPartyItem, 3
				add sp, 6
				test ax, ax
				jz canNotCast
				
			mov dword [fs:esi+CastByKey_selectedRuneCount], 0
			mov dword [fs:esi+CastByKey_selectedRunes+0], 0
			mov dword [fs:esi+CastByKey_selectedRunes+4], 0
			mov byte [fs:esi+CastByKey_isCastingInProgress], 1
			
			push word Sound_OPEN_DIALOG
			callFromOverlay playSoundSimple
			pop cx
			
			jmp afterProcessingKey
			
		stillCasting:
			mov ax, word [bp+arg_keyCode]
			cmp ax, REMOVE_LAST_RUNE_KEY
			jz removeLastRune
			cmp ax, EXECUTE_CASTING_KEY
			jz executeCasting
			cmp ax, CANCEL_CASTING_KEY
			jz noSpellToCast
			
		tryRuneKey:
			%ifdef ACCEPT_FRIO_RUNE
			cmp ax, 'F'
			jz .haveRuneKey
			%endif
			
			cmp ax, 'a'
			jb afterProcessingKey
			cmp ax, 'z'
			ja afterProcessingKey
			
			.haveRuneKey:
			
			mov word [bp+var_wasKeyConsumed], 1
			
			; don't accept a 9th rune
			cmp dword [fs:esi+CastByKey_selectedRuneCount], 8
			jae noSpellToCast
			
			; store the new rune in the array of accumulated runes
			mov ebx, [fs:esi+CastByKey_selectedRuneCount]
			mov byte [fs:esi+CastByKey_selectedRunes+ebx], al
			inc dword [fs:esi+CastByKey_selectedRuneCount]
			
			push word ADD_RUNE_SOUND
			callFromOverlay playSoundSimple
			pop cx
			
			jmp afterProcessingKey
			
		removeLastRune:
			mov word [bp+var_wasKeyConsumed], 1
			
			cmp dword [fs:esi+CastByKey_selectedRuneCount], 0
			jz .noRunesToRemove
			
			dec dword [fs:esi+CastByKey_selectedRuneCount]
			mov ebx, [fs:esi+CastByKey_selectedRuneCount]
			mov byte [fs:esi+CastByKey_selectedRunes+ebx], 0
			
			push word REMOVE_RUNE_SOUND
			callFromOverlay playSoundSimple
			pop cx
			
			.noRunesToRemove:
			jmp afterProcessingKey
			
		executeCasting:
			mov word [bp+var_wasKeyConsumed], 1
			
			; don't try to find a zero-length spell
			cmp dword [fs:esi+CastByKey_selectedRuneCount], 0
			jz noSpellToCast
			
			; try to find a spell matching the selected runes
			xor edi, edi
			.forSpell:
				cmp edi, NUMBER_OF_SPELLS
				jae .noMoreSpells
				
				mov eax, [fs:esi+CastByKey_selectedRunes+0]
				cmp eax, [fs:esi+CastByKey_spellRunes+edi*8+0]
				jnz .notThisSpell
				mov eax, [fs:esi+CastByKey_selectedRunes+4]
				cmp eax, [fs:esi+CastByKey_spellRunes+edi*8+4]
				jnz .notThisSpell
				
				mov [bp+var_spellNumber], di
				jmp runesMatchedSpell
				
				.notThisSpell:
				inc edi
				jmp .forSpell
				
				.noMoreSpells:
				jmp noSpellToCast
				
		runesMatchedSpell:
		; now try to find a spellbook having the matched spell
			push 0xFF ; frame
			push 0xFF ; quality
			push ItemType_SPELLBOOK ; type
			callVarArgsEopFromOverlay findAllPartyItems, 3
			add sp, 6
			
			test ax, ax
			jz noSpellToCast
			
			mov [bp+var_pn_spellbookList], ax
			
			; set di = 1 if spell found in a spellbook
			mov di, 0
			mov word [bp+var_pn_spellbookListNode], 0
			forSpellbookInList:
				lea ax, [bp+var_pn_spellbookListNode]
				push ax
				push word [bp+var_pn_spellbookList]
				callFromOverlay List_stepForward
				pop cx
				pop cx
				
				test ax, ax
				jz doneCheckingSpellbooks
				
				; payload of list node is ibo of a found spellbook
				push word [bp+var_spellNumber]
				mov bx, [bp+var_pn_spellbookListNode]
				lea ax, [bx+ListNode_payload]
				push ax
				callFromOverlay doesSpellbookHaveSpell
				pop cx
				pop cx
				
				test ax, ax
				jz forSpellbookInList
				
				mov di, 1
				
			doneCheckingSpellbooks:
			; list was allocated on heap; needs to be freed
			push word [bp+var_pn_spellbookList]
			callFromOverlay List_removeAndDestroyAll
			pop cx
			push word [bp+var_pn_spellbookList]
			callFromOverlay deallocateNearMemory
			pop cx
			
			; di == found spell in a spellbook
			test di, di
			jz noSpellToCast
			
			; a spellbook had the spell
			; fail if avatar cannot cast the spell
				push 1 ; require mana
				push 1 ; require reagents
				push word [bp+var_spellNumber]
				push dseg_avatarIbo
				callFromOverlay canCastSpell
				add sp, 8
				test ax, ax
				jz canNotCast
				
			; close dialogs so that the casting can be performed
				mov byte [dseg_dialogState], DialogState_CLOSE_ALL
				
			; to prevent castByKey reentrance, clear the castByKey state before
			;     going to Usecode to cast the spell
				mov byte [fs:esi+CastByKey_isCastingInProgress], 0
				
			; suppress any bark from the spell's Usecode purporting to show the
			;     Avatar incanting the spell's runes. several of them are
			;     inaccurate, and castByKey makes them all redundant anyway.
				mov byte [dseg_areBarksSuppressed], 1
				
			; try to cast the spell (checks mana and reagents)
				mov ax, 1
				push ax
				push ax
				push ax
				push word [bp+var_spellNumber]
				push dseg_avatarIbo
				callFromOverlay tryToCastSpell
				add sp, 10
				
			; allow barks again now that the spell's Usecode has run
				mov byte [dseg_areBarksSuppressed], 0
				
			jmp afterProcessingKey
			
		noSpellToCast:
			mov byte [fs:esi+CastByKey_isCastingInProgress], 0
			
			push word Sound_FIZZLE
			callFromOverlay playSoundSimple
			pop cx
			
			jmp afterProcessingKey
			
		canNotCast:
			mov byte [fs:esi+CastByKey_isCastingInProgress], 0
			
			push word Sound_CAN_NOT
			callFromOverlay playSoundSimple
			pop cx
			
			jmp afterProcessingKey
			
		afterProcessingKey:
			cmp byte [fs:esi+CastByKey_isCastingInProgress], 0
			jz afterPrintingStatus
			
			cmp dword [fs:esi+CastByKey_selectedRuneCount], 0
			jnz createStatusStringWithRunes
			
			createCastingStringWithoutRunes:
				jmp castingString_end
				castingString:
					db '(casting)', 0
					castingString_end:
					
				lea ax, [bp+var_statusString]
				fmemcpy ss, ax, \
						cs, offsetInCodeSegment(castingString), \
						castingString_end - castingString
				
				jmp haveStatusString
				
			createStatusStringWithRunes:
			; e.g. '"An Bet Corp..."'
				
				; string starts with an open-quote
				mov word [bp+var_statusString], `"\0`
				
				xor edi, edi
				.forSelectedRune:
					cmp edi, [fs:esi+CastByKey_selectedRuneCount]
					jae .noMoreSelectedRunes
					
					movzx ebx, byte [fs:esi+CastByKey_selectedRunes+edi]
					.adjustIfFrio:
						cmp ebx, 'F'
						jnz .notFrio
						mov ebx, 'z' + 1
						.notFrio:
					sub ebx, 'a'
					; copy the rune string to near memory
						mov eax, [fs:esi+CastByKey_runeStrings+ebx*8+0]
						mov [bp+var_runeString+0], eax
						mov eax, [fs:esi+CastByKey_runeStrings+ebx*8+4]
						mov [bp+var_runeString+4], eax
						
					; append the rune string to the status string
						lea ax, [bp+var_runeString]
						push ax
						lea ax, [bp+var_statusString]
						push ax
						callFromOverlay strcat
						pop cx
						pop cx
						
					; append a space
						mov word [bp+var_runeString], ` \0`
						lea ax, [bp+var_runeString]
						push ax
						lea ax, [bp+var_statusString]
						push ax
						callFromOverlay strcat
						pop cx
						pop cx
						
					inc edi
					jmp .forSelectedRune
					
					.noMoreSelectedRunes:
					
				; append an ellipsis and close-quote after the last rune
					mov dword [bp+var_runeString+0], '..."'
					mov dword [bp+var_runeString+4], 0
					lea ax, [bp+var_runeString]
					push ax
					lea ax, [bp+var_statusString]
					push ax
					callFromOverlay strcat
					pop cx
					pop cx
					
				jmp haveStatusString
				
		haveStatusString:
			push word 0
			push word 1 ; short duration so the text can be changed quickly
			push word 5
			lea ax, [bp+var_statusString]
			push ax
			push word [dseg_avatarIbo]
			push dseg_spriteManager
			callFromOverlay SpriteManager_barkOnItem
			add sp, 12
			
		afterPrintingStatus:
			; extend deadline if a keypress has contributed to a casting
			cmp byte [fs:esi+CastByKey_isCastingInProgress], 0
			jz .afterSettingTimer
			cmp word [bp+var_wasKeyConsumed], 0
			jz .afterSettingTimer
			
			push 0
			push TIME_FOR_CASTING
			push word [fs:esi+CastByKey_pn_timer]
			callFromOverlay Timer_set
			add sp, 6
			
			.afterSettingTimer:
			mov ax, word [bp+var_wasKeyConsumed]
			
		pop edi
		pop esi
		mov sp, bp
		pop bp
		retn
		
		runeStrings:
			db 'An', 0
			db 'Bet', 0
			db 'Corp', 0
			db 'Des', 0
			db 'Ex', 0
			db 'Flam', 0
			db 'Grav', 0
			db 'Hur', 0
			db 'In', 0
			db 'Jux', 0
			db 'Kal', 0
			db 'Lor', 0
			db 'Mani', 0
			db 'Nox', 0
			db 'Ort', 0
			db 'Por', 0
			db 'Quas', 0
			db 'Rel', 0
			db 'Sanct', 0
			db 'Tym', 0
			db 'Uus', 0
			db 'Vas', 0
			db 'Wis', 0
			db 'Xen', 0
			db 'Ylem', 0
			db 'Zu', 0
			db 'Frio', 0
			runeStrings_end:
			
		spellRunes:
			gameSpecificSpellRunes
			spellRunes_end:
			
	endBlockAt off_eop_castByKey_end
endPatch
