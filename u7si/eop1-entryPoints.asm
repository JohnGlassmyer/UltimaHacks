%include "include/u7si-all-includes.asm"

startPatch EXE_LENGTH, eop1-entryPoints
	startBlockAt addr_eop1_entry1
		jmp calcJump(off_eop1_varArgsDispatcher)
		
		times 3 nop
	endBlockOfLength 5
	
	startBlockAt addr_eop1_entry2
		jmp calcJump(off_eop1_byteArgDispatcher)
		
		times 3 nop
	endBlockOfLength 5
	
	startBlockAt addr_eop1_entry3
		retf
		
		times 4 nop
	endBlockOfLength 5
endPatch
