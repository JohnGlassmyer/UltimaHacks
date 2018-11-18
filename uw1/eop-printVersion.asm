%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	%include "include/uw1-eop.asm"
%endif

[bits 16]

startPatch EXE_LENGTH, eop-printVersion
	startBlockAt addr_eop_printVersion
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_string             -0x40
		add sp, var_string
		
		callFromOverlay printVersion
		
		mov ax, offsetInCodeSegment(ultimaHacksString1)
		call printString
		
		mov ax, offsetInCodeSegment(ultimaHacksString2)
		call printString
		
		mov sp, bp
		pop bp
		retn
		
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
			pop cx
			pop cx
			
			retn
			
		ultimaHacksString1:
			db 'with UltimaHacks (assembled ', __DATE__, ')', `\n`, 0
			
		ultimaHacksString2:
			db 'https://github.com/JohnGlassmyer/UltimaHacks', `\n`, 0
			
	endBlockAt off_eop_printVersion_end
endPatch
