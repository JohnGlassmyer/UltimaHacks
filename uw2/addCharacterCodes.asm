%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/additionalCharacterCodes.asm"

[bits 16]

off_asciiForScancodeTable EQU 0x637A0

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		add character codes for Shift / Ctrl / Alt keys
		
	; insertCharacterMapping scancode, character
	%macro insertCharacterMapping 2
		startBlockAt off_asciiForScancodeTable + %1
			db %2
		endBlockAt startAbsolute + 1
	%endmacro
	
	%assign i 0
	%rep mappedCharacterCount
		insertCharacterMapping scancode_%[i], character_%[i]
		
		%assign i i+1
	%endrep
	
endPatch
