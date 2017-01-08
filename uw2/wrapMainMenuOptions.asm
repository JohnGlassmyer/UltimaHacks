%include "../UltimaPatcher.asm"
%include "include/uw2.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		wrap navigation of main-menu options from end to start and vice-versa
		
	startBlockAt 0x992C6
		; si == selected option index
		; di == number of options
		
		or si, si
		jl wrapToEnd
		
		cmp si, di
		jl calcJump (0x992D7)
		
		wrapToStart:
			xor si, si
			jmp calcJump (0x992D7)
			
		wrapToEnd:
			mov ax, di
			dec ax
			mov si, ax
	endBlockAt 0x992D7
endPatch
