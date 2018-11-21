%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	%include "include/uw1-eop.asm"
%endif

[bits 16]

startPatch EXE_LENGTH, eop-orientMouseLook
	startBlockAt addr_eop_orientMouseLook
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_string             -0x20
		
		add sp, var_string
		push si
		push di
		
		movzx ax, byte [dseg_mouseLookOrientation]
		inc al
		add al, 4
		mov bl, 4
		div bl
		mov byte [dseg_mouseLookOrientation], ah
		
		mov byte [bp+var_string], 0
		
		push cs
		push offsetInCodeSegment(orientationString)
		push ss
		lea ax, [bp+var_string]
		push ax
		callFromOverlay strcat_far
		add sp, 8
		
		test byte [dseg_mouseLookOrientation], MOUSE_LOOK_INVERT_X
		jz afterXSign
		mov byte [bp+var_string+xSign-orientationString], '-'
		afterXSign:
		
		test byte [dseg_mouseLookOrientation], MOUSE_LOOK_INVERT_Y
		jz afterYSign
		mov byte [bp+var_string+ySign-orientationString], '-'
		afterYSign:
		
		push ss
		lea ax, [bp+var_string]
		push ax
		callFromOverlay printStringToScroll
		add sp, 4
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
		orientationString:
			db 'Mouse-look orientation: ',
			xSign: db '+X '
			ySign: db '+Y'
			db `\n`, 0
			
	endBlockAt off_eop_orientMouseLook_end
endPatch
