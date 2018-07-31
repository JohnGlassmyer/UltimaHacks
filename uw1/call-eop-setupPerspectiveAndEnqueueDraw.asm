%include "../UltimaPatcher.asm"
%include "include/uw1.asm"
%include "include/uw1-eop.asm"

[bits 16]

%define off_beforeSetupA  0x2E09C
%define off_afterEnqueueA 0x2E0AA
%define off_beforeSetupB  0x2E106
%define off_afterEnqueueB 0x2E118

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		call eop setupPerspectiveAndEnqueueDraw to draw blocks behind player
		
	startBlockAt off_beforeSetupA
		push varArgsEopArg(setupPerspectiveAndEnqueueDraw, 0)
		callFromLoadModule varArgsEopDispatcher
		add sp, 2
	endBlockWithFillAt nop, off_afterEnqueueA
	
	startBlockAt off_beforeSetupB
		push varArgsEopArg(setupPerspectiveAndEnqueueDraw, 0)
		callFromLoadModule varArgsEopDispatcher
		add sp, 2
	endBlockWithFillAt nop, off_afterEnqueueB
endPatch
