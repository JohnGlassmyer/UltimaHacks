%include "include/u7bg-all-includes.asm"

[bits 16]

startPatch EXE_LENGTH, eop-toggleFrameLimiter
	startBlockAt addr_eop_toggleFrameLimiter
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_string             -0x20
		add sp, var_string
		
		push si
		push di
		
		cmp byte [dseg_frameLimiterEnabled], 0
		jz enableFrameLimiter
		
		disableFrameLimiter:
			mov si, offsetInCodeSegment(frameLimiterDisabledText)
			mov cx, frameLimiterDisabledText_end - frameLimiterDisabledText
			jmp haveStringOffsetAndLength
			
		enableFrameLimiter:
			mov si, offsetInCodeSegment(frameLimiterEnabledText)
			mov cx, frameLimiterEnabledText_end - frameLimiterEnabledText
			
		haveStringOffsetAndLength:
			lea di, [bp+var_string]
			fmemcpy ss, di, cs, si, cx
			
			xor byte [dseg_frameLimiterEnabled], 1
			
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
		
		frameLimiterDisabledText:
			db 'Frame Limiting off', 0
			frameLimiterDisabledText_end:
			
		frameLimiterEnabledText:
			db 'Frame Limiting on', 0
			frameLimiterEnabledText_end:
			
	endBlockAt off_eop_toggleFrameLimiter_end
endPatch
