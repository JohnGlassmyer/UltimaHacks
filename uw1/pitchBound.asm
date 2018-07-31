%include "../UltimaPatcher.asm"
%include "include/uw1.asm"

[bits 16]

%define off_pushCrystalBallPitchBound 0x7F700
%define off_pushPlayerPitchBound      0x7F70B

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		change how far up or down the player may look using keys
		
	; pitchBound is now defined in uw1.asm
	
	startBlockAt off_pushCrystalBallPitchBound
		push word pitchBound
	endBlockAt startAbsolute + 3
	
	startBlockAt off_pushPlayerPitchBound
		push word pitchBound
	endBlockAt startAbsolute + 3
endPatch
