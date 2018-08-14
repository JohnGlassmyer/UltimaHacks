%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	%include "include/uw1-eop.asm"
%endif

[bits 16]

startPatch EXE_LENGTH, \
		expanded overlay procedure: enqueueGridCoords
		
	startBlockAt addr_eop_enqueueGridCoords
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_height              0x08
		%assign arg_row                 0x06
		%assign arg_column              0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		cmp byte [dseg_isDrawingBehindPlayer], 1
		jz isDrawingBehindPlayer
		
		isDrawingAheadOfPlayer:
			push word [bp+arg_height]
			push word [bp+arg_row]
			push word [bp+arg_column]
			callFromOverlay enqueueGridCoords
			add sp, 6
			
			jmp endProc
			
		isDrawingBehindPlayer:
		; call original proc with coords rotated 180 degrees
			push word [bp+arg_height]
			movsx ax, byte [bp+arg_row]
			neg ax
			inc ax
			push ax
			movsx ax, byte [bp+arg_column]
			sub ax, 16
			neg ax
			inc ax
			add ax, 16
			push ax
			callFromOverlay enqueueGridCoords
			add sp, 6
			
			jmp endProc
			
		endProc:
		
		; preserve return value of enqueueGridCoords in ax
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_enqueueGridCoords_end
endPatch
