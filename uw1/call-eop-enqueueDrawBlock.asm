%include "../UltimaPatcher.asm"
%include "include/uw1.asm"
%include "include/uw1-eop.asm"

[bits 16]

startPatch EXE_LENGTH, \
		call eop enqueueDrawBlock to skip drawing if draw-queue is nearly full
		
	%macro callEopEnqueueDrawBlockAt 2
		startBlockAt %1, %2
			; si : grid index for current row and column
			
			push si
			push varArgsEopArg(enqueueDrawBlock, 1)
			callFromLoadModule varArgsEopDispatcher
			add sp, 4
			nop
		endBlockOfLength 13
	%endmacro
	
	; 3 calls to enqueueDrawBlock in enqueueDrawBlocksWithinLimits
	callEopEnqueueDrawBlockAt 19, 0x0652
	callEopEnqueueDrawBlockAt 19, 0x06C7
	callEopEnqueueDrawBlockAt 19, 0x06FE
endPatch
