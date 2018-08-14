%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	%include "include/uw1-eop.asm"

	defineAddress 39, 0x11E8, animateSlidingPanel
%endif

[bits 16]

startPatch EXE_LENGTH, \
		call eop slidePanel to slide panel more rapidly
		
	startBlockAt addr_animateSlidingPanel
		callFromLoadModule byCallSiteEopDispatcher
	endBlockOfLength 5
endPatch
