%include "../UltimaPatcher.asm"
%include "include/uw2.asm"

[bits 16]

defineAddress 112, 0x020E, callPlayCutscene

startPatch EXE_LENGTH, \
		skip playing the opening cutscene
		
	startBlockAt addr_callPlayCutscene
		; originally a (5-byte) far call to the playCutscene proc
		times 5 nop
	endBlock
endPatch
