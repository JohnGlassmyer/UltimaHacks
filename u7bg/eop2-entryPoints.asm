%include "include/u7bg-all-includes.asm"

startPatch EXE_LENGTH, eop2-entryPoints
	startBlockAt addr_eop2_entry1
		jmp calcJump(off_eop2_varArgsDispatcher)
		
		times 3 nop
	endBlockOfLength 5
	
	startBlockAt addr_eop2_entry2
		retf
		
		times 4 nop
	endBlockOfLength 5
	
	startBlockAt addr_eop2_entry3
		retf
		
		times 4 nop
	endBlockOfLength 5
endPatch
