%include "../UltimaPatcher.asm"
%include "include/uw1.asm"

[bits 16]

defineAddress 109, 0x001D, showTitleScreen

startPatch EXE_LENGTH, \
		skip showing the title screen
		
	startBlockAt addr_showTitleScreen
		; originally a (3-byte) near call to title-scene proc
		times 3 nop
	endBlock
endPatch
