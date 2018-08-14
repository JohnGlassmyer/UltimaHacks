%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	%include "include/uw1-eop.asm"
%endif

[bits 16]

startPatch EXE_LENGTH, \
		expanded overlay procedure: interactAtCursor
		
	startBlockAt addr_eop_interactAtCursor
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_interactionType     0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		; if the cursor is moving or using an item, don't try to Use
			cmp word [dseg_cursorMode], 0
			jz afterCheckingCursorMode
			
			cmp word [bp+arg_interactionType], 0
			jz endProc
			
		afterCheckingCursorMode:
		
		; don't interact if cursor is not within 3d-view area
			mov ax, [dseg_cursorX]
			cmp ax, [dseg_3dViewLeftX]
			jl endProc
			sub ax, [dseg_3dViewWidth]
			cmp ax, [dseg_3dViewLeftX]
			jg endProc
			
			mov ax, [dseg_cursorY]
			cmp ax, [dseg_3dViewBottomY]
			jl endProc
			sub ax, [dseg_3dViewHeight]
			cmp ax, [dseg_3dViewBottomY]
			jg endProc
			
		; map cursor coords to inputState coords (relative to the 3d-view area)
		; so that findItemAtCursor looks up the appropriate 3d-view pixel
			mov bx, [dseg_pn_inputState]
			mov ax, [dseg_cursorX]
			sub ax, [dseg_3dViewLeftX]
			mov [bx+InputState_relativeX], ax
			mov ax, [dseg_cursorY]
			sub ax, [dseg_3dViewBottomY]
			mov [bx+InputState_relativeY], ax
			
		push 2
		callFromOverlay findItemAtCursor
		add sp, 2
		
		mov [dseg_ps_itemAtCursor+2], dx
		mov [dseg_ps_itemAtCursor+0], ax
		
		test ax, dx
		jnz lookOrUseClickedItem
		
		; no item clicked. but, if Looking, describe clicked terrain
			cmp word [bp+arg_interactionType], 1
			jnz endProc
			
			push word [dseg_findItemThing]
			push 2 ; Look interaction-mode
			callFromOverlay describeClickedTerrain
			add sp, 4
			
			jmp endProc
			
		lookOrUseClickedItem:
			cmp word [bp+arg_interactionType], 1
			jz lookItem
			jmp useItem
			
		useItem:
			push dx
			push ax
			callFromOverlay isItemCharacter
			add sp, 4
			test al, al
			jz notCharacter
			
			character:
				les bx, [dseg_ps_itemAtCursor]
				mov ax, [es:bx]
				and ax, 0b0000000111000000
				shr ax, 6
				cmp ax, 1
				jz doTalk
				jmp notCharacter
				
			notCharacter:
				les bx, [dseg_ps_itemAtCursor]
				mov ax, [es:bx]
				and ax, 0b0000000111111111
				cmp ax, 0x1CD
				jz doTalk
				jmp doUse
				
			doTalk:
				callFromOverlay talkModeProc
				jmp endProc
				
			doUse:
				callFromOverlay useModeProc
				jmp endProc
				
		lookItem:
			callFromOverlay lookModeProc
			
			jmp endProc
			
		endProc:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_interactAtCursor_end
endPatch
