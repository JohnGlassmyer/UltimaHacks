%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

startPatch EXE_LENGTH, \
		eop-toggleCheats
		
	startBlockAt seg_eop, off_eop_toggleCheats
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_newCheatsEnabled   -0x02
		%assign var_string             -0x20
		add sp, var_string
		
		push si
		push di
		
		cmp byte [dseg_cheatsEnabled], 0
		jz enableCheats
		
		; disable cheats
			mov dword [bp+var_string+0x0], 'Chea'
			mov dword [bp+var_string+0x4], 'ts d'
			mov dword [bp+var_string+0x8], 'isab'
			mov dword [bp+var_string+0xC], `led\0`
			jmp haveString
			
		enableCheats:
			mov dword [bp+var_string+0x0], 'Chea'
			mov dword [bp+var_string+0x4], 'ts e'
			mov dword [bp+var_string+0x8], 'nabl'
			mov dword [bp+var_string+0xC], `ed\0\0`
			
		haveString:
			mov ah, 1
			mov al, byte [dseg_cheatsEnabled]
			sub ah, al
			mov byte [dseg_cheatsEnabled], ah
			
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
		
	endBlockAt off_eop_toggleCheats_end
endPatch
