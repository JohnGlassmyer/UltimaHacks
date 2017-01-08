%include "../UltimaPatcher.asm"
%include "include/uw2.asm"
%include "include/uw2-eop.asm"

[bits 16]

; TODO: use FPU also for
;   - square root
;   - atan2
; TODO: find a use for the obviated code and lookup-tables
startPatch EXPANDED_OVERLAY_EXE_LENGTH, \
		replace trigonometric table-lookups with calls to FPU trig instructions
		
	off_sinCos_notInRender            EQU 0x24B63
	off_interpolateSinCos_notInRender EQU 0x24BAE
	
	; angle, sin and cos in [-8000h, 8000h)
	startBlockAt off_sinCos_notInRender
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_cos_pn      0x0A
		%assign arg_sin_pn      0x08
		%assign arg_angle       0x06
		%assign ____callerCs    0x04
		%assign ____callerIp    0x02
		%assign ____callerBp    0x00
		%assign var_sin        -0x02
		%assign var_cos        -0x04
		
		add sp, var_cos
		push si
		push di
		
		; ds := dseg
			push ds
			pushWithRelocation 0x65E9
			pop ds
			
		mov si, [bp+arg_sin_pn]
		mov di, [bp+arg_cos_pn]
		
		cmp word [bp+arg_angle], 0
		jz angle0
		
		cmp word [bp+arg_angle], 0x4000
		jz angle4000
		
		cmp word [bp+arg_angle], 0x8000
		jz calcJump(angle8000 \
				- secondEntryPoint + off_interpolateSinCos_notInRender)
				
		cmp word [bp+arg_angle], 0xC000
		jz calcJump(angleC000 \
				- secondEntryPoint + off_interpolateSinCos_notInRender)
				
		jmp calcJump(calculateUsingFpu \
				- secondEntryPoint + off_interpolateSinCos_notInRender)
				
		angle0:
			mov word [si], 0
			mov word [di], 0x7FFF
			jmp calcJump(endProc \
					- secondEntryPoint + off_interpolateSinCos_notInRender)
					
		angle4000:
			mov word [si], 0x7FFF
			mov word [di], 0
			jmp calcJump(endProc \
					- secondEntryPoint + off_interpolateSinCos_notInRender)
					
	endBlockAt off_interpolateSinCos_notInRender
	
	startBlockAt off_interpolateSinCos_notInRender
		secondEntryPoint:
		; redirect calls to interpolatedSinCos to new sinCos above
			jmp calcJump(off_sinCos_notInRender)
			
		angle8000:
			mov word [si], 0
			mov word [di], 0x8000
			jmp endProc
			
		angleC000:
			mov word [si], 0x8000
			mov word [di], 0
			jmp endProc
			
		calculateUsingFpu:
			finit
			fild word [bp+arg_angle]
			fidiv dword [dseg_radianAngle]
			fsincos
			fimul dword [dseg_trigScale]
			fistp word [bp+var_cos]
			fimul dword [dseg_trigScale]
			fistp word [bp+var_sin]
			
			mov ax, [bp+var_sin]
			mov [si], ax
			
			mov ax, [bp+var_cos]
			mov [di], ax
			
		endProc:
		
		; restore ds (after setting it to dseg)
			pop ds
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retf
	endBlockAt 0x24BFB
endPatch
