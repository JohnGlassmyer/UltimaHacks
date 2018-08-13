%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

off_keyMappingCode                  EQU 0x07EB
off_keyMappingCode_end              EQU off_keyMappingCode + 199
off_toggleCheats                    EQU off_keyMappingCode_end
off_toggleCheats_end                EQU off_toggleCheats + 16
off_cheatMappingTable               EQU off_toggleCheats_end
off_cheatMappingTable_end           EQU 0x0924

off_mouseMove                       EQU 0x0924
off_mouseName                       EQU 0x0941
off_mouseAutoroute                  EQU 0x0949
off_mouseUse                        EQU 0x09DD
off_exit                            EQU 0x09ED
off_combat                          EQU 0x09FD
off_save                            EQU 0x0A27
off_audio                           EQU 0x0A34
off_inventory                       EQU 0x0A5E
off_stats                           EQU 0x0A72
off_version                         EQU 0x0A7F
off_handedness                      EQU 0x0A86

off_cheatsBlock                     EQU 0x0ADB
off_cheat_f1                        EQU 0x0AE5
off_cheat_f2                        EQU 0x0AF6
off_cheat_f3                        EQU 0x0B17
off_cheat_f4                        EQU 0x0B29
off_cheat_f5                        EQU 0x0B50
off_cheat_f7                        EQU 0x0B62
off_cheat_f8                        EQU 0x0B7C
off_cheat_f9                        EQU 0x0B8E
off_cheat_alt1                      EQU 0x0D04
off_cheat_alt2                      EQU 0x0D16
off_cheat_alt3                      EQU 0x0D35
off_cheat_alt4                      EQU 0x0DA1
off_cheat_alt5                      EQU 0x0DA9
off_cheat_w                         EQU 0x0DBB
off_cheat_f                         EQU 0x0DD1
off_cheat_o                         EQU 0x0DE7
off_cheat_d                         EQU 0x0DFD
off_cheatsBlock_end                 EQU 0x0E1A

off_directionKeys                   EQU 0x0E1A
off_numberKeys                      EQU 0x0E29

off_afterKeyHandlers                EQU 0x0E42
off_endOfFunction                   EQU 0x0ED5

off_actionMappingTable              EQU 0x0EDB
off_actionMappingTable_end          EQU 0x0F77

;-----------------------------------------------------------
;-----------------------------------------------------------

%define mapAction(keyCode, off_handler) dw keyCode, off_handler

responsiveAvatarActionMappingCount \
	EQU (responsiveAvatarActionMappingEnd - actionMappingStart) / 4
unresponsiveAvatarActionMappingCount \
	EQU (unresponsiveAvatarActionMappingEnd - actionMappingStart) / 4

cheatMappingCount EQU (cheatMappingEnd - cheatMappingStart) / 4

;-----------------------------------------------------------
;-----------------------------------------------------------

