%include "../UltimaPatcher.asm"
%include "include/uw1.asm"
%include "include/uw1-eop.asm"

[bits 16]

startPatch EXE_LENGTH, \
		call eop enqueueGridCoords to flip drawing of geometry behind player 
		
	%macro callEopEnqueueGridCoordsAt 2
		startBlockAt %1, %2
			callFromLoadModule byCallSiteEopDispatcher
		endBlockOfLength 5
	%endmacro
	
	; 16 calls to enqueueGridCoords in enqueueDrawBlock
	callEopEnqueueGridCoordsAt 19, 0x0F7E
	callEopEnqueueGridCoordsAt 19, 0x0F9F
	callEopEnqueueGridCoordsAt 19, 0x0FBE
	callEopEnqueueGridCoordsAt 19, 0x0FDA
	callEopEnqueueGridCoordsAt 19, 0x101C
	callEopEnqueueGridCoordsAt 19, 0x1033
	callEopEnqueueGridCoordsAt 19, 0x104C
	callEopEnqueueGridCoordsAt 19, 0x1063
	callEopEnqueueGridCoordsAt 19, 0x1218
	callEopEnqueueGridCoordsAt 19, 0x1235
	callEopEnqueueGridCoordsAt 19, 0x125E
	callEopEnqueueGridCoordsAt 19, 0x1286
	callEopEnqueueGridCoordsAt 19, 0x1344
	callEopEnqueueGridCoordsAt 19, 0x1362
	callEopEnqueueGridCoordsAt 19, 0x1382
	callEopEnqueueGridCoordsAt 19, 0x13A1
endPatch
