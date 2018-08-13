%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; show given string in a "scroll" popup a la version display
startPatch EXE_LENGTH, \
		eop-popupScrollWithText
		
	startBlockAt seg_eop, off_eop_popupScrollWithText
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_stringSegment       0x06
		%assign arg_stringOffset        0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_farString          -0x04
		add sp, var_farString
		
		push si
		push di
		
		; adapted from sub_147B6, which displays version info
		
		push word 0x031D
		callFromOverlay beginConversation
		add sp, 2
		
		lea si, [bp+var_farString]
		
		push si
		callFromOverlay FarString_new
		add sp, 2
		
		push word [bp+arg_stringSegment]
		push word [bp+arg_stringOffset]
		push si
		callFromOverlay FarString_append
		add sp, 6
		
		push si
		callFromOverlay FarString_showInConversation
		add sp, 2
		
		callFromOverlay endConversation
		
		push 2
		push si
		callFromOverlay FarString_destructor
		add sp, 4
		
		cmp byte [dseg_isDialogMode], 0
		jz afterRedrawingDialogs
		callFromOverlay redrawDialogs
		afterRedrawingDialogs:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_popupScrollWithText_end
	
endPatch