startPatch EXE_LENGTH, \
		no-dialogs key handling code - now calls eop-Keyactions for many things
		
	off_callTranslateKeyBeforeProcessKey     EQU 0x0F9F
	off_callTranslateKeyBeforeProcessKey_end EQU 0x0FB3
	startBlockAt 31, off_callTranslateKeyBeforeProcessKey
		; don't translate key here, so that eop-keyActions
		; can process keys even when a mouse button is held
	endBlockWithFillAt nop, off_callTranslateKeyBeforeProcessKey_end
	
	off_translateKey_pollkey     EQU 0x0177
	off_translateKey_pollkey_end EQU 0x0191
	startBlockAt 56, off_translateKey_pollkey
		; don't try to poll a key code in translateKey;
		; instead, use the key code now passed from processKey (below)
		mov bx, [bp+0xA]
		xor ax, ax
		mov [bx], ax
		mov [di], ax
	endBlockWithFillAt nop, off_translateKey_pollkey_end
	
	startBlockAt 31, off_keyMappingCode
		%assign arg_mouseY                      0x0A
		%assign arg_mouseX                      0x08
		%assign arg_keyCode                     0x06
		%assign var_keyActionsReturnValue      -0x02
		
		push 1
		callFromLoadModule pollKey
		pop cx
		mov [bp+arg_keyCode], ax
		
		push dseg_avatarIbo
		callFromLoadModule isNpcUnconscious
		pop cx
		or al, al
		jnz avatarUnresponsive
		
		avatarResponsive:
			cmp byte [di], 0
			jnz calcJump(off_afterKeyHandlers)
			
			push word [bp+arg_keyCode]
			callEopFromLoadModule 1, keyActions
			pop cx
			mov [bp+var_keyActionsReturnValue], ax
			
			lea ax, [bp+arg_mouseY]
			push ax
			lea ax, [bp+arg_mouseX]
			push ax
			lea ax, [bp+arg_keyCode]
			push ax
			callFromLoadModule translateKeyWithoutDialogs
			add sp, 6
			
			mov bx, [bp+arg_keyCode]
			
			; skip handling any "key" other than a translated mouse button
			; if eop-keyActions has already handled the untranslated key
				cmp bx, 0x200
				jae notSkipKey
				cmp word [bp+var_keyActionsReturnValue], 0
				jz notSkipKey
				jmp calcJump(off_afterKeyHandlers)
				
			notSkipKey:
			
			cmp bx, '1'
			jb notTranslatedNumberKey
			cmp bx, '9'
			ja notTranslatedNumberKey
			jmp calcJump(off_numberKeys)
			notTranslatedNumberKey:
			
			cmp bx, 0x147
			jb notDirectionKey
			cmp bx, 0x151
			ja notDirectionKey
			jmp calcJump(off_directionKeys)
			notDirectionKey:
			
			mov cx, responsiveAvatarActionMappingCount
			
			jmp tryKeyMappings
			
		avatarUnresponsive:
			mov byte [di], 0
			
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
			
			cmp word [dseg_cheatsEnabled], 0
			jz afterCheats
			mov cx, cheatMappingCount
			mov bx, off_cheatMappingTable
			tryCheatMapping:
			mov ax, [cs:bx]
			cmp ax, [bp+arg_keyCode]
			jnz notThisCheatMapping
			jmp [cs:bx+2]
			notThisCheatMapping:
			add bx, 4
			loop tryCheatMapping
			afterCheats:
			
		afterTryingMappings:
		
		jmp calcJump(off_afterKeyHandlers)
	endBlockAt off_keyMappingCode_end
	
	startBlockAt 31, off_toggleCheats
		callEopFromLoadModule 0, toggleCheats
		jmp calcJump(off_afterKeyHandlers)
	endBlockAt off_toggleCheats_end
	
	startBlockAt 31, off_cheatMappingTable
		cheatMappingStart:
		
		mapAction(0x13B, off_cheat_f1)          ; F1
		mapAction(0x13C, off_cheat_f2)          ; F2
		mapAction(0x13D, off_cheat_f3)          ; F3
		mapAction(0x13E, off_cheat_f4)          ; F4
		mapAction(0x13F, off_cheat_f5)          ; F5
		mapAction(0x141, off_cheat_f7)          ; F7
		mapAction(0x142, off_cheat_f8)          ; F8
		mapAction(0x143, off_cheat_f9)          ; F9
		
		; Alt+digit cheats moved to Alt+Fn
		; as Alt+digit now opens party member Stats
		mapAction(0x168, off_cheat_alt1)        ; Alt+F1
		mapAction(0x169, off_cheat_alt2)        ; Alt+F2
		mapAction(0x16A, off_cheat_alt3)        ; Alt+F3
		mapAction(0x16B, off_cheat_alt4)        ; Alt+F4
		mapAction(0x16C, off_cheat_alt5)        ; Alt+F5
		
		; Disabled because I'm not sure what these are supposed to do
		; or whether they work, and they conflict with key-mappings
		; that I use to do other things.
		;mapAction(  'w', off_cheat_w)
		;mapAction(  'f', off_cheat_f)
		;mapAction(  'o', off_cheat_o)
		;mapAction(  'd', off_cheat_d)
		
		cheatMappingEnd:
		
		times 35 nop
		
	endBlockAt off_cheatMappingTable_end
	
	;-----------------------------------------------------------
	;-----------------------------------------------------------
	
	startBlockAt 31, off_actionMappingTable
		actionMappingStart:
		
		; mappings which may be used by a conscious or unconscious Avatar
		mapAction(0x203, off_mouseUse)          ; left button double
		mapAction(0x12B, off_toggleCheats)      ; Alt+Backslash
		
		; (many actions are now handled by eop-keyActions instead,
		;   so that they are also available in dialog mode)
		
		unresponsiveAvatarActionMappingEnd:
		
		; mappings which may only be used by a conscious Avatar
		mapAction(0x201, off_mouseName)         ; left button
		mapAction(0x205, off_mouseName)         ; left button held
		mapAction(0x202, off_mouseMove)         ; right button
		mapAction(0x206, off_mouseMove)         ; right button held
		mapAction(0x204, off_mouseAutoroute)    ; right button double
		
		responsiveAvatarActionMappingEnd:
		
		times 128 nop
	endBlockAt off_actionMappingTable_end
endPatch
