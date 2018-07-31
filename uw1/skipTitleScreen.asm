%include "../UltimaPatcher.asm"
%include "include/uw1.asm"

[bits 16]

%define off_showTitleScreen 0x74C8D

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		skip showing the title screen
		
	startBlockAt off_showTitleScreen
		; originally a (3-byte) near call to title-scene proc
		times 3 nop
	endBlock
endPatch
