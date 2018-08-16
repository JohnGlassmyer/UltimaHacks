[bits 16]

startPatch EXE_LENGTH, eop-shapeBarkForContent
	startBlockAt addr_eop_shapeBarkForContent
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_ibo                 0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_shape              -0x02
		%assign var_frame              -0x04
		%assign var_containedIbo       -0x06
		add sp, var_containedIbo
		
		push si
		push di
		
		; assuming that no other code changes gs, we need set this only once
		mov gs, [dseg_itemBufferSegment]
		
		tryContainedItem:
			disallowIfLockedContainer:
				cmp byte [dseg_isHackMoverEnabled], 0
				jnz .notDisallow
				
				mov bx, [bp+arg_ibo]
				mov ax, [gs:bx+4]
				and ax, 0x3FF
				
				isAxLockedItemType
				test ax, ax
				jnz canNot
				
				.notDisallow:
				
			skipIfNpc:
				cmp byte [dseg_isHackMoverEnabled], 0
				jnz .notSkip
				
				mov bx, [bp+arg_ibo]
				mov ax, [gs:bx+4]
				and ax, 0x3FF
				mov dx, 3
				mul dx
				mov bx, ax
				movzx bx, byte [dseg_itemTypeInfo+bx+1]
				and bx, 0xF
				shl bx, 1
				test word [dseg_itemTypeClassFlags+bx], ItemClassBit_NPC
				jnz procEnd
				
				.notSkip:
				
			; TODO: show multiple contained items in a synthesized shape, and
			;     then dispose of that shape after showing.
			
			lea ax, [bp+arg_ibo]
			push ax
			push ds
			lea ax, [bp+var_containedIbo]
			push ax
			callFromOverlay getContainedItem
			add sp, 6
			
			cmp word [bp+var_containedIbo], 0
			jz .notContainedItem
			
			mov bx, [bp+var_containedIbo]
			
			; shape
			mov ax, [gs:bx+4]
			and ax, 0x3FF
			mov [bp+var_shape], ax
			
			; frame
			mov ax, [gs:bx+4]
			and ax, 0x7C00
			shr ax, 10
			mov [bp+var_frame], ax
			
			jmp barkWithShapeAndFrame
			
			.notContainedItem:
			
		%ifnum ItemType_MAGIC_SCROLL
		tryMagicScroll:
			mov bx, [bp+arg_ibo]
			mov ax, [gs:bx+4]
			and ax, 0x3FF
			
			cmp ax, ItemType_MAGIC_SCROLL
			jne .notMagicScroll
			
			; item's quality is the spell number of the scroll
			lea ax, [bp+arg_ibo]
			push ax
			callFromOverlay Item_getQuality
			pop cx
			
			; shape = quality / 8 + spellPageBase
			; frame = quality % 8
			cwd
			mov ebx, 8
			div ebx
			add ax, ShapeNumber_MAGIC_SCROLL_BASE
			mov [bp+var_shape], ax
			mov [bp+var_frame], dx
			
			jmp barkWithShapeAndFrame
			
			.notMagicScroll:
		%endif
		
		jmp procEnd
		
		barkWithShapeAndFrame:
			push word [bp+var_frame]
			push word [bp+var_shape]
			push word [bp+arg_ibo]
			callVarArgsEopFromOverlay shapeBark, 3
			add sp, 6
			
			jmp procEnd
			
		canNot:
			push Sound_CAN_NOT
			callFromOverlay playSoundSimple
			pop cx
			
		procEnd:
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_shapeBarkForContent_end
endPatch
