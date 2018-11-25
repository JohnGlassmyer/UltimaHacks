%include "../UltimaPatcher.asm"
%include "include/uw1.asm"

[bits 16]

defineAddress 109, 0x001C, showTitleScreen

startPatch EXE_LENGTH, \
		skip showing the title screen
		
	startBlockAt addr_showTitleScreen
		; originally [push cs, call near] to title-scene proc
		times 4 nop
	endBlock
endPatch
