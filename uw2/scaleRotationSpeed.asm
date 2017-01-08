%include "../UltimaPatcher.asm"
%include "include/uw2.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		scale the speed at which the player turns
		
	startBlockAt off_dseg_segmentZero + dseg_rotationSpeedBase
		; player rotation (yaw) speed is proportional to this value
		; original is 15
		dw 15
	endBlockAt startAbsolute + 2
endPatch
