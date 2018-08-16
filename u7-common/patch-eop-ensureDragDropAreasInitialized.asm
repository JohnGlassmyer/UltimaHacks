; Instantiates two global objects which act like the objects used to represent
;     on-screen inventory dialogs during the drag-and-drop movement of items,
;     but which can be configured to move items to and from arbitrary
;     destinations, not just open containers/inventories.

[bits 16]

startPatch EXE_LENGTH, \
		eop-ensureDragAndDropAreasInitialized
	
	startBlockAt addr_eop_ensureDragAndDropAreasInitialized
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp                0x02
		%assign ____callerBp                0x00
		
		cmp word [dseg_pn_dragArea], 0
		jnz .dragAreaInitialized
		call createInventoryArea
		mov [dseg_pn_dragArea], ax
		.dragAreaInitialized:
		
		cmp word [dseg_pn_dropArea], 0
		jnz .dropAreaInitialized
		call createInventoryArea
		mov [dseg_pn_dropArea], ax
		.dropAreaInitialized:
		
		mov sp, bp
		pop bp
		retn
		
		createInventoryArea:
			push si
			
			; TODO: handle allocation failure?
			push word InventoryArea_SIZE
			callFromOverlay allocateNearMemory
			pop cx
			mov si, ax
			
			; copy code from this overlay into the allocated chunk of memory
			fmemcpy	ds, si, \
					cs, offsetInCodeSegment(InventoryArea), \
					InventoryArea_SIZE
			
			; set the object's vtable pointer
			lea ax, [si+InventoryArea_vtable]
			mov [si+InventoryArea_pn_vtable], ax
			
			; set vtable entries (pointers to virtual member functions)
			lea bx, [si+InventoryArea_vtable]
			lea ax, [si+InventoryArea_f00_drawTree]
			mov [bx+00*4+2], ds
			mov [bx+00*4+0], ax
			lea ax, [si+InventoryArea_f04_getIbo]
			mov [bx+04*4+2], ds
			mov [bx+04*4+0], ax
			lea ax, [si+InventoryArea_f05_tryToAccept]
			mov [bx+05*4+2], ds
			mov [bx+05*4+0], ax
			lea ax, [si+InventoryArea_f06_getDraggedIbo]
			mov [bx+06*4+2], ds
			mov [bx+06*4+0], ax
			lea ax, [si+InventoryArea_f07_getX1]
			mov [bx+07*4+2], ds
			mov [bx+07*4+0], ax
			lea ax, [si+InventoryArea_f08_getY1]
			mov [bx+08*4+2], ds
			mov [bx+08*4+0], ax
			lea ax, [si+InventoryArea_f09_getX2]
			mov [bx+09*4+2], ds
			mov [bx+09*4+0], ax
			lea ax, [si+InventoryArea_f10_getY2]
			mov [bx+10*4+2], ds
			mov [bx+10*4+0], ax
			lea ax, [si+InventoryArea_f11_recordXOffset]
			mov [bx+11*4+2], ds
			mov [bx+11*4+0], ax
			lea ax, [si+InventoryArea_f12_recordYOffset]
			mov [bx+12*4+2], ds
			mov [bx+12*4+0], ax
			
			; return near pointer to the created InventoryArea
			mov ax, si
			
			pop si
			
			retn
			
		InventoryArea:
			%macro zeroPadToOffset 1
				times (%1 - ($ - InventoryArea)) db 0
			%endmacro
			
			zeroPadToOffset InventoryArea_ibo
			dw 0
			
			zeroPadToOffset InventoryArea_draggedIbo
			dw 0
			
			zeroPadToOffset InventoryArea_worldX
			dw 0
			
			zeroPadToOffset InventoryArea_worldY
			dw 0
			
			zeroPadToOffset InventoryArea_worldZ
			dw 0
			
			zeroPadToOffset InventoryArea_pn_vtable
			dw 0
			
			zeroPadToOffset InventoryArea_setByDropDraggedItem
			dw 0
			
			zeroPadToOffset InventoryArea_vtable
			times 14 dd 0
			
			; called by redrawDialogs (called by dragItem) when this area is
			;     pretending to be the world area.
			zeroPadToOffset InventoryArea_f00_drawTree
				retf
				
			; get destination ibo (U7SI calls this to look for a contained
			;   keyring before actually dropping a dragged key)
			zeroPadToOffset InventoryArea_f04_getIbo
				push bp
				mov bp, sp
				
				; bp-based stack frame:
				%assign arg_pn_this             0x06
				%assign ____callerCs            0x04
				%assign ____callerIp            0x02
				%assign ____callerBp            0x00
				
				push si
				push di
				
				mov si, [bp+arg_pn_this]
				
				mov ax, [si+InventoryArea_ibo]
				
				pop di
				pop si
				mov sp, bp
				pop bp
				retf
				
			; try to accept dropped item (at the current mouse cursor position,
			;   which we ignore)
			zeroPadToOffset InventoryArea_f05_tryToAccept
				tryToAccept_start:
				
				push bp
				mov bp, sp
				
				; bp-based stack frame:
				%assign arg_pn_this             0x06
				%assign ____callerCs            0x04
				%assign ____callerIp            0x02
				%assign ____callerBp            0x00
				
				push si
				push di
				
				mov si, [bp+arg_pn_this]
				
				cmp word [si+InventoryArea_ibo], 0
				jnz .acceptAsItem
				
				.acceptAsWorld:
					; place the item at worldX/Y/Z
					
					push word [si+InventoryArea_worldZ]
					lea ax, [si+InventoryArea_worldY]
					push ax
					lea ax, [si+InventoryArea_worldX]
					push ax
					lea ax, [si+InventoryArea_draggedIbo]
					push ax
					callFromOverlay placeItemInWorld
					add sp, 8
					
					jmp .returnSuccess
					
				.acceptAsItem:
					; try to place the item into the configured destination item
					
					; don't let the player place an item into e.g. a spellbook.
					;     that would be bad, as there is no way to get items
					;     back out of a spellbook.
					push word [si+InventoryArea_ibo]
					callVarArgsEopFromOverlay canItemAcceptItems, 1
					pop cx
					test ax, ax
					jnz .validDestination
					mov ax, 0
					jmp .failWithError
					.validDestination:
					
					push 1 ; shouldSetBit
					push 1 ; shouldTryToStack
					lea ax, [si+InventoryArea_ibo]
					push ax
					callFromOverlay tryToPlaceItem
					add sp, 6
					
					cmp ax, 0
					jz .returnSuccess
					cmp ax, 1
					jz .error4
					cmp ax, 2
					jz .error0
					cmp ax, 3
					jz .error0
					cmp ax, 4
					jz .error5
					jmp .returnFailure
					
				.error0:
					mov ax, 0
					jmp .failWithError
				.error4:
					mov ax, 4
					jmp .failWithError
				.error5:
					mov ax, 5
					jmp .failWithError
				.failWithError:
					push ax
					callFromOverlay reportNoCanDo
					pop cx
					jmp .returnFailure
					
				.returnSuccess: 
					mov ax, 1
					jmp .endProc
					
				.returnFailure:
					mov ax, 0
					
				.endProc:
					; zero-out this area's ibo field so the patched dragLoop
					;     won't keep trying to drop items to this area
					mov word [si+InventoryArea_ibo], 0
					
				pop di
				pop si
				mov sp, bp
				pop bp
				retf
				
			zeroPadToOffset InventoryArea_f06_getDraggedIbo
				push bp
				mov bp, sp
				
				; bp-based stack frame:
				%assign arg_pn_this             0x0A
				%assign arg_ps_ibo              0x06
				%assign ____callerCs            0x04
				%assign ____callerIp            0x02
				%assign ____callerBp            0x00
				
				push si
				push di
				
				les bx, [bp+arg_ps_ibo]
				mov si, [bp+arg_pn_this]
				mov ax, [si+InventoryArea_draggedIbo]
				mov [es:bx], ax
				
				pop di
				pop si
				mov sp, bp
				pop bp
				retf
				
			; We have no use, in artificial dragging and/or dropping, for the
			;     relative on-screen position of the dragged item with respect
			;     to the mouse cursor, because
			;   a) the dragged-item display will not be visible,
			;   b) we already know the destination for dropping, and
			;   c) we already know where to put the item if dropping fails.
			zeroPadToOffset InventoryArea_f07_getX1
			zeroPadToOffset InventoryArea_f08_getY1
			zeroPadToOffset InventoryArea_f09_getX2
			zeroPadToOffset InventoryArea_f10_getY2
			zeroPadToOffset InventoryArea_f11_recordXOffset
			zeroPadToOffset InventoryArea_f12_recordYOffset
				retf
				
			zeroPadToOffset InventoryArea_SIZE
	endBlockAt off_eop_ensureDragAndDropAreasInitialized_end
endPatch
