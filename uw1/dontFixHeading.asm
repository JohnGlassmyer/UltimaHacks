%include "../UltimaPatcher.asm"
%include "include/uw1.asm"

[bits 16]

%define off_maybeJumpOverAdjustment 0x1D036
%define off_afterAdjustment         0x1D07D

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		dont change player heading when player has moved against an obstacle
		
	startBlockAt off_maybeJumpOverAdjustment
		jmp calcJump(off_afterAdjustment)
	endBlock
endPatch
