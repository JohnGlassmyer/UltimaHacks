; Returns a bitmask telling whether the Alt/Ctrl/Shift keys are held.
;
; One eop that returns all shift bits together reduces the number of calls (and
;     entries in the relocation table) needed to test for multiple shift keys.

[bits 16]

startPatch EXE_LENGTH, eop-getKeyboardShiftBits
	startBlockAt addr_eop_getKeyboardShiftBits
		mov ah, 2
		int 16h
		
		retn
	endBlockAt off_eop_getKeyboardShiftBits_end
endPatch
