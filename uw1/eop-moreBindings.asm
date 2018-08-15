%include "../UltimaPatcher.asm"
%include "include/uw1.asm"
%include "include/uw1-eop.asm"
%include "include/bindKeyOrMouse.asm"

[bits 16]

; UW1-specific bindings
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
		
		; TODO: add mouse-handedness switching to UW1
		
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
			dKey 1, 0x85, activateMode, 0 ; F6
			dKey 1, 0x84, activateMode, 1 ; F5
			dKey 1, 0x83, activateMode, 2 ; F4
			dKey 1, 0x82, activateMode, 3 ; F3
			dKey 1, 0x81, activateMode, 4 ; F2
			dKey 1, 0x80, activateMode, 5 ; F1
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
			; click arrows below the compass to move
			dMouse 1, 107,  33, 123,  47, easyMove, -1, ; Easy-left
			dMouse 1, 130,  31, 146,  44, easyMove,  0, ; Easy-walk
			dMouse 1, 155,  33, 170,  47, easyMove,  1, ; Easy-right
			
			; in conversation
			dMouse 4,  82, 152, 136, 190, clickOtherTrade,          4
			dMouse 4, 139, 152, 193, 190, clickAvatarTrade,         4
			dMouse 4,  15,   1, 305,  30, selectConversationOption, 0
		mouseBindings_end:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_moreBindings_end
endPatch
