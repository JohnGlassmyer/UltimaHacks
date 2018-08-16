[bits 16]

startPatch EXE_LENGTH, eop-cycleInventoryDialogs
	startBlockAt addr_eop_cycleInventoryDialogs
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_direction           0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		cmp byte [dseg_isDialogMode], 0
		jz endProc
		
		cmp word [bp+arg_direction], 1
		jz cycleForward
		cmp word [bp+arg_direction], -1
		jz cycleReverse
		jmp endProc
		
		cycleForward:
			; select second-top inventory dialog
			mov si, [dseg_openItemDialogsList+List_pn_head]
			test si, si
			jz endProc
			mov si, [si+ListNode_pn_next]
			test si, si
			jz endProc
			jmp haveListNodeInSi
			
		cycleReverse:
			; select bottom inventory dialog
			mov si, [dseg_openItemDialogsList+List_pn_tail]
			test si, si
			jz endProc
			
		haveListNodeInSi:
			; move mouse cursor to center of the dialog
			mov bx, [si+ListNode_payload]
			add bx, 0x3F
			mov ax, [bx+XyBounds_minY]
			add ax, [bx+XyBounds_maxY]
			shr ax, 1
			push ax
			mov ax, [bx+XyBounds_minX]
			add ax, [bx+XyBounds_maxX]
			shr ax, 1
			push ax
			callFromOverlay setMouseCursorPosition
			pop cx
			pop cx
			
		; bring the dialog to the top
			push word si
			push dseg_openItemDialogsList
			callFromOverlay List_bringToFront
			pop cx
			pop cx
			
		callFromOverlay redrawDialogs
		
		endProc:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_cycleInventoryDialogs_end
endPatch
