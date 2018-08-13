%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

TIME_FOR_CASTING                        EQU 130

START_CASTING_KEY                       EQU '/'
REMOVE_LAST_RUNE_KEY                    EQU 8   ; Backspace
EXECUTE_CASTING_KEY                     EQU 13  ; Enter
CANCEL_CASTING_KEY                      EQU 27  ; Escape

NUMBER_OF_SPELLS                        EQU 72

NO_SPELL_TO_CAST_SOUND                  EQU 69  ; fizzle/bad casting sound
START_CASTING_SOUND                     EQU 14  ; open spellbook sound
ADD_RUNE_SOUND                          EQU 15
REMOVE_RUNE_SOUND                       EQU 92
CAN_NOT_CAST_SOUND                      EQU 76  ; "no can do" sound

dseg_castByKeyDataAddress               EQU 4

; offsets into castByKey data
CAST_BY_KEY_DATA_SIZE                   EQU 20
cbk_runeLetters                         EQU  8
cbk_runeCount                           EQU  6
cbk_castingDeadline                     EQU  2
cbk_castingInProgress                   EQU  0

; Enable the player to select and cast a spell by typing its runes
; in real-time gameplay, without going through a spellbook dialog.
;
; Inspired by the ability to cast a spell by typing its runes
; (though not in real time) in Ultima VI.
startPatch EXE_LENGTH, \
		eop-castByKey
		
	; taking 4 bytes occupied by Borland copyright text
	; to store pointer to persistent heap-allocated castByKey data
	startBlockAt seg_dseg, dseg_castByKeyDataAddress
		dd 0
	endBlock
	
	startBlockAt seg_eop, off_eop_castByKey
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_keyCode             0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_keyConsumed        -0x02
		%assign var_spellbookList      -0x04
		%assign var_spellbookListNode  -0x06
		%assign var_spellNumber        -0x08
		%assign var_currentTime        -0x0C
		%assign var_statusString       -0x50
		%assign var_runesCopy          -0x60
		%assign var_spellCopy          -0x70
		add sp, var_spellCopy
		
		push esi
		push edi
		
		; assume that we have not used the pressed key
		mov word [bp+var_keyConsumed], 0
		
		; save the current time, for consistency's sake
		mov eax, [dseg_timeLow]
		mov [bp+var_currentTime], eax
		
		; load address of previously allocated castByKey memory
			mov esi, [dseg_castByKeyDataAddress]
			test esi, esi
			jnz haveDataAddress
			
		; memory not previously allocated;
		; allocate memory and save the address for future calls
			push word 0
			push word CAST_BY_KEY_DATA_SIZE
			push dseg_voodooAllocationThing
			callFromOverlay allocateVoodooMemory
			add sp, 6
			
			movzx esi, dx
			shl esi, 16
			movzx eax, ax
			add esi, eax
			
			test esi, esi
			jz afterPrintingStatus
			mov [dseg_castByKeyDataAddress], esi
			
		; initialize the allocated memory
			mov byte [esi+cbk_castingInProgress], 0
			
		haveDataAddress:
		; is a casting in progress?
			cmp byte [esi+cbk_castingInProgress], 0
			jz noCastingInProgress
			
		; if the deadline has been passed,
		; try to cast with whatever runes have been entered
			mov eax, [esi+cbk_castingDeadline]
			cmp [bp+var_currentTime], eax
			jae executeCasting
			jmp stillCasting
			
		noCastingInProgress:
			cmp word [bp+arg_keyCode], START_CASTING_KEY
			jz startCasting
			jmp afterProcessingKey
			
		startCasting:
			mov word [bp+var_keyConsumed], 1
			
			; require possession of a spellbook to start casting
			push 0xFF ; frame
			push 0xFF ; quality
			push 761  ; spellbook
			callEopFromOverlay 3, findPartyItem
			add sp, 6
			test ax, ax
			jz canNotCast
			
			mov word [esi+cbk_runeCount], 0
			mov dword [esi+cbk_runeLetters+0], 0
			mov dword [esi+cbk_runeLetters+4], 0
			mov byte [esi+cbk_castingInProgress], 1
			
			push word START_CASTING_SOUND
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
			cmp ax, 'a'
			jb afterProcessingKey
			cmp ax, 'z'
			ja afterProcessingKey
			
			; a rune key was pressed
			mov word [bp+var_keyConsumed], 1
			
			; don't accept a 9th rune
			cmp word [esi+cbk_runeCount], 8
			jae noSpellToCast
			
			; store the new rune in the array of accumulated runes
			movzx ebx, word [esi+cbk_runeCount]
			mov byte [esi+cbk_runeLetters+ebx], al
			inc word [esi+cbk_runeCount]
			
			push word ADD_RUNE_SOUND
			callFromOverlay playSoundSimple
			pop cx
			
			jmp afterProcessingKey
			
		removeLastRune:
			mov word [bp+var_keyConsumed], 1
			cmp word [esi+cbk_runeCount], 0
			jz noRunesToRemove
			
			dec word [esi+cbk_runeCount]
			movzx ebx, word [esi+cbk_runeCount]
			mov byte [esi+cbk_runeLetters+ebx], 0
			
			push word REMOVE_RUNE_SOUND
			callFromOverlay playSoundSimple
			pop cx
			
			noRunesToRemove:
			jmp afterProcessingKey
			
		executeCasting:
			mov word [bp+var_keyConsumed], 1
			
			; don't try to find a zero-length spell
			cmp word [esi+cbk_runeCount], 0
			jz noSpellToCast
			
			; try to find a spell matching the selected runes
			mov word [bp+var_spellNumber], 0
			mov di, offsetInEopSegment(spellRunes)
			forSpell:
				; copy the spell runes into the stack
				mov eax, [cs:di+0]
				mov [bp+var_spellCopy+0], eax
				mov eax, [cs:di+4]
				mov [bp+var_spellCopy+4], eax
				mov byte [bp+var_spellCopy+8], 0
				
				; copy the selected runes onto the stack
				mov eax, [esi+cbk_runeLetters+0]
				mov [bp+var_runesCopy+0], eax
				mov eax, [esi+cbk_runeLetters+4]
				mov [bp+var_runesCopy+4], eax
				mov byte [bp+var_runesCopy+8], 0
				
				; do the runes match?
				lea ax, [bp+var_spellCopy]
				push ax
				lea ax, [bp+var_runesCopy]
				push ax
				callFromOverlay strcmp
				add sp, 4
				cmp ax, 0
				jz runesMatchedSpell
				
				; have we run out of spells to try?
				inc word [bp+var_spellNumber]
				cmp word [bp+var_spellNumber], NUMBER_OF_SPELLS
				jae noSpellToCast
				
				; advance to the next spell's string of runes
				forNotZero:
				inc di
				cmp byte [cs:di], 0
				jnz forNotZero
				inc di
				
				jmp forSpell
				
		runesMatchedSpell:
		; now try to find a spellbook having the matched spell
			push 0xFF ; frame
			push 0xFF ; quality
			push 761  ; spellbook
			callEopFromOverlay 3, findAllPartyItems
			add sp, 6
			
			cmp ax, 0
			jz noSpellToCast
			mov [bp+var_spellbookList], ax
			
			; set di = 1 if spell found in a spellbook
			mov di, 0
			mov word [bp+var_spellbookListNode], 0
			forSpellbookInList:
				lea ax, [bp+var_spellbookListNode]
				push ax
				push word [bp+var_spellbookList]
				callFromOverlay list_stepForward
				add sp, 4
				
				test ax, ax
				jz doneCheckingSpellbooks
				
				; payload of list node is ibo of a found spellbook
				mov bx, [bp+var_spellbookListNode]
				push word [bp+var_spellNumber]
				lea ax, [bx+ListNode_payload]
				push ax
				callFromOverlay doesSpellbookHaveSpell
				add sp, 4
				
				test ax, ax
				jz forSpellbookInList
				
				mov di, 1
				
			doneCheckingSpellbooks:
			; list was allocated on heap; needs to be freed
			push word [bp+var_spellbookList]
			callFromOverlay list_removeAndDestroyAll
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
				
			; try to cast the spell (checks mana and reagents)
				mov ax, 1
				push ax
				push ax
				push ax
				push word [bp+var_spellNumber]
				push dseg_avatarIbo
				callFromOverlay tryToCastSpell
				add sp, 10
				
			; close dialogs so that the casting can be performed
				mov byte [dseg_dialogState], 6
				
			mov byte [esi+cbk_castingInProgress], 0
			jmp afterProcessingKey
			
		noSpellToCast:
			mov byte [esi+cbk_castingInProgress], 0
			
			push word NO_SPELL_TO_CAST_SOUND
			callFromOverlay playSoundSimple
			pop cx
			
			jmp afterProcessingKey
			
		canNotCast:
			mov byte [esi+cbk_castingInProgress], 0
			
			push word CAN_NOT_CAST_SOUND
			callFromOverlay playSoundSimple
			pop cx
			
			jmp afterProcessingKey
			
		afterProcessingKey:
			cmp byte [esi+cbk_castingInProgress], 0
			jz afterPrintingStatus
			
			; select the string template for the number of accumulated runes
			mov ax, word [esi+cbk_runeCount]
			test ax, ax
			jnz createStatusStringWithRunes
			
			; create status string without runes: '(casting)'
				mov dword [bp+var_statusString+0], '(cas'
				mov dword [bp+var_statusString+4], 'ting'
				mov byte  [bp+var_statusString+8], ')'
				mov byte  [bp+var_statusString+9], 0
				jmp haveStatusString
				
			createStatusStringWithRunes:
			; e.g. '"An Bet Corp..."'
				; string starts with an open-quote
				; and must be terminated for strcat to work.
				mov byte [bp+var_statusString+0], '"'
				mov byte [bp+var_statusString+1], 0
				xor edi, edi
				forRuneStringInSpell:
					; find the rune's string (in the code segment)
					mov bx, offsetInEopSegment(runeStrings)
					mov al, 'a'
					forRuneString:
						cmp al, [esi+cbk_runeLetters+edi]
						jz haveRuneString
						
						; find the start of the next rune string
						forLetterInRuneString:
							cmp byte [cs:bx], 0
							jz foundEndOfRuneString
							inc bx
							jmp forLetterInRuneString
						foundEndOfRuneString:
						inc bx
						
						inc al
						jmp forRuneString
						
					haveRuneString:
					; copy the rune string to the stack
						mov eax, [cs:bx+0]
						mov [bp+var_runesCopy+0], eax
						mov eax, [cs:bx+4]
						mov [bp+var_runesCopy+4], eax
						
					; append the rune string to the status string
						lea ax, [bp+var_runesCopy]
						push ax
						lea ax, [bp+var_statusString]
						push ax
						callFromOverlay strcat
						add sp, 4
						
					; find the end of the accumulated string
						push 0
						lea ax, [bp+var_statusString]
						push ax
						callFromOverlay strchr
						add sp, 4
						mov bx, ax
						
					inc di
					cmp di, [esi+cbk_runeCount]
					jz lastRune
					
					; append a space before the following rune
						mov byte [bx+0], ' '
						mov byte [bx+1], 0
						jmp forRuneStringInSpell
						
					lastRune:
					; append an ellipsis and close-quote after the last rune
						mov dword [bx+0], '..."'
						mov byte  [bx+4], 0
						jmp haveStatusString
						
		haveStatusString:
		; finally, print the text over the Avatar
			push word 0
			push word 1 ; short duration so the text can be changed quickly
			push word 5
			lea ax, [bp+var_statusString]
			push ax
			push word [dseg_avatarIbo]
			push dseg_graphicsThing
			callFromOverlay barkOnItemInWorld
			add sp, 12
			
		afterPrintingStatus:
			; extend deadline if a keypress has contributed to a casting
			cmp byte [esi+cbk_castingInProgress], 0
			jz afterSettingDeadline
			cmp word [bp+var_keyConsumed], 0
			jz afterSettingDeadline
			
			mov eax, [bp+var_currentTime]
			add eax, TIME_FOR_CASTING
			mov [esi+cbk_castingDeadline], eax
			
			afterSettingDeadline:
			mov ax, word [bp+var_keyConsumed]
			
		pop edi
		pop esi
		mov sp, bp
		pop bp
		retn
		
		nextStringInCs:
			%assign arg_stringOffsetInCs    0x04
			%assign ____callerIp            0x02
			%assign ____callerBp            0x00
			mov bx, [bp+arg_stringOffsetInCs]
			forByte:
				mov al, byte [cs:bx]
				cmp al, 0
				jz foundEndOfString;
				inc bx
				jmp forByte
				
			foundEndOfString:
			inc bx
			mov ax, bx
			
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
			
		; these don't seem to be stored in the original game anywhere.
		; for shame!
		spellRunes:
			db 'az', 0
			db 'rh', 0
			db 'af', 0
			db 'bo', 0
			db 'bl', 0
			db 'kl', 0
			db 'if', 0
			db 'vk', 0
			db 'imy', 0
			db 'an', 0
			db 'wj', 0
			db 'vaf', 0
			db 'vif', 0
			db 'il', 0
			db 'iw', 0
			db 'vaz', 0
			db 'aj', 0
			db 'oy', 0
			db 'vf', 0
			db 'vl', 0
			db 'van', 0
			db 'us', 0
			db 'opy', 0
			db 'pow', 0
			db 'ds', 0
			db 'm', 0
			db 'kbx', 0
			db 'vus', 0
			db 'ap', 0
			db 'vw', 0
			db 'in', 0
			db 'iz', 0
			db 'kx', 0
			db 'og', 0
			db 'kpy', 0
			db 'vds', 0
			db 'kop', 0
			db 'wq', 0
			db 'kwc', 0
			db 'ep', 0
			db 'axe', 0
			db 'px', 0
			db 'ag', 0
			db 'vfh', 0
			db 'vm', 0
			db 'sl', 0
			db 'ifg', 0
			db 'vz', 0
			db 'qw', 0
			db 'iqx', 0
			db 'kfg', 0
			db 'vifg', 0
			db 'voh', 0
			db 'ing', 0
			db 'izg', 0
			db 'vpy', 0
			db 'ry', 0
			db 'cp', 0
			db 'tvf', 0
			db 'isg', 0
			db 'ihgy', 0
			db 'vaxe', 0
			db 'ivp', 0
			db 'vm', 0
			; only spell with more than 4 runes.
			; otherwise, would have scanned an array of dwords.
			db 'vkamicht', 0
			db 'vch', 0
			db 'vc', 0
			db 'vsl', 0
			db 'imc', 0
			db 'kvx', 0
			db 'ijpy', 0
			db 'at', 0
			
	endBlockAt off_eop_castByKey_end
endPatch
