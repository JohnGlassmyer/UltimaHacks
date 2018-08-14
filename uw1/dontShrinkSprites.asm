%ifndef EXE_LENGTH
	%include "../UltimaPatcher.asm"
	%include "include/uw1.asm"

	defineAddress 4, 0x6879, adjustSpriteVerticalPosition
	defineAddress 4, 0x6898, adjustSpriteHeight
%endif

[bits 16]

; This patch removes the view-pitch-dependent vertical scaling of sprites.
;
; UW would scale the height and vertical position of sprites (including those of
; NPCs) up as the 3d perspective pitched up, and down as the 3d perspective
; pitched down. This wasn't a problem originally, as the player was only allowed
; to pitch the view up or down by a small amount. However, as my other patches
; have expanded the allowed range of view pitch, sprites of NPCs would be scaled
; to absurd dimensions when the player pitched the view further up or down.
startPatch EXE_LENGTH, \
		do not scale sprite height and position with view pitch
		
	startBlockAt addr_adjustSpriteVerticalPosition
		; original: imul word [0x160A]
		
		shr ax, 1
		mov dx, ax
	endBlockOfLength 4
	
	startBlockAt addr_adjustSpriteHeight
		; original: imul word [0x160A]
		
		shr ax, 1
		mov dx, ax
	endBlockOfLength 4
endPatch
