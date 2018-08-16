%include "include/u7bg-all-includes.asm"

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
		
		; use a food item from a party member's inventory
		push 0xFF ; frame
		push 0xFF ; quality
		push 377 ; type
		callVarArgsEopFromOverlay usePartyItem, 3
		add sp, 6
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_feed_end
endPatch
