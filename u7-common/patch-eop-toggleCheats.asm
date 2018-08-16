[bits 16]

startPatch EXE_LENGTH, eop-toggleCheats
	startBlockAt addr_eop_toggleCheats
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_string             -0x20
		add sp, var_string
		
		push si
		push di
		
		cmp byte [dseg_cheatsEnabled], 0
		jz enableCheats
		
		disableCheats:
			mov si, offsetInCodeSegment(cheatsDisabledText)
			mov cx, cheatsDisabledText_end - cheatsDisabledText
			jmp haveStringOffsetAndLength
			
		enableCheats:
			mov si, offsetInCodeSegment(cheatsEnabledText)
			mov cx, cheatsEnabledText_end - cheatsEnabledText
			
		haveStringOffsetAndLength:
			lea di, [bp+var_string]
			fmemcpy ss, di, cs, si, cx
			
			xor byte [dseg_cheatsEnabled], 1
			
			push word 1
			push word 15
			push word 5
			lea ax, [bp+var_string]
			push ax
			push word [dseg_avatarIbo]
			push dseg_spriteManager
			callFromOverlay SpriteManager_barkOnItem
			add sp, 12
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
		cheatsDisabledText:
			db 'Cheats disabled', 0
			cheatsDisabledText_end:
			
		cheatsEnabledText:
			db 'Cheats enabled', 0
			cheatsEnabledText_end:
			
	endBlockAt off_eop_toggleCheats_end
endPatch
