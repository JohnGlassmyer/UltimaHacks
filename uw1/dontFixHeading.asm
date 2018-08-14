%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	
	defineAddress 9, 0x0A66, maybeJumpOverAdjustment
	defineAddress 9, 0x0AAD, afterAdjustment
%endif

[bits 16]

startPatch EXE_LENGTH, \
		dont change player heading when player has moved against an obstacle
		
	startBlockAt addr_maybeJumpOverAdjustment
		jmp calcJump(off_afterAdjustment)
	endBlock
endPatch
