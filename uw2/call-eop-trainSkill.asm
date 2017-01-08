%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		call eop trainSkill to print results of skill-training
		
	startBlockAt 0x76EF7
		callWithRelocation o_byCallSiteEopDispatcher
	endBlockAt startAbsolute + 5
endPatch
