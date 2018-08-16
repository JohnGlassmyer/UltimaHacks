; Barks on an item with a drawn shape rather than with printed text, either in
;     dialog-mode or not.

[bits 16]

; display shape barks for 1/3 as long as text barks (15 / 120).
; drawn shapes would tend to clutter the screen, and the player should be able
;     to interpret images faster than they would printed text.
%assign SPRITE_DURATION 5
%assign BARK_DURATION 40

startPatch EXE_LENGTH, eop-shapeBark
	startBlockAt addr_eop_shapeBark
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_frame                   0x08
		%assign arg_shape                   0x06
		%assign arg_ibo                     0x04
		%assign ____callerIp                0x02
		%assign ____callerBp                0x00
		%assign var_itemX                  -0x02
		%assign var_itemY                  -0x04
		add sp, var_itemY
		
		push si
		push di
		
		cmp byte [dseg_isDialogMode], 0
		jnz barkInDialogMode
		
		spriteInWorldMode:
			push 5 ; cause
			push SPRITE_DURATION ; duration
			push word [bp+arg_frame]
			push word [bp+arg_shape]
			push 0 ; yVelocity
			push 0 ; xVelocity
			push 0 ; yOffset
			push 0 ; xOffset
			push word [bp+arg_ibo]
			push dseg_spriteManager
			callFromOverlay SpriteManager_playSpriteForItem
			add sp, 20
			
			mov bx, ax
			mov ax, [bp+arg_ibo]
			mov [bx+Sprite_ibo], ax
			
			jmp endProc
			
		barkInDialogMode:
			mov di, dseg_apn_barkTexts
			.forBarkSlot:
				cmp di, dseg_apn_barkTexts + 10 * 2
				jae endProc
				
				cmp word [di], 0
				jz .haveSlot
				
				add di, 2
				jmp .forBarkSlot
				
			.haveSlot:
			
			push word ShapeBark_SIZE
			callFromOverlay allocateNearMemory
			pop cx
			mov si, ax
			
			fmemcpy ds, si, cs, off_ShapeBark, ShapeBark_SIZE
			
			lea bx, [si+ShapeBark_vtableA]
			lea ax, [si+ShapeBark_a00_destroy]
			mov [bx+0*4+2], ds
			mov [bx+0*4+0], ax
			mov [si+ShapeBark_pn_vtableA], bx
			
			lea bx, [si+ShapeBark_vtableB]
			lea ax, [si+ShapeBark_b00_drawTree]
			mov [bx+0*4+2], ds
			mov [bx+0*4+0], ax
			mov [si+ShapeBark_pn_vtableB], bx
			
			mov ax, [bp+arg_shape]
			mov [si+ShapeBark_shape], ax
			
			mov ax, [bp+arg_frame]
			mov [si+ShapeBark_frame], ax
			
			mov ax, [dseg_mouseXx]
			shr ax, 1
			mov [si+ShapeBark_x], ax
			
			mov ax, [dseg_mouseY]
			mov [si+ShapeBark_y], ax
			
			push 0
			push BARK_DURATION
			lea ax, [si+ShapeBark_timer]
			push ax
			callFromOverlay Timer_set
			add sp, 6
			
			mov [di], si
			
		endProc:
		
		pop di
		pop si
		
		mov sp, bp
		pop bp
		retn
		
		; A type of object that is like a dialog-mode text bark, but which draws
		;     a particular shape (image) when drawn rather than printing text.
		off_ShapeBark EQU block_currentOffset
		ShapeBark:
			%macro zeroPadToOffset 1
				times (%1 - ($ - ShapeBark)) db 0
			%endmacro
			
			zeroPadToOffset ShapeBark_shape
			dw 0
			
			zeroPadToOffset ShapeBark_frame
			dw 0
			
			zeroPadToOffset ShapeBark_x
			dw 0
			
			zeroPadToOffset ShapeBark_y
			dw 0
			
			zeroPadToOffset ShapeBark_pn_vtableA
			dw 0
			
			zeroPadToOffset ShapeBark_pn_vtableB
			dw 0
			
			; (if this were non-zero, then endDialogMode would try to call
			;     StringWithLength's destructor on it, which could be bad.)
			zeroPadToOffset ShapeBark_stringWithLength
			times 2 dw 0
			
			; after this timer finishes, itemDialogLoop destroys the bark and
			;     reclaims its slot.
			zeroPadToOffset ShapeBark_timer
			times 2 dd 0
			
			zeroPadToOffset ShapeBark_vtableA
			dd 0
			
			zeroPadToOffset ShapeBark_vtableB
			dd 0
			
			; called by endDialogMode before it deallocates this object.
			zeroPadToOffset ShapeBark_a00_destroy
				retf
				
			; called by the dialog-mode loop to draw the bark.
			zeroPadToOffset ShapeBark_b00_drawTree
				push bp
				mov bp, sp
				
				; bp-based stack frame:
				%assign arg_pn_viewport         0x08
				%assign arg_pn_this             0x06
				%assign ____callerCs            0x04
				%assign ____callerIp            0x02
				%assign ____callerBp            0x00
				
				push si
				push di
				
				mov si, [bp+arg_pn_this]
				
				push 0
				push 0
				push word [si+ShapeBark_frame]
				push word [si+ShapeBark_shape]
				push word [si+ShapeBark_y]
				push word [si+ShapeBark_x]
				push word [bp+arg_pn_viewport]
				push dseg_shapeManager
				callFromOverlay ShapeManager_draw
				add sp, 16
				
				callFromOverlay copyFrameBuffer
				
				pop di
				pop si
				mov sp, bp
				pop bp
				retf
				
			zeroPadToOffset ShapeBark_SIZE
	endBlockAt off_eop_shapeBark_end
endPatch
