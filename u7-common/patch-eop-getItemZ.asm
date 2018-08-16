[bits 16]

startPatch EXE_LENGTH, eop-getItemZ
	startBlockAt addr_eop_getItemZ
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_ibo                 0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_zAndStuff          -0x02
		add sp, var_zAndStuff
		
		push esi
		push edi
		
		lea ax, [bp+arg_ibo]
		push ax
		push ss
		lea ax, [bp+var_zAndStuff]
		push ax
		callFromOverlay getItemZAndStuff
		add sp, 6
		
		movzx ax, [bp+var_zAndStuff]
		and ax, 0xF0
		shr ax, 4
		
		pop edi
		pop esi
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_getItemZ_end
endPatch
