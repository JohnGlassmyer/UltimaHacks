%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"
%include "include/bindKeyOrMouse.asm"

[bits 16]

startPatch EXE_LENGTH, \
		expanded overlay procedure: moreBindings
		
	startBlockAt addr_eop_moreBindings
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		; UW2-specific:
		
		; click areas adjacent to compass to turn (broken in original game)
		bindMouse 1,  66,  33,  84,  49, easyMove, -1  ; Easy-left
		bindMouse 1, 156,  33, 174,  49, easyMove,  1  ; Easy-right
		
		bindKey 1, 0x81, setInteractionMode, 0 ; F2
		bindKey 1, 0x80, setInteractionMode, 1 ; F1
		bindKey 1, 0x84, setInteractionMode, 2 ; F5
		bindKey 1, 0x82, setInteractionMode, 3 ; F3
		bindKey 1, 0x83, setInteractionMode, 4 ; F4
		bindKey 1, 0x85, setInteractionMode, 5 ; F6
		
		bindMouse 4,  70, 135, 116, 188, clickOtherTrade, 4
		bindMouse 4, 119, 135, 163, 188, clickAvatarTrade, 4
		bindMouse 4,  16,   1, 223,  30, selectConversationOption, 0
		
		bindKey 2, 'd', byteArgEopDispatcher, \
				byteArgEopArg(mapControl, MapControl_REALM_UP)
		bindKey 2, 'a', byteArgEopDispatcher, \
				byteArgEopArg(mapControl, MapControl_REALM_DOWN)
		
		bindKey 27, A|'h',  toggleBool,   dseg_mouseHand ; Alt+h
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_moreBindings_end
endPatch
