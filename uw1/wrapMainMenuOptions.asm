%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	
	defineAddress 138, 0x08F8, haveSelectedOption
	defineAddress 138, 0x0909, nextInput
%endif

[bits 16]

startPatch EXE_LENGTH, \
		wrap navigation of main-menu options from end to start and vice-versa
		
	startBlockAt addr_haveSelectedOption
		; si == selected option index
		; di == number of options
		
		or si, si
		jl wrapToEnd
		
		cmp si, di
		jl calcJump (off_nextInput)
		
		wrapToStart:
			xor si, si
			jmp calcJump (off_nextInput)
			
		wrapToEnd:
			mov ax, di
			dec ax
			mov si, ax
	endBlockAt off_nextInput
endPatch
