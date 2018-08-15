%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

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
		cmp word [bp+arg_mapControl], MapControl_REALM_UP
		jz realmUp
		cmp word [bp+arg_mapControl], MapControl_REALM_DOWN
		jz realmDown
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
			
		realmUp:
			mov bx, [dseg_mapDungeonLevel]
			dec bx
			shr bx, 3
			shl bx, 1
			movzx ax, [cs:offsetInCodeSegment(adjacentRealmTable)+bx+1]
			jmp haveNewRealm
			
		realmDown:
			mov bx, [dseg_mapDungeonLevel]
			dec bx
			shr bx, 3
			shl bx, 1
			movzx ax, [cs:offsetInCodeSegment(adjacentRealmTable)+bx+0]
			jmp haveNewRealm
			
		haveNewRealm:
			shl ax, 3
			mov bx, [dseg_mapDungeonLevel]
			dec bx
			and bx, 0b111
			add ax, bx
			inc ax
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
		
		adjacentRealmTable:
			db 8, 1 ; from realm 0
			db 0, 2 ; from realm 1
			db 1, 3 ; from realm 2
			db 2, 4 ; from realm 3
			db 3, 5 ; from realm 4
			db 4, 7 ; from realm 5
			db 7, 8 ; from realm 6
			db 5, 6 ; from realm 7
			db 6, 0 ; from realm 8
			
	endBlockAt off_eop_mapControl_end
endPatch
