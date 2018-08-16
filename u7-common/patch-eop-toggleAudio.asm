[bits 16]

startPatch EXE_LENGTH, eop-toggleAudio
	startBlockAt addr_eop_toggleAudio
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_newAudioState      -0x02
		%assign var_string             -0x20
		add sp, var_string
		
		push si
		push di
		
		mov byte [bp+var_string], 0
		
		cmp byte [dseg_isAudioDisabled], 0
		jz disableAudio
		
		enableAudio:
			mov word [bp+var_newAudioState], 2
			mov ax, 1
			jmp haveNewAudioState
			
		disableAudio:
			mov word [bp+var_newAudioState], 1
			mov ax, 0
			
		haveNewAudioState:
			copyAudioStateStringToVar ax, [bp+var_string]
			
			push word 1
			push word 15
			push word 5
			lea ax, [bp+var_string]
			push ax
			push word [dseg_avatarIbo]
			push dseg_spriteManager
			callFromOverlay SpriteManager_barkOnItem
			add sp, 12
			
			mov ax, [bp+var_newAudioState]
			push ax
			push ax
			push ax
			callFromOverlay setAudioState
			add sp, 6
			
			xor byte [dseg_isAudioDisabled], 1
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_toggleAudio_end
endPatch
