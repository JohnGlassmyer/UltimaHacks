; Adds U7SI's method of frame limiting to U7BG. Delays calling drawWorld until
;     the 60 Hz timer has fired 6 times since the last call, limiting the
;     maximum update rate to 10 fps.

%include "include/u7bg-all-includes.asm"

defineAddress   30, 0x018A, drawWorldCall
defineAddress   30, 0x018F, drawWorldCall_end

[bits 16]

startPatch EXE_LENGTH, eop-frameLimiter
	startBlockAt addr_eop_frameLimiter
		check:
			cmp byte [dseg_frameLimiterEnabled], 0
			jz done
			mov ax, [dseg_time]
			mov dx, [dseg_time+2]
			sub ax, [dseg_prevFrameTime]
			sbb dx, [dseg_prevFrameTime+2]
			cmp ax, 6
			jc check
		done:
			mov ax, [dseg_time]
			mov dx, [dseg_time+2]
			mov [dseg_prevFrameTime], ax
			mov [dseg_prevFrameTime+2], dx
			callFromOverlay drawWorld
			jmpFromOverlay drawWorldCall_end
	endBlockAt off_eop_frameLimiter_end

	startBlockAt addr_drawWorldCall
		; jmp instead of call to preserve the position of drawWorld's stack args
		jmpFromLoadModule eop1_entry_frameLimiter
	endBlockOfLength 5
endPatch
