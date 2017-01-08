%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		expanded overlay procedure: tryKeyAndMouseBindings
		
	startBlockAt off_eop_tryKeyAndMouseBindings
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp                0x02
		%assign ____callerBp                0x00
		%assign var_savedLastKeyTime       -0x04
		
		add sp, var_savedLastKeyTime
		push si
		push di
		
		; assume that we have not cleared the last-key time
			mov dword [bp+var_savedLastKeyTime], 0
			
		; if enough time has elapsed since the last key binding was called,
		; then save and (subsequently) clear the last-key time to allow a key
		; to be detected (even if other code has recently detected a key)
			les bx, [dseg_time_ps]
			mov ebx, [es:bx]
			
			mov eax, [dseg_lastKeyBindingTime]
			add eax, 50
			
			cmp eax, ebx
			ja afterSavingLastKeyTime
			
			mov eax, [dseg_lastKeyTime]
			mov [bp+var_savedLastKeyTime], eax
			
			afterSavingLastKeyTime:
			
		; Try several times to execute a key or mouse binding.
		;
		; If multiple keys of a multi-key binding (e.g. with Ctrl or Alt) are
		; held, then the code that tries key bindings will try to match each of
		; those keys, one at a time, each time it is invoked. As only one of the
		; keys (e.g. the non-modifier key) will match the multi-key binding,
		; bindings need to be tried for each of the currently held keys.
		; Otherwise, multi-key commands would fail to work seemingly at random.
		mov word [dseg_lastKeyOrMouseBinding_pn], 0
		mov si, 1
		tryBindingsLoop:
			; if the last-key time was saved, that means we need to clear it
			; before checking for a key
				cmp dword [bp+var_savedLastKeyTime], 0
				jz afterClearingLastKeyTime
				mov dword [dseg_lastKeyTime], 0
				afterClearingLastKeyTime:
				
			push word [dseg_inputState_pn]
			callWithRelocation o_tryKeyAndMouseBindings
			add sp, 2
			
			; If a key or mouse binding was called, we can quit the loop.
				cmp word [dseg_lastKeyOrMouseBinding_pn], 0
				jnz calledBinding
				
			dec si
			jnz tryBindingsLoop
			jmp ranOutOfBindings
			
		calledBinding:
			; If a key binding was called, then record the time.
				cmp byte [dseg_wasLastBindingKey], 0
				jz afterRecordingKeyBindingTime
				
				les bx, [dseg_time_ps]
				mov eax, [es:bx]
				mov [dseg_lastKeyBindingTime], eax
				
				afterRecordingKeyBindingTime:
				
			; (The key detection code has set the last-key time to a new value.)
			
			jmp endProc
			
		ranOutOfBindings:
		; No key binding was called. If we saved (and cleared) the last-key
		; time, then restore its correct value.
			mov eax, [bp+var_savedLastKeyTime]
			cmp eax, 0
			jz afterRestoringLastKeyTime
			mov [dseg_lastKeyTime], eax
			afterRestoringLastKeyTime:
			
		endProc:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_tryKeyAndMouseBindings_end
endPatch
