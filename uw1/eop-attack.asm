%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"
	%include "include/uw1-eop.asm"
%endif

[bits 16]

startPatch EXE_LENGTH, \
		expanded overlay procedure: attack
		
	startBlockAt addr_eop_attack
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_attackType          0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		movzx ax, byte [bp+arg_attackType]
		
		test al, al
		jz autoAttack
		
		numberedAttack:
			; save the attack type for subsequent auto-attacks
				mov [dseg_autoAttackType], al
				
			push ax
			callFromOverlay attack
			add sp, 2
			
			jmp endProc
			
		autoAttack:
			; attack with the last used attack-type, or the hard-coded default
			movzx ax, [dseg_autoAttackType]
			push ax
			callFromOverlay attack
			add sp, 2
			
			mov word [dseg_currentAttackScancode], 0x39 ; scancode of Spacebar
			
		endProc:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_attack_end
endPatch
