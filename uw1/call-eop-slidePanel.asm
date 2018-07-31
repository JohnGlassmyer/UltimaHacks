%include "../UltimaPatcher.asm"
%include "include/uw1.asm"
%include "include/uw1-eop.asm"

[bits 16]

%define off_animateSlidingPanel 0x32D88

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		call eop slidePanel to slide panel more rapidly
		
	startBlockAt off_animateSlidingPanel
		callFromLoadModule byCallSiteEopDispatcher
	endBlockAt startAbsolute + 5
endPatch
