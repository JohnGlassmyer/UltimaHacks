%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		expanded overlay procedure: closeContainer
		
	startBlockAt off_eop_closeContainer
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		callWithRelocation o_closeInventoryContainer
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_closeContainer_end
endPatch
