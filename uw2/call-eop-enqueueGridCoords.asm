%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		call eop enqueueGridCoords to flip drawing of geometry behind player 
		
	%macro callEopEnqueueGridCoordsAt 1
		startBlockAt %1
			callWithRelocation l_byCallSiteEopDispatcher
		endBlockAt startAbsolute + 5
	%endmacro
	
	callEopEnqueueGridCoordsAt 0x237D8
	callEopEnqueueGridCoordsAt 0x237F9
	callEopEnqueueGridCoordsAt 0x23818
	callEopEnqueueGridCoordsAt 0x23834
	callEopEnqueueGridCoordsAt 0x2387D
	callEopEnqueueGridCoordsAt 0x23894
	callEopEnqueueGridCoordsAt 0x238AD
	callEopEnqueueGridCoordsAt 0x238C4
	callEopEnqueueGridCoordsAt 0x23A79
	callEopEnqueueGridCoordsAt 0x23A96
	callEopEnqueueGridCoordsAt 0x23ABF
	callEopEnqueueGridCoordsAt 0x23AE7
	callEopEnqueueGridCoordsAt 0x23BA5
	callEopEnqueueGridCoordsAt 0x23BC3
	callEopEnqueueGridCoordsAt 0x23BE3
	callEopEnqueueGridCoordsAt 0x23C02
endPatch
