; Uses a keyring, if the party has one; otherwise, allows the player to select
;     a target and then automatically finds and uses a party-held key for that
;     target.
; Removes the hassle associated with managing keys in U7BG in particular, but
;     also in the part of U7SI before acquiring the keyring.

[bits 16]

startPatch EXE_LENGTH, eop-selectAndUseKey
	startBlockAt addr_eop_selectAndUseKey
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		%assign var_dontCare           -0x02
		%assign var_selectedIbo        -0x04
		%assign var_quality            -0x06
		%assign var_keyIbo             -0x08
		add sp, var_keyIbo
		
		push si
		push di
		
		; if game has a keyring type, and party has a keyring, then use that
		%ifnum ItemType_KEYRING
			push word 0xFF  ; frame
			push word 0xFF  ; quality
			push word ItemType_KEYRING
			callVarArgsEopFromOverlay findPartyItem, 3
			add sp, 6
			
			test ax, ax
			jz afterTryingKeyring
			
			mov [bp+var_keyIbo], ax
			jmp useItem
			
			afterTryingKeyring:
		%endif
		
		; otherwise, have the player select a target
		;   and try to find a matching key
		
		lea ax, [bp+var_dontCare]
		push ax
		lea ax, [bp+var_dontCare] ; coordinateY
		push ax
		lea ax, [bp+var_dontCare] ; coordinateX
		push ax
		lea ax, [bp+var_selectedIbo] ; ibo
		push ax
		callFromOverlay havePlayerSelect
		add sp, 8
		
		cmp word [bp+var_selectedIbo], 0
		jz short nothingSelected
		
		lea ax, [bp+var_selectedIbo]
		push ax
		callFromOverlay Item_getQuality
		pop cx
		
		and ax, 0xFF
		
		test ax, ax
		jz qualityZero
		
		push word 0xFF  ; frame
		push ax         ; key quality
		push word 641   ; key itemType
		callVarArgsEopFromOverlay findPartyItem, 3
		add sp, 6
		mov [bp+var_keyIbo], ax
		
		test ax, ax
		jz noKey
		
		push USE_KEY_SOUND
		callFromOverlay playSoundSimple
		pop cx
		
		useItem:
			; enable Hack Mover temporarily so use doesn't get blocked
			movzx si, byte [dseg_isHackMoverEnabled]
			mov byte [dseg_isHackMoverEnabled], 1
			
			push word 0 ; flags
			push word 0 ; y coordinate
			push word 0 ; x coordinate
			lea ax, [bp+var_keyIbo]
			push ax
			callFromOverlay use
			add sp, 8
			
			; restore state of Hack Mover
			mov ax, si
			mov byte [dseg_isHackMoverEnabled], al
			
			jmp procEnd
			
		nothingSelected:
		qualityZero:
		noKey:
			push NO_KEY_SOUND
			callFromOverlay playSoundSimple
			pop cx
			
		procEnd:
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_selectAndUseKey_end
endPatch
