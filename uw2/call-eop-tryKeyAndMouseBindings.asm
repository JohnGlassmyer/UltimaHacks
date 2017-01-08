%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		call eop tryKeyAndMouseBindings to respond to multiple simultaneous keys
		
	startBlockAt 0x1E04B
		push varArgsEopArg(tryKeyAndMouseBindings, 0)
		callWithRelocation l_varArgsEopDispatcher
		add sp, 2
	endBlockWithFillAt nop, 0x1E056
endPatch
