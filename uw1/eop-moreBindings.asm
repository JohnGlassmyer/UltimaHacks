%include "../UltimaPatcher.asm"
%include "include/uw1.asm"
%include "include/uw1-eop.asm"
%include "include/bindKeyOrMouse.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		expanded overlay procedure: moreBindings
		
	startBlockAt off_eop_moreBindings
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
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
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_moreBindings_end
endPatch
