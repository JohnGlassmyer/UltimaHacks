%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		call eop setupPerspectiveAndEnqueueDraw to draw blocks behind player
		
	startBlockAt 0x2F9E0
		push varArgsEopArg(setupPerspectiveAndEnqueueDraw, 0)
		callWithRelocation l_varArgsEopDispatcher
		add sp, 2
	endBlockWithFillAt nop, 0x2F9EE
	
	startBlockAt 0x2FA4A
		push varArgsEopArg(setupPerspectiveAndEnqueueDraw, 0)
		callWithRelocation l_varArgsEopDispatcher
		add sp, 2
	endBlockWithFillAt nop, 0x2FA5C
endPatch
