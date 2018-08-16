; Adds the ability to suppress printing of bark-texts by setting a global flag.
; Used to suppress the printing of (redundant and sometimes inaccurate) spell-
;     rune incantations by the Avatar that are triggered by spell Usecode.

[bits 16]

startPatch EXE_LENGTH, suppressBarks
	%macro maybeSuppressBarkWhileGettingItemZ 2
		%define %%ibo %1
		%define %%off_dontBark %2
		
		cmp byte [dseg_areBarksSuppressed], 0
		jnz calcJump(%%off_dontBark)
		
		push word %%ibo
		callVarArgsEopFromOverlay getItemZ, 1
		pop cx
		
		; leave item Z in ax
	%endmacro
	
	startBlockAt addr_barkWithoutDialogs_getItemZ
		maybeSuppressBarkWhileGettingItemZ \
				barkWithoutDialogs_ibo, off_barkWithoutDialogs_dontBark
		
		times 15 nop
	endBlockAt off_barkWithoutDialogs_getItemZ_end
	
	startBlockAt addr_barkWithDialogs_getItemZ
		maybeSuppressBarkWhileGettingItemZ \
				barkWithDialogs_ibo, off_barkWithDialogs_dontBark
		
		times 6 nop
	endBlockAt off_barkWithDialogs_getItemZ_end
endPatch
