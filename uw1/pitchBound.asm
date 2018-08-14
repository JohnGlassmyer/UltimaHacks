%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"

	defineAddress 134, 0x0ED0, pushCrystalBallPitchBound
	defineAddress 134, 0x0EDB, pushPlayerPitchBound
%endif

[bits 16]

startPatch EXE_LENGTH, \
		change how far up or down the player may look using keys
		
	; pitchBound is now defined in uw1.asm
	
	startBlockAt addr_pushCrystalBallPitchBound
		push word pitchBound
	endBlockOfLength 3
	
	startBlockAt addr_pushPlayerPitchBound
		push word pitchBound
	endBlockOfLength 3
endPatch
