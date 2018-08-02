%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		expanded overlay procedure: clickFlasks
		
	startBlockAt off_eop_clickFlasks
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		mov si, [dseg_inputState_pn]
		
		mov word [si+InputState_relativeX], 20
		mov word [si+InputState_relativeY], 11
		callFromOverlay clickFlasks
		
		mov word [si+InputState_relativeX], 60
		mov word [si+InputState_relativeY], 11
		callFromOverlay clickFlasks
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_clickFlasks_end
endPatch
