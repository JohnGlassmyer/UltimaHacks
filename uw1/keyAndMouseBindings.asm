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

; TODO: loop over arrays of bindings, calling bindKey / bindMouse for each

; TODO: read key bindings from a configuration file

startPatch EXE_LENGTH, \
		customize key and mouse bindings
		
	startBlockAt addr_bindsBegin
		; TODO: find out the difference between interface modes 1 and 16
		;   (is 17 useful, or can it be replaced with 1?)
		
		; movement keys here were redundant; handled in movementKeys.asm
		
		; there wasn't enough space here to bind all of the old commands and new
		;   commands, so I've moved some bindings to eop-moreBindings
			push varArgsEopArg(moreBindings, 0)
			callFromOverlay varArgsEopDispatcher
			add sp, 2
			
		; Ctrl+Alt+Backspace => clear runes
		bindKey 17, C|A| 8,  byteArgEopDispatcher, byteArgEopArg(runeKey,  8 ) 
		; Ctrl+Alt+Space => cast runes
		bindKey 17, C|A|' ', tryToCast, 1
		
		; Ctrl+Alt+<letter> => select a rune
		mov si, 'a'
		forRuneCharacter:
			mov ax, eopNumber_runeKey
			shl ax, 8
			add ax, si
			mov bx, si
			or bx, C|A
			bindKey 17, bx, byteArgEopDispatcher, ax
			inc si
			cmp si, 'z'
			jle forRuneCharacter
			
		; call eop-attack, which remembers the chosen attack type and then
		;   delegates to the original attack proc
		bindKey 1, ' ', byteArgEopDispatcher, byteArgEopArg(attack, 0) ; auto-attack
		bindKey 1, '.', byteArgEopDispatcher, byteArgEopArg(attack, 3) ; thrust
		bindKey 1, ';', byteArgEopDispatcher, byteArgEopArg(attack, 6) ; slash
		bindKey 1, 'p', byteArgEopDispatcher, byteArgEopArg(attack, 9) ; bash
		
		bindKey 1, 'r', byteArgEopDispatcher, byteArgEopArg(flipToPanel, 1)
		bindKey 1, 'f', byteArgEopDispatcher, byteArgEopArg(flipToPanel, 2)
		
		bindKey 1, '`', byteArgEopDispatcher, byteArgEopArg(toggleMouseLook, 0)
		bindKey 1, 'q', byteArgEopDispatcher, byteArgEopArg(interactAtCursor, 1) ; look
		bindKey 1, 'e', byteArgEopDispatcher, byteArgEopArg(interactAtCursor, 0) ; use
		
		bindKey 1, 'z', transitionToInterfaceMode, InterfaceMode_MAP
		
		bindKey 1, 'c', closeInventoryContainer, 0
		bindKey 1, 'v', scrollInventoryDown, 0
		bindKey 1, 'b', scrollInventoryUp, 0
		
		; simulate click on compass
		bindKey 1, 'g', clickCompass, 0
		
		; simulate clicks on health and mana flasks
		bindKey 1, 'h', byteArgEopDispatcher, byteArgEopArg(clickFlasks, 0)
		
		bindKey 1, C|0xA6, easyMove,  0           ; Ctrl+Up    => Easy-walk
		bindKey 1, C|0xAB, easyMove, -2           ; Ctrl+Down  => Easy-back
		bindKey 1, C|0xA8, easyMove, -1           ; Ctrl+Left  => Easy-left
		bindKey 1, C|0xA9, easyMove,  1           ; Ctrl+Right => Easy-right
		
		bindKey 17, '1'  , adjustPitch,  1        ; 1    => look up
		bindKey 17, 0xA6 , adjustPitch,  1        ; Up   => look up
		bindKey 17, '2'  , adjustPitch,  0        ; 2    => look ahead
		bindKey 17, 0x90 , adjustPitch,  0        ; KP5  => look ahead
		bindKey 17, '3'  , adjustPitch, -1        ; 3    => look down
		bindKey 17, 0xAB , adjustPitch, -1        ; Down => look down
		
		bindKey 17, H|LShift,   move, 7           ; jump
		bindKey 17, H|C|LShift, move, 6           ; standing long jump
		
		bindKey 1, 0x86, flipCharPanel, 0         ; F7
		bindKey 1, 0x87, tryToCast,     1         ; F8
		bindKey 1, 0x88, track,         2         ; F9
		bindKey 1, 0x89, sleep,         0         ; F10
		
		bindKey 1, C|'d', handleControlKey, C|'d' ; detail level
		bindKey 1, C|'f', handleControlKey, C|'f' ; toggle sounds
		bindKey 1, C|'m', handleControlKey, C|'m' ; toggle music
		bindKey 1, C|'q', handleControlKey, C|'q' ; quit
		bindKey 1, C|'r', handleControlKey, C|'r' ; restore
		bindKey 1, C|'s', handleControlKey, C|'s' ; save
		
		; in conversation
		bindKey 4, '1', selectConversationOption, 1
		bindKey 4, '2', selectConversationOption, 2
		bindKey 4, '3', selectConversationOption, 3
		bindKey 4, '4', selectConversationOption, 4
		bindKey 4, '5', selectConversationOption, 5
		
		; on map screen
		bindKey 2, 's', byteArgEopDispatcher, \
				byteArgEopArg(mapControl, MapControl_LEVEL_UP)
		bindKey 2, 'w', byteArgEopDispatcher, \
				byteArgEopArg(mapControl, MapControl_LEVEL_DOWN)
		bindKey 2, 'c', byteArgEopDispatcher, \
				byteArgEopArg(mapControl, MapControl_AVATAR_LEVEL)
		
		bindKey 27, A|0x86, printVersion, 0 ; Alt+F7
		bindKey 27, A|0x87, printDebug,   0 ; Alt+F8
		
		bindKey 7, H|0xA3, moveCursor, H|0xA3 ; Shift+Tab
		bindKey 7,      9, moveCursor,      9 ; Tab
		bindKey 7,   0x8C, moveCursor,   0x8C ; (numeric keypad)
		bindKey 7,   0x8D, moveCursor,   0x8D ; (numeric keypad)
		bindKey 7,   0x8E, moveCursor,   0x8E ; (numeric keypad)
		bindKey 7,   0x8F, moveCursor,   0x8F ; (numeric keypad)
		bindKey 7,   0x91, moveCursor,   0x91 ; (numeric keypad)
		bindKey 7,   0x92, moveCursor,   0x92 ; (numeric keypad)
		bindKey 7,   0x93, moveCursor,   0x93 ; (numeric keypad)
		bindKey 7,   0x94, moveCursor,   0x94 ; (numeric keypad)
		bindKey 7,   0x95, moveCursor,   0x95 ; (numeric keypad)
		bindKey 7,   0x96, moveCursor,   0x96 ; (numeric keypad)
		
	endBlockWithFillAt nop, off_bindsEnd
endPatch
