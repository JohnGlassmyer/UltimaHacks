%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXE_LENGTH, \
		expanded overlay procedure call-site-dependent dispatcher
		
	startBlockAt addr_eop_byCallSiteDispatcher
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_firstArg            0x06
		%assign ____callerCs            0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		; push 3 (optional) arguments before calling
		push word [bp+arg_firstArg+4]
		push word [bp+arg_firstArg+2]
		push word [bp+arg_firstArg+0]
		
		; enqueueDrawBlock calls enqueueGridCoords from load module
			pushWithRelocation segmentFromOverlay_enqueueDrawBlock
			pop ax
			cmp ax, [bp+____callerCs]
			jnz notEnqueueGridCoords
			
			mov bx, off_eop_enqueueGridCoords
			jmp callEop
			
			notEnqueueGridCoords:
			
		; animateSlidingPanel calls slidePanel from load module
			pushWithRelocation segmentFromOverlay_animateSlidingPanel
			pop ax
			cmp ax, [bp+____callerCs]
			jnz notSlidePanel
			
			mov bx, off_eop_slidePanel
			jmp callEop
			
			notSlidePanel:
			
		; ark_x_skills calls trainSkill from overlay 96 with IP 0x093C
			mov ax, 0x093C
			cmp ax, [bp+____callerIp]
			jnz notTrainSkill
			
			mov bx, off_eop_trainSkill
			jmp callEop
			
			notTrainSkill:
			
		jmp popArguments
		
		callEop:
			call bx
			
		popArguments:
			add sp, 6
			
		; preserve return value in ax
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retf
	endBlockAt off_eop_byCallSiteDispatcher_end
endPatch
