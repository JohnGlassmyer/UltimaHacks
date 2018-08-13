%include "../UltimaPatcher.asm"
%include "include/u7.asm"
%include "include/u7-eop.asm"

[bits 16]

USE_KEY_SOUND                           EQU 14  ; sound of dialog opening
NO_KEY_SOUND                            EQU 76  ; "no can do" sound

; Performs a similar function as Serpent Isle's keyring.
startPatch EXE_LENGTH, \
		eop-selectAndUseKey
		
	startBlockAt seg_eop, off_eop_selectAndUseKey
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
		add sp, 2
		
		and ax, 0xFF
		
		test ax, ax
		jz qualityZero
		
		push word 0xFF  ; frame
		push ax         ; key quality
		push word 641   ; key itemType
		callEopFromOverlay 3, findPartyItem
		add sp, 6
		mov [bp+var_keyIbo], ax
		
		test ax, ax
		jz noKey
		
		; found a matching key; use it
			push USE_KEY_SOUND
			callFromOverlay playSoundSimple
			pop cx
			
			; enable Hack Mover temporarily so use doesn't get blocked
			movzx si, byte [dseg_hackMoverEnabled]
			mov byte [dseg_hackMoverEnabled], 1
			
			push word 0 ; flags
			push word 0 ; y coordinate
			push word 0 ; x coordinate
			lea ax, [bp+var_keyIbo]
			push ax
			callFromOverlay use
			add sp, 8
			
			; restore state of Hack Mover
			mov ax, si
			mov byte [dseg_hackMoverEnabled], al
			
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
