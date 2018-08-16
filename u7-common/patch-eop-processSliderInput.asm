; Add keyboard controls and right-click-to-close to quantity sliders.

[bits 16]

startPatch EXE_LENGTH, eop-processSliderInput
	; needs to do the Close-button check in whose place it is called
	startBlockAt addr_eop_processSliderInput
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_pn_mouseState       0x06
		%assign arg_pn_Slider_this      0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		mov si, [bp+arg_pn_Slider_this]
		mov di, [bp+arg_pn_mouseState]
		
		cmp byte [di+MouseState_action], MouseAction_PRESS
		jz tryButtons
		jmp tryKeys
		
		tryButtons:
		; click of mouse button 1? (-> process mb1 input)
			cmp byte [di+MouseState_button], 1
			jnz tryButton2
			push di
			push si
			callFromOverlay Slider_processInput
			pop cx
			pop cx
			; return the original handler's return value as-is
			jmp endProc
			
		tryButton2:
		; click of mouse button 2? (-> close slider)
			cmp byte [di+MouseState_button], 2
			jz returnToCloseSlider
			jmp returnToContinueSlider
			
		tryKeys:
		; shift pressed? (-> step value 5x per key)
			mov di, 1
			callFromOverlay getLeftAndRightShiftStatus
			or ax, ax
			jz justOneStep
			mov di, 5
			justOneStep:
			
		; key pressed? (-> step value up or down; accept)
			callFromOverlay pollKeyToGlobalDiscarding
			or ax, ax
			jz returnToContinueSlider
		; determine what to do with key
			mov ax, [dseg_polledKey]
			cmp ax, 0x148 ; Up
			jz up
			cmp ax, 0x150 ; Down
			jz down
			cmp ax, 0x14B ; Left
			jz left
			cmp ax, 0x14D ; Right
			jz right
			cmp ax, 0xD   ; Enter
			jz returnToCloseSlider
			jmp returnToContinueSlider
			
		up:
			; set to min value
			mov ax, [si+0x77]
			jmp setSliderValue
		down:
			; set to max value
			mov ax, [si+0x79]
			jmp setSliderValue
		setSliderValue:
			mov [si+0x85], ax
			jmp returnToRedrawSlider
			
		left:
			; decrease quantity
			push si
			callFromOverlay Slider_stepDown
			pop cx
			dec di
			or di, di
			jnz left
			jmp returnToRedrawSlider
			
		right:
		; increase quantity
			push si
			callFromOverlay Slider_stepUp
			pop cx
			dec di
			or di, di
			jnz right
			jmp returnToRedrawSlider
			
		returnToCloseSlider:
			mov ax, 0x1
			jmp endProc
			
		returnToRedrawSlider:
			mov ax, 0xB
			jmp endProc
			
		returnToContinueSlider:
			mov ax, 0
			jmp endProc
			
		endProc:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_processSliderInput_end
endPatch
