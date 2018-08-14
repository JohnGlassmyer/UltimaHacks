%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	%include "include/uw1-eop.asm"

	defineAddress 109, 0x02C4, setInterfaceMode_proc
	defineAddress 109, 0x02FF, setInterfaceMode_endp
%endif

[bits 16]

startPatch EXE_LENGTH, \
		call eop-setInterfaceMode to disable mouseLook in conversations
		
	startBlockAt addr_setInterfaceMode_proc
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
		
	endBlockAt off_setInterfaceMode_endp
endPatch
