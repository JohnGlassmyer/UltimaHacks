%include "../UltimaPatcher.asm"
%include "include/uw1.asm"
%include "include/uw1-eop.asm"

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
		
		; enqueueDrawBlock calls eop-enqueueGridCoords
			pushWithRelocation segmentFromOverlay_enqueueDrawBlock
			pop ax
			cmp ax, [bp+____callerCs]
			jnz notEnqueueGridCoords
			
			mov bx, off_eop_enqueueGridCoords
			jmp callEop
			
			notEnqueueGridCoords:
			
		; animateSlidingPanel calls eop-slidePanel
			pushWithRelocation segmentFromOverlay_animateSlidingPanel
			pop ax
			cmp ax, [bp+____callerCs]
			jnz notSlidePanel
			
			mov bx, off_eop_slidePanel
			jmp callEop
			
			notSlidePanel:
			
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
