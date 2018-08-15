%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	%include "include/uw1-eop.asm"
%endif

[bits 16]

startPatch EXE_LENGTH, \
		expanded overlay procedure: toggleMouseLook
		
	startBlockAt addr_eop_toggleMouseLook
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_string             -0x20
		
		add sp, var_string
		push si
		push di
		
		cmp byte [dseg_isMouseLookEnabled], 0
		jz enableMouseLook
		
		disableMouseLook:
			push 0
			call calcJump(off_eop_setMouseLookState)
			add sp, 2
			
			mov ax, offsetInCodeSegment(mouseLookDisabledString)
			
			jmp printString
			
		enableMouseLook:
			push 1
			call calcJump(off_eop_setMouseLookState)
			add sp, 2
			
			mov ax, offsetInCodeSegment(mouseLookEnabledString)
			
		printString:
			mov byte [bp+var_string], 0
			
			push cs
			push ax
			push ss
			lea ax, [bp+var_string]
			push ax
			callFromOverlay strcat_far
			add sp, 8
			
			push ss
			lea ax, [bp+var_string]
			push ax
			callFromOverlay printStringToScroll
			add sp, 4
			
		endProc:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
		mouseLookEnabledString:
			db "Mouse look enabled.", `\n`, 0
			
		mouseLookDisabledString:
			db "Mouse look disabled.", `\n`, 0
			
	endBlockAt off_eop_toggleMouseLook_end
endPatch
