%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

startPatch EXE_LENGTH, \
		call eop-produceItemLabelText when clicking items
		
	off_clickItemInWorld                EQU 0x03CF
	off_clickItemInWorld_end            EQU 0x044A
	startBlockAt 243, off_clickItemInWorld
		; [bp-2] is ibo
		; [bp-0x68] is string
		mov byte [bp-0x68], 0
		mov word [bp-0x17], 0
		
		push word [bp-2]
		lea ax, [bp-0x68]
		push ax
		callEopFromOverlay 2, produceItemLabelText
		add sp, 4
	endBlockWithFillAt nop, off_clickItemInWorld_end
	
	off_clickItemInInventory            EQU 0x1895
	off_clickItemInInventory_end        EQU 0x1907
	startBlockAt 340, off_clickItemInInventory
		; [bp+6] is iboRef
		; [bp-0x60] is string
		mov bx, [bp+6]
		push word [bx]
		lea ax, [bp-0x60]
		push ax
		callEopFromOverlay 2, produceItemLabelText
		add sp, 4
	endBlockWithFillAt nop, off_clickItemInInventory_end

endPatch
