%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"
%include "include/additionalCharacterCodes.asm"
%include "include/bindKeyOrMouse.asm"

[bits 16]

%define bo_controlKey   0x0078, 0x018B
%define bo_attack       0x00D0, 0x134B
%define bo_activateMode 0x00E0, 0x112A
%define bo_move         0x0128, 0x0056
%define bo_easyMove     0x0128, 0x0350
%define bo_byteArgEop   0x02E8, 0x0066
%define bo_otherTrade   0x0308, 0x007A
%define bo_avatarTrade  0x0308, 0x008E
%define bo_selectOption 0x0338, 0x007A
%define bo_castRunes    0x03D8, 0x0020
%define bo_clickCompass 0x0448, 0x0020
%define bo_clickFlasks  0x0448, 0x002A
%define bo_charPanel    0x0448, 0x0043
%define bo_adjustPitch  0x0478, 0x004D
%define bo_printVersion 0x0478, 0x005C
%define bo_printDebug   0x0478, 0x0061
%define bo_sleep        0x04D0, 0x0093
%define bo_track        0x04D0, 0x009D
%define bo_toggleBool   0x0538, 0x0052

; TODO: read key bindings from a configuration file

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		customize key and mouse bindings
		
	startBlockAt 0x97A7D
		; TODO: find out the difference between interface contexts 1 and 16
		;   (is 17 useful, or can it be replaced with 1?)
		
		; movement keys here were redundant; handled in movementKeys.asm
		
		; there wasn't enough space here to bind all of the old commands and new
		;   commands, so I've moved some bindings to eop-moreBindings
			push varArgsEopArg(moreBindings, 0)
			callWithRelocation o_varArgsEopDispatcher
			add sp, 2
			
		; Ctrl+Alt+Backspace => clear runes
		bindKey bo_byteArgEop, 17, byteArgEopArg(runeKey,  8 ), C|A| 8
		
		; Ctrl+Alt+Space and Ctrl+Space => cast runes 
		; (equivalent to F8, but more convenient)
		bindKey bo_byteArgEop, 17, byteArgEopArg(runeKey, ' '), C|A|' '
		bindKey bo_byteArgEop, 17, byteArgEopArg(runeKey, ' '), C|' '
		
		; Ctrl+Alt+letter to select each rune
		mov si, 'a'
		forRuneCharacter:
			mov ax, eopNumber_runeKey
			shl ax, 8
			add ax, si
			mov bx, si
			or bx, C|A
			bindKey bo_byteArgEop, 17, ax, bx
			inc si
			cmp si, 'z'
			jle forRuneCharacter
			
		; call eop-attack, which remembers the chosen attack type and then
		;   delegates to the original attack proc
		bindKey bo_byteArgEop, 1, byteArgEopArg(attack, 0), ' ' ; auto-attack
		bindKey bo_byteArgEop, 1, byteArgEopArg(attack, 3), '.' ; thrust
		bindKey bo_byteArgEop, 1, byteArgEopArg(attack, 6), ';' ; slash
		bindKey bo_byteArgEop, 1, byteArgEopArg(attack, 9), 'p' ; bash
		
		bindKey bo_byteArgEop, 1, byteArgEopArg(flipToPanel, 1), 'r'
		bindKey bo_byteArgEop, 1, byteArgEopArg(flipToPanel, 2), 'f'
		
		bindKey bo_byteArgEop, 1, byteArgEopArg(toggleMouseLook, 0),  '`'
		bindKey bo_byteArgEop, 1, byteArgEopArg(interactAtCursor, 1), 'q' ; look
		bindKey bo_byteArgEop, 1, byteArgEopArg(interactAtCursor, 0), 'e' ; use
		bindKey bo_byteArgEop, 1, byteArgEopArg(displayMap, 0),       'c'
		bindKey bo_byteArgEop, 1, byteArgEopArg(closeContainer, 0),   'v'
		
		; simulate click on compass
		bindKey bo_clickCompass, 1, 0, 'g'
		
		; simulate clicks on health and mana flasks
		bindKey bo_byteArgEop, 1, byteArgEopArg(clickFlasks, 0), 'h'
		
		; click areas adjacent to compass to turn (broken in original game)
		bindMouse bo_easyMove, 1, -1,  66,  33,  84,  49 ; Easy-left
		bindMouse bo_easyMove, 1,  1, 156,  33, 174,  49 ; Easy-right
		
		bindKey bo_easyMove,      1,      0, C|0xA6 ; Ctrl+Up    => Easy-walk
		bindKey bo_easyMove,      1,     -2, C|0xAB ; Ctrl+Down  => Easy-back
		bindKey bo_easyMove,      1,     -1, C|0xA8 ; Ctrl+Left  => Easy-left
		bindKey bo_easyMove,      1,      1, C|0xA9 ; Ctrl+Right => Easy-right
		
		bindKey bo_adjustPitch,  17,      1,   0xA6 ; Up   => look up
		bindKey bo_adjustPitch,  17,      0,   0x90 ; KP5  => look ahead
		bindKey bo_adjustPitch,  17,     -1,   0xAB ; Down => look down
		
		bindKey bo_move,         17,      7, H|LShift   ; jump
		bindKey bo_move,         17,      6, H|C|LShift ; standing long jump
		
		bindKey bo_charPanel,    17,      0,   0x86 ; F7
		bindKey bo_castRunes,    17,      1,   0x87 ; F8
		bindKey bo_track,        17,      2,   0x88 ; F9
		bindKey bo_sleep,        17,      0,   0x89 ; F10
		
		bindKey bo_controlKey,    1,  C|'d',  C|'d' ; detail level
		bindKey bo_controlKey,    1,  C|'f',  C|'f' ; toggle sounds
		bindKey bo_controlKey,    1,  C|'m',  C|'m' ; toggle music
		bindKey bo_controlKey,    1,  C|'q',  C|'q' ; quit
		bindKey bo_controlKey,    1,  C|'r',  C|'r' ; restore
		bindKey bo_controlKey,    1,  C|'s',  C|'s' ; save
		
		bindKey bo_activateMode,  1,      0,   0x81 ; F2
		bindKey bo_activateMode,  1,      1,   0x80 ; F1
		bindKey bo_activateMode,  1,      2,   0x84 ; F5
		bindKey bo_activateMode,  1,      3,   0x82 ; F3
		bindKey bo_activateMode,  1,      4,   0x83 ; F4
		bindKey bo_activateMode,  1,      5,   0x85 ; F6
		
		; in conversation
		bindKey bo_selectOption,   4, 1, '1'
		bindKey bo_selectOption,   4, 2, '2'
		bindKey bo_selectOption,   4, 3, '3'
		bindKey bo_selectOption,   4, 4, '4'
		bindKey bo_selectOption,   4, 5, '5'
		bindMouse bo_otherTrade,   4, 4,  70, 135, 116, 188
		bindMouse bo_avatarTrade,  4, 4, 119, 135, 163, 188
		bindMouse bo_selectOption, 4, 0,  16,   1, 223,  30
		
		; on map screen
		%define mapControlEopArg(number) \
				byteArgEopArg(mapControl, MapControl_ %+ number)
		bindKey bo_byteArgEop,  2, mapControlEopArg(LEVEL_UP),      's'
		bindKey bo_byteArgEop,  2, mapControlEopArg(LEVEL_DOWN),    'w'
		bindKey bo_byteArgEop,  2, mapControlEopArg(REALM_UP),      'd'
		bindKey bo_byteArgEop,  2, mapControlEopArg(REALM_DOWN),    'a'
		bindKey bo_byteArgEop,  2, mapControlEopArg(AVATAR_LEVEL),  'c'
		
		bindKey bo_toggleBool,   27, dseg_mouseHand, A|'h'
		bindKey bo_printVersion, 27,      0, A|0x86 ; Alt+F7
		bindKey bo_printDebug,   27,      0, A|0x87 ; Alt+F8
	endBlockWithFillAt nop, 0x97FEF
endPatch
