%include "../UltimaPatcher.asm"
%include "include/uw2.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		dont change player heading when player has moved against an obstacle
		
	startBlockAt 0x1CC51
		jmp calcJump(0x1CC9F)
	endBlock
endPatch
