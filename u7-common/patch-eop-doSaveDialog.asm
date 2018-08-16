[bits 16]

startPatch EXE_LENGTH, eop-doSaveDialog
	startBlockAt addr_eop_doSaveDialog
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		push DialogState_SHOW_SAVE
		callFromOverlay startAndLoopNumberedDialog
		pop cx
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_doSaveDialog_end
endPatch
