; Show the given string in a "scroll" or "book" popup.

[bits 16]

startPatch EXE_LENGTH, eop-displayText
	startBlockAt addr_eop_displayText
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_textDisplayType     0x06
		%assign arg_pn_farString        0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		push word [bp+arg_textDisplayType]
		callFromOverlay beginConversation
		pop cx
		
		push word [bp+arg_pn_farString]
		callFromOverlay FarString_showInConversation
		pop cx
		
		callFromOverlay endConversation
		
		cmp byte [dseg_isDialogMode], 0
		jz afterRedrawingDialogs
		callFromOverlay redrawDialogs
		afterRedrawingDialogs:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_displayText_end
endPatch
