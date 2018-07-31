%include "../UltimaPatcher.asm"
%include "include/uw1.asm"

[bits 16]

%define off_haveSelectedOption 0x801B8
%define off_nextInput          0x801C9

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		wrap navigation of main-menu options from end to start and vice-versa
		
	startBlockAt off_haveSelectedOption
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
