%include "../UltimaPatcher.asm"
%include "include/uw1.asm"
%include "include/uw1-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		call eop enqueueDrawBlock to skip drawing if draw-queue is nearly full
		
	%macro callEopEnqueueDrawBlockAt 1
		startBlockAt %1
			; si : grid index for current row and column
			
			push si
			push varArgsEopArg(enqueueDrawBlock, 1)
			callFromLoadModule varArgsEopDispatcher
			add sp, 4
		endBlockWithFillAt nop, startAbsolute + 13
	%endmacro
	
	; 3 calls to enqueueDrawBlock in enqueueDrawBlocksWithinLimits
	callEopEnqueueDrawBlockAt 0x21752
	callEopEnqueueDrawBlockAt 0x217C7
	callEopEnqueueDrawBlockAt 0x217FE
endPatch
