%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

startPatch EXE_LENGTH, \
		expanded overlay procedure dispatcher
		
	startBlockAt seg_eop, off_eop_dispatcher
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_numberOfArguments   0x08
		%assign arg_procedureOffset     0x06
		%assign ____callerCs            0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		mov cx, [bp+arg_numberOfArguments]
		cmp cx, 0
		jz callProcedure
		
		; point [bp+si] at first argument pushed by caller
			mov si, cx
			shl si, 1
			add si, arg_numberOfArguments
			
		; push arguments in order pushed by caller
		forArgument:
			push word [bp+si]
			sub si, 2
			loop forArgument
			
		callProcedure:
		; call procedure specified by caller
			mov bx, [bp+arg_procedureOffset]
			call bx
			
		; preserve return value in ax
		
		; pop arguments
			mov bx, [bp+arg_numberOfArguments]
			shl bx, 1
			add sp, bx
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retf
		
	endBlockAt off_eop_dispatcher_end
endPatch
