%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		expanded overlay procedure: slidePanel
		
	startBlockAt off_eop_slidePanel
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		; calling slidePanel twice makes the panel slide twice as fast
			callWithRelocation 0x0138:0x136B
			callWithRelocation 0x0138:0x136B
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_slidePanel_end
endPatch
