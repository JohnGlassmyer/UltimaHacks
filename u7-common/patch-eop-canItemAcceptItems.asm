; Determines whether an item is a valid target for dropping other items into.

[bits 16]

startPatch EXE_LENGTH, eop-canItemAcceptItems
	startBlockAt addr_eop_canItemAcceptItems
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_ibo                     0x04
		%assign ____callerIp                0x02
		%assign ____callerBp                0x00
		
		push si
		push di
		
		mov es, [dseg_itemBufferSegment]
		mov bx, [bp+arg_ibo]
		mov ax, word [es:bx+4]
		and ax, 0x3FF
		mov dx, 3
		imul dx
		mov bx, ax
		mov bl, [dseg_itemTypeInfo+1+bx]
		and bx, 0xF
		shl bx, 1
		mov ax, [dseg_itemTypeClassFlags+bx]
		and ax, 0x80
		shr ax, 7
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_canItemAcceptItems_end
endPatch
