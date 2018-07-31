%include "../UltimaPatcher.asm"
%include "include/uw1.asm"
%include "include/uw1-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		expanded overlay procedure var-args dispatcher
		
	startBlockAt off_eop_varArgsDispatcher
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_varArgsEopArg       0x06
		%assign ____callerCs            0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		; push arguments
			movzx cx, byte [bp+arg_varArgsEopArg+0]
			
			cmp cx, 0
			jz afterPushingArguments
			
			; point [bp+si] at first argument pushed by caller
				mov si, cx
				shl si, 1
				add si, arg_varArgsEopArg
				
			; push arguments in order pushed by caller
			forArgument:
				push word [bp+si]
				sub si, 2
				loop forArgument
				
		afterPushingArguments:
		
		; lookup procedure offset
			movzx bx, byte [bp+arg_varArgsEopArg+1]
			shl bx, 1
			add bx, off_eop_dispatchTable - off_eop_segmentZero
			mov bx, [cs:bx]
			
		call bx
		
		; preserve return value in ax
		
		; pop arguments
			movzx cx, byte [bp+arg_varArgsEopArg+0]
			shl cx, 1
			add sp, cx
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retf
	endBlockAt off_eop_varArgsDispatcher_end
endPatch
