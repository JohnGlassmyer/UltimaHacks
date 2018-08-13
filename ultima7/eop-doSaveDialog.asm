%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; show memory usage stats in a "scroll" popup
startPatch EXE_LENGTH, \
		eop-doSaveDialog
		
	startBlockAt seg_eop, off_eop_doSaveDialog
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		; 2 => Save dialog
		push 2
		callFromOverlay startDialogLoopWithDialogType
		add sp, 2
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_doSaveDialog_end
endPatch
