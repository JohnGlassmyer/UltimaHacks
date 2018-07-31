%include "../UltimaPatcher.asm"
%include "include/uw1.asm"
%include "include/uw1-eop.asm"

[bits 16]

%define off_tryHandlersInMainLoop 0x1DD78

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		call eop tryKeyAndMouseBindings to respond to multiple simultaneous keys
		
	startBlockAt off_tryHandlersInMainLoop
		push varArgsEopArg(tryKeyAndMouseBindings, 0)
		callFromLoadModule varArgsEopDispatcher
		add sp, 2
	endBlockWithFillAt nop, off_tryHandlersInMainLoop + 11
endPatch
