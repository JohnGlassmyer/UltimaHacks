%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		expanded overlay procedure: setInterfaceContext
		
	startBlockAt off_eop_setInterfaceContext
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_interfaceContext    0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		mov si, [bp+arg_interfaceContext]
		mov di, [dseg_inputState_pn]
		
		; disable mouseLook if switching from normal movement
			test word [di+InputState_context], 17
			jz afterDisablingMouseLook
			mov al, byte [dseg_isMouseLookEnabled]
			mov byte [dseg_wasMouseLookEnabledIn3dView], al
			push 0
			call calcJump(off_eop_setMouseLookState)
			add sp, 2
			afterDisablingMouseLook:
			
		; set interface context
			mov [di+InputState_context], si
			mov [dseg_interfaceContext], si
			
		; set index of function-pointer-table (??) based on new context
			cmp si, 2
			jnz not2
			mov ax, 1 ; map screen
			jmp haveOtherValue
			not2:
			
			cmp si, 4
			jnz not4
			mov ax, 2 ; conversation
			jmp haveOtherValue
			not4:
			
			xor ax, ax
			
			haveOtherValue:
			mov word [dseg_interfaceRoutinesSelector], ax
			
		; restore mouseLook if switching back to normal movement
			test word [di+InputState_context], 17
			jz afterRestoringMouseLook
			movzx ax, byte [dseg_wasMouseLookEnabledIn3dView]
			push ax
			call calcJump(off_eop_setMouseLookState)
			add sp, 2
			afterRestoringMouseLook:
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_setInterfaceContext_end
endPatch
