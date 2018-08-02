; =============================================================================
; Ultima Underworld II Hacks -- expanded overlay
; -----------------------------------------------------------------------------

; assuming that the expanded overlay has been moved to the end of the file
off_eop_segmentZero EQU ORIGINAL_EXE_LENGTH

%assign nextEopNumber 0
; eopProc length, procName
%macro eopProc 2
    %assign eopNumber nextEopNumber
    
    %assign eopStart nextEopStart
    %assign eopEnd eopStart + %1
    
    off_eop_%[%2]     EQU eopStart
    off_eop_%[%2]_end EQU eopEnd
    
    off_eop_%[eopNumber]     EQU eopStart
    off_eop_%[eopNumber]_end EQU eopEnd
    
    eopNumber_%[%2] EQU eopNumber
    
    %assign nextEopStart eopEnd
    %assign nextEopNumber nextEopNumber + 1
%endmacro

%assign nextEopStart off_eop_segmentZero + ORIGINAL_EOP_LENGTH

eopProc 0x100, varArgsDispatcher
eopProc 0x100, byteArgDispatcher
eopProc 0x100, byCallSiteDispatcher

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
eopProc 0x0E0, runeKey
eopProc 0x060, setInterfaceMode
eopProc 0x0C0, setMouseLookState
eopProc 0x1F0, setupPerspectiveAndEnqueueDraw
eopProc 0x020, slidePanel
eopProc 0x080, toggleMouseLook
eopProc 0x130, trainSkill
eopProc 0x090, tryKeyAndMouseBindings

%define varArgsEopArg(eopName, argCount) \
        ((eopNumber_ %+ eopName) << 8) + argCount
        
%define byteArgEopArg(eopName, byteArg) \
        ((eopNumber_ %+ eopName) << 8) + byteArg
        
%define offsetInEopSegment(label) \
        (label - $$ - startRelative) + startAbsolute - off_eop_segmentZero
