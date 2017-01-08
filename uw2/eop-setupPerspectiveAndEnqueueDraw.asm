%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		expanded overlay procedure: setupPerspectiveAndEnqueueDraw
		
	startBlockAt off_eop_setupPerspectiveAndEnqueueDraw
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp                    0x02
		%assign ____callerBp                    0x00
		
		push si
		push di
		
		callWithRelocation o_clearDrawQueue
		
		; draw terrain behind the player
			; signal to other patches that the view is flipped
				mov byte [dseg_isDrawingBehindPlayer], 1
				
			; flip heading around to draw terrain behind the player
				add word [dseg_heading], 0x8000
				
			callWithRelocation o_setupPerspective
			
			; flip intra-block coordinates (coord = 0x100 - coord)
				les bx, [dseg_perspective_ps]
				neg word [es:bx+Perspective_x]
				add word [es:bx+Perspective_x], 0xFF
				neg word [es:bx+Perspective_y]
				add word [es:bx+Perspective_y], 0xFF
				
			callWithRelocation o_setupViewLimits
			
			; broaden view-clipping half-angle from 45 degrees to 90 degrees
				mov bx, dseg_leftViewLimit
				mov word [bx+ViewLimit_headingSin], -0x7FFF
				mov word [bx+ViewLimit_headingCos], 0
				mov bx, dseg_rightViewLimit
				mov word [bx+ViewLimit_headingSin], 0x7FFF
				mov word [bx+ViewLimit_headingCos], 0
				
			callWithRelocation o_applyViewLimits
			
			call cullRearwardBlocks
			
			; si := relocated base of seg034 (base 0x2F20 / 0x0120)
				pushWithRelocation 0x0120
				pop si
				
			; disable enqueueDrawItemsInBlock (seg034:0x0465) to prevent drawing
			; (non-terrain) items in rearward blocks
				mov es, si
				mov byte [es:0x0465], 0xCB ; <retf> instruction
				
			callWithRelocation o_enqueueDrawWithinLimits
			
			; re-enable enqueueDrawItemsInBlock
				mov es, si
				mov byte [es:0x0465], 0x55 ; <push bp> instruction
				
			; flip back around to original player heading
				add word [dseg_heading], 0x8000
				
			mov byte [dseg_isDrawingBehindPlayer], 0
			
		; draw terrain and items in front of the player
			callWithRelocation o_setupPerspective
			callWithRelocation o_setupViewLimits
			
			; broaden view-clipping half-angle from ~45 degrees to ~90 degrees
				mov bx, dseg_leftViewLimit
				mov word [bx+ViewLimit_headingSin], -0x7FFF
				mov word [bx+ViewLimit_headingCos], 0
				mov bx, dseg_rightViewLimit
				mov word [bx+ViewLimit_headingSin], 0x7FFF
				mov word [bx+ViewLimit_headingCos], 0
				
			callWithRelocation o_applyViewLimits
			
			call cullForwardBlocks
			
			callWithRelocation o_enqueueDrawWithinLimits
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
		; cull blocks not possibly in view when drawing behind the player
		;   '+' = retained block
		;   '.' = culled block
		;   'x' = player position (row 0, column 0; this block is retained)
		;       row 3: .............
		;       row 2: ...+++++++...
		;       row 1: .+++++++++++.
		;       row 0: ...+++x+++...
		; (the blocks in row 0 will be drawn again as forward blocks, but they
		; need to be retained here (as rearward blocks) for forward-facing walls
		; (on their rear sides) to be drawn)
		cullRearwardBlocks:
			push bp
			mov bp, sp
			
			%assign ____callerIp      0x02
			%assign ____callerBp      0x00
			
			push si
			push di
			
			mov bx, dseg_gridViewFlags
			
			xor si, si ; row [0, 16]
			crb_forRow:
				mov di, -16 ; column [-16, 16]
				crb_forColumn:
					cmp si, 0
					ja crb_maybeRow1
					cmp di, 3
					jg crb_cullBlock
					cmp di, -3
					jl crb_cullBlock
					jmp crb_doneWithBlock
					
					crb_maybeRow1:
					cmp si, 1
					ja crb_maybeRow2
					cmp di, 5
					jg crb_cullBlock
					cmp di, -5
					jl crb_cullBlock
					jmp crb_doneWithBlock
					
					crb_maybeRow2:
					cmp si, 2
					ja crb_cullBlock
					cmp di, 3
					jg crb_cullBlock
					cmp di, -3
					jl crb_cullBlock
					jmp crb_doneWithBlock
					
					crb_cullBlock:
						mov byte [bx], 0
						
					crb_doneWithBlock:
					
					; advance bx to the next block's flags
						add bx, 2
						
					inc di
					cmp di, 17
					jl crb_forColumn
				inc si
				cmp si, 17
				jb crb_forRow
				
			pop di
			pop si
			mov sp, bp
			pop bp
			retn
			
		; culls blocks that are neither
		;   a) within +/- 45 degrees of the player's heading
		;   b) within a Manhattan distance of 5 from the player
		cullForwardBlocks:
			push bp
			mov bp, sp
			
			%assign ____callerIp            0x02
			%assign ____callerBp            0x00
			%assign var_leftCullAngle      -0x02
			%assign var_leftCullAngleSin   -0x04
			%assign var_leftCullAngleCos   -0x06
			%assign var_rightCullAngle     -0x08
			%assign var_rightCullAngleSin  -0x0A
			%assign var_rightCullAngleCos  -0x0C
			%assign var_leftmostColumn     -0x0E
			%assign var_rightmostColumn    -0x10
			
			add sp, var_rightmostColumn
			push si
			push di
			
			; set cull angles to heading +/- 45 degrees
				les bx, [dseg_perspective_ps]
				mov ax, [es:bx+Perspective_heading]
				mov word [bp+var_leftCullAngle], ax
				sub word [bp+var_leftCullAngle], 0x2000
				mov word [bp+var_rightCullAngle], ax
				add word [bp+var_rightCullAngle], 0x2000
				
			; sin and cos: [-0x8000, 0x7FFF]
				lea ax, [bp+var_leftCullAngleCos]
				push ax
				lea ax, [bp+var_leftCullAngleSin]
				push ax
				push word [bp+var_leftCullAngle]
				callWithRelocation o_sinAndCosInterpolated
				add sp, 6
				
			; sin and cos: [-0x8000, 0x7FFF]
				lea ax, [bp+var_rightCullAngleCos]
				push ax
				lea ax, [bp+var_rightCullAngleSin]
				push ax
				push word [bp+var_rightCullAngle]
				callWithRelocation o_sinAndCosInterpolated
				add sp, 6
				
			mov bx, dseg_gridViewFlags
			
			xor si, si ; row [0, 16]
			cfb_forRow:
				; determine leftmost visible column for this row
					; if left cull-angle approaches (or exceeds) perpendicular,
					; set left bound all the way to the left
						cmp word [bp+var_leftCullAngle], -0x3F00
						jg cfb_calculateLeftmostColumn
						mov di, -16
						jmp cfb_haveLeftmostColumn
						
					cfb_calculateLeftmostColumn:
						; leftmost column = ((row + 1) * sin / cos) - 1
    						mov ax, si
    						inc ax
    						cwd
    						mov cx, [bp+var_leftCullAngleSin]
    						imul cx
    						mov cx, [bp+var_leftCullAngleCos]
    						idiv cx
    						dec ax
    						mov di, ax
    						
						cmp di, -16
						jge cfb_haveLeftmostColumn
						mov di, -16
						
					cfb_haveLeftmostColumn:
						mov word [bp+var_leftmostColumn], di
						
				; determine rightmost visible column for this row
					; if right cull-angle approaches (or exceeds) perpendicular,
					; set right bound all the way to the right
						cmp word [bp+var_rightCullAngle], 0x3F00
						jl cfb_calculateRightmostColumn
						mov di, 16
						jmp cfb_haveRightmostColumn
						
					cfb_calculateRightmostColumn:
						; rightmost column = ((row + 1) * sin / cos) + 1
    						mov ax, si
    						inc ax
    						cwd
    						mov cx, [bp+var_rightCullAngleSin]
    						imul cx
    						mov cx, [bp+var_rightCullAngleCos]
    						idiv cx
    						inc ax
    						mov di, ax
    						
						cmp di, 16
						jle cfb_haveRightmostColumn
						mov di, 16
						
					cfb_haveRightmostColumn:
						mov word [bp+var_rightmostColumn], di
						
				mov di, -16 ; column [-16, 16]
				cfb_forColumn:
					; don't cull blocks if (|column| + row) <= 5
						mov ax, di
						cwd
						xor ax, dx
						sub ax, dx
						add ax, si
						cmp ax, 5
						jg cfb_cullToView
						jmp cfb_doneWithBlock
						
					cfb_cullToView:
						cmp di, [bp+var_leftmostColumn]
						jl cfb_cullBlock
						cmp di, [bp+var_rightmostColumn]
						jg cfb_cullBlock
						jmp cfb_doneWithBlock
						
					cfb_cullBlock:
						mov byte [bx], 0
						
					cfb_doneWithBlock:
					
					; advance bx to the grid-view flags for the next block
						add bx, 2
						
					inc di
					cmp di, 17
					jl cfb_forColumn
				inc si
				cmp si, 17
				jb cfb_forRow
				
			pop di
			pop si
			mov sp, bp
			pop bp
			retn
			
	endBlockAt off_eop_setupPerspectiveAndEnqueueDraw_end
endPatch
