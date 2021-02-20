%include "include/u7bg-all-includes.asm"

defineAddress seg_dseg, 0x0B00, cheatMenuTimeFormat
defineAddress seg_dseg, 0x0B0E, cheatMenuTimeFormat_end

[bits 16]

startPatch EXE_LENGTH, itemLabels
	startBlockAt addr_cheatMenuTimeFormat
		db '%s %d:%02d %s', 0
	endBlockAt off_cheatMenuTimeFormat_end
endPatch
