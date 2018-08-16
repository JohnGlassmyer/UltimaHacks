; Have the player select an item by clicking on it, and then "use" the selected
;     item.
; Serpent Isle had this functionality mapped to the 'T' key (but only in
;     non-dialog mode).

[bits 16]

startPatch EXE_LENGTH, eop-target
	startBlockAt addr_eop_target
		proc_target:
			push bp
			mov bp, sp
			
			; bp-based stack frame:
			%assign ____callerIp            0x02
			%assign ____callerBp            0x00
			%assign var_wasDialogMode      -0x02
			%assign var_unusedByRef        -0x04
			%assign var_ibo                -0x06
			add sp, var_ibo
			
			push si
			push di
			
			mov byte [dseg_isSelectingFromEopTarget], 1
			
			lea ax, [bp+var_unusedByRef]
			push ax
			lea ax, [bp+var_unusedByRef] ; coordinateY
			push ax
			lea ax, [bp+var_unusedByRef] ; coordinateX
			push ax
			lea ax, [bp+var_ibo]
			push ax
			callFromOverlay havePlayerSelect
			add sp, 8
			
			mov byte [dseg_isSelectingFromEopTarget], 0
			
			cmp word [bp+var_ibo], 0
			jz procEnd
			
			push word 0 ; flags
			push word 0 ; y coordinate
			push word 0 ; x coordinate
			lea ax, [bp+var_ibo]
			push ax
			callFromOverlay use
			add sp, 8
			
			procEnd:
			
			pop di
			pop si
			mov sp, bp
			pop bp
			retn
	endBlockAt off_eop_target_end
endPatch
