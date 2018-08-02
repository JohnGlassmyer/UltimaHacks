%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		call eop-setInterfaceMode to disable mouseLook in conversations
		
	startBlockAt 0x8886F
		push bp
		mov bp, sp
		
		%assign arg_interfaceMode       0x06
		%assign ____callerCs            0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		push word [bp+arg_interfaceMode]
		push varArgsEopArg(setInterfaceMode, 1)
		callFromOverlay varArgsEopDispatcher
		add sp, 4
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retf
		
	endBlockAt 0x888AA
endPatch
