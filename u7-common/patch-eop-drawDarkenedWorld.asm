; Draws the world with the view darkened.
;
; Makes use of a boolean flag in the global Camera object that causes colors to
;     be translated to darker shades while drawing. I don't know when (if ever)
;     this flag was used in the original games, but this works to provide deeper
;     contrast and increased legibility of text during conversations.

[bits 16]

startPatch EXE_LENGTH, eop-drawDarkenedWorld
	startBlockAt addr_eop_drawDarkenedWorld
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_ibo                     0x04
		%assign ____callerIp                0x02
		%assign ____callerBp                0x00
		
		push si
		push di
		
		movzx ax, [dseg_camera+Camera_isViewDarkened]
		mov si, ax
		
		mov byte [dseg_camera+Camera_isViewDarkened], 1
		
		push dseg_camera
		callFromOverlay drawWorld
		pop cx
		
		mov ax, si
		mov [dseg_camera+Camera_isViewDarkened], al
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_drawDarkenedWorld_end
endPatch
