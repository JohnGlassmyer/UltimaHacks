%include "../UltimaPatcher.asm"
%include "include/uw2.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		skip playing the opening cutscene
		
	startBlockAt 0x8879E
		; originally a (5-byte) far call to the playCutscene proc
		times 5 nop
	endBlock
endPatch
