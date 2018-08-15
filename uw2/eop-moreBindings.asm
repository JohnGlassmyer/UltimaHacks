%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"
%include "include/bindKeyOrMouse.asm"

[bits 16]

; UW2-specific bindings
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
			dKey 1, 0x81, setInteractionMode, 0 ; F2
			dKey 1, 0x80, setInteractionMode, 1 ; F1
			dKey 1, 0x84, setInteractionMode, 2 ; F5
			dKey 1, 0x82, setInteractionMode, 3 ; F3
			dKey 1, 0x83, setInteractionMode, 4 ; F4
			dKey 1, 0x85, setInteractionMode, 5 ; F6
			
			dKey 2, 'd', byteArgEopDispatcher, byteArgEopArg(mapControl, MapControl_REALM_UP)
			dKey 2, 'a', byteArgEopDispatcher, byteArgEopArg(mapControl, MapControl_REALM_DOWN)
			
			dKey 27, A|'h', toggleBool, dseg_mouseHand ; Alt+h
		keyBindings_end:
		
		mov di, offsetInCodeSegment(mouseBindings)
		forMouseBinding:
			cmp di, offsetInCodeSegment(mouseBindings_end)
			jae mouseBindings_end
			
			push cs
			pop es
			
			bindDMouseAt es:di
			
			add di, dMouse_SIZE
			jmp forMouseBinding
			
		mouseBindings:
			; click areas adjacent to compass to turn (broken in original game)
			dMouse 1,  66,  33,  84,  49, easyMove, -1  ; Easy-left
			dMouse 1, 156,  33, 174,  49, easyMove,  1  ; Easy-right
			
			; in conversation
			dMouse 4,  70, 135, 116, 188, clickOtherTrade,          4
			dMouse 4, 119, 135, 163, 188, clickAvatarTrade,         4
			dMouse 4,  16,   1, 223,  30, selectConversationOption, 0
		mouseBindings_end:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_moreBindings_end
endPatch
