[bits 16]

startPatch EXE_LENGTH, eop-keepMoving
	%assign CYCLE_SPEED_FORWARD_KEY 'q'
	%assign CYCLE_SPEED_REVERSE_KEY 'Q'

	%assign MAX_SPEED 3

	startBlockAt addr_eop_keepMoving
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign arg_pn_stepsRemaining   0x06
		%assign arg_keyCode             0x04
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		%ifnum dseg_isPlayerControlDisabled
		; cancel and skip if Usecode has disabled player control
			cmp byte [dseg_isPlayerControlDisabled], 0
			jz .notControlDisabled
			
			mov byte [dseg_keepMoving_speed], 0
			jmp returnWithoutConsumingKey
			
			.notControlDisabled:
		%endif
		
		cancelIfAutoroute:
			cmp word [dseg_autorouteIbo], 0
			jz .notAutoroute
			
			mov byte [dseg_keepMoving_speed], 0
			
			.notAutoroute:
			
		tryChangeSpeed:
			cmp word [bp+arg_keyCode], CYCLE_SPEED_FORWARD_KEY
			jz .cycleForward
			cmp word [bp+arg_keyCode], CYCLE_SPEED_REVERSE_KEY
			jz .cycleReverse
			jmp .notChangeSpeed
			
			.cycleForward:
			mov di, 1
			jmp .cycleSpeed
			
			.cycleReverse:
			mov di, -1
			
			.cycleSpeed:
			; if starting from a standstill, adopt the Avatar's facing direction
				cmp byte [dseg_keepMoving_speed], 0
				jnz .notFromStandstill
				push dseg_avatarIbo
				callFromOverlay getNpcBufferForIbo
				pop cx
				mov es, dx
				mov bx, ax
				mov al, [es:bx+4]
				and al, 7
				mov [dseg_keepMoving_direction], al
				.notFromStandstill:
				
			movzx ax, [dseg_keepMoving_speed]
			add ax, di
			add ax, MAX_SPEED+1
			mov cl, MAX_SPEED+1
			div cl
			mov [dseg_keepMoving_speed], ah
			
			jmp returnWithKeyConsumed
			
			.notChangeSpeed:
			
		tryDirectionFromMovementKeys:
			cmp word [bp+arg_keyCode], 0x147
			jb .notDirectionFromMovementKeys
			cmp word [bp+arg_keyCode], 0x151
			ja .notDirectionFromMovementKeys
			mov bx, [bp+arg_keyCode]
			mov al, [dseg_directionForDirectionKey+bx-0x147]
			cmp al, -1
			jz .notDirectionFromMovementKeys
			
			mov byte [dseg_keepMoving_direction], al
			cmp byte [dseg_keepMoving_speed], 0
			jnz returnWithKeyConsumed
			
			.notDirectionFromMovementKeys:
			
		ignoreSingleLeftClick:
			cmp word [bp+arg_keyCode], 0x201 ; press left
			jz ignoreKey
			cmp word [bp+arg_keyCode], 0x207 ; release left
			jz ignoreKey
			
		tryDirectionFromMouse:
			cmp word [bp+arg_keyCode], 0x202 ; press right
			jz .takeDirectionFromMouse
			cmp word [bp+arg_keyCode], 0x206 ; hold right
			jz .takeDirectionFromMouse
			cmp word [bp+arg_keyCode], 0x208 ; release right
			jz .takeDirectionFromMouse
			jmp .notDirectionFromMouse
			
			.takeDirectionFromMouse:
			mov al, [dseg_mouseCursorImageNumber]
			sub al, [dseg_mouseCursorBaseNumber]
			and al, 7
			mov [dseg_keepMoving_direction], al
			
			; also take speed from mouse, if keepMoving is currently engaged
				cmp byte [dseg_keepMoving_speed], 0
				jz .notSpeedFromMouse
				callFromOverlay getCursorLength
				mov [dseg_keepMoving_speed], al
				.notSpeedFromMouse:
				
			jmp ignoreKey
			
			.notDirectionFromMouse:
			
		tryStopOnOtherKey:
			cmp word [bp+arg_keyCode], 0
			jz ignoreKey
			
			mov byte [dseg_keepMoving_speed], 0
			jmp returnWithoutConsumingKey
			
		ignoreKey:
		tryKeepMoving:
			mov bx, [bp+arg_pn_stepsRemaining]
			cmp byte [bx], 0
			jnz .notKeepMoving
			cmp byte [dseg_keepMoving_speed], 0
			jz .notKeepMoving
			cmp word [dseg_autorouteIbo], 0
			jnz .notKeepMoving
			cmp byte [dseg_keepMoving_direction], 0
			jl .notKeepMoving
				
			mov al, [dseg_keepMoving_direction]
			mov [dseg_movementDirection], al
			mov al, [dseg_keepMoving_speed]
			mov [bx], al
			
			.notKeepMoving:
			
		jmp returnWithoutConsumingKey
		
		returnWithoutConsumingKey:
			xor ax, ax
			jmp returnAx
			
		returnWithKeyConsumed:
			mov ax, 1
			
		returnAx:
		
		mov sp, bp
		pop bp
		retn
	endBlockAt off_eop_keepMoving_end
endPatch
