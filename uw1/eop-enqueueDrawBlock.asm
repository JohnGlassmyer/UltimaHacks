%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	%include "include/uw1-eop.asm"
	
	%assign off_drawQueueLimit 0xAFF4
%endif

; assumption: each block adds fewer than 0x300 bytes to the draw queue
%assign off_drawQueueSafeLimit off_drawQueueLimit - 0x300

[bits 16]

startPatch EXE_LENGTH, \
		expanded overlay procedure: enqueueDrawBlock
		
	startBlockAt addr_eop_enqueueDrawBlock
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_gridIndex           0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_string             -0x30
		add sp, var_string
		
		push si
		push di
		
		; skip drawing this block if doing so is likely
		; to cause the draw queue to overflow
			cmp word [dseg_ps_drawQueueEnd], off_drawQueueSafeLimit
			ja skipDrawing
			
		safeToDraw:
			mov ax, [bp+arg_gridIndex]
			add ax, dseg_mappedTerrain
			push ax
			callFromOverlay enqueueDrawBlock
			add sp, 2
			
			jmp endProc
			
		skipDrawing:
		; don't print the warning message a second time
			cmp byte [dseg_haveWarnedAboutDrawQueueLimit], 0
			jnz endProc
			
		; print a warning message about approaching the draw queue limit
			push cs
			push offsetInCodeSegment(drawQueueLimitWarningString)
			callFromOverlay printStringToScroll
			add sp, 4
			
			mov byte [dseg_haveWarnedAboutDrawQueueLimit], 1
			
		endProc:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
		drawQueueLimitWarningString:
			db `Warning: draw queue close to overflowing;`
			db ` skipped drawing block.`
			db `\n\0`
	endBlockAt off_eop_enqueueDrawBlock_end
endPatch
