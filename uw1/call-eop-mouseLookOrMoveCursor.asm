%include "../UltimaPatcher.asm"
%include "include/uw1.asm"
%include "include/uw1-eop.asm"

[bits 16]

%define off_moveCursor       0x1EAD6
%define off_doneMovingCursor 0x1EB1B

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		call mouselook eop instead of updating cursor position
		
	startBlockAt off_moveCursor
		%assign var_mouseXDelta -0x0A
		; di == mouseYDelta
		
		push word [bp+var_mouseXDelta]
		push di
		push word varArgsEopArg(mouseLookOrMoveCursor, 2)
		callFromLoadModule varArgsEopDispatcher
		add sp, 6
		
		jmp calcJump(off_doneMovingCursor)
	endBlock
endPatch
