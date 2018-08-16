; Returns ibo of nth non-dead party member (ordered by NPC number).

[bits 16]

startPatch EXE_LENGTH, eop-getPartyMemberIbo
	startBlockAt addr_eop_getPartyMemberIbo
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_partyMemberIndex    0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_npcNumber          -0x02
		%assign var_foundIt            -0x04
		%assign var_npcIbo             -0x06
		add sp, var_npcIbo
		
		push si
		push di
		
		mov ax, [dseg_partySize]
		cmp word [bp+arg_partyMemberIndex], ax
		jge notFound
		
		xor di, di
		mov word [bp+var_npcNumber], 0
		forNpc:
			cmp word [bp+var_npcNumber], 356
			jae notFound
			
			push word [bp+var_npcNumber]
			lea ax, [bp+var_npcIbo]
			push ax
			callFromOverlay getNpcIbo
			pop cx
			pop cx
			
			lea ax, [bp+var_npcIbo]
			push ax
			callFromOverlay getNpcBufferForIbo
			pop cx
			mov bx, ax
			mov es, dx
			test word [es:bx+4], 0x800 ; is npc in party?
			jz nextNpc
			
			test word [es:bx+4], 0x8000 ; is NPC dead?
			jnz nextNpc
			
			cmp di, word [bp+arg_partyMemberIndex]
			jl nextPartyMember
			
			mov ax, [bp+var_npcIbo]
			jmp endProc
			
			nextPartyMember:
			inc di
			
			nextNpc:
			inc word [bp+var_npcNumber]
			jmp forNpc
			
		notFound:
			xor ax, ax
			
		endProc:
			; ax == ibo of nth party member, or 0
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_getPartyMemberIbo_end
endPatch
