[bits 16]

startPatch EXE_LENGTH, call-eop-barkOverItemInWorld
	startBlockAt addr_usecodeCallSite
		; di == ibo
		
		; get bark-text string pointer from Usecode list
		push 1
		lea ax, [si-8]
		push ax
		callFromOverlay usecode_getListNode
		pop cx
		pop cx
		
		mov bx, ax
		
		push word [bx+5]
		push di
		callVarArgsEopFromOverlay barkOverItemInWorld, 2
		pop cx
		pop cx
		
		jmp calcJump(off_usecodeCallSite_end)
	endBlockAt off_usecodeCallSite_end
endPatch
