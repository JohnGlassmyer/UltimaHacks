%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

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
	
	callEopEnqueueDrawBlockAt 21, 0x0693
	callEopEnqueueDrawBlockAt 21, 0x0708
	callEopEnqueueDrawBlockAt 21, 0x073F
endPatch
