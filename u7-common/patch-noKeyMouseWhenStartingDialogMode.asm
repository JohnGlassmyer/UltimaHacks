; Original game would enable key-mouse mode when starting dialog mode. This
;     would prevent response to hotkeys after opening a dialog until the user
;     moved the mouse. This removes the key-mouse (which can now be deliberately
;     enabled with Spacebar).

[bits 16]

startPatch EXE_LENGTH, noKeyMouseWhenStartingDialogMode
	startBlockAt addr_startDialogMode_enableKeyMouse
		push MouseCursor_FINGER
		callFromOverlay selectMouseCursor
		pop cx
		
		times 20 nop
	endBlockAt off_startDialogMode_enableKeyMouse_end
endPatch
