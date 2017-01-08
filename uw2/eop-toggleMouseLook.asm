%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		expanded overlay procedure: toggleMouseLook
		
	startBlockAt off_eop_toggleMouseLook
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
			
			mov ax, offsetInEopSegment(mouseLookDisabledString)
			
			jmp printString
			
		enableMouseLook:
			push 1
			call calcJump(off_eop_setMouseLookState)
			add sp, 2
			
			mov ax, offsetInEopSegment(mouseLookEnabledString)
			
		printString:
			mov byte [bp+var_string], 0
			
			push cs
			push ax
			push ss
			lea ax, [bp+var_string]
			push ax
			callWithRelocation o_strcat_far
			add sp, 8
			
			push ss
			lea ax, [bp+var_string]
			push ax
			callWithRelocation o_printStringToScroll
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
