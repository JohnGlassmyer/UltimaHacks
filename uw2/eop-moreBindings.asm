%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"
%include "include/bindKeyOrMouse.asm"

[bits 16]

%define bo_moveCursor   0x0080, 0x0DA7

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
		
		bindKey bo_moveCursor,    7, H|0xA3, H|0xA3 ; Shift+Tab
		bindKey bo_moveCursor,    7,      9,      9 ; Tab
		bindKey bo_moveCursor,    7,   0x8C,   0x8C ; (numeric keypad)
		bindKey bo_moveCursor,    7,   0x8D,   0x8D ; (numeric keypad)
		bindKey bo_moveCursor,    7,   0x8E,   0x8E ; (numeric keypad)
		bindKey bo_moveCursor,    7,   0x8F,   0x8F ; (numeric keypad)
		bindKey bo_moveCursor,    7,   0x91,   0x91 ; (numeric keypad)
		bindKey bo_moveCursor,    7,   0x92,   0x92 ; (numeric keypad)
		bindKey bo_moveCursor,    7,   0x93,   0x93 ; (numeric keypad)
		bindKey bo_moveCursor,    7,   0x94,   0x94 ; (numeric keypad)
		bindKey bo_moveCursor,    7,   0x95,   0x95 ; (numeric keypad)
		bindKey bo_moveCursor,    7,   0x96,   0x96 ; (numeric keypad)
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_moreBindings_end
endPatch
