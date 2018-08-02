%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		expanded overlay procedure: trainSkill
		
	startBlockAt off_eop_trainSkill
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_skillNumber         0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_oldSkillValue      -0x02
		%assign var_axFromTrainSkill   -0x04
		%assign var_fragmentString     -0x20
		%assign var_messageString      -0x40
		
		add sp, var_messageString
		push si
		push di
		
		; si -> skill value
			mov si, [dseg_avatarData_pn]
			add si, [bp+arg_skillNumber]
			add si, 0x21
			
		movzx ax, byte [si]
		mov [bp+var_oldSkillValue], ax
		
		push word [bp+arg_skillNumber]
		callFromOverlay trainSkill
		add sp, 2
		
		mov [bp+var_axFromTrainSkill], ax
		
		; don't report increase in skill value if training failed
			test ax, ax
			jz endProc
			
		; di := increase in skill value
			movzx di, byte [si]
			mov ax, [bp+var_oldSkillValue]
			sub di, ax
			
		; don't report increase in skill value if increase is zero
			jz endProc
			
		reportIncrease:
			; string color: narration (black)
				mov word [bp+var_messageString+0], '\2'
				mov byte [bp+var_messageString+2], 0
				
			; skill name
				mov ax, [bp+arg_skillNumber]
				add ax, 31
				or ax, 0x400
				push ax
				callFromOverlay getExternalizedString
				add sp, 2
				
				push dx
				push ax
				push ss
				lea ax, [bp+var_messageString]
				push ax
				callFromOverlay strcat_far
				add sp, 8
				
			; " increased by "
				mov dword [bp+var_fragmentString+0x00], ` inc`
				mov dword [bp+var_fragmentString+0x04], `reas`
				mov dword [bp+var_fragmentString+0x08], `es b`
				mov dword [bp+var_fragmentString+0x0C], `y \0`
				
				lea ax, [bp+var_fragmentString]
				push ax
				lea ax, [bp+var_messageString]
				push ax
				callFromOverlay strcat
				add sp, 4
				
			; skill-value increase
				push 10
				lea ax, [bp+var_fragmentString]
				push ax
				push di
				callFromOverlay signedWordToString
				add sp, 6
				
				lea ax, [bp+var_fragmentString]
				push ax
				lea ax, [bp+var_messageString]
				push ax
				callFromOverlay strcat
				add sp, 4
				
			; " to "
				mov dword [bp+var_fragmentString], ` to `
				mov byte [bp+var_fragmentString+4], 0
				
				lea ax, [bp+var_fragmentString]
				push ax
				lea ax, [bp+var_messageString]
				push ax
				callFromOverlay strcat
				add sp, 4
				
			; new skill value
				push 10
				lea ax, [bp+var_fragmentString]
				push ax
				movzx ax, byte [si]
				push ax
				callFromOverlay signedWordToString
				add sp, 6
				
				lea ax, [bp+var_fragmentString]
				push ax
				lea ax, [bp+var_messageString]
				push ax
				callFromOverlay strcat
				add sp, 4
				
			; "."
				mov word [bp+var_fragmentString], `.\0`
				
				lea ax, [bp+var_fragmentString]
				push ax
				lea ax, [bp+var_messageString]
				push ax
				callFromOverlay strcat
				add sp, 4
				
			cmp word [dseg_interfaceMode], 4
			jz printInConversation
			
			printToScroll:
				push ss
				lea ax, [bp+var_messageString]
				push ax
				callFromOverlay printStringToScroll
				add sp, 4
				
			printInConversation:
				push ss
				lea ax, [bp+var_messageString]
				push ax
				callFromOverlay ark_say
				add sp, 4
				
		endProc:
		
		mov ax, [bp+var_axFromTrainSkill]
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_trainSkill_end
endPatch
