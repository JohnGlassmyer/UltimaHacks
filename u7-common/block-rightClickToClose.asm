[bits 16]
	%macro checkMouseCoordsAndButton 0
		mov bx, [bp+arg_pn_mouseState]
		mov ax, [bx+2]
		shr ax, 1
		mov [bp+var_mouseX], ax
		mov [bp+var_mouseXy], ax
		mov ax, [bx+4]
		mov [bp+var_mouseY], ax
		mov [bp+var_mouseXy+2], ax
		
		lea bx, [pn_bounds]
		
		mov ax, [bx]
		cmp ax, [bp+var_mouseX]
		jg %%notInBounds
		
		mov ax, [bx+4]
		cmp ax, [bp+var_mouseX]
		jl %%notInBounds
		
		mov ax, [bx+2]
		cmp ax, [bp+var_mouseY]
		jg %%notInBounds
		
		mov ax, [bx+6]
		cmp ax, [bp+var_mouseY]
		jl %%notInBounds
		
		lea ax, [bp+var_mouseXy]
		push ax
		push bx
		push 0
		push word [pn_controlPosition]
		push dseg_shapeManager
		callFromOverlay isCursorInBounds
		add sp, 10
		mov byte [bp+var_inBoundsReturn], al
		or al, al
		jz calcJump(off_notInBounds)
		
		mov bx, [bp+arg_pn_mouseState]
		cmp byte [bx+MouseState_button], 2
		jz calcJump(off_returnCloseCode)
		
		jmp calcJump(off_mouseInBounds)
		
		%%notInBounds:
		jmp calcJump(off_notInBounds)
	%endmacro
	
	; don't skip mouse button 2 events when processing input for dialogs
	startBlockAt addr_processInput_skipIfMouse2
		nop
		nop
	endBlock
	
	; prevent buttons from intercepting mouse button 2
	startBlockAt addr_Button_checkCoords
		%assign arg_pn_mouseState       0x08
		%assign var_mouseX             -0x06
		%assign var_mouseY             -0x04
		%assign var_xyBounds           -0x0E
		
		mov bx, [bp+arg_pn_mouseState]
		mov ax, [bx+2]
		shr ax, 1
		mov [bp+var_mouseX], ax
		mov ax, [bx+4]
		mov [bp+var_mouseY], ax
		
		mov ax, [bp+var_mouseX]
		cmp ax, [bp+var_xyBounds+XyBounds_minX]
		jl notInBounds
		
		mov ax, [bp+var_mouseX]
		cmp ax, [bp+var_xyBounds+XyBounds_maxX]
		jg notInBounds
		
		mov ax, [bp+var_mouseY]
		cmp ax, [bp+var_xyBounds+XyBounds_minY]
		jl notInBounds
		
		mov ax, [bp+var_mouseY]
		cmp ax, [bp+var_xyBounds+XyBounds_maxY]
		jg notInBounds
		
		lea ax, [bp+var_mouseX]
		push ax
		lea ax, [bp+var_xyBounds+XyBounds_maxX]
		push ax
		push word [si+0x14]
		push word [si+0x12]
		push dseg_shapeManager
		callFromOverlay isCursorInBounds
		add sp, 10
		
		or ax, ax
		jz notInBounds
		
		mov bx, [bp+arg_pn_mouseState]
		cmp byte [bx+MouseState_button], 2
		jz notPressed
		jmp calcJump(off_Button_mouseInBounds)
		
		notInBounds:
		jmp calcJump(off_Button_notInBounds)
		
		notPressed:
		jmp calcJump(off_Button_notPressed)
		
		times 50 nop
	endBlockAt off_Button_mouseInBounds
	
	startBlockAt addr_Spellbook_checkCoords
		%assign arg_pn_mouseState       0x08
		%assign var_mouseXy            -0x04
		%assign var_isInButtonBounds   -0x05
		%assign var_isInBounds         -0x06
		
		mov bx, [bp+arg_pn_mouseState]
		mov ax, [bx+2]
		shr ax, 1
		mov [bp+var_mouseXy], ax
		mov ax, [bx+4]
		mov [bp+var_mouseXy+2], ax
		lea ax, [bp+var_mouseXy]
		push ax
		lea ax, [si+0x3F]
		push ax
		push 0
		push word [si+0x21]
		push dseg_shapeManager
		callFromOverlay isCursorInBounds
		add sp, 10
		mov byte [bp+var_isInBounds], al
		
		cmp al, 0
		jz calcJump(off_Spellbook_notInBounds)
		
		mov bx, [bp+arg_pn_mouseState]
		cmp byte [bx+MouseState_button], 2
		jz calcJump(off_Spellbook_returnCloseCode)
		
		; was the Close button clicked?
		push word [bp+arg_pn_mouseState]
		lea ax, [si+0x23]
		push ax
		mov bx, [si+0x2F]
		call far [bx+8] ; Button_processInput
		pop cx
		pop cx
		mov [bp+var_isInButtonBounds], al
		test al, al
		jz calcJump(off_Spellbook_mouseInBounds)
		; fall through to handling Close-button click
		
		times 21 nop
	endBlockAt off_Spellbook_checkCoords_end
	
	startBlockAt addr_Container_checkCoords
		%assign off_mouseInBounds       off_Container_mouseInBounds
		%assign off_returnCloseCode     off_Container_returnCloseCode
		%assign off_notInBounds         off_Container_notInBounds
		
		%define pn_controlPosition      di+0x21
		%define pn_bounds               di+0x3F
		
		%assign arg_pn_mouseState       0x08
		%assign var_inBoundsReturn     -0x02
		%assign var_mouseX             -0x06
		%assign var_mouseY             -0x08
		%assign var_mouseXy            -0x0C
		
		checkMouseCoordsAndButton
	endBlockAt off_Container_mouseInBounds
	
	startBlockAt addr_Stats_checkCoords
		%assign off_mouseInBounds       off_Stats_mouseInBounds
		%assign off_returnCloseCode     off_Stats_returnCloseCode
		%assign off_notInBounds         off_Stats_notInBounds
		
		%define pn_controlPosition      di+0x21
		%define pn_bounds               di+0x3F
		
		%assign arg_pn_mouseState       0x08
		%assign arg_pn_this             0x06
		%assign var_inBoundsReturn     -0x08
		%assign var_mouseX             -0x04
		%assign var_mouseY             -0x06
		%assign var_mouseXy            -0x0C
		
		mov di, [bp+arg_pn_this]
		
		checkMouseCoordsAndButton
		
		times 55 nop
	endBlockAt off_Stats_mouseInBounds
