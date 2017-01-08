%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		show subtitles in cut-scenes even if speech is played
		
	; replace a jmp over displaying subtitles with nop's
	startBlockAt 0x809C6
		nop
		nop
	endBlockAt startAbsolute+2
endPatch
