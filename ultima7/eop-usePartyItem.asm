%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

; Find and use a matching item held by a party member.
startPatch EXE_LENGTH, \
		eop-usePartyItem
		
	startBlockAt seg_eop, off_eop_usePartyItem
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_itemFrame           0x08
		%assign arg_itemQuality         0x06
		%assign arg_itemType            0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_foundItemIbo       -0x02
		add sp, var_foundItemIbo
		
		push si
		push di
		
		push word [bp+arg_itemFrame]
		push word [bp+arg_itemQuality]
		push word [bp+arg_itemType]
		callEopFromOverlay 3, findPartyItem
		add sp, 6
		
		cmp ax, 0
		jz noItemFound
		
		mov word [bp+var_foundItemIbo], ax
		
		foundItem:
			; Enable Hack Mover temporarily so use doesn't get blocked
			; if sailing a ship. The item is held by a party member, so
			; it's probably reasonable to be able to access it.
			movzx si, byte [dseg_hackMoverEnabled]
			mov byte [dseg_hackMoverEnabled], 1
			
			push word 0 ; flags
			push word 0 ; y coordinate
			push word 0 ; x coordinate
			lea ax, [bp+var_foundItemIbo]
			push ax     ; ibo ref
			callFromOverlay use
			add sp, 8
			
			; restore state of Hack Mover
			mov ax, si
			mov byte [dseg_hackMoverEnabled], al
			
			mov ax, [bp+var_foundItemIbo]
			jmp endProc
			
		noItemFound:
			mov ax, 0
			
		endProc:
			; ax == ibo of found & used item, or 0
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_usePartyItem_end
endPatch
