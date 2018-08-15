%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	%include "include/uw1-eop.asm"
	%include "include/additionalCharacterCodes.asm"
	%include "include/bindKeyOrMouse.asm"
	
	defineAddress 134, 0x018E, bindsBegin
	defineAddress 134, 0x06D8, bindsEnd
%endif
	
[bits 16]

; TODO: read key bindings from a configuration file

startPatch EXE_LENGTH, \
		customize key and mouse bindings
		
	startBlockAt addr_bindsBegin
		; TODO: find out the difference between interface modes 1 and 16
		;   (is 17 useful, or can it be replaced with 1?)
		
		; movement keys here were redundant; handled in movementKeys.asm
		
		; call eop to set-up game-specific (UW1 or UW2) bindings
			push varArgsEopArg(moreBindings, 0)
			callFromOverlay varArgsEopDispatcher
			add sp, 2
			
		mov di, offsetInCodeSegment(keyBindings)
		forKeyBinding:
			cmp di, offsetInCodeSegment(keyBindings_end)
			jae keyBindings_end
			
			push cs
			pop es
			
			bindDKeyAt es:di
			
			add di, dKey_SIZE
			jmp forKeyBinding
			
		keyBindings:
			; Ctrl+Alt+<letter> => select a rune
			%assign rune 'a'
			%rep 26
				dKey 17, C|A|rune, byteArgEopDispatcher, byteArgEopArg(runeKey, rune)
				%assign rune rune + 1
			%endrep
			
			; Ctrl+Alt+Backspace => clear runes
			dKey 17, C|A| 8,  byteArgEopDispatcher, byteArgEopArg(runeKey, 8) 
			; Ctrl+Alt+Space => cast runes
			dKey 17, C|A|' ', tryToCast, 1
			
			; call eop-attack, which remembers the chosen attack type and then
			;   delegates to the original attack proc
			dKey 1, ' ', byteArgEopDispatcher, byteArgEopArg(attack, 0) ; auto-attack
			dKey 1, '.', byteArgEopDispatcher, byteArgEopArg(attack, 3) ; thrust
			dKey 1, ';', byteArgEopDispatcher, byteArgEopArg(attack, 6) ; slash
			dKey 1, 'p', byteArgEopDispatcher, byteArgEopArg(attack, 9) ; bash
			
			dKey 1, 'r', byteArgEopDispatcher, byteArgEopArg(flipToPanel, 1)
			dKey 1, 'f', byteArgEopDispatcher, byteArgEopArg(flipToPanel, 2)
			
			dKey 1, '`', byteArgEopDispatcher, byteArgEopArg(toggleMouseLook, 0)
			dKey 1, 'q', byteArgEopDispatcher, byteArgEopArg(interactAtCursor, 1) ; look
			dKey 1, 'e', byteArgEopDispatcher, byteArgEopArg(interactAtCursor, 0) ; use
			
			dKey 1, 'z', transitionToInterfaceMode, InterfaceMode_MAP
			
			dKey 1, 'c', closeInventoryContainer, 0
			dKey 1, 'v', scrollInventoryDown, 0
			dKey 1, 'b', scrollInventoryUp, 0
			
			; simulate click on compass
			dKey 1, 'g', clickCompass, 0
			
			; simulate clicks on health and mana flasks
			dKey 1, 'h', byteArgEopDispatcher, byteArgEopArg(clickFlasks, 0)
			
			dKey 1, C|0xA6, easyMove,  0           ; Ctrl+Up    => Easy-walk
			dKey 1, C|0xAB, easyMove, -2           ; Ctrl+Down  => Easy-back
			dKey 1, C|0xA8, easyMove, -1           ; Ctrl+Left  => Easy-left
			dKey 1, C|0xA9, easyMove,  1           ; Ctrl+Right => Easy-right
			
			dKey 17, '1'  , adjustPitch,  1        ; 1    => look up
			dKey 17, 0xA6 , adjustPitch,  1        ; Up   => look up
			dKey 17, '2'  , adjustPitch,  0        ; 2    => look ahead
			dKey 17, 0x90 , adjustPitch,  0        ; KP5  => look ahead
			dKey 17, '3'  , adjustPitch, -1        ; 3    => look down
			dKey 17, 0xAB , adjustPitch, -1        ; Down => look down
			
			dKey 17, H|LShift,   move, 7           ; jump
			dKey 17, H|C|LShift, move, 6           ; standing long jump
			
			dKey 1, 0x86, flipCharPanel, 0         ; F7
			dKey 1, 0x87, tryToCast,     1         ; F8
			dKey 1, 0x88, track,         2         ; F9
			dKey 1, 0x89, sleep,         0         ; F10
			
			dKey 1, C|'d', handleControlKey, C|'d' ; detail level
			dKey 1, C|'f', handleControlKey, C|'f' ; toggle sounds
			dKey 1, C|'m', handleControlKey, C|'m' ; toggle music
			dKey 1, C|'q', handleControlKey, C|'q' ; quit
			dKey 1, C|'r', handleControlKey, C|'r' ; restore
			dKey 1, C|'s', handleControlKey, C|'s' ; save
			
			; in conversation
			dKey 4, '1', selectConversationOption, 1
			dKey 4, '2', selectConversationOption, 2
			dKey 4, '3', selectConversationOption, 3
			dKey 4, '4', selectConversationOption, 4
			dKey 4, '5', selectConversationOption, 5
			
			; on map screen
			dKey 2, 's', byteArgEopDispatcher, byteArgEopArg(mapControl, MapControl_LEVEL_UP)
			dKey 2, 'w', byteArgEopDispatcher, byteArgEopArg(mapControl, MapControl_LEVEL_DOWN)
			dKey 2, 'c', byteArgEopDispatcher, byteArgEopArg(mapControl, MapControl_AVATAR_LEVEL)
			
			dKey 7, H|0xA3, moveCursor, H|0xA3 ; Shift+Tab
			dKey 7,      9, moveCursor,      9 ; Tab
			dKey 7,   0x8C, moveCursor,   0x8C ; (numeric keypad)
			dKey 7,   0x8D, moveCursor,   0x8D ; (numeric keypad)
			dKey 7,   0x8E, moveCursor,   0x8E ; (numeric keypad)
			dKey 7,   0x8F, moveCursor,   0x8F ; (numeric keypad)
			dKey 7,   0x91, moveCursor,   0x91 ; (numeric keypad)
			dKey 7,   0x92, moveCursor,   0x92 ; (numeric keypad)
			dKey 7,   0x93, moveCursor,   0x93 ; (numeric keypad)
			dKey 7,   0x94, moveCursor,   0x94 ; (numeric keypad)
			dKey 7,   0x95, moveCursor,   0x95 ; (numeric keypad)
			dKey 7,   0x96, moveCursor,   0x96 ; (numeric keypad)
			
			dKey 27, A|0x86, printVersion,    0 ; Alt+F7
			dKey 27, A|0x87, printDebug,      0 ; Alt+F8
		keyBindings_end:
		
		; bytes reclaimed from the oblivion of inefficiency
		times 428 nop
		
	endBlockWithFillAt nop, off_bindsEnd
endPatch
