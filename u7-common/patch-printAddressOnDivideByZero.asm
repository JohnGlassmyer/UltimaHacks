; Changes the divide-by-zero interrupt handler to include the CS:IP of the fault
;     in the error message that the game subsequently prints on exit, to
;     facilitate tracking down bugs.

[bits 16]

startPatch EXE_LENGTH, printAddressOnDivideByZero
	startBlockAt addr_divideByZeroHandler
		mov bp, sp
		
		%assign arg_divideCs  0x02
		%assign arg_divideIp  0x00
		
		pushWithRelocation 0
		push word [bp+arg_divideIp]
		push word [bp+arg_divideCs]
		push dseg_divideByZeroString
		push dseg_divideByZeroTemplate
		callFromLoadModule exitWithErrorPrintf
		
		; the preceding call will never return
	endBlockAt off_divideByZeroHandler_end
endPatch
