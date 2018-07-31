%include "../UltimaPatcher.asm"
%include "include/uw1.asm"
%include "include/uw1-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		expanded overlay procedure: mouseLookOrMoveCursor
		
	startBlockAt off_eop_mouseLookOrMoveCursor
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_mouseXDelta         0x06
		%assign arg_mouseYDelta         0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		cmp byte [dseg_isMouseLookEnabled], 0
		jz moveCursor
		
		changeLookDirection:
			; mouse x changes heading
				cmp word [bp+arg_mouseXDelta], 0
				jz xZero
				mov ax, word [bp+arg_mouseXDelta]
				shl ax, 6
				add word [dseg_heading], ax
				
				xZero:
				
			; mouse y changes pitch
				cmp word [bp+arg_mouseYDelta], 0
				jz yZero
				mov ax, word [bp+arg_mouseYDelta]
				shl ax, 7
				sub word [dseg_pitch], ax
				
				cmp word [dseg_pitch], pitchBound
				jle boundedAbove
				mov word [dseg_pitch], pitchBound
				boundedAbove:
				
				cmp word [dseg_pitch], -pitchBound
				jge boundedBelow
				mov word [dseg_pitch], -pitchBound
				boundedBelow:
				
				yZero:
				
			; update avatar heading for compass display (as at seg008:02A4)
				les bx, [dseg_ps_avatarItem]
				
				mov ax, [es:bx+2]
				and ax, 0b1111110001111111
				mov dx, [dseg_heading]
				sar dx, 13
				and dx, 0b0000000000000111
				shl dx, 7
				or ax, dx
				mov [es:bx+2], ax
				
				mov al, [es:bx+0x18]
				and al, 0b11100000
				mov dx, [dseg_heading]
				sar dx, 8
				and dl, 0b00011111
				or al, dl
				mov [es:bx+0x18], al
				
			; signal that the 3d view needs to be redrawn
				push 2
				callFromOverlay setInterfaceRoutineBit
				add sp, 2
				
			mov ax, 1
			
			jmp endProc
			
		moveCursor:
			; add X
				mov ax, [dseg_cursorX]
				add ax, [bp+arg_mouseXDelta]
				
			; bound X
				cmp ax, [dseg_cursorMinX]
				jge xBoundedBelow
				mov ax, [dseg_cursorMinX]
				jmp xBounded
				xBoundedBelow:
				cmp ax, [dseg_cursorMaxX]
				jle xBounded
				mov ax, [dseg_cursorMaxX]
				xBounded:
				
			; set X
				mov [dseg_cursorX], ax
				
			; subtract Y (vertical coordinates are bottom-up in this game)
				mov ax, [dseg_cursorY]
				sub ax, [bp+arg_mouseYDelta]
				
			; bound Y
				cmp ax, [dseg_cursorMinY]
				jge yBoundedBelow
				mov ax, [dseg_cursorMinY]
				jmp yBounded
				yBoundedBelow:
				cmp ax, [dseg_cursorMaxY]
				jle yBounded
				mov ax, [dseg_cursorMaxY]
				yBounded:
				
			; set Y
				mov [dseg_cursorY], ax
				
			xor ax, ax
			
		endProc:
			; ax == 0 if cursor was moved
			; ax == 1 if look direction was changed
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_mouseLookOrMoveCursor_end
endPatch
