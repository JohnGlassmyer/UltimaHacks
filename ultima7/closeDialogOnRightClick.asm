%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

%macro checkMouseCoordsAndButton 0
	mov bx, [bp+arg_mouseState]
	mov ax, [bx+2]
	shr ax, 1
	mov [bp+var_mouseXy], ax
	mov ax, [bx+4]
	mov [bp+var_mouseXy+2], ax
	
	lea bx, [bounds]
	
	mov ax, [bx]
	cmp ax, [bp+var_mouseXy]
	jg %%notInBounds
	
	mov ax, [bx+4]
	cmp ax, [bp+var_mouseXy]
	jl %%notInBounds
	
	mov ax, [bx+2]
	cmp ax, [bp+var_mouseXy+2]
	jg %%notInBounds
	
	mov ax, [bx+6]
	cmp ax, [bp+var_mouseXy+2]
	jl %%notInBounds
	
	lea ax, [bp+var_mouseXy]
	push ax
	push bx
	push 0
	push word [controlPosition]
	push 0x380E
	callFromOverlay isCursorInBounds
	add sp, 10
	mov byte [bp+var_inBoundsReturn], al
	or al, al
	jz calcJump(off_notInBounds)
	
	mov bx, [bp+arg_mouseState]
	cmp byte [bx+MouseState_button], 2
	jz calcJump(off_returnCloseCode)
	
	jmp calcJump(off_mouseInBounds)
	
	%%notInBounds:
	jmp calcJump(off_notInBounds)
%endmacro

[bits 16]

