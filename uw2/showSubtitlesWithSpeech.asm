%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

defineAddress 108, 0x1036, jumpOverSubtitles

startPatch EXE_LENGTH, \
		show subtitles in cut-scenes even if speech is played
		
	; replace a jmp over displaying subtitles with nop's
	startBlockAt addr_jumpOverSubtitles
		nop
		nop
	endBlock
endPatch
