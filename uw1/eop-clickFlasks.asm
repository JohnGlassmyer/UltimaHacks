%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	%include "include/uw1-eop.asm"
%endif

[bits 16]

startPatch EXE_LENGTH, \
		expanded overlay procedure: clickFlasks
		
	startBlockAt addr_eop_clickFlasks
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		mov si, [dseg_pn_inputState]
		
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
