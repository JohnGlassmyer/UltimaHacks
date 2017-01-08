%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		expanded overlay procedure byte-arg dispatcher
		
	startBlockAt off_eop_byteArgDispatcher
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_byteArgEopArg       0x06
		%assign ____callerCs            0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		; push single argument
			movzx ax, byte [bp+arg_byteArgEopArg+0]
			push ax
			
		; lookup procedure offset
			movzx bx, byte [bp+arg_byteArgEopArg+1]
			shl bx, 1
			add bx, off_eop_dispatchTable - off_eop_segmentZero
			mov bx, [cs:bx]
			
		call bx
		
		; preserve return value in ax
		
		; pop the single argument
			add sp, 2
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retf
	endBlockAt off_eop_byteArgDispatcher_end
endPatch
