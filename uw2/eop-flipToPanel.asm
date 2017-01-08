%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		expanded overlay procedure: flipToPanel
		
	startBlockAt off_eop_flipToPanel
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_panelNumber         0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		; if specified panel is already active, flip to inventory panel instead
			mov ax, [bp+arg_panelNumber]
			cmp byte [dseg_activePanelNumber], al
			jz flipToInventoryPanel
			
		flipToSpecifiedPanel:
			push ax
			push 6
			callWithRelocation o_setPanelState
			add sp, 4
			
			jmp endProc
			
		flipToInventoryPanel:
			push 0
			push 6
			callWithRelocation o_setPanelState
			add sp, 4
			
		endProc:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_flipToPanel_end
endPatch
