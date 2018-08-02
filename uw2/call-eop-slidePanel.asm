%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		call eop slidePanel to slide panel more rapidly
		
	startBlockAt 0x34360
		callFromLoadModule byCallSiteEopDispatcher
	endBlockAt startAbsolute + 5
endPatch
