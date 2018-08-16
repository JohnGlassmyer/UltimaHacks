; Determines whether an item is a valid target for dropping other items into.

%include "include/u7si-all-includes.asm"

[bits 16]

startPatch EXE_LENGTH, eop-printDarkPathDestinations
	%assign ToothDestination_x      0
	%assign ToothDestination_y      2
	%assign ToothDestination_string 4
	
	startBlockAt addr_eop_printDarkPathDestinations
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp                0x02
		%assign ____callerBp                0x00
		%assign var_findItemQuery          -0x30
		%assign var_string                 -0x50
		add sp, var_string
		
		push si
		push di
		
		lea si, [bp+var_findItemQuery]
		
		push 0xFF
		push 0xFF
		push 559 ; serpent tooth
		push 0 ; queryFlags
		push dseg_avatarIbo
		push si
		callFromOverlay findItemInContainer
		add sp, 12
		
		.forFoundTooth:
			mov bx, [si+FindItemQuery_ibo]
			
			test bx, bx
			jz .noMoreTeeth
			
			; item frame identifies the particular tooth
			mov es, [dseg_itemBufferSegment]
			mov bx, [es:bx+4]
			shr bx, 10
			
			push bx
			mov dword [bp+var_string], `%d \0`
			lea ax, [bp+var_string]
			push ax
			push 1
			push 1
			callFromOverlay debugPromptfAtCoords
			add sp, 8
			
			shl bx, 1
			mov bx, [cs:offsetInCodeSegment(toothDestinations)+bx]
			
			lea di, [bp+var_string]
			
			lea ax, [bx+ToothDestination_string]
			%assign MAX_TOOTH_STRING_LENGTH 0x20
			fmemcpy ss, di, cs, ax, MAX_TOOTH_STRING_LENGTH
			
			push di
			push TextAlignment_HORIZONTAL_CENTER | TextAlignment_VERTICAL_CENTER
			push Font_TINY_BLACK
			push word [cs:bx+ToothDestination_y]
			push word [cs:bx+ToothDestination_x]
			push dseg_viewport
			callVarArgsEopFromOverlay printText, 6
			add sp, 12
			
			push si
			callFromOverlay findItem
			pop cx
			jmp .forFoundTooth
			
			.noMoreTeeth:
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
		toothDestinations:
			%assign toothFrame 0
			%rep 18
				dw offsetInCodeSegment(tooth_ %+ toothFrame)
				
				%assign toothFrame (toothFrame + 1)
			%endrep
			
		%macro tooth 4
			tooth_ %+ %1:
			dw %2, %3
			db %4, 0
		%endmacro
		
		tooth  0, 160,  49, 'Balance'
		tooth  1,  73,  67, 'Emotion'
		tooth  2, 118,  49, 'Skullcrusher'
		tooth  3, 203,  49, 'Spinebreaker'
		tooth  4, 248,  67, 'Discipline'
		tooth  5, 236,  94, 'Monk Isle'
		tooth  6, 285,  94, 'Isle of Crypts'
		tooth  7, 236, 116, 'Fawn'
		tooth  8, 285, 116, 'Great N. Forest'
		tooth  9,  36,  94, 'Sleeping Bull'
		tooth 10,  85,  94, 'Furnace'
		tooth 11,  36, 116, 'Mad Mage'
		tooth 12,  85, 116, 'Moonshade'
		tooth 13,  73, 145, 'Enthusiasm'
		tooth 14, 118, 163, 'Tolerance'
		tooth 15, 160, 164, 'Monitor'
		tooth 16, 203, 163, 'Ethicality'
		tooth 17, 248, 145, 'Logic'
	endBlockAt off_eop_printDarkPathDestinations_end
endPatch
