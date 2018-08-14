%include "../UltimaPatcher.asm"
%include "include/uw1.asm"
%include "include/uw1-eop.asm"

[bits 16]

startPatch EXE_LENGTH, \
		expanded overlay procedure: mapControl
		
	startBlockAt addr_eop_mapControl
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_mapControl          0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		cmp word [bp+arg_mapControl], MapControl_LEVEL_UP
		jz levelUp
		cmp word [bp+arg_mapControl], MapControl_LEVEL_DOWN
		jz levelDown
		cmp word [bp+arg_mapControl], MapControl_AVATAR_LEVEL
		jz avatarLevel
		jmp endProc
		
		levelUp:
			test word [dseg_mapDungeonLevel], 7
			jz endProc
			
			mov ax, [dseg_mapDungeonLevel]
			inc ax
			jmp changeMapLevel
			
		levelDown:
			mov ax, [dseg_mapDungeonLevel]
			and ax, 7
			cmp ax, 1
			jz endProc
			
			mov ax, [dseg_mapDungeonLevel]
			dec ax
			jmp changeMapLevel
			
		avatarLevel:
			mov ax, [dseg_avatarDungeonLevel]
			
			cmp ax, [dseg_mapDungeonLevel]
			jz endProc
			
			jmp changeMapLevel
			
		changeMapLevel:
			push ax
			callFromOverlay changeMapLevel
			add sp, 2
			
		endProc:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_mapControl_end
endPatch
