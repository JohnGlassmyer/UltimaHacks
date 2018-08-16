[bits 16]

startPatch EXE_LENGTH, spaceEndsKeyMouse
	startBlockAt addr_valueForKey
		callFromOverlay waitForClickOrKey
	endBlockAt off_valueForKey_end
endPatch
