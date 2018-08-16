; Initiates drop of the item currently being dragged, using a specified
;     inventory area as source and using our fake dropArea as the destination.
; This allows dropping a dragged item into an arbitrary container, which might
;     not be open as an on-screen inventory dialog, and for which there might
;     therefore be no real inventory area to specify as the destination.

[bits 16]

startPatch EXE_LENGTH, eop-dropToPresetDestination
	startBlockAt addr_eop_dropToPresetDestination
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_pn_sourceControl        0x04
		%assign ____callerIp                0x02
		%assign ____callerBp                0x00
		%assign var_draggedIbo             -0x02
		%assign var_itemHasQuantity        -0x04
		add sp, var_itemHasQuantity
		
		push si
		push di
		
		lea ax, [bp+var_draggedIbo]
		push ax
		callFromOverlay getItemBeingDragged
		pop cx
		
		; stop if nothing's being dragged
		test ax, ax
		jz returnFailure
		
		callVarArgsEopFromOverlay ensureDragAndDropAreasInitialized, 0
		
		; require that the drop area be already configured with a destination
		mov bx, [dseg_pn_dropArea]
		cmp word [bx+InventoryArea_ibo], 0
		jz returnFailure
		
		push word [bp+var_draggedIbo]
		callVarArgsEopFromOverlay doesItemHaveQuantity, 1
		pop cx
		mov word [bp+var_itemHasQuantity], ax
		
		push 1 ; destination is item, not world
		push word [bp+var_itemHasQuantity]
		push word [dseg_pn_dropArea]
		push word [bp+arg_pn_sourceControl]
		lea ax, [bp+var_draggedIbo]
		push ax
		callFromOverlay dropDraggedItem
		add sp, 10
		
		returnSuccess:
			mov ax, 1
			jmp endProc
			
		returnFailure:
			mov ax, 0
			
		endProc:
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_dropToPresetDestination_end
endPatch
