; =============================================================================
; Ultima Underworld II Hacks -- expanded overlay
; -----------------------------------------------------------------------------

%assign nextEopNumber 0
; eopProc length, procName
%macro eopProc 2
	%assign eopNumber nextEopNumber
	
	%assign eopStart nextEopStart
	%assign eopEnd eopStart + %1
	
	defineAddress seg_eop, eopStart, eop_%[%2]
	defineAddress seg_eop, eopEnd,   eop_%[%2]_end
	
	defineAddress seg_eop, eopStart, eop_%[eopNumber]
	defineAddress seg_eop, eopEnd,   eop_%[eopNumber]_end
	
	eopNumber_%[%2] EQU eopNumber
	
	%assign nextEopStart eopEnd
	%assign nextEopNumber nextEopNumber + 1
%endmacro

%assign nextEopStart ORIGINAL_EOP_LENGTH

eopProc 0x100, varArgsDispatcher
eopProc 0x100, byteArgDispatcher
eopProc 0x100, byCallSiteDispatcher

; (a table, not a procedure)
eopProc 0x100, dispatchTable

eopProc 0x040, attack
eopProc 0x030, clickFlasks
eopProc 0x090, enqueueDrawBlock
eopProc 0x050, enqueueGridCoords
eopProc 0x030, flipToPanel
eopProc 0x0E0, interactAtCursor
eopProc 0x0B0, mapControl
eopProc 0x120, moreBindings
eopProc 0x0D0, mouseLookOrMoveCursor
eopProc 0x0D0, runeKey
eopProc 0x060, setInterfaceMode
eopProc 0x0C0, setMouseLookState
eopProc 0x1E0, setupPerspectiveAndEnqueueDraw
eopProc 0x020, slidePanel
eopProc 0x080, toggleMouseLook
eopProc 0x190, trainSkill
eopProc 0x090, tryKeyAndMouseBindings

%define varArgsEopArg(eopName, argCount) \
		((eopNumber_ %+ eopName) << 8) + argCount
		
%define byteArgEopArg(eopName, byteArg) \
		((eopNumber_ %+ eopName) << 8) + byteArg
