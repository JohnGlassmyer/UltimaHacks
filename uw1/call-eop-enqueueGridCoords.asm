%include "../UltimaPatcher.asm"
%include "include/uw1.asm"
%include "include/uw1-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		call eop enqueueGridCoords to flip drawing of geometry behind player 
		
	%macro callEopEnqueueGridCoordsAt 1
		startBlockAt %1
			callFromLoadModule byCallSiteEopDispatcher
		endBlockWithFillAt nop, startAbsolute + 5
	%endmacro
	
	; 16 calls to enqueueGridCoords in enqueueDrawBlock
	callEopEnqueueGridCoordsAt 0x2207E
	callEopEnqueueGridCoordsAt 0x2209F
	callEopEnqueueGridCoordsAt 0x220BE
	callEopEnqueueGridCoordsAt 0x220DA
	callEopEnqueueGridCoordsAt 0x2211C
	callEopEnqueueGridCoordsAt 0x22133
	callEopEnqueueGridCoordsAt 0x2214C
	callEopEnqueueGridCoordsAt 0x22163
	callEopEnqueueGridCoordsAt 0x22318
	callEopEnqueueGridCoordsAt 0x22335
	callEopEnqueueGridCoordsAt 0x2235E
	callEopEnqueueGridCoordsAt 0x22386
	callEopEnqueueGridCoordsAt 0x22444
	callEopEnqueueGridCoordsAt 0x22462
	callEopEnqueueGridCoordsAt 0x22482
	callEopEnqueueGridCoordsAt 0x224A1
endPatch
