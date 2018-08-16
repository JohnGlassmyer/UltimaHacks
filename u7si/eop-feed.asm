%include "include/u7si-all-includes.asm"

[bits 16]

startPatch EXE_LENGTH, eop-feed
	startBlockAt addr_eop_feed
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp                0x02
		%assign ____callerBp                0x00
		
		push si
		push di
		
		; call the U7SI 'f'-key script that feeds a party member to fullness
		push 1557
		push 0
		push 0
		callFromOverlay runUsecode
		add sp, 6
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_feed_end
endPatch
