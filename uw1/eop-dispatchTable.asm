%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	%include "include/uw1-eop.asm"
%endif

[bits 16]

startPatch EXE_LENGTH, \
		dispatch table for eop procs
		
	startBlockAt addr_eop_dispatchTable
		%assign eopNumber 0
		%rep nextEopNumber
			dw off_eop_%[eopNumber]
			
			%assign eopNumber eopNumber + 1
		%endrep
	endBlockAt off_eop_dispatchTable_end
endPatch
