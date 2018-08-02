%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		call mouselook eop instead of updating cursor position
		
	startBlockAt 0x1EF8B
		%assign arg_isRendering  0x06
		%assign var_mouseXDelta -0x0A
		%assign var_mouseYDelta -0x0C
		
		push word [bp+var_mouseXDelta]
		push word [bp+var_mouseYDelta]
		push word varArgsEopArg(mouseLookOrMoveCursor, 2)
		callFromLoadModule varArgsEopDispatcher
		add sp, 6
		
		jmp calcJump(0x1EFD3)
	endBlock
endPatch
