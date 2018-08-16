; Restores the ability to inspect and set game flags in the cheat menu. In the
;     released versions of U7BG and U7SI, the sites that might have called some
;     function to prompt the user for a flag number instead called a function
;     that would always return -1 (an invalid flag number). This patch replaces
;     those with calls to a function that prompts for an integer.

[bits 16]

startPatch EXE_LENGTH, restoreGameFlagsCheatMenu
	%macro restoreFlagNumberPrompt 3
		%define %%off_end %1
		%define %%reg_pn_flags %2
		%define %%reg_flagNumber %3
		
		push dseg_flagNumberPromptString
		callFromOverlay promptForIntegerWord
		pop cx
		
		; jae will catch -1 (to cancel) along with out-of-range flag numbers
		cmp ax, [%%reg_pn_flags+8]
		jae calcJump(%%off_end)
		
		mov %%reg_flagNumber, ax
		
		push 5
		push 1
		callFromOverlay positionTextCursor
		pop cx
		pop cx
	%endmacro
	
	startBlockAt addr_setFlag_promptForFlagNumber
		restoreFlagNumberPrompt off_setFlag_end, si, di
	endBlockAt off_setFlag_havePositionedCursor
	
	startBlockAt addr_inspectFlag_promptForFlagNumber
		restoreFlagNumberPrompt off_inspectFlag_end, di, si
	endBlockAt off_inspectFlag_havePositionedCursor
endPatch
