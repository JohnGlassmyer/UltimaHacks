%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	%include "include/uw1-eop.asm"
	%include "include/additionalCharacterCodes.asm"

	defineAddress 11, 0x03CA, redundantMouseHandlerAddressingStart
	defineAddress 11, 0x03D7, redundantMouseHandlerAddressingEnd
	defineAddress 11, 0x0458, redundantKeyHandlerAddressingStart
	defineAddress 11, 0x0465, redundantKeyHandlerAddressingEnd
%endif

[bits 16]

startPatch EXE_LENGTH, \
		record the identity of each called key or mouse binding
		
	; mouse handler
	startBlockAt addr_redundantMouseHandlerAddressingStart
		mov [dseg_pn_lastKeyOrMouseBinding], bx
		mov byte [dseg_wasLastBindingKey], 0
	endBlockWithFillAt nop, off_redundantMouseHandlerAddressingEnd
	
	; key handler
	startBlockAt addr_redundantKeyHandlerAddressingStart
		mov [dseg_pn_lastKeyOrMouseBinding], bx
		mov byte [dseg_wasLastBindingKey], 1
	endBlockWithFillAt nop, off_redundantKeyHandlerAddressingEnd
endPatch
