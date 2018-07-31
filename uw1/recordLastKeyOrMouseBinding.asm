%include "../UltimaPatcher.asm"
%include "include/uw1.asm"
%include "include/uw1-eop.asm"
%include "include/additionalCharacterCodes.asm"

[bits 16]

%define off_redundantMouseHandlerAddressingStart 0x1DCBA
%define off_redundantMouseHandlerAddressingEnd   0x1DCC7
%define off_redundantKeyHandlerAddressingStart   0x1DD48
%define off_redundantKeyHandlerAddressingEnd     0x1DD55

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		record the identity of each called key or mouse binding
		
	; mouse handler
	startBlockAt off_redundantMouseHandlerAddressingStart
		mov [dseg_pn_lastKeyOrMouseBinding], bx
		mov byte [dseg_wasLastBindingKey], 0
	endBlockWithFillAt nop, off_redundantMouseHandlerAddressingEnd
	
	; key handler
	startBlockAt off_redundantKeyHandlerAddressingStart
		mov [dseg_pn_lastKeyOrMouseBinding], bx
		mov byte [dseg_wasLastBindingKey], 1
	endBlockWithFillAt nop, off_redundantKeyHandlerAddressingEnd
endPatch
