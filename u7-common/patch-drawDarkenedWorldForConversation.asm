; Calls eop-drawDarkenedWorld to draw a darker background view of the world when
;     starting a conversation (or when reading a book or a scroll).
; By darkening the background, this enhances the legibility of text. That yellow
;     font could be so hard to read against Ultima VII's bright, colorful world.

[bits 16]

startPatch EXE_LENGTH, drawDarkenedWorldForConversation.asm
	startBlockAt addr_beginConversation_drawWorld
		callVarArgsEopFromOverlay drawDarkenedWorld, 0
	endBlockAt off_beginConversation_drawWorld_end
endPatch
