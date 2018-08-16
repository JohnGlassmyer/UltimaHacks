; Draws the spellbook displaying spell runes in place of reagent counts on
;     spells if the Shift key is held.

startPatch EXE_LENGTH, printRuneTextOnSpellbook
	%macro SpellbookDialog_update_stackFrame 0
		%assign .arg_pn_viewport      0x08
		%assign .var_x               -0x08
		%assign .var_y               -0x0A
		%assign .var_spellNumber     -0x0C
		%assign .var_selectedCircle  -0x10
		%assign .var_string          -0x22
		%assign .var_template        -0x26
		%assign .var_fontNumber      -0x28
	%endmacro

	startBlockAt addr_SpellbookDialog_update_printReagentCount
		SpellbookDialog_update_stackFrame
		
		mov ax, [bp+.var_selectedCircle]
		shl ax, 3
		add ax, di
		mov [bp+.var_spellNumber], ax
		
		push ax
		lea ax, [si+SpellbookDialog_ibo]
		push ax ; pn_spellbookIbo
		callFromOverlay doesSpellbookHaveSpell
		pop cx
		pop cx
		test al, al
		jz .afterPrinting
		
		jmp calcJump(off_needStringAndFont)
		
		; ---------
		off_backForSpellRunes EQU block_currentOffset
		
		.displaySpellRunes:
			mov word [bp+.var_fontNumber], Font_RED
			
			; assuming that eop-castByKey has initialized the CastByKey data
			push VOODOO_SELECTOR
			pop fs
			movzx ecx, word [bp+.var_spellNumber]
			mov ebx, [dseg_pf_castByKeyData]
			mov eax, [fs:ebx+CastByKey_spellRunes + ecx*8+0]
			mov edx, [fs:ebx+CastByKey_spellRunes + ecx*8+4]
			
			mov dword [bp+.var_string+0], eax
			mov dword [bp+.var_string+4], edx
			mov byte [bp+.var_string+8], 0
			
		; ---------
		off_haveStringAndFont EQU block_currentOffset
		
		; account for right-alignment of text
		add word [bp+.var_x], 10
		
		lea ax, [bp+.var_string]
		push ax
		push TextAlignment_RIGHT | TextAlignment_TOP
		push word [bp+.var_fontNumber]
		push word [bp+.var_y]
		push word [bp+.var_x]
		push word [bp+.arg_pn_viewport]
		callVarArgsEopFromOverlay printText, 6
		add sp, 12
		
		.afterPrinting:
		
		times 6 nop
	endBlockAt off_SpellbookDialog_update_printReagentCount_end
	
	startBlockAt addr_SpellbookDialog_updateReagentCounts
		push bp
		mov bp, sp
		
		%assign .arg_pn_this        0x06
		%assign .____callerCs       0x04
		%assign .____callerIp       0x02
		%assign .____callerBp       0x00
		%assign .var_itemIbo       -0x02
		%assign .var_outerBoundIbo -0x04
		add sp, .var_outerBoundIbo
		
		push si
		
		mov si, [bp+.arg_pn_this]
		mov ax, [si+SpellbookDialog_ibo]
		mov [bp+.var_itemIbo], ax
		
		push dseg_avatarIbo
		lea ax, [bp+.var_itemIbo]
		push ax
		push 0
		lea ax, [si+SpellbookDialog_containingIbo]
		push ax
		callFromOverlay getOuterContainer
		add sp, 8
		
		lea ax, [si+SpellbookDialog_containingIbo]
		push ax
		push 0 ; unused
		callFromOverlay countReagentsInPossession
		pop cx
		pop cx
		
		pop si
		
		mov sp, bp
		pop bp
		retf
		
		; now that SpellbookDialog_updateReagentCounts is shorter, we can use
		;     this space for what would not fit in SpellbookDialog_update.
		
		; ---------
		off_needStringAndFont EQU block_currentOffset
		needStringAndFont:
			callFromOverlay getLeftAndRightShiftStatus
			test ax, ax
			jnz calcJump(off_backForSpellRunes)
			
			; (in stack frame of SpellbookDialog_update, above)
			SpellbookDialog_update_stackFrame
			
			mov word [bp+.var_fontNumber], Font_TINY_GLOWING_BLUE
			
			; display no count for a free spell
			mov bx, [bp+.var_spellNumber]
			cmp byte [dseg_reagentCountForSpell+bx], 0
			jl .useNothing
			
			%ifdef off_isAvatarWearingRingOfReagents
				callFromOverlay isAvatarWearingRingOfReagents
				test al, al
				jz .notInfinity
				
				mov dword [bp+.var_string], ` #\0\0`
				jmp .haveString
				
				.notInfinity:
			%endif
			
			mov bx, [bp+.var_spellNumber]
			movzx ax, [dseg_reagentCountForSpell+bx]
			
			; don't display a zero count
			test ax, ax
			jz .useNothing
			
			push ax
			mov dword [bp+.var_template], `%3d\0`
			lea ax, [bp+.var_template]
			push ax
			lea ax, [bp+.var_string]
			push ax
			callFromOverlay sprintf
			add sp, 6
			
			jmp .haveString
			
			.useNothing:
				mov byte [bp+.var_string], 0
				
			.haveString:
				jmp calcJump(off_haveStringAndFont)
				
		times 10 nop
	endBlockAt off_SpellbookDialog_updateReagentCounts_end
endPatch
