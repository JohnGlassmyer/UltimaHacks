; Find all matching items held by all party members and return their ibos in a
;     (near-allocated) linked list.

[bits 16]

startPatch EXE_LENGTH, eop-findAllPartyItems
	startBlockAt addr_eop_findAllPartyItems
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
		%assign var_list               -0x32
		add sp, var_list
		
		push si
		push di
		
		push List_SIZE
		callFromOverlay allocateNearMemory
		pop cx
		test ax, ax
		jz endProc
		
		mov bx, ax
		mov word [bx+List_pn_head], 0
		mov word [bx+List_pn_tail], 0
		mov [bp+var_list], bx
		
		mov word [bp+var_iPartyMember], 0
		forPartyMember:
			mov al, byte [dseg_partySize]
			cbw
			cmp ax, [bp+var_iPartyMember]
			jle noMorePartyMembers
			mov bx, [bp+var_iPartyMember]
			
			push word [bp+arg_itemFrame]
			push word [bp+arg_itemQuality]
			push word [bp+arg_itemType]
			push word 0 ; flags
			shl bx, 1
			lea ax, [dseg_partyMemberIbos+bx]
			push ax
			lea ax, [bp+var_findItemQuery]
			push ax
			callFromOverlay findItemInContainer
			add sp, 12
			
			forItemHeldByPartyMember:
				cmp word [bp+var_findItemQuery], 0
				jz doneWithPartyMember
				
				; add the found item ibo to the list (in a new node)
				push word [bp+var_findItemQuery]
				push word [bp+var_list]
				callFromOverlay List_insertNewNodeAtTail
				pop cx
				pop cx
				
				; advance to the next item held by this party member
				lea ax, [bp+var_findItemQuery]
				push ax
				callFromOverlay findItem
				pop cx
				
				jmp forItemHeldByPartyMember
				
			doneWithPartyMember:
			inc word [bp+var_iPartyMember]
			jmp forPartyMember
			
		noMorePartyMembers:
			mov ax, [bp+var_list]
			
		endProc:
			; ax == (near) address of list, or 0
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_findAllPartyItems_end
endPatch
