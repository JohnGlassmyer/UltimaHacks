; Splits the pollKeyAndTranslateWithMouse function into two functions: one, at
;     the original entry point, which behaves as before, polling for a keycode
;     and then translating it together with mouse actions, and another, at an
;     entry point located within the original function body, which translates a
;     provided keycode without itself polling for one.
; This separates out the key/mouse-translation functionality without breaking
;     existing callers (e.g. displayMap) of the original function.

[bits 16]

startPatch EXE_LENGTH, splitTranslateKeyAndMouse
	startBlockAt addr_pollKeyAndTranslateWithMouse
		push bp
		mov bp, sp
		
		%assign arg_pn_mouseY    0x0A
		%assign arg_pn_mouseX    0x08
		%assign arg_pn_keyCode   0x06
		%assign ____callerCs     0x04
		%assign ____callerIp     0x02
		%assign ____callerBp     0x00
		%assign var_shiftStatus -0x02
		%assign var_mouseAction -0x03
		%assign var_mouseButton -0x04
		%assign var_mouseState  -0x10
		add sp, var_mouseState
		
		push si
		push di
		
		push 1
		callFromLoadModule pollKey
		pop cx
		
		mov bx, [bp+arg_pn_keyCode]
		mov [bx], ax
		
		jmp junctionPoint
		
		; ---------
		times (off_translateKeyWithMouse - block_currentOffset) nop
		
		push bp
		mov bp, sp
		
		%assign arg_pn_mouseY    0x0A
		%assign arg_pn_mouseX    0x08
		%assign arg_pn_keyCode   0x06
		%assign ____callerCs     0x04
		%assign ____callerIp     0x02
		%assign ____callerBp     0x00
		%assign var_shiftStatus -0x02
		%assign var_mouseAction -0x03
		%assign var_mouseButton -0x04
		%assign var_mouseState  -0x10
		add sp, var_mouseState
		
		%define reg_pn_keyCode   si
		%define reg_pn_mouseX    di
		
		push si
		push di
		
		; here the two functions' paths of execution merge
		junctionPoint:
		
		xor ax, ax
		mov reg_pn_mouseX, [bp+arg_pn_mouseX]
		mov [reg_pn_mouseX], ax
		mov bx, [bp+arg_pn_mouseY]
		mov [bx], ax
		
		mov reg_pn_keyCode, [bp+arg_pn_keyCode]
		
		cmp word [reg_pn_keyCode], ' '
		jz calcJump(off_doKeyMouse)
		
		mov byte [bp+var_mouseState+MouseState_action], MouseAction_NONE
		
		callFromLoadModule getLeftAndRightShiftStatus
		mov [bp+var_shiftStatus], ax
		
		; jump over the key-mouse code
		jmp calcJump(off_doKeyMouse_end)
		
		off_numberForDirectionKey EQU block_currentOffset
			dw 0x148, '8'
			dw 0x14B, '4'
			dw 0x14D, '6'
			dw 0x150, '2'
			off_numberForDirectionKey_end EQU block_currentOffset
			
;		times 8 nop
	endBlockAt off_doKeyMouse
	
	startBlockAt addr_doKeyMouse_end
		mov ax, [reg_pn_keyCode]
		
		mov bx, off_numberForDirectionKey
		forDirectionKey:
			; if no more direction keys to test, then translate mouse buttons
				cmp bx, off_numberForDirectionKey_end
				jae calcJump(off_readMouseState)
				
			cmp ax, [cs:bx+0]
			jnz notThisDirectionKey
			
			; without Shift, use the direction key as-is
				cmp word [bp+var_shiftStatus], 0
				jz calcJump(off_haveKeyAndMouseState)
				
			; with Shift, translate the direction key to its corresponding digit
				mov ax, [cs:bx+2]
				mov [reg_pn_keyCode], ax
				jmp calcJump(off_haveKeyAndMouseState)
				
			notThisDirectionKey:
			
			add bx, 4
			jmp forDirectionKey
			
		times 13 nop
	endBlockAt off_readMouseState
endPatch
