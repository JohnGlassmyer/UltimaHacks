%include "../UltimaPatcher.asm"
%include "include/uw1.asm"
%include "include/uw1-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		dispatch table for eop procs
		
	startBlockAt off_eop_dispatchTable
		%assign eopNumber 0
		%rep nextEopNumber
			dw off_eop_%[eopNumber] - off_eop_segmentZero
			
			%assign eopNumber eopNumber + 1
		%endrep
	endBlockAt off_eop_dispatchTable_end
endPatch
