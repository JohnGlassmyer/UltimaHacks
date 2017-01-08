%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		expanded overlay procedure: displayMap
		
	startBlockAt off_eop_displayMap
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		; don't switch to map interface-mode unless inteface context == 1
		; (imitating code in sub_906DF)
			mov bx, [dseg_inputState_pn]
			cmp word [bx+InputState_context], 1
			jnz endProc
			
		; switch to map interface-mode
			push 2
			callWithRelocation 0x0380:0x004D ; 0x64BF:0x004D
			add sp, 2
			
		endProc:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_displayMap_end
endPatch
