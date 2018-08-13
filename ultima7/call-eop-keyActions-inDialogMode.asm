%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; Call the new key-handler procedure from the gump (dialog) loop
; to enable the use of many key commands while Stats or Inventory
; dialogs are on-screen. Gives the player flexibility and removes
; some of the distinction between the two modes of gameplay.
startPatch EXE_LENGTH, \
		call new key-handler in dialog loop
		
	off_handleKeyInput                  EQU 0x0EC2
	off_afterHandlingKeyInput           EQU 0x0F80
	startBlockAt 340, off_handleKeyInput
		cmp byte [dseg_isKeyMouseEnabled], 0
		jnz afterKeyActions
		push 0
		callEopFromOverlay 1, keyActions
		pop cx
		afterKeyActions:
		
		jmp calcJump(off_afterHandlingKeyInput)
	endBlockAt off_afterHandlingKeyInput
	
	off_mappingTable                    EQU 0x1030
	off_mappingTable_end                EQU 0x1044
	startBlockAt 340, off_mappingTable
		; 'i', 'z', and Escape are now handled in eop-keyActions
	endBlockAt off_mappingTable_end
endPatch
