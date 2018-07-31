%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		expanded overlay procedure: runeKey
		
	startBlockAt off_eop_runeKey
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_character           0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		mov si, [dseg_inputState_pn]
		
		mov di, [bp+arg_character]
		
		cmp di, 8
		jz clearRunes
		
		cmp di, ' '
		jz tryToCast
		
		cmp di, 'a'
		jb endProc
		cmp di, 'y'
		jz ylem
		cmp di, 'w'
		ja endProc
		
		sub di, 'a'
		jmp haveRuneIndexInDi
		
		; 'y' has to be translated separately because there is no 'x' rune
		ylem:
			mov di, 23
			jmp haveRuneIndexInDi
			
		tryToCast:
			callWithRelocation o_tryToCast
			jmp endProc
			
		clearRunes:
			push 0
			push 64
			push 4
			callWithRelocation o_playSoundEffect
			add sp, 6
			
			mov word [si+InputState_relativeX], 40
			mov word [si+InputState_relativeY], 10
			jmp simulateClickOnRunePanel
			
		haveRuneIndexInDi:
		
		; does the avatar have the selected rune?
			; ax := runeBitmasks[runeIndex / 8]
				mov ax, di
				sar ax, 3
				mov bx, [dseg_avatarData_pn]
				add bx, ax
				movzx ax, byte [bx+0x44]
				
			; test bit corresponding to selected rune
				mov cx, di
				and cx, 7
				mov bx, 0b10000000
				shr bx, cl
				test ax, bx
				jnz avatarHasRune
				
		avatarDoesNotHaveRune:
			push 0
			push 64
			push 45
			callWithRelocation o_playSoundEffect
			add sp, 6
			
			jmp endProc
			
		avatarHasRune:
			; play rune-selection sound
				push 0
				push 64
				push 3
				callWithRelocation o_playSoundEffect
				add sp, 6
				
			; dx:ax := column:row
				mov ax, di
				xor dx, dx
				mov bx, 4
				div bx
				
			push dx
			
			; y := 26 + ((5 - row) * 15)
				neg ax
				add ax, 5
				mov dx, 15
				mul dx
				add ax, 26
				mov word [si+InputState_relativeY], ax
				
			pop ax
			
			; x := 12 + (column * 18)
				mov dx, 18
				mul dx
				add ax, 12
				mov word [si+InputState_relativeX], ax
				
		simulateClickOnRunePanel:
			mov word [si+InputState_mouseButton], 1
			
			push word [dseg_cursorMode]
			mov word [dseg_cursorMode], 0
			
			callWithRelocation o_clickRunePanel
			
			pop word [dseg_cursorMode]
			
			mov word [si+InputState_mouseButton], 0
			
		endProc:
		
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_runeKey_end
endPatch
