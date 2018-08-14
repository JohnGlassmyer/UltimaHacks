%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

defineAddress 96, 0x0937, callTrainSkillFromArk

[bits 16]

startPatch EXE_LENGTH, \
		call eop trainSkill to print results of skill-training
		
	startBlockAt addr_callTrainSkillFromArk
		callFromOverlay byCallSiteEopDispatcher
	endBlockOfLength 5
endPatch
