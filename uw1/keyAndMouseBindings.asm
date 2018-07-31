%include "../UltimaPatcher.asm"
%include "include/uw1.asm"
%include "include/uw1-eop.asm"
%include "include/additionalCharacterCodes.asm"
%include "include/bindKeyOrMouse.asm"

[bits 16]

%define off_bindsBegin 0x7E9BE
%define off_bindsEnd   0x7EF08

; TODO: read key bindings from a configuration file

; TODO: add mouse-handedness switching, like in UW2

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		customize key and mouse bindings
		
	startBlockAt off_bindsBegin
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
		
		; click arrows below the compass to move
		bindMouse 1, 107,  33, 123,  47, easyMove, -1, ; Easy-left
		bindMouse 1, 130,  31, 146,  44, easyMove,  0, ; Easy-walk
		bindMouse 1, 155,  33, 170,  47, easyMove,  1, ; Easy-right
		
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
		
		bindKey 1, 0x85, activateMode, 0          ; F6
		bindKey 1, 0x84, activateMode, 1          ; F5
		bindKey 1, 0x83, activateMode, 2          ; F4
		bindKey 1, 0x82, activateMode, 3          ; F3
		bindKey 1, 0x81, activateMode, 4          ; F2
		bindKey 1, 0x80, activateMode, 5          ; F1
		
		; in conversation
		bindKey 4, '1', selectConversationOption, 1
		bindKey 4, '2', selectConversationOption, 2
		bindKey 4, '3', selectConversationOption, 3
		bindKey 4, '4', selectConversationOption, 4
		bindKey 4, '5', selectConversationOption, 5
		bindMouse 4,  82, 152, 136, 190, clickOtherTrade,  4
		bindMouse 4, 139, 152, 193, 190, clickAvatarTrade, 4
		bindMouse 4,  15,   1, 305,  30, selectConversationOption, 0
		
		; on map screen
		bindKey 2, 's', byteArgEopDispatcher, \
				byteArgEopArg(mapControl, MapControl_LEVEL_UP)
		bindKey 2, 'w', byteArgEopDispatcher, \
				byteArgEopArg(mapControl, MapControl_LEVEL_DOWN)
		bindKey 2, 'c', byteArgEopDispatcher, \
				byteArgEopArg(mapControl, MapControl_AVATAR_LEVEL)
		
		bindKey 27, A|0x86, printVersion, 0 ; Alt+F7
		bindKey 27, A|0x87, printDebug,   0 ; Alt+F8
		
	endBlockWithFillAt nop, off_bindsEnd
endPatch
