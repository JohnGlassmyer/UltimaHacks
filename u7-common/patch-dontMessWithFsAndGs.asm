; With certainty that nothing else in the executable modifies the fs (or gs)
;     register, I can use the register as a selector to address Voodoo memory
;     without having to constantly restore its value because some other function
;     could have changed it.
; The only function in Ultima VII that modifies these registers without saving
;     and restoring their values on entry and exit is a rectangle-painter used
;     to paint above-ground areas black when the player is inside of a cave.
; The function seems to be built as a general-purpose rectangle painter, and it
;     would use fs and gs as general-purpose registers for counts of pixels to
;     fill. However, as I know that the function will only be called to paint
;     aligned 8-pixel tiles, I can modify it and remove its use of fs and gs.
; This is hacky, but it works.

[bits 16]

startPatch EXE_LENGTH, dontMessWithFsAndGs
	startBlockAt addr_enter
		; rather than allocating 4 bytes for stack variables, allocate 8 bytes
		enter 8, 0
	endBlockOfLength 4
	
	startBlockAt addr_setRepCounts
		; rather than putting dword and byte counts into fs and gs, just put
		;     the dword count into bp-8
		mov ax, dx
		shr ax, 2
		mov [bp-8], ax
	endBlockAt off_setRepCounts_end
	
	startBlockAt addr_stosDwordsAndBytes
		; rather than filling dwords and single bytes, just fill dwords
		mov cx, [bp-8]
		a32 rep stosd
	endBlockAt off_stosDwordsAndBytes_end
endPatch
