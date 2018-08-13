%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

startPatch EXE_LENGTH, \
		eop-toggleCombat
		
	startBlockAt seg_eop, off_eop_toggleCombat
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		; don't toggle combat mode if dialogs are on-screen
		; TODO: allow toggling combat mode while dialogs are on-screen
		; after figuring out how to redraw the Avatar's inventory dialog
			cmp byte [dseg_isDialogMode], 0
			jz notInDialogMode
			jmp endProc
			
		notInDialogMode:
		
		callFromOverlay isAvatarInCombatMode
		test al, al
		jz beginCombat
		
		callFromOverlay breakOffCombat
		jmp endProc
		
		beginCombat:
			callFromOverlay beginCombat
			
		endProc:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_toggleCombat_end
endPatch
