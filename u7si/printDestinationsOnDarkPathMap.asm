%include "include/u7si-all-includes.asm"

defineAddress 245, 0x0119, afterDrawingDarkPathMap
defineAddress 245, 0x014E, afterDrawingDarkPathMap_end

startPatch EXE_LENGTH, printDestinationsOnDarkPathMap
	startBlockAt addr_afterDrawingDarkPathMap
		callVarArgsEopFromOverlay printDarkPathDestinations, 0
		
		times 44 nop
	endBlockAt off_afterDrawingDarkPathMap_end
endPatch
