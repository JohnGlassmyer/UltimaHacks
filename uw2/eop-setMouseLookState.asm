%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		expanded overlay procedure: setMouseLookState
		
	startBlockAt off_eop_setMouseLookState
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_newMouseLookState   0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_seg015Base         -0x02
		add sp, var_seg015Base
		
		push si
		push di
		
		; determine relocated base of seg015 (base 0x1B8F / 0x0080)
		pushWithRelocation 0x0080
		pop word [bp+var_seg015Base]
		
		cmp word [bp+arg_newMouseLookState], 0
		jz disableMouseLook
		
		enableMouseLook:
			mov byte [dseg_isMouseLookEnabled], 1
			
			; disable Tab and Shift+Tab cursor-movement keys
				mov es, [bp+var_seg015Base]
				mov word [es:0x0DD5], 0x9090 ; <nop> <nop>
				mov word [es:0x0E15], 0x9090 ; <nop> <nop>
				
			; erase cursor at its current location
				callWithRelocation o_eraseCursorIfVisible
				
			; save cursor coordinates and place cursor in middle of screen
				mov ax, [dseg_cursorX]
				mov word [dseg_cursorXDuringMouseLook], ax
				mov word [dseg_cursorX], 120
				
				movzx ax, byte [dseg_cursorY]
				mov word [dseg_cursorYDuringMouseLook], ax
				mov byte [dseg_cursorY], 120
				
			; forge a point cursor-area to protect the cursor image
				mov ax, [dseg_cursorX]
				mov [dseg_currentCursorAreaMinX], ax
				mov [dseg_currentCursorAreaMaxX], ax
				
				movzx ax, [dseg_cursorY]
				mov [dseg_currentCursorAreaMinY], ax
				mov [dseg_currentCursorAreaMaxY], ax
				
			; save background pixels in new location (over 3d view)
			; before setCursorImage redraws the cursor background
				callWithRelocation o_savePixelsAroundCursor
				
			; if the cursor is moving or using an item, don't change the image
				cmp word [dseg_cursorMode], 0
				jnz afterSettingToCrosshairs
				
			; set cursor to crosshairs
				push dseg_cursorNumbersArray + 0
				callWithRelocation o_setCursorImage
				add sp, 2
				
			afterSettingToCrosshairs:
			
			jmp endProc
			
		disableMouseLook:
			mov byte [dseg_isMouseLookEnabled], 0
			
			; re-enable Tab and Shift+Tab cursor-movement keys
				mov es, [bp+var_seg015Base]
				mov word [es:0x0DD5], 0x7774 ; <jz 0x77>
				mov word [es:0x0E15], 0x0374 ; <jz 0x03>
				
			; automatic redraw of 3d view will erase cursor image left there
			
			; restore cursor coordinates from before mouse-look
				mov ax, [dseg_cursorXDuringMouseLook]
				mov [dseg_cursorX], ax
				mov ax, [dseg_cursorYDuringMouseLook]
				mov byte [dseg_cursorY], al
				
			; saving the background pixels at the restored cursor location
			; before updateCursorRegion redraws them
				callWithRelocation o_savePixelsAroundCursor
				
			; update cursor region, to select the cursor image appropriate
			; to the restored cursor location
				callWithRelocation o_updateCursorRegion
				
			; and draw the cursor (in its restored location)
				callWithRelocation o_drawCursor
				
		endProc:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_setMouseLookState_end
endPatch
