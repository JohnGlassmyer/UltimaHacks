; Returns ibo of first found matching item held by any party member, or zero.

[bits 16]

startPatch EXE_LENGTH, eop-findPartyItem
	startBlockAt addr_eop_findPartyItem
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_itemFrame           0x08
		%assign arg_itemQuality         0x06
		%assign arg_itemType            0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_iPartyMember       -0x02
		%assign var_findItemQuery      -0x30
		add sp, var_findItemQuery
		
		push si
		push di
		
		mov word [bp+var_iPartyMember], 0
		tryPartyMember:
			mov al, byte [dseg_partySize]
			cbw
			cmp ax, [bp+var_iPartyMember]
			jle noMorePartyMembers
			mov bx, [bp+var_iPartyMember]
			
			push word [bp+arg_itemFrame]
			push word [bp+arg_itemQuality]
			push word [bp+arg_itemType]
			push word 0 ; queryFlags
			shl bx, 1
			lea ax, [dseg_partyMemberIbos+bx]
			push ax
			lea ax, [bp+var_findItemQuery]
			push ax
			callFromOverlay findItemInContainer
			add sp, 12
			mov ax, [bp+var_findItemQuery]
			
			test ax, ax
			jnz foundItem
			
			inc word [bp+var_iPartyMember]
			jmp tryPartyMember
			
		foundItem:
			jmp endProc
			
		noMorePartyMembers:
			mov ax, 0
			jmp endProc
			
		endProc:
			; ax == foundItemIbo or 0
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_findPartyItem_end
endPatch
