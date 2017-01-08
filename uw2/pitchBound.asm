%include "../UltimaPatcher.asm"
%include "include/uw2.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		change how far up or down the player may look using keys
		
	; pitchBound is now defined in uw2.asm
	
	startBlockAt 0x98857
		push word pitchBound
	endBlockAt startAbsolute + 3
	
	startBlockAt 0x98862
		push word pitchBound
	endBlockAt startAbsolute + 3
endPatch
