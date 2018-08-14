%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	%include "include/additionalCharacterCodes.asm"
	
	defineAddress 72, 0x0010, asciiForScancodeTable
%endif

[bits 16]

startPatch EXE_LENGTH, \
		add character codes for Shift / Ctrl / Alt keys
		
	; insertCharacterMapping scancode, character
	%macro insertCharacterMapping 2
		startBlockAt addr_asciiForScancodeTable + %1
			db %2
		endBlockOfLength 1
	%endmacro
	
	%assign i 0
	%rep mappedCharacterCount
		insertCharacterMapping scancode_%[i], character_%[i]
		
		%assign i i+1
	%endrep
	
endPatch