; (Save dialog and Slider not handled here
;       because I have separate patches for them)
startPatch EXE_LENGTH, \
		close dialogs on right-click
		
	; don't skip mouse button 2 events when processing input for dialogs
	off_processInput_skipIfMouse2   EQU 0x1810
	startBlockAt 340, off_processInput_skipIfMouse2
		nop
		nop
	endBlock
	
	; now need to prevent Yes/No Prompt buttons
	; from responding to mouse button 2
	off_Button_checkCoords       EQU 0x07A5
	off_Button_mouseInBounds     EQU 0x0836
	off_Button_notPressed        EQU 0x0923
	off_Button_notInBounds       EQU 0x0935
	startBlockAt 339, off_Button_checkCoords
		%assign arg_mouseState 8
		%assign var_mouseX -6
		%assign var_mouseY -4
		%assign var_struct -0xE
		
		mov bx, [bp+arg_mouseState]
		mov ax, [bx+2]
		shr ax, 1
		mov [bp+var_mouseX], ax
		mov ax, [bx+4]
		mov [bp+var_mouseY], ax
		
		mov ax, [bp+var_mouseX]
		cmp ax, [bp+var_struct]
		jl notInBounds
		
		mov ax, [bp+var_mouseX]
		cmp ax, [bp+var_struct+4]
		jg notInBounds
		
		mov ax, [bp+var_mouseY]
		cmp ax, [bp+var_struct+2]
		jl notInBounds
		
		mov ax, [bp+var_mouseY]
		cmp ax, [bp+var_struct+6]
		jg notInBounds
		
		lea ax, [bp+var_mouseX]
		push ax
		lea ax, [bp+var_struct+4]
		push ax
		push word [si+0x14]
		push word [si+0x12]
		push 0x380E
		callFromOverlay isCursorInBounds
		add sp, 10
		
		or ax, ax
		jz notInBounds
		
		mov bx, [bp+arg_mouseState]
		cmp byte [bx+MouseState_button], 2
		jz notPressed
		jmp calcJump(off_Button_mouseInBounds)
		
		notInBounds:
		jmp calcJump(off_Button_notInBounds)
		
		notPressed:
		jmp calcJump(off_Button_notPressed)
	endBlockAt off_Button_mouseInBounds
	
	; Spellbook close on right-click, if in bounds
	off_Spellbook_checkCoords       EQU 0x082E
	off_Spellbook_checkCoords_end   EQU 0x0894
	off_Spellbook_returnCloseCode   EQU 0x089D
	off_Spellbook_mouseInBounds     EQU 0x08A8
	off_Spellbook_notInBounds       EQU 0x0A80
	startBlockAt 348, off_Spellbook_checkCoords
		%assign arg_mouseState 8
		%assign var_mouseXy -4
		
		mov bx, [bp+arg_mouseState]
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
		push 0x380E
		callFromOverlay isCursorInBounds
		add sp, 10
		mov byte [bp-6], al
		
		cmp al, 0
		jz calcJump(off_Spellbook_notInBounds)
		
		mov bx, [bp+arg_mouseState]
		cmp byte [bx+MouseState_button], 2
		jz calcJump(off_Spellbook_returnCloseCode)
		
		; was the Close button clicked?
		push word [bp+arg_mouseState]
		lea ax, [si+0x23]
		push ax
		mov bx, [si+0x2F]
		call far [bx+8] ; Button_processInput
		pop cx
		pop cx
		mov [bp-5], al
		test al, al
		jz calcJump(off_Spellbook_mouseInBounds)
		; fall through to handling Close-button click
	endBlockWithFillAt nop, off_Spellbook_checkCoords_end
	
	; Character Inventory close on right-click, if in bounds
	off_Character_checkCoords       EQU 0x1225
	off_Character_mouseInBounds     EQU 0x12D1
	off_Character_returnCloseCode   EQU 0x1596
	off_Character_notInBounds       EQU 0x1868
	startBlockAt 342, off_Character_checkCoords
		%assign off_mouseInBounds       off_Character_mouseInBounds
		%assign off_returnCloseCode     off_Character_returnCloseCode
		%assign off_notInBounds         off_Character_notInBounds
		
		%define controlPosition         si+0x21
		%define bounds                  si+0x3F
		
		%assign arg_mouseState          0x8
		%assign var_inBoundsReturn     -0x2
		%assign var_mouseXy            -0x4
		
		; copy mouseY to where the rest of the proc expects it to be
		mov bx, [bp+arg_mouseState]
		mov ax, [bx+4]
		mov [bp-6], ax
		
		checkMouseCoordsAndButton
	endBlockAt off_Character_mouseInBounds

	; Container Inventory close on right-click, if in bounds
	off_Container_checkCoords       EQU 0x0238
	off_Container_mouseInBounds     EQU 0x02AA
	off_Container_returnCloseCode   EQU 0x02E4
	off_Container_notInBounds       EQU 0x0333
	startBlockAt 341, off_Container_checkCoords
		%assign off_mouseInBounds       off_Container_mouseInBounds
		%assign off_returnCloseCode     off_Container_returnCloseCode
		%assign off_notInBounds         off_Container_notInBounds
		
		%define controlPosition         di+0x21
		%define bounds                  di+0x3F
		
		%assign arg_mouseState          0x8
		%assign var_inBoundsReturn     -0x2
		%assign var_mouseXy            -0x4
		
		; copy mouseY to where the rest of the proc expects it to be
		mov ax, [bp+var_mouseXy]
		mov [bp-6], ax
		
		checkMouseCoordsAndButton
	endBlockAt off_Container_mouseInBounds
	
	; Stats window close on right-click, if in bounds
	off_Stats_checkCoords           EQU 0x04F5
	off_Stats_mouseInBounds         EQU 0x0593
	off_Stats_returnCloseCode       EQU 0x05B6
	off_Stats_notInBounds           EQU 0x05D3
	startBlockAt 342, off_Stats_checkCoords
		%assign off_mouseInBounds       off_Stats_mouseInBounds
		%assign off_returnCloseCode     off_Stats_returnCloseCode
		%assign off_notInBounds         off_Stats_notInBounds
		
		%define controlPosition         di+0x21
		%define bounds                  di+0x3F
		
		%assign arg_mouseState          0x8
		%assign var_inBoundsReturn     -0x2
		%assign var_mouseXy            -0x6
		
		mov di, [bp+6]
		
		checkMouseCoordsAndButton
	endBlockAt off_Stats_mouseInBounds
endPatch
