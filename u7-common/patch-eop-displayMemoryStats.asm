; Show memory usage stats in a "scroll" popup.

[bits 16]

startPatch EXE_LENGTH, eop-displayMemoryStats
	startBlockAt addr_eop_displayMemoryStats
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_string             -0x80
		%assign var_farString          -0x84
		add sp, var_farString
		
		push si
		push di
		
		lea si, [bp+var_farString]
		push si
		callFromOverlay FarString_new
		pop cx
		
		push dseg_originalFreeMemoryStats
		callFromOverlay sprintfMemoryUsage
		pop cx
		
		; massage the memory-stats text so that it displays
		; nicely in the "scroll" popup without line-wrapping
			mov di, [dseg_pn_workstring]
			lea bx, [bp+var_string]
			forCharacter:
				mov ax, [ds:di]
				cmp al, 0
				jz afterTranslatingString
				
				cmp ax, '  '
				jnz notTwoSpaces
				; skip second of two subsequent spaces
				inc di
				notTwoSpaces:
				
				cmp al, "'"
				jnz notQuote
				; skip single-quote mark
				inc di
				jmp forCharacter
				notQuote:
				
				cmp al, ' '
				jae notUnprintable
				mov al, '~'
				notUnprintable:
				
				doneWithCharacter:
				mov [bx], al
				inc di
				inc bx
				jmp forCharacter
				
			afterTranslatingString:
			mov byte [bx], 0
			
		push 1000
		push ss
		lea ax, [bp+var_string]
		push ax
		push word [si+2]
		push word [si+0]
		callFromOverlay strncat_far
		add sp, 10
		
		; print the current value of the stack pointer and the segment-
		;     relocation base of the loaded executable
			lea bx, [bp+var_string+0x40]
			fmemcpy ss, bx, \
					cs, offsetInCodeSegment(stackAndRelocationTemplate), \
					stackAndRelocationTemplate_end - stackAndRelocationTemplate
			
			pushWithRelocation 0
			push sp
			lea ax, [bp+var_string+0x40]
			push ax
			lea ax, [bp+var_string]
			push ax
			callFromOverlay sprintf
			add sp, 8
			
			push 1000
			push ss
			lea ax, [bp+var_string]
			push ax
			push word [si+2]
			push word [si+0]
			callFromOverlay strncat_far
			add sp, 10
			
		push TextDisplayType_SCROLL
		push si
		callVarArgsEopFromOverlay displayText, 2
		pop cx
		pop cx
		
		push 0
		push si
		callFromOverlay FarString_destructor
		pop cx
		pop cx
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
		stackAndRelocationTemplate:
			db '~sp: %04X'
			db '~'
			db '~seg 0: %04X'
			db 0
			stackAndRelocationTemplate_end:
			
	endBlockAt off_eop_displayMemoryStats_end
endPatch
