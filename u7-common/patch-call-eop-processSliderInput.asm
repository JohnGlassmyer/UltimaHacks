[bits 16]

startPatch EXE_LENGTH, call-eop-processSliderInput
	; don't enable keyMouse mode, which would block the Left and Right keys
	startBlockAt addr_doSlider_switchToKeyMouseMode
		jmp calcJump(off_doSlider_switchToKeyMouseMode_end)
	endBlockWithFillAt nop, off_doSlider_switchToKeyMouseMode_end
	
	startBlockAt addr_doSlider_haveMouseState
		%assign var_pn_mouseState -0x12
		%assign var_pn_slider -0x9A
		
		lea ax, [bp+var_pn_mouseState]
		push ax
		lea ax, [bp+var_pn_slider]
		push ax
		callVarArgsEopFromOverlay processSliderInput, 2
		pop cx
		pop cx
		
		jmp calcJump(off_doSlider_afterProcessInput)
		
		times 23 nop
	endBlockAt off_doSlider_afterProcessInput
endPatch
