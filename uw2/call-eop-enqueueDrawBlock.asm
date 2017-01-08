%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		call eop enqueueDrawBlock to skip drawing if draw-queue is nearly full
		
	%macro callEopEnqueueDrawBlockAt 1
		startBlockAt %1
			; si : grid index for current row and column
			
			push si
			push varArgsEopArg(enqueueDrawBlock, 1)
			callWithRelocation l_varArgsEopDispatcher
			add sp, 4
			nop
		endBlockAt startAbsolute + 13
	%endmacro
	
	callEopEnqueueDrawBlockAt 0x22F63
	callEopEnqueueDrawBlockAt 0x22FD8
	callEopEnqueueDrawBlockAt 0x2300F
endPatch
