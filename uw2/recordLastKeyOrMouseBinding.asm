%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"
%include "include/additionalCharacterCodes.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		record the identity of each called key or mouse binding
		
	; mouse handler
	startBlockAt 0x1DAF9
		mov [dseg_lastKeyOrMouseBinding_pn], bx
		mov byte [dseg_wasLastBindingKey], 0
	endBlockWithFillAt nop, 0x1DB06
	
	; key handler
	startBlockAt 0x1DB87
		mov [dseg_lastKeyOrMouseBinding_pn], bx
		mov byte [dseg_wasLastBindingKey], 1
	endBlockWithFillAt nop, 0x1DB94
endPatch
