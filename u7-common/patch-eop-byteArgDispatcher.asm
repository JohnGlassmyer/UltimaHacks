[bits 16]

startPatch EXE_LENGTH, %[eopSegmentName]-byteArgDispatcher
	startBlockAt addr_%[eopSegmentName]_byteArgDispatcher
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_byteArgEopArg       0x06
		%assign ____callerCs            0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		; push single argument
			movzx ax, byte [bp+arg_byteArgEopArg+0]
			push ax
			
		; lookup procedure offset
			movzx bx, byte [bp+arg_byteArgEopArg+1]
			shl bx, 1
			add bx, off_%[eopSegmentName]_dispatchTable
			mov bx, [cs:bx]
			
		call bx
		
		; preserve return value in ax
		
		; pop the single argument
			add sp, 2
			
		mov sp, bp
		pop bp
		retf
	endBlockAt off_%[eopSegmentName]_byteArgDispatcher_end
endPatch
