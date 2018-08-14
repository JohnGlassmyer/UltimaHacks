%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXE_LENGTH, \
		call eop enqueueGridCoords to flip drawing of geometry behind player 
		
	%macro callEopEnqueueGridCoordsAt 2
		startBlockAt %1, %2
			callFromLoadModule byCallSiteEopDispatcher
		endBlockOfLength 5
	%endmacro
	
	callEopEnqueueGridCoordsAt 21, 0x0F08
	callEopEnqueueGridCoordsAt 21, 0x0F29
	callEopEnqueueGridCoordsAt 21, 0x0F48
	callEopEnqueueGridCoordsAt 21, 0x0F64
	callEopEnqueueGridCoordsAt 21, 0x0FAD
	callEopEnqueueGridCoordsAt 21, 0x0FC4
	callEopEnqueueGridCoordsAt 21, 0x0FDD
	callEopEnqueueGridCoordsAt 21, 0x0FF4
	callEopEnqueueGridCoordsAt 21, 0x11A9
	callEopEnqueueGridCoordsAt 21, 0x11C6
	callEopEnqueueGridCoordsAt 21, 0x11EF
	callEopEnqueueGridCoordsAt 21, 0x1217
	callEopEnqueueGridCoordsAt 21, 0x12D5
	callEopEnqueueGridCoordsAt 21, 0x12F3
	callEopEnqueueGridCoordsAt 21, 0x1313
	callEopEnqueueGridCoordsAt 21, 0x1332
endPatch
