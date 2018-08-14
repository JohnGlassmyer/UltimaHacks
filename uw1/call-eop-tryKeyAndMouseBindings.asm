%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	%include "include/uw1-eop.asm"

	defineAddress 12, 0x0018, tryHandlersInMainLoop
%endif

[bits 16]

startPatch EXE_LENGTH, \
		call eop tryKeyAndMouseBindings to respond to multiple simultaneous keys
		
	startBlockAt addr_tryHandlersInMainLoop
		push varArgsEopArg(tryKeyAndMouseBindings, 0)
		callFromLoadModule varArgsEopDispatcher
		add sp, 2
	endBlockOfLength 11
endPatch
