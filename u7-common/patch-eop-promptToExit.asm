[bits 16]

startPatch EXE_LENGTH, eop-promptToExit
	startBlockAt addr_eop_promptToExit
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		push 0
		callFromOverlay doYesNoDialog
		pop cx
		
		mov [dseg_shouldExitMainGameLoop], al
		
		test al, al
		jz redrawDialogs
		
		; the player chose to exit, so close dialogs
		; in order to get control back to the main game loop
			mov byte [dseg_dialogState], DialogState_CLOSE_ALL
			jmp endProc
			
		redrawDialogs:
		; the player chose not to exit, so redraw dialogs
			callFromOverlay redrawDialogs
			
		endProc:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_promptToExit_end
endPatch
