%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

startPatch EXE_LENGTH, \
		eop-toggleAudio
		
	startBlockAt seg_eop, off_eop_toggleAudio
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_newIsAudioDisabled -0x02
		%assign var_newAudioState      -0x04
		%assign var_string             -0x20
		add sp, var_string
		
		push si
		push di
		
		cmp byte [dseg_isAudioDisabled], 0
		jz disableAudio
		
		; TODO: define strings as db; use strcpy
		
		; enable audio
			mov byte [bp+var_newIsAudioDisabled], 0
			mov word [bp+var_newAudioState], 2
			mov dword [bp+var_string+0x0], 'Audi'
			mov dword [bp+var_string+0x4], 'o en'
			mov dword [bp+var_string+0x8], 'able'
			mov dword [bp+var_string+0xC], `d\0\0\0`
			jmp haveNewAudioState
			
		disableAudio:
			mov byte [bp+var_newIsAudioDisabled], 1
			mov word [bp+var_newAudioState], 1
			mov dword [bp+var_string+0x0], 'Audi'
			mov dword [bp+var_string+0x4], 'o di'
			mov dword [bp+var_string+0x8], 'sabl'
			mov dword [bp+var_string+0xC], `ed\0`
			
		haveNewAudioState:
			mov ax, [bp+var_newAudioState]
			push ax
			push ax
			push ax
			callFromOverlay setAudioState
			add sp, 6
			
			mov al, [bp+var_newIsAudioDisabled]
			mov [dseg_isAudioDisabled], al
			
			push word 0
			push word 15
			push word 5
			lea ax, [bp+var_string]
			push ax
			push word [dseg_avatarIbo]
			push dseg_graphicsThing
			callFromOverlay barkOnItemInWorld
			add sp, 0xC
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_toggleAudio_end
endPatch
