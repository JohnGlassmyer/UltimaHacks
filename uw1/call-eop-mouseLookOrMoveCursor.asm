%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	%include "include/uw1-eop.asm"

	defineAddress 14, 0x0B16, moveCursor
	defineAddress 14, 0x0B5B, doneMovingCursor

	%define pushYDelta push di
%endif

[bits 16]

startPatch EXE_LENGTH, \
		call mouselook eop instead of updating cursor position
		
	startBlockAt addr_moveCursor
		%assign var_mouseXDelta -0x0A
		; di == mouseYDelta
		
		push word [bp+var_mouseXDelta]
		pushYDelta
		push word varArgsEopArg(mouseLookOrMoveCursor, 2)
		callFromLoadModule varArgsEopDispatcher
		add sp, 6
		
		jmp calcJump(off_doneMovingCursor)
	endBlock
endPatch
