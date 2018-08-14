%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	%include "include/uw1-eop.asm"
	
	defineAddress 34, 0x02FC, beforeSetupA  
	defineAddress 34, 0x030A, afterEnqueueA  
	defineAddress 34, 0x0366, beforeSetupB  
	defineAddress 34, 0x0378, afterEnqueueB  
%endif

[bits 16]
	
startPatch EXE_LENGTH, \
		call eop setupPerspectiveAndEnqueueDraw to draw blocks behind player
		
	startBlockAt addr_beforeSetupA
		push varArgsEopArg(setupPerspectiveAndEnqueueDraw, 0)
		callFromLoadModule varArgsEopDispatcher
		add sp, 2
	endBlockWithFillAt nop, off_afterEnqueueA
	
	startBlockAt addr_beforeSetupB
		push varArgsEopArg(setupPerspectiveAndEnqueueDraw, 0)
		callFromLoadModule varArgsEopDispatcher
		add sp, 2
	endBlockWithFillAt nop, off_afterEnqueueB
endPatch
