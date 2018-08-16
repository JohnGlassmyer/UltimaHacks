; U7SI would crash with an error message whenever the player tried to open the
;     Combat Status display with more than 6 members in the party. (And it is
;     certainly possible to get, through normal gameplay, to having more than 6
;     members in the party.)
; This prevents that crash by skipping the creation of the Combat Status dialog
;     whenever the party size is greater than 6.

%include "include/u7si-all-includes.asm"

defineAddress 327, 0x0035, displayItemDialog_didNotOpenDialog
defineAddress 327, 0x0176, displayItemDialog_considerIbo
defineAddress 327, 0x019D, displayItemDialog_haveOpenedDialog
defineAddress 327, 0x01A3, displayItemDialog_openItemInventory

[bits 16]

startPatch EXE_LENGTH, dontCrashWithMoreThanSix
	startBlockAt addr_displayItemDialog_considerIbo
		; si     : pn_ibo
		; bp+0xE : pn_openedDialog
		
		%assign var_pn_openedDialog -0x0E
		
		cmp word [si], 0
		jnz calcJump(off_displayItemDialog_openItemInventory)
		
		cmp byte [dseg_partySize], 6
		jbe sixOrFewer
		
		; it would be nice to play a sound or something to acknowledge the
		;     blocked intent, but this overlay's relocation table is full!
		
		jmp calcJump(off_displayItemDialog_didNotOpenDialog)
		
		sixOrFewer:
		
		push 0
		callFromOverlay CombatStatus_new
		pop cx
		test ax, ax
		jz calcJump(off_displayItemDialog_didNotOpenDialog)
		
		mov [bp+var_pn_openedDialog], ax
		
		; fall through
		
	endBlockAt off_displayItemDialog_haveOpenedDialog
endPatch
