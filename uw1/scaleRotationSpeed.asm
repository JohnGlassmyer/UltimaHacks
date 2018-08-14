%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
%endif

[bits 16]

startPatch EXE_LENGTH, \
		scale the speed at which the player turns
		
	startBlockAt seg_dseg, dseg_rotationSpeedBase
		; player rotation (yaw) speed is proportional to this value
		; original is 15
		dw 15
	endBlock
endPatch
