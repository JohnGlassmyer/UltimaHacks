[bits 16]

startPatch EXE_LENGTH, eop-toggleMouseHand
	startBlockAt addr_eop_toggleMouseHand
		push bp
		mov bp, sp
		
		; bp-based stack frame:
		%assign ____callerIp            0x02
		%assign ____callerBp            0x00
		
		push si
		push di
		
		cmp word [dseg_mouseHand], 0
		jz setToLeftHanded
		
		setToRightHanded:
			mov word [dseg_mouseHand], 0
			getRightHandedStringPnInAx
			jmp haveStringPn
			
		setToLeftHanded:
			mov word [dseg_mouseHand], 1
			getLeftHandedStringPnInAx
			
		haveStringPn:
			push word 1
			push word 15
			push word 5
			push ax
			push word [dseg_avatarIbo]
			push dseg_spriteManager
			callFromOverlay SpriteManager_barkOnItem
			add sp, 12
			
		pop di
		pop si
		mov sp, bp
		pop bp
		retn
		
	endBlockAt off_eop_toggleMouseHand_end
endPatch
