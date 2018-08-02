%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"
%include "include/additionalCharacterCodes.asm"
%include "include/bindKeyOrMouse.asm"

[bits 16]

; TODO: read key bindings from a configuration file

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		customize key and mouse bindings
		
	startBlockAt 0x97A7D
		; TODO: find out the difference between interface modes 1 and 16
		;   (is 17 useful, or can it be replaced with 1?)
		
		; movement keys here were redundant; handled in movementKeys.asm
		
		; there wasn't enough space here to bind all of the old commands and new
		;   commands, so I've moved some bindings to eop-moreBindings
			push varArgsEopArg(moreBindings, 0)
			callFromOverlay varArgsEopDispatcher
			add sp, 2
			
		; Ctrl+Alt+Backspace => clear runes
		bindKey 17, C|A| 8, byteArgEopDispatcher, byteArgEopArg(runeKey,  8 )
		
		; Ctrl+Alt+Space => cast runes
		bindKey 17, C|A|' ', tryToCast, 0
		
		; Ctrl+Alt+letter to select each rune
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
		
		; display map
		bindKey 1, 'c', transitionToInterfaceMode, InterfaceMode_MAP
		
		bindKey 1, 'v', closeInventoryContainer, 0
		
		; simulate click on compass
		bindKey 1, 'g', clickCompass, 0
		
		; simulate clicks on health and mana flasks
		bindKey 1, 'h', byteArgEopDispatcher, byteArgEopArg(clickFlasks, 0)
		
		; click areas adjacent to compass to turn (broken in original game)
		bindMouse 1,  66,  33,  84,  49, easyMove, -1  ; Easy-left
		bindMouse 1, 156,  33, 174,  49, easyMove,  1  ; Easy-right
		
		bindKey 1, C|0xA6, easyMove,  0 ; Ctrl+Up    => Easy-walk
		bindKey 1, C|0xAB, easyMove, -2 ; Ctrl+Down  => Easy-back
		bindKey 1, C|0xA8, easyMove, -1 ; Ctrl+Left  => Easy-left
		bindKey 1, C|0xA9, easyMove,  1 ; Ctrl+Right => Easy-right
		
		bindKey 17, 0xA6, adjustPitch,  1 ; Up   => look up
		bindKey 17, 0x90, adjustPitch,  0 ; KP5  => look ahead
		bindKey 17, 0xAB, adjustPitch, -1 ; Down => look down
		
		bindKey 17, H|LShift,   move, 7 ; jump
		bindKey 17, H|C|LShift, move, 6 ; standing long jump
		
		bindKey 17, 0x86, flipCharPanel, 0 ; F7
		bindKey 17, 0x87, tryToCast,     1 ; F8
		bindKey 17, 0x88, track,         2 ; F9
		bindKey 17, 0x89, sleep,         0 ; F10
		
		bindKey 1,  C|'d', handleControlKey, C|'d' ; detail level
		bindKey 1,  C|'f', handleControlKey, C|'f' ; toggle sounds
		bindKey 1,  C|'m', handleControlKey, C|'m' ; toggle music
		bindKey 1,  C|'q', handleControlKey, C|'q' ; quit
		bindKey 1,  C|'r', handleControlKey, C|'r' ; restore
		bindKey 1,  C|'s', handleControlKey, C|'s' ; save
		
		bindKey 1, 0x81, setInteractionMode, 0 ; F2
		bindKey 1, 0x80, setInteractionMode, 1 ; F1
		bindKey 1, 0x84, setInteractionMode, 2 ; F5
		bindKey 1, 0x82, setInteractionMode, 3 ; F3
		bindKey 1, 0x83, setInteractionMode, 4 ; F4
		bindKey 1, 0x85, setInteractionMode, 5 ; F6
		
		; in conversation
		bindKey   4, '1', selectConversationOption, 1
		bindKey   4, '2', selectConversationOption, 2
		bindKey   4, '3', selectConversationOption, 3
		bindKey   4, '4', selectConversationOption, 4
		bindKey   4, '5', selectConversationOption, 5
		bindMouse 4,  70, 135, 116, 188, clickOtherTrade, 4
		bindMouse 4, 119, 135, 163, 188, clickAvatarTrade, 4
		bindMouse 4,  16,   1, 223,  30, selectConversationOption, 0
		
		; on map screen
		%define mapControlEopArg(number) \
				byteArgEopArg(mapControl, MapControl_ %+ number)
		bindKey 2, 's', byteArgEopDispatcher, mapControlEopArg(LEVEL_UP)
		bindKey 2, 'w', byteArgEopDispatcher, mapControlEopArg(LEVEL_DOWN)
		bindKey 2, 'd', byteArgEopDispatcher, mapControlEopArg(REALM_UP)
		bindKey 2, 'a', byteArgEopDispatcher, mapControlEopArg(REALM_DOWN)
		bindKey 2, 'c', byteArgEopDispatcher, mapControlEopArg(AVATAR_LEVEL)
		
		bindKey 27, A|'h',  toggleBool,   dseg_mouseHand
		bindKey 27, A|0x86, printVersion, 0; Alt+F7
		bindKey 27, A|0x87, printDebug,   0; Alt+F8
	endBlockWithFillAt nop, 0x97FEF
endPatch
